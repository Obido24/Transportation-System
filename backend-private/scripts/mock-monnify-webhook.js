const crypto = require('crypto');
const http = require('http');
const { seedTestPayment } = require('./seed-test-payment');

const backend = process.env.BACKEND_URL || 'http://localhost:3000';
const secret = process.env.MONNIFY_SECRET_KEY || '';
const paymentReference = process.env.MONNIFY_TEST_REFERENCE || `IMT-MOCK-${Date.now()}`;
const amountPaid = Number(process.env.MONNIFY_TEST_AMOUNT || 600);
const currency = process.env.MONNIFY_TEST_CURRENCY || 'NGN';

if (!secret) {
  console.error('Missing MONNIFY_SECRET_KEY in env.');
  process.exit(1);
}

async function run() {
  const seeded = await seedTestPayment({
    provider: 'MONIEPOINT',
    reference: paymentReference,
    amount: amountPaid,
    currency,
  });

  if (!seeded.ok) {
    console.error('Seed failed:', seeded.reason || 'unknown');
    if (seeded.details) {
      console.error('Available PaymentProvider values:', seeded.details);
    }
    process.exit(1);
  }

  const payload = {
    eventType: 'SUCCESSFUL_TRANSACTION',
    eventData: {
      paymentStatus: 'PAID',
      paymentReference,
      transactionReference: paymentReference,
      amountPaid,
      totalPayable: amountPaid,
      currency,
    },
  };

  const rawBody = JSON.stringify(payload);
  const signature = crypto.createHmac('sha512', secret).update(rawBody).digest('hex');

  const url = new URL('/api/payments/monnify/webhook', backend);

  const req = http.request(
    {
      method: 'POST',
      hostname: url.hostname,
      port: url.port || 80,
      path: url.pathname,
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(rawBody),
        'monnify-signature': signature,
      },
    },
    (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        console.log('Status:', res.statusCode);
        console.log('Response:', data);
      });
    }
  );

  req.on('error', (err) => {
    console.error('Request error:', err.message);
  });

  req.write(rawBody);
  req.end();
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
