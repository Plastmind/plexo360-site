@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo.
echo ============================================
echo   PUBLICANDO PLEXO 360
echo ============================================
echo.

echo [1/4] Copiando versao mais recente do Desktop...
copy /Y "C:\Users\Anderson\Desktop\Plexo360 (3).html" "index.html" >nul
if errorlevel 1 (
  echo ERRO: nao encontrei "Plexo360 (3).html" no Desktop.
  pause
  exit /b 1
)

echo [2/4] Incrementando versao do cache (service-worker)...
powershell -NoProfile -Command "$sw = Get-Content 'service-worker.js' -Raw; if ($sw -match 'plexo360-v(\d+)') { $n = [int]$Matches[1] + 1; $sw = $sw -replace 'plexo360-v\d+', ('plexo360-v' + $n); Set-Content 'service-worker.js' -Value $sw -NoNewline -Encoding UTF8; Write-Host ('      cache -> plexo360-v' + $n) }"

echo [3/4] Registrando alteracoes...
git add -A
git commit -m "Atualizacao Plexo 360 - %date% %time%" >nul 2>&1
if errorlevel 1 (
  echo      Nada novo para publicar ^(sem alteracoes^).
)

echo [4/4] Enviando ao GitHub ^(Cloudflare publica sozinho^)...
git push
if errorlevel 1 (
  echo.
  echo ERRO ao enviar. Verifique sua conexao ou login do GitHub.
  pause
  exit /b 1
)

echo.
echo ============================================
echo   PUBLICADO COM SUCESSO!
echo   O Cloudflare atualiza em ~1 minuto.
echo   Link: https://plexo360.pages.dev
echo ============================================
echo.
pause
