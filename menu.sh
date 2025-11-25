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
      for i in {1..10}; do
        num=$(printf "%02d" "$i")
        title=$(grep -m 1 "Challenge:" "${ROOT_DIR}/modules/B_mock_exam/exam_${num}/task.md" | sed 's/Challenge: //')
        echo "  $i) $title"
      done
      echo
      read -rp "Select exam [1-10]: " ex
      if [[ "$ex" -ge 1 && "$ex" -le 10 ]]; then
        num=$(printf "%02d" "$ex")
        bash "${ROOT_DIR}/modules/B_mock_exam/exam_${num}/start_exam.sh"
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
