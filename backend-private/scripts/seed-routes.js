const { Client } = require('pg');
const { randomUUID } = require('crypto');
require('dotenv').config();

const routes = [
  { from: 'Nyanya', to: 'Banex', price: 600 },
  { from: 'Banex', to: 'Nyanya', price: 600 },
  { from: 'Nyanya', to: 'Berga', price: 600 },
  { from: 'Berga', to: 'Nyanya', price: 600 },
  { from: 'Area1', to: 'Nyanya', price: 600 },
  { from: 'Nyanyan', to: 'Area1', price: 600 },
];

async function run() {
  const connectionString = process.env.DATABASE_URL;
  const isLocal = /localhost|127\.0\.0\.1/i.test(connectionString || '');
  const client = new Client({
    connectionString,
    ssl: isLocal ? false : { rejectUnauthorized: false, servername: 'db.prisma.io' },
    connectionTimeoutMillis: 20000,
  });

  await client.connect();

  for (const route of routes) {
    const exists = await client.query(
      'SELECT id FROM "Route" WHERE "fromLocation" = $1 AND "toLocation" = $2 AND "price" = $3 LIMIT 1',
      [route.from, route.to, route.price],
    );

    if (exists.rows.length === 0) {
      const now = new Date().toISOString();
      await client.query(
        'INSERT INTO "Route" ("id", "fromLocation", "toLocation", "price", "currency", "isActive", "createdAt", "updatedAt") VALUES ($1,$2,$3,$4,$5,$6,$7,$8)',
        [randomUUID(), route.from, route.to, route.price, 'NGN', true, now, now],
      );
    }
  }

  await client.end();
  console.log('Routes seeded.');
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
