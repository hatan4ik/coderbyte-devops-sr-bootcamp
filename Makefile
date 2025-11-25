.PHONY: help test lint exam menu

help:
	@echo "Targets:"
	@echo "  make test      - run all tests"
	@echo "  make lint      - basic lint (python -m py_compile)"
	@echo "  make exam      - run mock exam #1 (interactive)"
	@echo "  make menu      - run interactive menu"

test:
	@echo "Running tests..."
	@find modules -name 'tests.py' -print -exec python {} \;

lint:
	@echo "Linting Python files..."
	@python -m py_compile `find . -name '*.py'`

exam:
	@bash modules/B_mock_exam/exam_01/start_exam.sh

menu:
	@bash ./menu.sh
