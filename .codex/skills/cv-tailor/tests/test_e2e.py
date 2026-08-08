from __future__ import annotations

import hashlib
import sys
import tempfile
import unittest
from pathlib import Path


SKILL_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SKILL_ROOT / "scripts"))

from discover_master import discover_master  # noqa: E402
from score_cv import score_cv  # noqa: E402
from validate_evidence_matrix import validate_evidence_matrix  # noqa: E402
from validate_provenance import validate_provenance  # noqa: E402
from validate_requirements import canonicalize_requirements, validate_requirements  # noqa: E402
from verify_cv import verify_typst  # noqa: E402


class CodexCvTailorEndToEndTests(unittest.TestCase):
    def test_grounded_java_application_flow(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            curriculo = root / "curriculo"
            curriculo.mkdir()
            (curriculo / "index.md").write_text(
                "# Currículo\n\n**Nome:** Luiz Gustavo\n**Localização:** Brasília, DF\n"
                "**Email:** luizgust.x@gmail.com\n**Telefone:** +55 61 99999-9999\n",
                encoding="utf-8",
            )
            (curriculo / "habilidades.md").write_text(
                "# Habilidades\n\n**Backend:** Java, Quarkus, JUnit 5\n",
                encoding="utf-8",
            )
            experience_text = (
                "# Desenvolvimento backend do BBSIA\n\n"
                "**Função:** Programador backend\n"
                "**Instituição:** BBSIA\n"
                "**Período:** Atual\n\n"
                "- Desenvolvo API REST reativa com Java e Quarkus para soluções de IA no setor público.\n"
                "- Mantenho testes automatizados com JUnit 5 para recursos e serviços.\n"
            )
            experience_path = curriculo / "bbsia.md"
            experience_path.write_text(experience_text, encoding="utf-8")

            master = discover_master(curriculo)
            self.assertEqual([item["source"] for item in master["experiences"]], ["bbsia.md"])
            experience = master["experiences"][0]

            requirements = canonicalize_requirements(
                {
                    "schema_version": 1,
                    "source": {
                        "kind": "pasted",
                        "url": None,
                        "sha256": hashlib.sha256(b"vaga backend java").hexdigest(),
                        "captured_at": "2026-08-04T12:00:00-03:00",
                    },
                    "language": "pt",
                    "role": "Backend Java",
                    "seniority": {"value": "junior", "confidence": 0.9, "evidence": ["júnior"]},
                    "requirements": [
                        {
                            "id": "",
                            "priority": "must",
                            "category": "technology",
                            "text": "Experiência com Java",
                            "canonical_term": "Java",
                            "aliases": [],
                            "expected_evidence": "experience",
                            "job_evidence": "Experiência com Java",
                            "knockout": False,
                        },
                        {
                            "id": "",
                            "priority": "must",
                            "category": "technology",
                            "text": "Experiência com Quarkus",
                            "canonical_term": "Quarkus",
                            "aliases": [],
                            "expected_evidence": "experience",
                            "job_evidence": "Experiência com Quarkus",
                            "knockout": False,
                        },
                        {
                            "id": "",
                            "priority": "must",
                            "category": "responsibility",
                            "text": "Desenvolver APIs REST",
                            "canonical_term": "API REST",
                            "aliases": ["REST API"],
                            "expected_evidence": "experience",
                            "job_evidence": "Desenvolvimento de APIs REST",
                            "knockout": False,
                        },
                        {
                            "id": "",
                            "priority": "preferred",
                            "category": "technology",
                            "text": "JUnit 5",
                            "canonical_term": "JUnit 5",
                            "aliases": ["JUnit"],
                            "expected_evidence": "experience",
                            "job_evidence": "JUnit será diferencial",
                            "knockout": False,
                        },
                    ],
                }
            )
            self.assertTrue(validate_requirements(requirements)["valid"])

            template = (SKILL_ROOT / "assets" / "resume.typ").read_text(encoding="utf-8")
            replacements = {
                "REPLACE_NAME": "Luiz Gustavo",
                "REPLACE_LOCATION": "Brasília, DF",
                "REPLACE_EMAIL": "luizgust.x@gmail.com",
                "REPLACE_PHONE": "+55 61 99999-9999",
                "REPLACE_GITHUB": "ttusk",
                "REPLACE_LINKEDIN": "luizgustavosc",
                "REPLACE_SUMMARY": "Desenvolvedor backend com experiência em Java, Quarkus e APIs REST para governo digital.",
                "REPLACE_CANONICAL_TITLE": "Programador backend",
                "REPLACE_COMPANY": "BBSIA",
                "REPLACE_WORK_LOCATION": "Brasília, DF",
                "REPLACE_DATES": "Atual",
                "REPLACE_GROUNDED_BULLET": (
                    "Desenvolvo API REST reativa com *Java* e *Quarkus* para soluções de IA no setor público.\n"
                    "- Mantenho testes automatizados com *JUnit 5* para recursos e serviços."
                ),
                "REPLACE_CATEGORY": "Backend",
                "REPLACE_RELEVANT_SKILLS": "Java, Quarkus, JUnit 5 e APIs REST",
                "REPLACE_DEGREE": "Bacharelado em Sistemas de Informação",
                "REPLACE_INSTITUTION": "Universidade do Distrito Federal",
                "REPLACE_EDUCATION_LOCATION": "Brasília, DF",
                "REPLACE_EDUCATION_DATES": "Em andamento",
                "REPLACE_LANGUAGE_AND_LEVEL": "Inglês C2 e português nativo",
            }
            for placeholder, value in replacements.items():
                template = template.replace(placeholder, value)
            typ_path = root / "cv.typ"
            pdf_path = root / "cv.pdf"
            typ_path.write_text(template, encoding="utf-8")

            bullets = experience["bullets"]
            provenance = {
                "schema_version": 1,
                "bullets": [
                    {
                        "generated_text": bullets[0]["text"],
                        "sources": [
                            {
                                "path": "bbsia.md",
                                "sha256": experience["source_sha256"],
                                "line_start": bullets[0]["line_start"],
                                "line_end": bullets[0]["line_end"],
                                "excerpt": bullets[0]["text"],
                            }
                        ],
                        "claims": ["API REST", "Java", "Quarkus"],
                        "transformations": ["selected"],
                        "metrics_preserved": [],
                    },
                    {
                        "generated_text": bullets[1]["text"],
                        "sources": [
                            {
                                "path": "bbsia.md",
                                "sha256": experience["source_sha256"],
                                "line_start": bullets[1]["line_start"],
                                "line_end": bullets[1]["line_end"],
                                "excerpt": bullets[1]["text"],
                            }
                        ],
                        "claims": ["JUnit 5"],
                        "transformations": ["selected"],
                        "metrics_preserved": [],
                    },
                ],
                "work_entries": [
                    {
                        "company": "BBSIA",
                        "canonical_title": "Programador backend",
                        "dates": "Atual",
                        "sources": [
                            {
                                "path": "bbsia.md",
                                "sha256": experience["source_sha256"],
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
            provenance_report = validate_provenance(provenance, curriculo, template)
            self.assertTrue(provenance_report["valid"], provenance_report)

            verification = verify_typst(
                typ_path,
                pdf_path,
                expected_text=["Luiz Gustavo", "BBSIA", "Experiência Profissional"],
            )
            self.assertTrue(verification["valid"], verification)

            matrix = {
                "schema_version": 1,
                "requirements": [
                    {
                        "requirement_id": item["id"],
                        "status": "supported",
                        "strength": "professional_experience",
                        "source_ids": [
                            bullets[1]["source_id"]
                            if item["canonical_term"] == "JUnit 5"
                            else bullets[0]["source_id"]
                        ],
                        "notes": "Evidência profissional no BBSIA.",
                    }
                    for item in requirements["requirements"]
                ],
                "eligibility": "eligible",
                "recommendation": "apply",
            }
            matrix_report = validate_evidence_matrix(matrix, requirements, master)
            self.assertTrue(matrix_report["valid"], matrix_report)
            match = score_cv(
                requirements,
                template,
                provenance,
                verification,
                matrix,
                provenance_validation=provenance_report,
                evidence_matrix_validation=matrix_report,
            )
            self.assertEqual(match["match_score"], 100)
            self.assertEqual(match["recommendation"], "apply")


if __name__ == "__main__":
    unittest.main()
