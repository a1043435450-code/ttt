#!/bin/bash

# Installation Script for Saqr Al-Rahba

echo "================================================"
echo "صقر الرحبة - نظام المحاسبة والمبيعات"
echo "Saqr Al-Rahba Accounting System"
echo "================================================"
echo ""

# Check Node.js
echo "[1/5] Checking Node.js..."
if ! command -v node &> /dev/null; then
    echo "✗ Node.js not found. Please install Node.js 18+"
    exit 1
fi
echo "✓ Node.js $(node --version)"

# Install root dependencies
echo ""
echo "[2/5] Installing dependencies..."
npm install

# Install backend
echo ""
echo "[3/5] Setting up backend..."
cd backend
npm install
cp .env.example .env 2>/dev/null || true
cd ..

# Install frontend
echo ""
echo "[4/5] Setting up frontend..."
cd frontend
npm install
cd ..

# Build frontend
echo ""
echo "[5/5] Building frontend..."
cd frontend
npm run build
cd ..

echo ""
echo "================================================"
echo "✓ Installation completed!"
echo "================================================"
echo ""
echo "To start the system:"
echo "  npm run dev"
echo ""
echo "Backend: http://localhost:3001"
echo "Frontend: http://localhost:3000"
echo ""
