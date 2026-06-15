import { contextBridge } from 'electron';

contextBridge.exposeInMainWorld('electronAPI', {
  getVersion: () => '0.1.0'
});
