# Webhook Test Scripts

These scripts let you simulate Monnify or Paystack webhooks locally. They now **auto-create a matching payment + booking** before sending the webhook.

## Requirements
- Backend running on http://localhost:3000
- `.env` contains the correct secrets:
  - `MONNIFY_SECRET_KEY`
  - `PAYSTACK_SECRET_KEY`

## Monnify test
```powershell
cd "C:\Users\user\Downloads\I-Metro App\i_metro\backend"
node scripts\mock-monnify-webhook.js
```

Optional overrides:
```powershell
$env:MONNIFY_TEST_REFERENCE="IMT-MOCK-123"; `
$env:MONNIFY_TEST_AMOUNT=600; `
node scripts\mock-monnify-webhook.js
```

## Paystack test
```powershell
cd "C:\Users\user\Downloads\I-Metro App\i_metro\backend"
node scripts\mock-paystack-webhook.js
```

Optional overrides:
```powershell
$env:PAYSTACK_TEST_REFERENCE="IMT-PS-MOCK-123"; `
$env:PAYSTACK_TEST_AMOUNT=600; `
node scripts\mock-paystack-webhook.js
```
