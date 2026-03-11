#!/bin/bash

# Navigate to script directory
cd "$(dirname "$0")"

echo "==================================================="
echo "  Antigravity Phone Connect - WEB ACCESS MODE"
echo "==================================================="
echo

# 0. Aggressive Cleanup
echo "[0/2] Cleaning up orphans..."
pkill -f "node server.js" &> /dev/null
pkill -f "ngrok" &> /dev/null
# Cleanup by port (Linux/Mac)
if command -v lsof &> /dev/null; then
    # Read PORT from .env or default to 3001
    TARGET_PORT=$(grep -E '^PORT=' .env 2>/dev/null | cut -d '=' -f 2 || echo "3001")
    lsof -ti:$TARGET_PORT | xargs kill -9 &> /dev/null
fi

# 1. Ensure dependencies are installed
if [ ! -d "node_modules" ]; then
    echo "[INFO] Installing Node.js dependencies..."
    npm install
fi

# 2. Check Node.js
if ! command -v node &> /dev/null; then
    echo "[ERROR] Node.js is not installed."
    exit 1
fi

# 3. Check Python
if ! command -v python3 &> /dev/null; then
    echo "[ERROR] Python 3 is not installed."
    exit 1
fi

# 4. Check for .env file
if [ ! -f ".env" ]; then
    echo "[WARNING] .env file not found. This is required for Web Access."
    echo
    if [ -f ".env.example" ]; then
        echo "[INFO] Creating .env from .env.example..."
        cp .env.example .env
        echo "[SUCCESS] .env created from template!"
        echo "[ACTION] Please open .env and update it with your configuration (e.g., NGROK_AUTHTOKEN)."
        exit 0
    else
        echo "[ERROR] .env.example not found. Cannot create .env template."
        exit 1
    fi
fi
echo "[INFO] .env configuration found."

# 5. Launch everything via Python
echo "[1/1] Launching Antigravity Phone Connect..."
echo "(This will start both the server and the web tunnel in the background)"
nohup python3 launcher.py --mode web > /tmp/ag_phone_connect.log 2>&1 &

# 6. Auto-close when done
echo "[SUCCESS] Phone Connect is now running in the background."
exit 0
