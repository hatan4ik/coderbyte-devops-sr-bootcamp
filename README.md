# Coderbyte DevOps Sr Bootcamp

This repository is a complete training and practice environment to prepare for
Sr. DevOps Coderbyte-style assignments.

It is organized into 5 main modules:

- `modules/A_zero_to_hero/` – step-by-step learning path (CLI & Linux oriented)
- `modules/B_mock_exam/` – timed mock Coderbyte exams
- `modules/C_full_project/` – complete DevOps project from app → Docker → Terraform → K8s
- `modules/D_practice_challenges/` – standalone tasks similar to real Coderbyte questions
- `modules/E_custom_plan/` – customize the training for a specific job description

Use the interactive menu to navigate:

```bash
./menu.sh
```

## Requirements

- Linux (preferred) or WSL
- Python 3.10+
- Docker
- Git
- (Optional) Terraform, kubectl, kind, make

Install Python deps:

```bash
pip install -r requirements.txt
```

Run tests:

```bash
make test
```

Run interactive menu:

```bash
./menu.sh
```
