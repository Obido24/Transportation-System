# I-Metro User App

Flutter customer app for I-Metro passengers.

## What it does
- Sign in and create bookings
- Pay for trips through the backend payment flow
- Show ticket details and QR codes
- Send support complaints and track their status
- Show ride history and passenger profile features

## Requirements
- Flutter SDK
- A running I-Metro backend
- Chrome, Android, or iOS for testing

## Run locally
1. Start the backend:
   ```powershell
   cd "C:\Users\user\Downloads\I-Metro App\i_metro\backend"
   npm run start:dev
   ```
2. Start the user app:
   ```powershell
   cd "C:\Users\user\Downloads\I-Metro App\i_metro\app"
   flutter pub get
   flutter run -d chrome
   ```

## Notes
- The app talks to the shared backend API.
- Support requests now show a delivery notice and live status updates.
- Ticket QR codes are generated from the backend booking/payment flow.
