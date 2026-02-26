#!/bin/bash
# Vidya Soudha - ML Backend Startup Script
# Starts the FastAPI server for enrolment forecasting and demand validation
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/school-infra-backend"

echo "======================================"
echo "  Vidya Soudha - ML Backend Server"
echo "======================================"
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "Error: python3 not found. Please install Python 3.8+"
    exit 1
fi

# Create venv if needed
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate venv
source venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt -q

echo ""
echo "Starting server on http://0.0.0.0:8000"
echo "API docs:  http://localhost:8000/docs"
echo "Health:    http://localhost:8000/health"
echo ""

uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
