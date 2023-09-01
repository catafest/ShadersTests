@echo off
setlocal

:: Solicitarea numelui repo-ului de la utilizator
set /p repo_name=Introduceți numele repo-ului: 

:: Solicitarea token-ului de acces personal de la utilizator
set /p github_token=Introduceți token-ul de acces personal GitHub: 

:: Inițializarea unui repo local
git init

:: Adăugarea tuturor fișierelor
git add .

:: Crearea fișierului README.md cu textul specificat
echo You can follow on web with nicknames: catafest and mythcat > README.md

:: Primul commit
git commit -m "Primul commit"

:: Crearea repo-ului pe GitHub
:: Asigurați-vă că utilizați token-ul introdus de utilizator pentru autentificare.
curl -u "catafest:%github_token%" https://api.github.com/user/repos -d "{\"name\":\"%repo_name%\"}"

:: Adăugarea repo-ului remote și push-ul inițial către ramura "main"
git remote add origin https://github.com/catafest/%repo_name%.git
git branch -M main
git push -u origin main

:: Finalizarea
echo Repo-ul a fost creat pe GitHub cu numele "%repo_name%", primul commit a fost efectuat pe ramura "main", și a fost adăugat fișierul README.md.
pause
