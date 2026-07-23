@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo.
echo ============================================
echo   PUBLICANDO PLEXO 360
echo ============================================
echo.

echo [1/5] Copiando versao mais recente do Desktop...
copy /Y "C:\Users\Anderson\Desktop\Plexo360 (3).html" "index.html" >nul
if errorlevel 1 (
  echo ERRO: nao encontrei "Plexo360 (3).html" no Desktop.
  pause
  exit /b 1
)

echo [2/5] Incrementando versao (apenas service-worker; rotulo vem em runtime)...
rem IMPORTANTE: NAO reescrever index.html aqui. Faze-lo via Get-Content/Set-Content no
rem PowerShell 5.1 corrompe o UTF-8 (mojibake nos acentos) e quebra o app. O rotulo da
rem versao ja e lido em runtime a partir do service-worker.js, entao basta bumpar o SW.
powershell -NoProfile -Command "$p='service-worker.js'; $sw=[System.IO.File]::ReadAllText($p); if($sw -match 'plexo360-v(\d+)'){ $n=[int]$Matches[1]+1; $sw=$sw -replace 'plexo360-v\d+',('plexo360-v'+$n); $enc=New-Object System.Text.UTF8Encoding($false); [System.IO.File]::WriteAllText((Resolve-Path $p),$sw,$enc); Write-Host ('      versao -> v'+$n) }"

echo [3/5] Publicando no Cloudflare (site no ar)...
call npx wrangler pages deploy . --project-name=plexo360 --branch=main --commit-dirty=true
if errorlevel 1 (
  echo.
  echo ERRO ao publicar no Cloudflare. Verifique sua conexao.
  echo Se pedir login, rode: npx wrangler login
  pause
  exit /b 1
)

echo [4/5] Salvando backup/historico no GitHub...
git add -A
git commit -m "Atualizacao Plexo 360 - %date% %time%" >nul 2>&1
if errorlevel 1 (
  echo      Nada novo no historico ^(sem alteracoes^).
)

echo [5/5] Enviando ao GitHub...
git push >nul 2>&1
if errorlevel 1 (
  echo      Aviso: nao consegui enviar ao GitHub ^(o site ja esta no ar^).
)

echo.
echo ============================================
echo   PUBLICADO COM SUCESSO!
echo   O site ja esta no ar.
echo   Link: https://plexo360.pages.dev
echo ============================================
echo.
pause
