from __future__ import annotations

import json
import hashlib
import shutil
import sys
import tempfile
import unittest
from pathlib import Path


SKILL_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SKILL_ROOT / "scripts"))

from discover_master import discover_master  # noqa: E402
from preflight_master import preflight_master  # noqa: E402
from score_cv import score_cv  # noqa: E402
from self_check import self_check  # noqa: E402
from validate_evidence_matrix import validate_evidence_matrix  # noqa: E402
from validate_provenance import validate_provenance  # noqa: E402
from validate_requirements import requirement_id, validate_requirements  # noqa: E402
from verify_cv import verify_typst  # noqa: E402


class DiscoverMasterTests(unittest.TestCase):
    def test_discovers_new_experiences_without_a_fixed_filename_list(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir) / "curriculo"
            (root / "versoes").mkdir(parents=True)
            (root / "exports").mkdir()
            (root / "index.md").write_text("# Perfil\n\n**Nome:** Luiz\n", encoding="utf-8")
            (root / "habilidades.md").write_text("# Habilidades\n\nJava\n", encoding="utf-8")
            (root / "banco.md").write_text(
                "# Banco\n\n**Período:** Atual\n\n- Desenvolvi uma API.\n",
                encoding="utf-8",
            )
            (root / "bbsia-backend-java-quarkus.md").write_text(
                "---\ntags: [curriculo]\n---\n\n# BBSIA\n\n"
                "**Stack:** Java, Quarkus\n\n"
                "## Atuação\n\n- Atuo em uma API REST reativa.\n\n"
                "## Fontes públicas\n\n- [Site](https://example.com)\n\n"
                "## Relações\n\n- [[index|Currículo]]\n",
                encoding="utf-8",
            )
            (root / "versoes" / "cv-antigo.typ").write_text("ignored", encoding="utf-8")
            (root / "exports" / "nao-usar.md").write_text("ignored", encoding="utf-8")
            outside = Path(temp_dir) / "outside.md"
            outside.write_text("# Segredo\n\n- Não pode entrar.\n", encoding="utf-8")
            (root / "escape.md").symlink_to(outside)

            master = discover_master(root)

            sources = [item["source"] for item in master["experiences"]]
            self.assertEqual(sources, ["banco.md", "bbsia-backend-java-quarkus.md"])
            bbsia = master["experiences"][1]
            self.assertEqual(bbsia["title"], "BBSIA")
            self.assertEqual(bbsia["fields"]["Stack"], "Java, Quarkus")
            self.assertEqual(bbsia["bullets"][0]["source_id"], "bbsia-backend-java-quarkus.md:L11")
            self.assertEqual(bbsia["bullets"][0]["section"], "Atuação")
            self.assertEqual(len(bbsia["bullets"]), 1)

    def test_discovery_is_deterministic(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / "index.md").write_text("# Perfil\n", encoding="utf-8")
            (root / "habilidades.md").write_text("# Skills\n", encoding="utf-8")
            (root / "experiencia.md").write_text("# Experiência\n\n- Fiz algo.\n", encoding="utf-8")
            self.assertEqual(discover_master(root), discover_master(root))

    def test_live_master_currently_discovers_bbsia(self) -> None:
        root = Path("/Users/luizgustavo/git/vault/curriculo")
        if not root.is_dir():
            self.skipTest("personal Codex vault is unavailable")
        master = discover_master(root)
        sources = {item["source"] for item in master["experiences"]}
        self.assertIn("bbsia-backend-java-quarkus.md", sources)


class MasterPreflightTests(unittest.TestCase):
    def test_reports_completeness_without_inventing_missing_data(self) -> None:
        master = {
            "profile": {
                "source": "index.md",
                "text": "# Currículo\n\n**Nome:** Luiz\n**Email:** luiz@example.com\n",
            },
            "skills": {"source": "habilidades.md", "text": "# Habilidades\n\nJava, Quarkus\n"},
            "experiences": [
                {
                    "source": "bbsia.md",
                    "fields": {"Função": "Programador backend", "Projeto": "BBSIA"},
                    "bullets": [{"text": "Desenvolvo uma API REST com Java."}],
                }
            ],
        }
        report = preflight_master(master)
        self.assertTrue(report["ready_for_tailoring"])
        self.assertEqual(report["categories"]["personal_data"]["status"], "partial")
        self.assertEqual(report["categories"]["contact"]["status"], "partial")
        self.assertEqual(report["categories"]["professional_experience"]["status"], "partial")
        self.assertEqual(report["categories"]["metric_achievements"]["status"], "missing")
        self.assertIn("do not invent", report["categories"]["metric_achievements"]["issues"][0])


