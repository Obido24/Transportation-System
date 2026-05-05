# I-Metro Backend API (Draft)

Base URL: `http://localhost:3000/api`

---
## Health

### GET /health
Response:
```json
{ "ok": true, "service": "i-metro-backend" }
```

---
## Auth

### POST /auth/register
```json
{
  "email": "user@example.com",
  "phone": "08012345678",
  "password": "Password123",
  "firstName": "Rita",
  "lastName": "Dominic"
}
```

### POST /auth/login
```json
{
  "emailOrPhone": "user@example.com",
  "password": "Password123"
}
```

### POST /auth/admin/create
```json
{
  "email": "admin@example.com",
  "password": "Password123",
  "firstName": "Admin",
  "lastName": "User",
  "role": "ADMIN",
  "bootstrapSecret": "set_admin_bootstrap_secret"
}
```

---
## Routes

### GET /routes
Returns all routes.

### POST /routes (ADMIN)
```json
{
  "fromLocation": "Nyanya",
  "toLocation": "Banex",
  "price": 600,
  "currency": "NGN"
}
```

### POST /routes/seed (ADMIN)
Seeds default routes.

---
## Bookings

### POST /bookings (JWT)
```json
{
  "userId": "uuid",
  "routeId": "uuid",
  "travelDate": "2026-04-07T09:00:00+01:00"
}
```

### GET /bookings/:id (JWT)

### GET /bookings/user/:userId (JWT)

### POST /bookings/:id/issue-ticket (JWT)

---
## Payments (Monnify)

### POST /payments/monnify/initiate (JWT)
```json
{
  "userId": "uuid",
  "routeId": "uuid"
}
```

### POST /payments/monnify/webhook
Headers:
- `monnify-signature`

Body:
```json
{
  "eventType": "SUCCESSFUL_TRANSACTION",
  "eventData": { }
}
```

### POST /payments/monnify/verify
```json
{ "paymentReference": "IMT-..." }
```

---
## Validator Devices

### POST /validators/devices (ADMIN)
```json
{ "name": "Validator A" }
```

### GET /validators/devices (ADMIN)

### POST /validators/devices/rotate-key (ADMIN)
```json
{ "deviceId": "uuid" }
```

---
## Validator QR Validation

### POST /validators/validate-qr
Headers:
- `x-api-key: vk_...`

Body:
```json
{ "qr": "IMT1...." }
```

---
## Admin (JWT + ADMIN)

### GET /admin/users

### GET /admin/users/:id

### GET /admin/merchants

### GET /admin/merchants/:id

### GET /admin/bookings

### GET /admin/payments
