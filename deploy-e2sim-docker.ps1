# E2SIM Docker Deployment Script
# Based on official E2SIM documentation

Write-Host "E2SIM Docker Deployment" -ForegroundColor Green

# Check if Docker is running
Write-Host "`n1. Checking Docker Status:" -ForegroundColor Yellow
docker --version
docker ps

# Check if e2simul image exists
Write-Host "`n2. Checking E2SIM Docker Image:" -ForegroundColor Yellow
docker images | findstr e2simul

# If image doesn't exist, provide build instructions
Write-Host "`n3. E2SIM Image Build Instructions:" -ForegroundColor Yellow
Write-Host "If e2simul image is not found, you need to:" -ForegroundColor Cyan
Write-Host "1. Clone the e2-interface repository" -ForegroundColor Cyan
Write-Host "2. Build the e2sim from source" -ForegroundColor Cyan
Write-Host "3. Build the Docker image with: docker build -t e2simul:0.0.2 ." -ForegroundColor Cyan

# Get E2T SCTP service IP for connection
Write-Host "`n4. Getting E2T SCTP Service IP:" -ForegroundColor Yellow
try {
    $e2tService = kubectl get service service-ricplt-e2term-sctp-alpha -n ricplt -o json | ConvertFrom-Json
    $e2tIP = $e2tService.spec.clusterIP
    $e2tPort = $e2tService.spec.ports[0].port
    Write-Host "E2T SCTP Service: $e2tIP`:$e2tPort" -ForegroundColor Green
} catch {
    Write-Host "E2T SCTP service not found" -ForegroundColor Red
}

# Run E2SIM container (if image exists)
Write-Host "`n5. Running E2SIM Container:" -ForegroundColor Yellow
try {
    docker run -d --name e2sim-container e2simul:0.0.2
    Write-Host "E2SIM container started successfully" -ForegroundColor Green
} catch {
    Write-Host "E2SIM container failed to start or image not found" -ForegroundColor Yellow
}

# Check container status
Write-Host "`n6. Container Status:" -ForegroundColor Yellow
docker ps | findstr e2sim

# Show container logs
Write-Host "`n7. E2SIM Container Logs:" -ForegroundColor Yellow
docker logs e2sim-container --tail 10

Write-Host "`nE2SIM Docker Deployment Complete!" -ForegroundColor Green
Write-Host "Check container logs for E2 connection status." -ForegroundColor Yellow 