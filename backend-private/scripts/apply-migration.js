const fs = require('fs');
const path = require('path');
const { Client } = require('pg');
require('dotenv').config();

async function run() {
  const sqlPath = path.join(__dirname, '..', 'prisma', 'migrations', '000_init.sql');
  const sql = fs.readFileSync(sqlPath, 'utf8');
  const connectionString = process.env.DATABASE_URL;
  const isLocal = /localhost|127\.0\.0\.1/i.test(connectionString || '');
  const client = new Client({
    connectionString,
    ssl: isLocal ? false : { rejectUnauthorized: false, servername: 'db.prisma.io' },
    connectionTimeoutMillis: 20000,
  });

  await client.connect();
  await client.query(sql);
  await client.end();
  console.log('Migration applied.');
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
