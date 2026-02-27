# Migration Script — Excel to Firestore

One-time script to import meetings, persons and activities from Excel to Firestore.

## Prerequisites
- Python 3.10+
- Firebase service account JSON (`serviceAccountKey.json` — never commit this file)

## Setup
```
python -m venv .venv
.venv\Scripts\activate      # Windows
pip install -r requirements.txt
```

## Usage
```
python migrate.py \
  --uid ZGO9LvtOqpQr7EJ51EZZgXLeL4u1 \
  --xlsx path/to/Migracja.xlsx \
  --key path/to/serviceAccountKey.json
```

## Idempotency
Running the script twice will not create duplicates.
Meetings are matched by date + name. Persons by full name.
