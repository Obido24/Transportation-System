# I-Metro QR Spec (Draft)

This document defines the versioned QR payload format and backend validation rules.

## 1) QR Formats

### 1.1 App QR (IMT1)
Format:

`IMT1.<payload_base64url>.<signature_base64url>`

Payload (JSON, UTF-8, then base64url encoded):

```
{
  "v": 1,
  "typ": "ticket",
  "ticketId": "uuid",
  "userId": "uuid",
  "routeId": "uuid",
  "amount": 2000,
  "currency": "NGN",
  "issuedAt": "2026-04-07T10:30:00+01:00",
  "validDate": "2026-04-07",
  "nonce": "random-16-24-chars",
  "paymentRef": "optional-ref"
}
```

Signature:
- HMAC-SHA256 of the **payload JSON bytes**
- Secret is stored on the backend only (`QR_SECRET`)

### 1.2 POS QR (POS1 - placeholder)
Format:

`POS1.<raw_string>`

Notes:
- For now, we treat the POS QR as opaque data.
- When we get the MoniePoint QR format or API, we will add a parser/validator.

## 2) Validation Rules (Backend)

### 2.1 Same-Day Validity
- Ticket is valid only on `validDate` (Africa/Lagos timezone).
- `validDate` is checked against server time in `Africa/Lagos`.
- After `23:59:59` on that date, ticket expires.

### 2.2 One-Time Use
- A ticket can only be used once.
- We store `usedAt` on the ticket (or a `ticket_uses` table).
- Validation is done in a transaction to prevent double-use.

### 2.3 Response
The backend returns:
- `valid: true/false`
- `reason`: e.g. `expired`, `already_used`, `invalid_signature`, `unknown_format`
- `ticketId`, `routeId`, `userId` when valid

## 3) Flow Summary

1. User pays → backend creates ticket
2. Backend returns IMT1 token → app shows QR
3. Validator scans QR and sends raw text → backend
4. Backend validates and returns result

