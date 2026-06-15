import { app, BrowserWindow, Menu, ipcMain } from 'electron';
import isDev from 'electron-is-dev';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { spawn } from 'child_process';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

let mainWindow;
let backendProcess;
let frontendProcess;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    webPreferences: {
      preload: join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true
    },
    icon: join(__dirname, '../assets/icon.png')
  });

  const startURL = isDev ? 'http://localhost:3000' : `file://${join(__dirname, '../frontend/dist/index.html')}`;
  mainWindow.loadURL(startURL);

  if (isDev) {
    mainWindow.webContents.openDevTools();
  }

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

function startBackend() {
  const backendPath = join(__dirname, '../backend');
  backendProcess = spawn('npm', ['start'], {
    cwd: backendPath,
    stdio: 'inherit'
  });
}

app.on('ready', () => {
  if (isDev) {
    startBackend();
  }
  createWindow();
});

app.on('window-all-closed', () => {
  if (backendProcess) {
    backendProcess.kill();
  }
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow();
  }
});
