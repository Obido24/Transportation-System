# I-Metro Backend

NestJS API for the I-Metro transport platform.

## What it does
- user authentication
- bookings and tickets
- payment verification
- support messages
- validator device registration
- QR validation logs
- admin data for dashboard, routes, and settings

## Local setup
```bash
npm install
npx prisma generate
npm run start:dev
```

The API listens on `http://localhost:3000/api` by default.

## Required environment variables
Set these in your host or local `.env` file:

- `DATABASE_URL`
- `JWT_SECRET`
- `QR_SECRET`
- `VALIDATOR_KEY_SECRET`
- `ADMIN_BOOTSTRAP_SECRET`

Optional integrations:
- `MONNIFY_API_KEY`
- `MONNIFY_BASE_URL`
- `MONNIFY_CONTRACT_CODE`
- `MONNIFY_REDIRECT_URL`
- `MONNIFY_SECRET_KEY`
- `PAYSTACK_BASE_URL`
- `PAYSTACK_CALLBACK_URL`
- `PAYSTACK_CHANNELS`
- `PAYSTACK_SECRET_KEY`
- `SMTP_HOST`
- `SMTP_PORT`
- `SMTP_USER`
- `SMTP_PASS`
- `SMTP_FROM`
- `SUPPORT_EMAIL_TO`
- `FCM_SERVICE_ACCOUNT_JSON`
- `FCM_SERVICE_ACCOUNT_PATH`

## Production build
```bash
npm install
npx prisma generate
npm run build
npm run start:prod
```

## Health check
- `GET /api/health`

## Notes
- Keep secrets out of GitHub.
- Render or any other host should provide the runtime env vars.
- The backend creates runtime `data/` files automatically when needed.