class ScoreCvTests(unittest.TestCase):
    def setUp(self) -> None:
        self.requirements = {
            "must_have": [
                {"id": "must-1", "term": "Java", "aliases": ["Java 25"]},
                {"id": "must-2", "term": "Quarkus", "aliases": []},
            ],
            "nice_to_have": [
                {"id": "nice-1", "term": "Kubernetes", "aliases": ["K8s"]},
            ],
            "responsibilities": [
                {"id": "resp-1", "term": "API REST", "aliases": ["REST API"]},
            ],
        }
        self.cv_text = """
== Experiência Profissional
- Desenvolvi uma API REST reativa com *Java 25* e *Quarkus*, entregue em *Kubernetes*.

== Habilidades Técnicas
- Java, Quarkus, Kubernetes.
"""
        self.provenance = {
            "bullets": [
                {
                    "generated_text": "Desenvolvi uma API REST reativa com Java 25 e Quarkus, entregue em Kubernetes.",
                    "source_id": "bbsia-backend-java-quarkus.md:L17",
                    "source_excerpt": "Atuo no desenvolvimento de uma API REST reativa em Java 25 e Quarkus com Kubernetes.",
                }
            ]
        }
        self.verification = {
            "compile_success": True,
            "page_count": 1,
            "searchable_text": True,
            "links_valid": True,
            "forbidden_constructs": [],
            "placeholders": [],
        }
        self.provenance_validation = {"valid": True, "coverage": 1.0, "errors": []}

    def test_score_is_deterministic_and_perfect_when_every_contract_is_met(self) -> None:
        first = score_cv(
            self.requirements,
            self.cv_text,
            self.provenance,
            self.verification,
            provenance_validation=self.provenance_validation,
        )
        second = score_cv(
            self.requirements,
            self.cv_text,
            self.provenance,
            self.verification,
            provenance_validation=self.provenance_validation,
        )

        self.assertEqual(first, second)
        self.assertEqual(first["match_score"], 100)
        self.assertEqual(first["decision"], "strong_match")
        self.assertEqual(first["recommendation"], "apply")
        self.assertEqual(first["gaps"], [])

    def test_invalid_provenance_cannot_receive_experience_evidence_points(self) -> None:
        result = score_cv(
            self.requirements,
            self.cv_text,
            self.provenance,
            self.verification,
            provenance_validation={"valid": False, "coverage": 0.5, "errors": [{"type": "stale_source_hash"}]},
        )
        self.assertEqual(result["components"]["experience_evidence"], 0)
        self.assertEqual(result["recommendation"], "reconsider")
        self.assertTrue(any(gap["type"] == "invalid_provenance" for gap in result["gaps"]))

    def test_keyword_only_in_skills_does_not_count_as_experience_evidence(self) -> None:
        cv_text = """
== Experiência Profissional
- Desenvolvi serviços internos e automações.

== Habilidades Técnicas
- Java, Quarkus, Kubernetes, API REST.
"""
        result = score_cv(
            self.requirements,
            cv_text,
            {"bullets": []},
            self.verification,
        )

        self.assertLess(result["match_score"], 80)
        self.assertEqual(result["decision"], "weak_match")
        self.assertTrue(any(gap["type"] == "missing_evidence" for gap in result["gaps"]))

    def test_evidence_matrix_can_mark_an_explicit_knockout_conflict(self) -> None:
        requirement = {
            "id": "req-location",
            "term": "São Paulo",
            "priority": "must",
            "category": "location",
            "expected_evidence": "profile",
            "knockout": True,
        }
        requirements = {"requirements": [requirement]}
        matrix = {
            "requirements": [
                {"requirement_id": "req-location", "status": "contradicted"},
            ]
        }
        result = score_cv(
            requirements,
            self.cv_text,
            self.provenance,
            self.verification,
            matrix,
        )
        self.assertEqual(result["eligibility"], "ineligible")
        self.assertEqual(result["recommendation"], "reconsider")

    def test_missing_knockout_requires_manual_eligibility_review(self) -> None:
        requirements = {
            "must_have": [
                {"id": "must-language", "term": "Inglês C2", "aliases": [], "knockout": True},
            ],
            "nice_to_have": [],
            "responsibilities": [],
        }
        result = score_cv(requirements, self.cv_text, self.provenance, self.verification)
        self.assertEqual(result["eligibility"], "review")
        self.assertEqual(result["decision"], "weak_match")

    def test_profile_requirement_does_not_demand_professional_bullet_evidence(self) -> None:
        requirements = {
            "requirements": [
                {
                    "id": "req-location",
                    "term": "Brasília",
                    "priority": "must",
                    "category": "location",
                    "expected_evidence": "profile",
                    "knockout": False,
                }
            ]
        }
        cv_text = self.cv_text + "\n== Contato\nBrasília, DF\n"
        result = score_cv(
            requirements,
            cv_text,
            self.provenance,
            self.verification,
            provenance_validation=self.provenance_validation,
        )
        self.assertFalse(any(gap["type"] == "missing_evidence" for gap in result["gaps"]))

    def test_responsibility_alignment_requires_source_backed_provenance(self) -> None:
        fabricated_cv = self.cv_text.replace(
            "Desenvolvi uma API REST reativa com *Java 25* e *Quarkus*, entregue em *Kubernetes*.",
            "Desenvolvi uma API REST reativa e liderei migrações sem evidência no registro mestre.",
        )
        result = score_cv(
            self.requirements,
            fabricated_cv,
            {"bullets": []},
            self.verification,
            provenance_validation={"valid": True, "coverage": 1.0, "errors": []},
        )
        self.assertEqual(result["components"]["responsibility_alignment"], 0)


