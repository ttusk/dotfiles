#!/usr/bin/env python3
"""Merge a mapped concurso JSON into a Leif data.json file."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def save_json(path: Path, data: dict[str, Any]) -> None:
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def ensure_data_shape(data: dict[str, Any]) -> None:
    data.setdefault("schemaVersion", 1)
    data.setdefault("activeContestId", None)
    data.setdefault("contests", [])
    data.setdefault("contestStates", [])
    data.setdefault("subjects", [])
    data.setdefault("topics", [])
    data.setdefault("studyItems", [])
    data.setdefault("studySessions", [])


def remove_existing_contest(data: dict[str, Any], contest_id: str) -> None:
    subject_ids = {s["id"] for s in data["subjects"] if s.get("contestId") == contest_id}
    item_ids = {i["id"] for i in data["studyItems"] if i.get("subjectId") in subject_ids}
    topic_ids = {t["id"] for t in data["topics"] if t.get("subjectId") in subject_ids}

    data["contests"] = [c for c in data["contests"] if c.get("id") != contest_id]
    data["contestStates"] = [s for s in data["contestStates"] if s.get("contestId") != contest_id]
    data["subjects"] = [s for s in data["subjects"] if s.get("contestId") != contest_id]
    data["studyItems"] = [i for i in data["studyItems"] if i.get("id") not in item_ids]
    data["topics"] = [t for t in data["topics"] if t.get("id") not in topic_ids]
    data["studySessions"] = [s for s in data["studySessions"] if s.get("contestId") != contest_id]


def import_concurso(data: dict[str, Any], mapped: dict[str, Any], replace: bool) -> dict[str, int]:
    ensure_data_shape(data)

    contest_in = mapped["contest"]
    contest_id = contest_in["id"]

    if any(c.get("id") == contest_id for c in data["contests"]):
      if not replace:
          raise SystemExit(f'Contest "{contest_id}" already exists. Re-run with --replace if intended.')
      remove_existing_contest(data, contest_id)

    subject_ids: list[str] = []
    added_items = 0
    added_topics = 0

    for subject_order, subject_in in enumerate(mapped.get("subjects", [])):
        subject_id = subject_in["id"]
        subject_ids.append(subject_id)
        item_ids: list[str] = []
        topic_ids: list[str] = []

        for item_order, item_in in enumerate(subject_in.get("items", [])):
            item_id = item_in["id"]
            item_ids.append(item_id)
            data["studyItems"].append({
                "id": item_id,
                "subjectId": subject_id,
                "title": item_in["title"],
                "order": item_in.get("order", item_order),
                **({"weight": item_in["weight"]} if "weight" in item_in else {}),
                **({"questionCount": item_in["questionCount"]} if "questionCount" in item_in else {}),
                **({"resourceReferences": item_in["resourceReferences"]} if "resourceReferences" in item_in else {}),
                **({"totalPages": item_in["totalPages"]} if "totalPages" in item_in else {}),
            })
            added_items += 1

        for topic_in in subject_in.get("topics", []):
            topic_id = topic_in["id"]
            topic_ids.append(topic_id)
            data["topics"].append({
                "id": topic_id,
                "subjectId": subject_id,
                "name": topic_in["name"],
                "resourceReferences": topic_in.get("resourceReferences", []),
                **({"questionNotebook": topic_in["questionNotebook"]} if "questionNotebook" in topic_in else {}),
            })
            added_topics += 1

        data["subjects"].append({
            "id": subject_id,
            "contestId": contest_id,
            "name": subject_in["name"],
            "order": subject_in.get("order", subject_order),
            "isActive": subject_in.get("isActive", True),
            "plannedStudyMinutes": subject_in.get("plannedStudyMinutes", 0),
            **({"currentStage": subject_in["currentStage"]} if "currentStage" in subject_in else {}),
            "itemIds": item_ids,
            "topicIds": topic_ids,
        })

    wall_in = contest_in.get("wall", {})
    wall = {
        "noticeLinks": wall_in.get("noticeLinks", []),
        "examLinks": wall_in.get("examLinks", []),
        "subjectSnapshots": wall_in.get("subjectSnapshots", []),
        "notes": wall_in.get("notes", ""),
    }
    data["contests"].append({
        "id": contest_id,
        "name": contest_in["name"],
        "subjectIds": subject_ids,
        "wall": wall,
        **({"examPlan": contest_in["examPlan"]} if "examPlan" in contest_in else {}),
    })
    data["contestStates"].append({
        "contestId": contest_id,
        "currentSubjectId": subject_ids[0] if subject_ids else None,
        "currentItemId": None,
    })

    if mapped.get("makeActive"):
        data["activeContestId"] = contest_id

    return {"subjects": len(subject_ids), "items": added_items, "topics": added_topics}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", required=True, type=Path)
    parser.add_argument("--import", dest="import_path", required=True, type=Path)
    parser.add_argument("--replace", action="store_true")
    args = parser.parse_args()

    data = load_json(args.data)
    mapped = load_json(args.import_path)
    counts = import_concurso(data, mapped, args.replace)
    save_json(args.data, data)
    print(
        f"Imported {mapped['contest']['name']}: "
        f"{counts['subjects']} matérias, {counts['items']} items, {counts['topics']} assuntos."
    )


if __name__ == "__main__":
    main()
