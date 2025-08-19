# O-RAN Near-RT RIC Comprehensive Status Check
# This script checks all components including E2 functionality

Write-Host "O-RAN Near-RT RIC Comprehensive Status Check" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# 1. Check Kubernetes cluster
Write-Host "`n1. Kubernetes Cluster Status:" -ForegroundColor Yellow
kubectl get nodes
kubectl cluster-info

# 2. Check all namespaces
Write-Host "`n2. Namespaces Status:" -ForegroundColor Yellow
kubectl get namespaces | findstr ric

# 3. Check infrastructure components (ricinfra)
Write-Host "`n3. Infrastructure Components (ricinfra):" -ForegroundColor Yellow
Write-Host "Pods:" -ForegroundColor Cyan
kubectl get pods -n ricinfra
Write-Host "`nServices:" -ForegroundColor Cyan
kubectl get services -n ricinfra

# 4. Check xApp components (ricxapp)
Write-Host "`n4. xApp Components (ricxapp):" -ForegroundColor Yellow
Write-Host "Pods:" -ForegroundColor Cyan
kubectl get pods -n ricxapp
Write-Host "`nServices:" -ForegroundColor Cyan
kubectl get services -n ricxapp

# 5. Check E2 components specifically
Write-Host "`n5. E2 Components Check:" -ForegroundColor Yellow
Write-Host "E2Mgr pods:" -ForegroundColor Cyan
kubectl get pods -n ricinfra | findstr e2mgr
Write-Host "`nE2Mgr services:" -ForegroundColor Cyan
kubectl get services -n ricinfra | findstr e2mgr

# 6. Check Helm releases
Write-Host "`n6. Helm Releases:" -ForegroundColor Yellow
& "D:\O-RAN - Task\helm-extracted\windows-amd64\helm.exe" list -A

# 7. Test HelloWorld xApp connectivity
Write-Host "`n7. HelloWorld xApp Connectivity Test:" -ForegroundColor Yellow
try {
    Start-Job -ScriptBlock {
        kubectl port-forward service/service-ricxapp-helloworld-rmr 8080:80 -n ricxapp
    } | Out-Null
    
    Start-Sleep -Seconds 3
    
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 5
    Write-Host "SUCCESS: HelloWorld xApp is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "ERROR: HelloWorld xApp test failed: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Get-Job | Stop-Job
    Get-Job | Remove-Job
}

# 8. Check for any errors in pods
Write-Host "`n8. Pod Error Check:" -ForegroundColor Yellow
$pods = kubectl get pods -n ricinfra -o json | ConvertFrom-Json
$pods.items | ForEach-Object {
    if ($_.status.phase -ne "Running") {
        Write-Host "WARNING: Pod $($_.metadata.name) is in $($_.status.phase) state" -ForegroundColor Red
    }
}

# 9. Check Kong proxy (if available)
Write-Host "`n9. Kong Proxy Check:" -ForegroundColor Yellow
try {
    $kongService = kubectl get service infrastructure-kong-proxy -n ricinfra -o json | ConvertFrom-Json
    Write-Host "Kong proxy service found: $($kongService.spec.ports[0].port)" -ForegroundColor Green
} catch {
    Write-Host "Kong proxy service not found or not accessible" -ForegroundColor Yellow
}

Write-Host "`nStatus Check Complete!" -ForegroundColor Green
Write-Host "Check the output above for any errors or warnings." -ForegroundColor Yellow
