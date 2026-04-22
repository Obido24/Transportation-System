# Transportation-System

I-Metro is a transport ticketing and validator system with:
- a Flutter passenger app
- a React admin web app
- a validator web app for gate/bus attendants
- a backend API for bookings, payments, support, and QR validation

## Project Layout
- `i_metro/app` - Flutter user app
- `i_metro/admin_app` - React + Vite admin app and validator web app
- `i_metro/backend` - API server

## Quick Start
### Backend
```powershell
cd "C:\Users\user\Downloads\I-Metro App\i_metro\backend"
npm install
npm run start:dev
```

### Admin App
```powershell
cd "C:\Users\user\Downloads\I-Metro App\i_metro\admin_app"
npm install
npm run dev -- --host 0.0.0.0
```

### User App
```powershell
cd "C:\Users\user\Downloads\I-Metro App\i_metro\app"
flutter pub get
flutter run -d chrome
```

## Validator
- Open `/validator` from the admin app.
- Use the phone camera first.
- Manual entry and image upload are available as backup options.
- Bus assignment is selected at startup and saved locally on the device.

## Notes
- Keep backend secrets and device API keys out of GitHub.
- The repo is meant for local development, testing, and release preparation.
