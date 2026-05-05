const { Client } = require('pg');
const { randomUUID } = require('crypto');
require('dotenv').config();

async function seedTestPayment({ provider, reference, amount, currency }) {
  const connectionString = process.env.DATABASE_URL;
  const isLocal = /localhost|127\.0\.0\.1/i.test(connectionString || '');
  const client = new Client({
    connectionString,
    ssl: isLocal ? false : { rejectUnauthorized: false, servername: 'db.prisma.io' },
    connectionTimeoutMillis: 20000,
  });

  await client.connect();

  const enumResult = await client.query('SELECT unnest(enum_range(NULL::"PaymentProvider")) AS value');
  const enumValues = enumResult.rows.map((row) => row.value);
  let providerValue = provider;
  const aliases = {
    MONNIFY: 'MONIEPOINT',
  };

  if (aliases[providerValue]) {
    providerValue = aliases[providerValue];
  }
  if (!enumValues.includes(providerValue)) {
    const match = enumValues.find((value) => value.toLowerCase() === providerValue.toLowerCase());
    if (match) {
      providerValue = match;
    } else {
      const contains = enumValues.find((value) => value.toLowerCase().includes(providerValue.toLowerCase()));
      if (contains) {
        providerValue = contains;
      } else {
        const shortHint = providerValue.toLowerCase().startsWith('monn') ? 'monn' : 'pay';
        const fuzzy = enumValues.find((value) => value.toLowerCase().includes(shortHint));
        if (fuzzy) {
          providerValue = fuzzy;
        } else {
          await client.end();
          return { ok: false, reason: 'invalid_provider_enum', details: enumValues };
        }
      }
    }
  }

  const existing = await client.query(
    'SELECT id, "bookingId" FROM "Payment" WHERE "provider" = $1 AND "providerRef" = $2 LIMIT 1',
    [providerValue, reference],
  );

  if (existing.rows.length > 0) {
    await client.end();
    return { ok: true, bookingId: existing.rows[0].bookingId };
  }

  let userId;
  const userResult = await client.query(
    'SELECT id FROM "User" WHERE email = $1 LIMIT 1',
    ['test@i-metro.local'],
  );

  if (userResult.rows.length > 0) {
    userId = userResult.rows[0].id;
  } else {
    userId = randomUUID();
    const now = new Date().toISOString();
    await client.query(
      'INSERT INTO "User" ("id", "email", "phone", "passwordHash", "role", "firstName", "lastName", "isActive", "createdAt", "updatedAt") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)',
      [userId, 'test@i-metro.local', null, null, 'USER', 'Test', 'User', true, now, now],
    );
  }

  const routeResult = await client.query('SELECT id, "price", "currency" FROM "Route" ORDER BY "createdAt" ASC LIMIT 1');
  if (routeResult.rows.length === 0) {
    await client.end();
    return { ok: false, reason: 'no_routes_seeded' };
  }
  const route = routeResult.rows[0];

  const bookingId = randomUUID();
  const paymentId = randomUUID();
  const now = new Date().toISOString();

  await client.query(
    'INSERT INTO "Booking" ("id", "userId", "routeId", "status", "travelDate", "createdAt", "updatedAt") VALUES ($1,$2,$3,$4,$5,$6,$7)',
    [bookingId, userId, route.id, 'PENDING', null, now, now],
  );

  await client.query(
    'INSERT INTO "Payment" ("id", "bookingId", "amount", "currency", "provider", "providerRef", "status", "paidAt", "createdAt", "updatedAt") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)',
    [paymentId, bookingId, amount || route.price, currency || route.currency || 'NGN', providerValue, reference, 'PENDING', null, now, now],
  );

  await client.end();
  return { ok: true, bookingId };
}

module.exports = { seedTestPayment };
