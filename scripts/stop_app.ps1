$conexiones = Get-NetTCPConnection -LocalPort 5000 -State Listen `
-ErrorAction SilentlyContinue
foreach ($c in $conexiones) {
Stop-Process -Id $c.OwningProcess -Force -ErrorAction SilentlyContinue
}
exit 0