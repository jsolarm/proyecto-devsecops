$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$python = Join-Path $root 'venv\Scripts\python.exe'
# Detener cualquier instancia previa en el puerto 5000
& "$PSScriptRoot\stop_app.ps1"
$params = @{
FilePath = $python
ArgumentList = 'app.py'
WorkingDirectory = $root
RedirectStandardOutput = "$root\app.log"
RedirectStandardError = "$root\app-error.log"
WindowStyle = 'Hidden'
}
Start-Process @params
# Esperar hasta 30 segundos a que la aplicacion responda
for ($i = 0; $i -lt 15; $i++) {
try {
Invoke-WebRequest -Uri 'http://localhost:8088/hello?name=test' `
-UseBasicParsing | Out-Null
Write-Host 'Aplicacion disponible en http://localhost:8088'
exit 0
} catch {
Start-Sleep -Seconds 2
}
}
Write-Error 'La aplicacion no respondio. Revise app-error.log'
exit 1