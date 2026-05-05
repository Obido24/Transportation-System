require("dotenv").config();
const fs = require("fs");
const path = require("path");
const { Client } = require("pg");

async function main() {
  const sqlPath = path.join(
    __dirname,
    "..",
    "prisma",
    "migrations",
    "20260416_add_audit_log",
    "migration.sql",
  );

  const sql = fs.readFileSync(sqlPath, "utf8");
  const client = new Client({
    connectionString: process.env.DATABASE_URL,
  });

  await client.connect();
  try {
    await client.query(sql);
    console.log("Audit log migration applied.");
  } finally {
    await client.end();
  }
}

main().catch((error) => {
  console.error("Failed to apply audit log migration:", error);
  process.exitCode = 1;
});