class ProvenanceTests(unittest.TestCase):
    def test_accepts_current_hash_and_rejects_stale_source_or_invented_metric(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            source = root / "experiencia.md"
            source_text = "# Experiência\n\n- Desenvolvi API com Java e reduzi a latência em 20%.\n"
            source.write_text(source_text, encoding="utf-8")
            digest = hashlib.sha256(source_text.encode("utf-8")).hexdigest()
            cv_text = "== Experiência Profissional\n- Desenvolvi API com Java e reduzi a latência em 20%.\n"
            provenance = {
                "bullets": [
                    {
                        "generated_text": "Desenvolvi API com Java e reduzi a latência em 20%.",
                        "sources": [
                            {
                                "path": "experiencia.md",
                                "sha256": digest,
                                "line_start": 3,
                                "line_end": 3,
                            }
                        ],
                        "claims": ["Java", "20%"],
                        "transformations": ["compressed"],
                    }
                ]
            }

            valid = validate_provenance(provenance, root, cv_text)
            self.assertTrue(valid["valid"])
            self.assertEqual(valid["coverage"], 1.0)

            source.write_text(source_text.replace("20%", "15%"), encoding="utf-8")
            stale = validate_provenance(provenance, root, cv_text)
            self.assertFalse(stale["valid"])
            self.assertTrue(any(error["type"] == "stale_source_hash" for error in stale["errors"]))

            source.write_text(source_text, encoding="utf-8")
            provenance["bullets"][0]["generated_text"] = "Desenvolvi API com Java e reduzi a latência em 30%."
            invented = validate_provenance(
                provenance,
                root,
                "== Experiência Profissional\n- Desenvolvi API com Java e reduzi a latência em 30%.\n",
            )
            self.assertFalse(invented["valid"])
            self.assertTrue(any(error["type"] == "unsupported_metric" for error in invented["errors"]))

    def test_work_entry_fields_must_be_grounded_in_current_source_lines(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            source = root / "bbsia.md"
            source_text = (
                "# BBSIA\n\n**Função:** Programador backend\n"
                "**Instituição:** BBSIA\n**Período:** Atual\n\n- Desenvolvo uma API.\n"
            )
            source.write_text(source_text, encoding="utf-8")
            digest = hashlib.sha256(source_text.encode("utf-8")).hexdigest()
            provenance = {
                "bullets": [
                    {
                        "generated_text": "Desenvolvo uma API.",
                        "sources": [
                            {
                                "path": "bbsia.md",
                                "sha256": digest,
                                "line_start": 7,
                                "line_end": 7,
                                "excerpt": "- Desenvolvo uma API.",
                            }
                        ],
                        "claims": ["API"],
                    }
                ],
                "work_entries": [
                    {
                        "company": "BBSIA",
                        "canonical_title": "Programador backend",
                        "dates": "Atual. Início não informado",
                        "sources": [
                            {
                                "path": "bbsia.md",
                                "sha256": digest,
                                "line_start": 3,
                                "line_end": 5,
                                "excerpt": (
                                    "**Função:** Programador backend\n"
                                    "**Instituição:** BBSIA\n**Período:** Atual"
                                ),
                            }
                        ],
                        "field_claims": {
                            "company": ["BBSIA"],
                            "canonical_title": ["Programador backend"],
                            "dates": ["Atual"],
                        },
                    }
                ],
            }
            cv_text = "== Experiência Profissional\n- Desenvolvo uma API.\n"
            self.assertTrue(validate_provenance(provenance, root, cv_text)["valid"])

            provenance["work_entries"][0]["canonical_title"] = "Senior Java Engineer"
            invalid = validate_provenance(provenance, root, cv_text)
            self.assertFalse(invalid["valid"])
            self.assertTrue(any(error["type"] == "work_field_claim_mismatch" for error in invalid["errors"]))


class EvidenceMatrixTests(unittest.TestCase):
    def test_requires_exact_requirement_coverage_and_known_master_sources(self) -> None:
        requirements = {
            "requirements": [
                {"id": "req-java", "canonical_term": "Java", "aliases": [], "knockout": False},
                {"id": "req-location", "knockout": True},
            ]
        }
        master = {
            "profile": {"source": "index.md"},
            "skills": {"source": "habilidades.md"},
            "experiences": [
                {
                    "source": "bbsia.md",
                    "field_sources": {"Função": "bbsia.md:L3"},
                    "bullets": [{"source_id": "bbsia.md:L7", "text": "Desenvolvo API com Java."}],
                }
            ],
        }
        matrix = {
            "schema_version": 1,
            "requirements": [
                {
                    "requirement_id": "req-java",
                    "status": "supported",
                    "strength": "professional_experience",
                    "source_ids": ["bbsia.md:L7"],
                    "notes": "Java em experiência profissional.",
                },
                {
                    "requirement_id": "req-location",
                    "status": "unknown",
                    "strength": "profile",
                    "source_ids": ["index.md"],
                    "notes": "Regime da vaga exige revisão.",
                },
            ],
            "eligibility": "review",
            "recommendation": "apply_with_caveats",
        }
        self.assertTrue(validate_evidence_matrix(matrix, requirements, master)["valid"])

        matrix["requirements"][0]["source_ids"] = ["inventado.md:L1"]
        invalid = validate_evidence_matrix(matrix, requirements, master)
        self.assertFalse(invalid["valid"])
        self.assertTrue(any(error["type"] == "unknown_source_id" for error in invalid["errors"]))

        matrix["requirements"][0]["source_ids"] = ["bbsia.md:L3"]
        irrelevant = validate_evidence_matrix(matrix, requirements, master)
        self.assertFalse(irrelevant["valid"])
        self.assertTrue(any(error["type"] == "unsupported_source_evidence" for error in irrelevant["errors"]))

    def test_rejects_duplicate_or_missing_requirements_and_wrong_eligibility(self) -> None:
        requirements = {"requirements": [{"id": "req-knockout", "knockout": True}]}
        master = {"profile": {"source": "index.md"}, "skills": None, "experiences": []}
        matrix = {
            "schema_version": 1,
            "requirements": [
                {
                    "requirement_id": "req-knockout",
                    "status": "contradicted",
                    "strength": "profile",
                    "source_ids": ["index.md"],
                    "notes": "Conflito explícito.",
                },
                {
                    "requirement_id": "req-knockout",
                    "status": "supported",
                    "strength": "profile",
                    "source_ids": ["index.md"],
                    "notes": "Duplicado.",
                },
            ],
            "eligibility": "eligible",
            "recommendation": "apply",
        }
        report = validate_evidence_matrix(matrix, requirements, master)
        self.assertFalse(report["valid"])
        error_types = {error["type"] for error in report["errors"]}
        self.assertIn("duplicate_requirement_id", error_types)
        self.assertIn("eligibility_mismatch", error_types)


class RequirementsContractTests(unittest.TestCase):
    def test_ids_are_content_based_and_schema_is_validated(self) -> None:
        requirement = {
            "priority": "must",
            "category": "technology",
            "text": "Experiência com Java",
            "canonical_term": "Java",
            "aliases": ["Java 25"],
            "expected_evidence": "experience",
            "job_evidence": "Experiência com Java e Quarkus",
            "knockout": False,
        }
        requirement["id"] = requirement_id(requirement)
        payload = {
            "schema_version": 1,
            "source": {
                "kind": "pasted",
                "url": None,
                "sha256": "a" * 64,
                "captured_at": "2026-08-04T12:00:00-03:00",
            },
            "language": "pt",
            "role": "Backend Java",
            "seniority": {"value": "junior", "confidence": 0.9, "evidence": ["vaga júnior"]},
            "requirements": [requirement],
        }

        report = validate_requirements(payload)
        self.assertTrue(report["valid"])
        self.assertEqual(report["errors"], [])

        reordered = dict(requirement)
        reordered["aliases"] = list(reversed(requirement["aliases"]))
        self.assertEqual(requirement_id(requirement), requirement_id(reordered))

        payload["requirements"][0]["id"] = "req-wrong"
        invalid = validate_requirements(payload)
        self.assertFalse(invalid["valid"])
        self.assertTrue(any(error["type"] == "unstable_requirement_id" for error in invalid["errors"]))


@unittest.skipUnless(shutil.which("typst"), "typst is required for integration verification")
class VerifyCvTests(unittest.TestCase):
    def test_compiles_one_page_extracts_text_and_validates_links(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            typ_path = root / "sample.typ"
            pdf_path = root / "sample.pdf"
            typ_path.write_text(
                '#set page(paper: "a4")\n'
                '#set text(size: 10pt)\n'
                '= Luiz Gustavo\n'
                '#link("mailto:luizgust.x@gmail.com")[Email] | '
                '#link("https://github.com/ttusk")[GitHub] | '
                '#link("https://linkedin.com/in/luizgustavosc")[LinkedIn]\n\n'
                '== Experiência Profissional\n'
                '- Desenvolvi uma API REST reativa com Java e Quarkus para soluções de inteligência artificial no setor público.\n\n'
                '== Habilidades Técnicas\n'
                '- Java, Quarkus, REST, Kubernetes e testes automatizados.\n\n'
                '== Educação\n'
                'Bacharelado em Sistemas de Informação, em andamento.\n',
                encoding="utf-8",
            )

            report = verify_typst(typ_path, pdf_path, max_pages=1)

            self.assertTrue(report["compile_success"])
            self.assertEqual(report["page_count"], 1)
            self.assertTrue(report["searchable_text"])
            self.assertTrue(report["links_valid"])
            self.assertEqual(report["forbidden_constructs"], [])
            self.assertEqual(report["placeholders"], [])
            self.assertRegex(report["typ_sha256"], r"^[0-9a-f]{64}$")
            self.assertRegex(report["pdf_sha256"], r"^[0-9a-f]{64}$")

    def test_requires_email_github_and_linkedin_links(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            typ_path = root / "missing-email.typ"
            pdf_path = root / "missing-email.pdf"
            typ_path.write_text(
                '#set page(paper: "a4")\n'
                '= Luiz Gustavo\n'
                '#link("https://github.com/ttusk")[GitHub] | '
                '#link("https://www.linkedin.com/in/luizgustavosc")[LinkedIn]\n\n'
                '== Experiência Profissional\n'
                '- Desenvolvo aplicações backend com Java e Quarkus para serviços públicos digitais.\n\n'
                '== Habilidades Técnicas\n- Java, Quarkus, APIs REST e testes automatizados.\n',
                encoding="utf-8",
            )
            report = verify_typst(typ_path, pdf_path)
            self.assertFalse(report["links_valid"])
            self.assertEqual(report["missing_required_links"], ["email"])

    def test_rejects_username_only_link_and_more_than_one_page(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            typ_path = root / "invalid.typ"
            pdf_path = root / "invalid.pdf"
            typ_path.write_text(
                '#set page(paper: "a4")\n'
                '#link("https://ttusk")[GitHub]\n\n'
                '= Currículo com texto suficiente para extração e validação documental automatizada.\n'
                '#pagebreak()\n'
                'Segunda página com conteúdo adicional suficiente para confirmar a contagem real do PDF.\n',
                encoding="utf-8",
            )
            report = verify_typst(typ_path, pdf_path, max_pages=1)
            self.assertFalse(report["valid"])
            self.assertEqual(report["page_count"], 2)
            self.assertFalse(report["links_valid"])
            self.assertIn("https://ttusk", report["invalid_links"])
            self.assertIn("forced_pagebreak", report["forbidden_constructs"])

    def test_codex_template_compiles_after_all_placeholders_are_filled(self) -> None:
        replacements = {
            "REPLACE_NAME": "Luiz Gustavo",
            "REPLACE_LOCATION": "Brasília, DF",
            "REPLACE_EMAIL": "luizgust.x@gmail.com",
            "REPLACE_PHONE": "+55 (61) 9 8555-8737",
            "REPLACE_GITHUB": "ttusk",
            "REPLACE_LINKEDIN": "luizgustavosc",
            "REPLACE_SUMMARY": "Desenvolvedor backend com experiência em APIs para governo digital.",
            "REPLACE_CANONICAL_TITLE": "Programador backend",
            "REPLACE_COMPANY": "BBSIA",
            "REPLACE_WORK_LOCATION": "Brasília, DF",
            "REPLACE_DATES": "Atual",
            "REPLACE_GROUNDED_BULLET": "Desenvolvo API REST reativa com *Java* e *Quarkus* para soluções de IA no setor público.",
            "REPLACE_CATEGORY": "Backend",
            "REPLACE_RELEVANT_SKILLS": "Java, Quarkus, JAX-RS e testes automatizados",
            "REPLACE_DEGREE": "Bacharelado em Sistemas de Informação",
            "REPLACE_INSTITUTION": "Universidade do Distrito Federal",
            "REPLACE_EDUCATION_LOCATION": "Brasília, DF",
            "REPLACE_EDUCATION_DATES": "Em andamento",
            "REPLACE_LANGUAGE_AND_LEVEL": "Inglês C2 e português nativo",
        }
        source = (SKILL_ROOT / "assets" / "resume.typ").read_text(encoding="utf-8")
        for placeholder, value in replacements.items():
            source = source.replace(placeholder, value)

        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            typ_path = root / "template-filled.typ"
            pdf_path = root / "template-filled.pdf"
            typ_path.write_text(source, encoding="utf-8")
            report = verify_typst(
                typ_path,
                pdf_path,
                expected_text=["Luiz Gustavo", "Experiência Profissional", "BBSIA"],
            )
            self.assertTrue(report["valid"], report)
            self.assertEqual(report["page_count"], 1)
            self.assertEqual(report["placeholders"], [])


class SkillContractTests(unittest.TestCase):
    def test_documentation_exposes_the_full_reliable_workflow(self) -> None:
        skill = (SKILL_ROOT / "SKILL.md").read_text(encoding="utf-8")
        self.assertIn("discover_master.py", skill)
        self.assertIn("requirements.json", skill)
        self.assertIn("provenance.json", skill)
        self.assertIn("score_cv.py", skill)
        self.assertIn("verify_cv.py", skill)
        self.assertIn("curriculo/versoes", skill)
        self.assertIn("curriculo/exports", skill)
        self.assertIn("Match Score", skill)
        self.assertIn("Codex-only", skill)

    def test_dependency_free_skill_self_check_passes(self) -> None:
        report = self_check(SKILL_ROOT)
        self.assertTrue(report["valid"], report)
        self.assertEqual(report["errors"], [])


if __name__ == "__main__":
    unittest.main()
