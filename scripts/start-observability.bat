@echo off
REM ##########################################################################
REM start-observability.bat
REM Start OpenTelemetry observability stack on Windows
REM ##########################################################################

echo ========================================
echo Starting OpenTelemetry Stack
echo ========================================

REM Create logs directory
if not exist "logs\otel" mkdir logs\otel

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo Error: Docker is not running
    exit /b 1
)

REM Start the observability stack
echo Starting containers...
docker-compose -f docker-compose-observability.yaml up -d

REM Wait for services to be ready
echo Waiting for services to start...
timeout /t 10 /nobreak >nul

REM Check service health
echo.
echo Checking service health...

REM Check OpenTelemetry Collector
curl -s http://localhost:13133 >nul 2>&1
if errorlevel 1 (
    echo [X] OpenTelemetry Collector is not responding
) else (
    echo [OK] OpenTelemetry Collector is running
)

REM Check Jaeger
curl -s http://localhost:16686 >nul 2>&1
if errorlevel 1 (
    echo [X] Jaeger is not responding
) else (
    echo [OK] Jaeger is running
)

REM Check Prometheus
curl -s http://localhost:9090/-/healthy >nul 2>&1
if errorlevel 1 (
    echo [X] Prometheus is not responding
) else (
    echo [OK] Prometheus is running
)

REM Check Grafana
curl -s http://localhost:3000/api/health >nul 2>&1
if errorlevel 1 (
    echo [X] Grafana is not responding
) else (
    echo [OK] Grafana is running
)

echo.
echo ========================================
echo Observability Stack Started
echo ========================================
echo.
echo Access the following UIs:
echo   - Jaeger UI:     http://localhost:16686
echo   - Prometheus UI: http://localhost:9090
echo   - Grafana UI:    http://localhost:3000 (admin/admin)
echo.
echo OpenTelemetry Collector endpoints:
echo   - OTLP gRPC:     localhost:4317
echo   - OTLP HTTP:     localhost:4318
echo   - Health Check:  http://localhost:13133
echo   - Metrics:       http://localhost:8888/metrics
echo.
echo To view logs:
echo   docker-compose -f docker-compose-observability.yaml logs -f
echo.
echo To stop:
echo   docker-compose -f docker-compose-observability.yaml down
echo.
pause
