# I-Metro Admin App

React + Vite admin dashboard for the I-Metro operations team.

## What it does
- Manage routes, users, merchants, bookings, and revenue
- Review support complaints and update their status
- View validator activity and bus scan logs
- Open the phone-friendly validator screen at `/validator`

## Requirements
- Node.js 18+
- npm
- A running I-Metro backend

## Run locally
1. Install dependencies:
   ```powershell
   cd "C:\Users\user\Downloads\I-Metro App\i_metro\admin_app"
   npm install
   ```
2. Start the dev server:
   ```powershell
   npm run dev -- --host 0.0.0.0
   ```

## Useful routes
- `/admin/login`
- `/admin/dashboard`
- `/admin/support`
- `/admin/validator-logs`
- `/validator`

## Notes
- The admin app talks to the shared backend API.
- The validator page is now the primary phone-based fallback for live QR scans.
- Bus assignment is saved locally on the validator device/browser.
