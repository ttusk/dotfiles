# Leif concurso import schema

Create a JSON file with this shape:

```json
{
  "contest": {
    "id": "tce-sp-auditor-2026",
    "name": "TCE-SP Auditor 2026",
    "examPlan": {
      "examDate": "2027-03-21",
      "board": "FGV",
      "weeklyStudyHours": 20,
      "weeklyQuestionGoal": 300
    },
    "wall": {
      "noticeLinks": [{ "id": "tce-sp-auditor-2026-notice", "label": "Edital", "url": "https://example.com" }],
      "examLinks": [],
      "notes": "Any concise strategy notes."
    }
  },
  "subjects": [
    {
      "id": "tce-sp-auditor-2026-portugues",
      "name": "Português",
      "order": 0,
      "isActive": true,
      "plannedStudyMinutes": 60,
      "currentStage": "Base teórica",
      "items": [
        {
          "id": "tce-sp-auditor-2026-portugues-interpretacao-textos",
          "title": "Interpretação de textos",
          "order": 0,
          "weight": 2,
          "questionCount": 20,
          "totalPages": 0
        }
      ],
      "topics": [
        {
          "id": "tce-sp-auditor-2026-portugues-coesao",
          "name": "Coesão e coerência"
        }
      ]
    }
  ],
  "makeActive": true
}
```

All fields except `contest.id`, `contest.name`, `subjects[].id`, `subjects[].name`, `items[].id`, `items[].title`, `topics[].id`, and `topics[].name` are optional.

The importer creates:

- one Contest
- one ContestState
- Subjects with `itemIds` and `topicIds`
- StudyItems
- Topics

It does not create StudySessions.
