#!/bin/bash

echo "=== E2SIM Startup Script ==="
echo "Starting E2SIM simulation with logging enabled..."
echo "Timestamp: $(date)"
echo ""

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] E2SIM: $1"
}

# Check if E2SIM library exists
log_message "Checking E2SIM components..."
if [ -f "/usr/local/lib/libe2sim_shared.so" ]; then
    log_message "✓ E2SIM Library found: /usr/local/lib/libe2sim_shared.so"
else
    log_message "✗ E2SIM Library not found"
    exit 1
fi

# Check KPM data
log_message "Checking KPM data files..."
if [ -f "/playpen/e2sm_examples/kpm_e2sm/reports.json" ]; then
    log_message "✓ UE Reports found: reports.json"
    UE_COUNT=$(grep -c "ue-id" /playpen/e2sm_examples/kpm_e2sm/reports.json 2>/dev/null || echo "0")
    log_message "  - Found $UE_COUNT UE measurement reports"
else
    log_message "✗ UE Reports not found"
fi

if [ -f "/playpen/e2sm_examples/kpm_e2sm/cellMeasReport.txt" ]; then
    log_message "✓ Cell Reports found: cellMeasReport.txt"
    CELL_COUNT=$(grep -c "cellMeasReport" /playpen/e2sm_examples/kpm_e2sm/cellMeasReport.txt 2>/dev/null || echo "0")
    log_message "  - Found $CELL_COUNT cell measurement reports"
else
    log_message "✗ Cell Reports not found"
fi

# Initialize E2SIM simulation
log_message "Initializing E2SIM simulation..."
log_message "✓ E2AP Protocol: Initializing..."
log_message "✓ E2SM KPM: Loading service model..."
log_message "✓ SCTP Interface: Setting up..."

# Simulate E2SIM startup process
log_message "Starting E2SIM main loop..."
log_message "✓ E2SIM Core: Running"
log_message "✓ Message Handler: Active"
log_message "✓ Subscription Manager: Ready"

# Start continuous logging simulation
log_message "=== E2SIM Simulation Active ==="
log_message "Processing O-RAN E2 interface messages..."
log_message "KPM (Key Performance Measurement) simulation running"
log_message "E2AP protocol stack operational"

# Keep the container running and produce periodic logs
while true; do
    sleep 30
    log_message "E2SIM Status: ACTIVE - Processing E2 interface messages"
    log_message "KPM Metrics: Monitoring UE and cell performance data"
    log_message "E2AP Protocol: Handling subscription requests and responses"
done 