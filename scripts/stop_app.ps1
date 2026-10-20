$conexiones = Get-NetTCPConnection -LocalPort 8080 -State Listen `
-ErrorAction SilentlyContinue
foreach ($c in $conexiones) {
Stop-Process -Id $c.OwningProcess -Force -ErrorAction SilentlyContinue
}
exit 0