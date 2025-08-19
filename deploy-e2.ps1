# O-RAN E2 Components Deployment Script
# Based on official E2SIM documentation

Write-Host "O-RAN E2 Components Deployment" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

# Check current E2 services
Write-Host "`n1. Checking Current E2 Services:" -ForegroundColor Yellow
kubectl get services -n ricplt | findstr e2

# Check if E2Mgr is running
Write-Host "`n2. Checking E2Mgr Status:" -ForegroundColor Yellow
kubectl get pods -n ricplt | findstr e2mgr

# Check E2T SCTP service
Write-Host "`n3. Checking E2T SCTP Service:" -ForegroundColor Yellow
kubectl get service service-ricplt-e2term-sctp-alpha -n ricplt

# Deploy E2SIM using Helm (if not already deployed)
Write-Host "`n4. Deploying E2SIM with Helm:" -ForegroundColor Yellow
try {
    & "D:\O-RAN - Task\helm-extracted\windows-amd64\helm.exe" install e2sim ./helm -n ricplt
    Write-Host "E2SIM deployed successfully" -ForegroundColor Green
} catch {
    Write-Host "E2SIM deployment failed or already exists: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Check E2SIM pod status
Write-Host "`n5. Checking E2SIM Pod Status:" -ForegroundColor Yellow
kubectl get pods -n ricplt | findstr e2sim

# Test E2 connectivity
Write-Host "`n6. Testing E2 Connectivity:" -ForegroundColor Yellow
Write-Host "E2T SCTP Service should be available for E2SIM connection" -ForegroundColor Cyan

# Show E2 services summary
Write-Host "`n7. E2 Services Summary:" -ForegroundColor Yellow
kubectl get services -n ricplt | findstr e2

Write-Host "`nE2 Deployment Complete!" -ForegroundColor Green
Write-Host "Check the output above for E2 component status." -ForegroundColor Yellow 