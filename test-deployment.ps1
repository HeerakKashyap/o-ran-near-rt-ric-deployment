# O-RAN Near-RT RIC Comprehensive Test Script
# This script tests all deployed components and xApps

Write-Host "O-RAN Near-RT RIC Comprehensive Test" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# 1. Test Kubernetes cluster
Write-Host "`n1. Testing Kubernetes Cluster:" -ForegroundColor Yellow
kubectl get nodes
kubectl cluster-info

# 2. Test all namespaces
Write-Host "`n2. Testing Namespaces:" -ForegroundColor Yellow
kubectl get namespaces | findstr ric

# 3. Test infrastructure components (ricinfra)
Write-Host "`n3. Testing Infrastructure Components (ricinfra):" -ForegroundColor Yellow
Write-Host "Pods:" -ForegroundColor Cyan
kubectl get pods -n ricinfra
Write-Host "`nServices:" -ForegroundColor Cyan
kubectl get services -n ricinfra

# 4. Test xApp components (ricxapp)
Write-Host "`n4. Testing xApp Components (ricxapp):" -ForegroundColor Yellow
Write-Host "Pods:" -ForegroundColor Cyan
kubectl get pods -n ricxapp
Write-Host "`nServices:" -ForegroundColor Cyan
kubectl get services -n ricxapp

# 5. Test platform components (ricplt)
Write-Host "`n5. Testing Platform Components (ricplt):" -ForegroundColor Yellow
Write-Host "Pods:" -ForegroundColor Cyan
kubectl get pods -n ricplt
Write-Host "`nServices:" -ForegroundColor Cyan
kubectl get services -n ricplt

# 6. Test HelloWorld xApp connectivity
Write-Host "`n6. Testing HelloWorld xApp Connectivity:" -ForegroundColor Yellow
try {
    # Start port forwarding in background
    Start-Job -ScriptBlock {
        kubectl port-forward service/helloworld-xapp-service 8080:80 -n ricxapp
    } | Out-Null
    
    Start-Sleep -Seconds 3
    
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 5
    Write-Host "SUCCESS: HelloWorld xApp is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
    Write-Host "Response Content Length: $($response.Content.Length) bytes" -ForegroundColor Green
} catch {
    Write-Host "ERROR: HelloWorld xApp test failed: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Get-Job | Stop-Job
    Get-Job | Remove-Job
}

# 7. Test Kong proxy
Write-Host "`n7. Testing Kong Proxy:" -ForegroundColor Yellow
try {
    $kongService = kubectl get service infrastructure-kong-proxy -n ricinfra -o json | ConvertFrom-Json
    Write-Host "SUCCESS: Kong proxy service found" -ForegroundColor Green
    Write-Host "External IP: $($kongService.spec.externalIPs)" -ForegroundColor Green
    Write-Host "Ports: $($kongService.spec.ports[0].port):$($kongService.spec.ports[0].targetPort)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Kong proxy test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 8. Test E2Mgr services
Write-Host "`n8. Testing E2Mgr Services:" -ForegroundColor Yellow
try {
    $e2mgrHttp = kubectl get service service-ricplt-e2mgr-http -n ricplt -o json | ConvertFrom-Json
    Write-Host "SUCCESS: E2Mgr HTTP service found on port $($e2mgrHttp.spec.ports[0].port)" -ForegroundColor Green
    
    $e2mgrRmr = kubectl get service service-ricplt-e2mgr-rmr -n ricplt -o json | ConvertFrom-Json
    Write-Host "SUCCESS: E2Mgr RMR service found on ports $($e2mgrRmr.spec.ports[0].port),$($e2mgrRmr.spec.ports[1].port)" -ForegroundColor Green
} catch {
    Write-Host "WARNING: E2Mgr services test failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

# 9. Test E2SIM container
Write-Host "`n9. Testing E2SIM Container:" -ForegroundColor Yellow
try {
    $e2simContainer = docker ps -a --filter "name=e2sim" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
    if ($e2simContainer -match "e2sim") {
        Write-Host "SUCCESS: E2SIM container found" -ForegroundColor Green
        Write-Host $e2simContainer -ForegroundColor Cyan
        
        # Test E2SIM logs
        $logs = docker logs e2sim-logging-fixed --tail 5 2>&1
        if ($logs -match "E2SIM") {
            Write-Host "SUCCESS: E2SIM logs are being generated" -ForegroundColor Green
        }
    } else {
        Write-Host "WARNING: E2SIM container not found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "ERROR: E2SIM test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 10. Overall deployment summary
Write-Host "`n10. Deployment Summary:" -ForegroundColor Yellow
$infraPods = kubectl get pods -n ricinfra --no-headers | Measure-Object | Select-Object -ExpandProperty Count
$xappPods = kubectl get pods -n ricxapp --no-headers | Measure-Object | Select-Object -ExpandProperty Count
$platformPods = kubectl get pods -n ricplt --no-headers | Measure-Object | Select-Object -ExpandProperty Count

Write-Host "Infrastructure Pods: $infraPods" -ForegroundColor Cyan
Write-Host "xApp Pods: $xappPods" -ForegroundColor Cyan
Write-Host "Platform Pods: $platformPods" -ForegroundColor Cyan

Write-Host "`nTest Complete!" -ForegroundColor Green
Write-Host "Check the output above for any errors or warnings." -ForegroundColor Yellow 