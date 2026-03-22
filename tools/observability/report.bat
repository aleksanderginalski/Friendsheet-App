@echo off
rem Wrapper for report.py — run from project root:
rem   tools\observability\report.bat --us US-INF-010 --sp 5 [--notes "text"]
"C:\Users\user\AppData\Roaming\uv\python\cpython-3.12-windows-x86_64-none\python.exe" tools/observability/report.py %*
