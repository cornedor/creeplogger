// Firebase Emulator Setup - Pure JavaScript to avoid ReScript wrapping issues
export function setupFirebaseEmulator(database) {
  if (process.env.NEXT_PUBLIC_USE_FIREBASE_EMULATOR === 'true') {
    try {
      const { connectDatabaseEmulator } = require('firebase/database');
      const host = process.env.NEXT_PUBLIC_FIREBASE_EMULATOR_HOST || 'localhost';
      const port = parseInt(process.env.NEXT_PUBLIC_FIREBASE_DATABASE_EMULATOR_PORT || '9000');
      
      console.log(`🔧 Connecting to Firebase Realtime Database Emulator at ${host}:${port}`);
      connectDatabaseEmulator(database, host, port);
      
      return true;
    } catch (error) {
      // Emulator might already be connected or not available
      console.log('Firebase emulator connection result:', error.message);
      return false;
    }
  }
  return false;
}