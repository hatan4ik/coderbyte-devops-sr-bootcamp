#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_main_menu() {
  clear
  echo "======================================"
  echo "  Coderbyte DevOps Sr Bootcamp Menu"
  echo "======================================"
  echo
  echo "A) Zero-to-Hero Path"
  echo "B) Mock Exams"
  echo "C) Full DevOps Project"
  echo "D) Practice Challenges"
  echo "E) Custom Plan (per job)"
  echo "Q) Quit"
  echo
}

handle_choice() {
  local choice="$1"
  case "$choice" in
    A|a)
      clear
      echo ">>> Zero-to-Hero module"
      echo "Location: modules/A_zero_to_hero"
      echo
      ls -R "${ROOT_DIR}/modules/A_zero_to_hero"
      ;;
    B|b)
      clear
      echo ">>> Mock Exams"
      echo "Available exams:"
      echo "  1) Mock Exam #1 (Web + Docker + TF + K8s)"
      echo "  2) Mock Exam #2 (Log pipeline + S3 + CI)"
      echo
      read -rp "Select exam [1-2]: " ex
      if [[ "$ex" == "1" ]]; then
        bash "${ROOT_DIR}/modules/B_mock_exam/exam_01/start_exam.sh"
      elif [[ "$ex" == "2" ]]; then
        bash "${ROOT_DIR}/modules/B_mock_exam/exam_02/start_exam.sh"
      else
        echo "Unknown exam: $ex"
      fi
      ;;
    C|c)
      clear
      echo ">>> Full DevOps Project"
      echo "Location: modules/C_full_project"
      echo
      ls -R "${ROOT_DIR}/modules/C_full_project"
      ;;
    D|d)
      clear
      echo ">>> Practice Challenges"
      echo "Location: modules/D_practice_challenges"
      echo
      ls -R "${ROOT_DIR}/modules/D_practice_challenges"
      ;;
    E|e)
      clear
      echo ">>> Custom Plan"
      echo "Location: modules/E_custom_plan"
      echo
      ls -R "${ROOT_DIR}/modules/E_custom_plan"
      ;;
    Q|q)
      echo "Bye."
      exit 0
      ;;
    *)
      echo "Unknown choice: $choice"
      ;;
  esac

  echo
  read -rp "Press ENTER to return to main menu..." _
}

while true; do
  show_main_menu
  read -rp "Select option [A-E,Q]: " ans
  handle_choice "$ans"
done
