@echo off
if not exist .venv\Scripts\python.exe (
  echo Virtual environment not found. Run: python -m venv .venv
  exit /b 1
)
call .venv\Scripts\activate
uvicorn app.main:app --reload
