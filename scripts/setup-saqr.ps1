# PowerShell setup script for Saqr Al-Rahba Accounting System
# Clones the repository to Desktop and runs the install script to build and start the desktop app
# Usage: Run PowerShell as Administrator and execute this script

Set-StrictMode -Version Latest
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = 'Stop'

$repoUrl = 'https://github.com/a1043435450-code/ttt.git'
$desktop = [Environment]::GetFolderPath('Desktop')
$projectDir = Join-Path $desktop 'Saqr-Al-Rahba'

Write-Host "==========================================================="
Write-Host "Saqr Al-Rahba - Setup Script"
Write-Host "Destination: $projectDir"
Write-Host "==========================================================="

function Ensure-Command {
    param($name, $checkCmd)
    try {
        & $checkCmd > $null 2>&1
        return $true
    } catch {
        return $false
    }
}

# Check Git
if (-not (Ensure-Command -name 'git' -checkCmd { git --version })) {
    Write-Error "Git is required but not found. Please install Git and re-run this script. https://git-scm.com/download/win"
    exit 1
}

# Check Node
if (-not (Ensure-Command -name 'node' -checkCmd { node --version })) {
    Write-Error "Node.js (18+) is required but not found. Please install Node.js and re-run this script. https://nodejs.org/en/download/"
    exit 1
}

# Check npm
if (-not (Ensure-Command -name 'npm' -checkCmd { npm --version })) {
    Write-Error "npm is required but not found. Please install Node.js which includes npm."
    exit 1
}

# Clone or update repository
if (-Not (Test-Path $projectDir)) {
    Write-Host "Cloning repository..."
    git clone $repoUrl $projectDir
} else {
    Write-Host "Repository already exists at $projectDir — pulling latest changes..."
    Push-Location $projectDir
    git pull
    Pop-Location
}

# Run the included install.bat (Windows) or fallback to manual steps
Push-Location $projectDir

$installBat = Join-Path $projectDir 'scripts\install.bat'
$installSh = Join-Path $projectDir 'scripts/install.sh'

if (Test-Path $installBat) {
    Write-Host "Running scripts\install.bat..."
    & $installBat
} elseif (Test-Path $installSh) {
    Write-Host "Running scripts/install.sh via WSL or Git Bash..."
    if (Ensure-Command -name 'bash' -checkCmd { bash --version }) {
        & bash $installSh
    } else {
        Write-Warning "Bash not found. Please run scripts/install.sh manually in Git Bash or WSL."
    }
} else {
    Write-Warning "No install script found. Proceeding with manual steps..."

    Write-Host "Installing root dependencies..."
    npm install

    if (Test-Path '.\backend') {
        Write-Host "Setting up backend..."
        Push-Location .\backend
        npm install
        if (Test-Path '.env.example' -and -not (Test-Path '.env')) { Copy-Item .env.example .env }
        Pop-Location
    }

    if (Test-Path '.\frontend') {
        Write-Host "Setting up frontend..."
        Push-Location .\frontend
        npm install
        npm run build
        Pop-Location
    }

    Write-Host "Backend and frontend installed."
}

# Initialize the local SQLite database if present
$schemaFile = Join-Path $projectDir 'database\schema.sql'
$seedFile = Join-Path $projectDir 'database\seed-data.sql'
$dbFile = Join-Path $projectDir 'database.sqlite3'

if (Test-Path $schemaFile) {
    Write-Host "Initializing SQLite database: $dbFile"
    if (Test-Path $dbFile) { Remove-Item $dbFile -Force }

    # Use sqlite3 if available
    if (Ensure-Command -name 'sqlite3' -checkCmd { sqlite3 --version }) {
        & sqlite3 $dbFile ".read $schemaFile"
        if (Test-Path $seedFile) { & sqlite3 $dbFile ".read $seedFile" }
    } else {
        Write-Warning "sqlite3 command-line not found. The backend will initialize the database on first run if supported."
    }
}

# Build Electron app if electron-builder config exists
$packageJson = Join-Path $projectDir 'package.json'
$hasElectronBuilder = $false
if (Test-Path $packageJson) {
    $pkg = Get-Content $packageJson -Raw | ConvertFrom-Json
    if ($pkg.devDependencies -and $pkg.devDependencies."electron-builder") { $hasElectronBuilder = $true }
}

if ($hasElectronBuilder) {
    Write-Host "electron-builder detected. Building Windows installer (may take several minutes)..."
    npm install
    npx electron-builder --win --x64 --config.extraMetadata.name="Saqr Al-Rahba Accounting System" --publish never
    Write-Host "Electron build finished. Installer should be in the dist/ folder."
} else {
    Write-Warning "electron-builder not detected. Skipping EXE packaging step. You can build manually via your Electron build scripts."
}

# Start the desktop application (if a start script exists)
if ($pkg.scripts -and $pkg.scripts.start) {
    Write-Host "Starting application via npm start..."
    Start-Process -NoNewWindow -FilePath npm -ArgumentList 'start' -WorkingDirectory $projectDir
    Write-Host "Application started."
} elseif (Test-Path '.\backend\src\index.js') {
    Write-Host "Starting backend and frontend (manual start)..."
    Start-Process -NoNewWindow -FilePath npm -ArgumentList 'run dev' -WorkingDirectory $projectDir
} else {
    Write-Warning "No start script found. Please consult the repository README or run the backend and frontend manually."
}

Pop-Location

Write-Host ""
Write-Host "==========================================================="
Write-Host "Setup complete. The project is located at: $projectDir"
Write-Host "Run the desktop application or open the project in your IDE to continue development."
Write-Host "==========================================================="
