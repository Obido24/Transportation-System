import { Injectable } from '@nestjs/common';
import { createHmac, randomBytes } from 'crypto';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { MonnifyWebhookDto } from './dto/monnify-webhook.dto';

const MONNIFY_PROVIDER = 'MONIEPOINT';

@Injectable()
export class PaymentsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService,
  ) {}

  async handleMonnifyWebhook(payload: MonnifyWebhookDto, signature?: string, rawBody = '') {
    if (!signature) {
      return { received: false, reason: 'missing_signature' };
    }

    if (!rawBody) {
      return { received: false, reason: 'missing_raw_body' };
    }

    if (!this.verifyMonnifySignature(rawBody, signature)) {
      return { received: false, reason: 'invalid_signature' };
    }

    const eventType = payload?.eventType;
    if (eventType !== 'SUCCESSFUL_TRANSACTION') {
      return { received: true, ignored: true };
    }

    const eventData = payload?.eventData ?? {};
    if (eventData?.paymentStatus && eventData.paymentStatus !== 'PAID') {
      return { received: true, ignored: true };
    }

    const paymentReference = eventData?.paymentReference ?? eventData?.transactionReference;
    const amountPaid = Number(eventData?.amountPaid ?? eventData?.totalPayable ?? 0);
    const currency = eventData?.currency ?? 'NGN';

    if (!paymentReference) {
      return { received: false, reason: 'missing_payment_reference' };
    }

    const payment = await this.prisma.payment.findFirst({
      where: {
        provider: MONNIFY_PROVIDER,
        providerRef: paymentReference,
      },
      include: {
        booking: true,
      },
    });

    if (!payment) {
      return { received: false, reason: 'payment_not_found' };
    }

    const ticket = await this.prisma.$transaction(async (tx) => {
      const updated = await tx.payment.update({
        where: { id: payment.id },
        data: {
          status: 'SUCCESS',
          paidAt: new Date(),
          amount: amountPaid || payment.amount,
          currency,
        },
      });

      const booking = await tx.booking.findUnique({
        where: { id: updated.bookingId },
      });

      if (!booking) {
        return null;
      }

      await tx.booking.update({
        where: { id: booking.id },
        data: { status: 'CONFIRMED' },
      });

      const existingTicket = await tx.ticket.findFirst({
        where: { bookingId: booking.id },
      });
      if (existingTicket) {
        return existingTicket;
      }

      return tx.ticket.create({
        data: {
          bookingId: booking.id,
          userId: booking.userId,
          routeId: booking.routeId,
          amount: updated.amount,
          currency: updated.currency,
          validDate: new Date(),
          nonce: randomBytes(8).toString('hex'),
        },
      });
    });

    if (!ticket) {
      return { received: false, reason: 'booking_not_found' };
    }

    await this.notificationsService.sendToUser(payment.booking?.userId ?? ticket.userId, {
      title: 'Ticket ready',
      body: 'Your payment was confirmed. Open I-Metro to view your ticket QR.',
      data: {
        type: 'ticket_ready',
        bookingId: payment.bookingId,
        ticketId: ticket.id,
        paymentReference: payment.providerRef ?? paymentReference,
        silent: '1',
      },
    });

    const validDate = ticket.validDate.toISOString().slice(0, 10);
    const dateCompact = validDate.replace(/-/g, '');
    const unsigned = `t=${ticket.id}|e=${dateCompact}|n=${ticket.nonce}`;
    const secret = process.env.QR_SECRET ?? 'dev_qr_secret';
    const signatureQr = createHmac('sha256', secret).update(unsigned).digest('base64url');
    const qr = `IMT1|${unsigned}|s=${signatureQr}`;

    return {
      received: true,
      paymentReference,
      ticketId: ticket.id,
      qr,
    };
  }

  async verifyMonnifyPayment(paymentReference: string) {
    if (!paymentReference) {
      return { ok: false, reason: 'missing_reference' };
    }

    const tokenResult = await this.getMonnifyAccessToken();
    if (!tokenResult.ok) {
      return tokenResult;
    }

    const baseUrl = process.env.MONNIFY_BASE_URL ?? 'https://api.monnify.com';
    const response = await fetch(
      `${baseUrl}/api/v2/merchant/transactions/query?paymentReference=${encodeURIComponent(paymentReference)}`,
      {
        method: 'GET',
        headers: {
          Authorization: `Bearer ${tokenResult.token}`,
          'Content-Type': 'application/json',
        },
      },
    );

    const data = await response.json();
    if (!data?.requestSuccessful) {
      return { ok: false, reason: 'verify_failed', details: data };
    }

    const status = String(data?.responseBody?.paymentStatus ?? data?.responseBody?.transactionStatus ?? '').toUpperCase();
    const amountPaid = Number(data?.responseBody?.amountPaid ?? data?.responseBody?.totalPayable ?? 0);
    const currency = data?.responseBody?.currency ?? 'NGN';

    const payment = await this.prisma.payment.findFirst({
      where: {
        provider: MONNIFY_PROVIDER,
        providerRef: paymentReference,
      },
      include: {
        booking: {
          include: {
            ticket: true,
            route: true,
          },
        },
      },
    });

    if (!payment) {
      return { ok: false, reason: 'payment_not_found' };
    }

    if (status === 'PAID' || status === 'SUCCESS') {
      const ticket = await this.completePaymentAndIssueTicket(payment.id, amountPaid || payment.amount, currency);
      if (ticket) {
        await this.notificationsService.sendToUser(payment.booking?.userId ?? ticket.userId, {
          title: 'Ticket ready',
          body: 'Your payment was confirmed. Open I-Metro to view your ticket QR.',
          data: {
            type: 'ticket_ready',
            bookingId: payment.bookingId,
            ticketId: ticket.id,
            paymentReference: payment.providerRef ?? paymentReference,
            silent: '1',
          },
        });
      }

      return {
        ok: true,
        status: 'SUCCESS',
        paymentReference,
        bookingId: payment.bookingId,
        ticketId: ticket?.id ?? payment.booking?.ticket?.id ?? null,
        ticket: ticket ?? payment.booking?.ticket ?? null,
      };
    }

    return {
      ok: false,
      status: status || payment.status,
      paymentReference,
      bookingId: payment.bookingId,
      ticketId: payment.booking?.ticket?.id ?? null,
      ticket: payment.booking?.ticket ?? null,
    };
  }

  async handlePaystackWebhook(payload: any, signature?: string, rawBody = '') {
    if (!signature) {
      return { received: false, reason: 'missing_signature' };
    }

    if (!rawBody) {
      return { received: false, reason: 'missing_raw_body' };
    }

    if (!this.verifyPaystackSignature(rawBody, signature)) {
      return { received: false, reason: 'invalid_signature' };
    }

    const eventType = payload?.event;
    if (eventType !== 'charge.success') {
      return { received: true, ignored: true };
    }

    const data = payload?.data ?? {};
    const paymentReference = data?.reference;
    if (!paymentReference) {
      return { received: false, reason: 'missing_reference' };
    }

    const amountPaid = Number(data?.amount ?? 0) / 100;
    const currency = data?.currency ?? 'NGN';

    const payment = await this.prisma.payment.findFirst({
      where: {
        provider: 'PAYSTACK',
        providerRef: paymentReference,
      },
      include: {
        booking: true,
      },
    });

    if (!payment) {
      return { received: false, reason: 'payment_not_found' };
    }

    const ticket = await this.completePaymentAndIssueTicket(payment.id, amountPaid || payment.amount, currency);
    if (!ticket) {
      return { received: false, reason: 'booking_not_found' };
    }

    await this.notificationsService.sendToUser(payment.booking?.userId ?? ticket.userId, {
      title: 'Ticket ready',
      body: 'Your payment was confirmed. Open I-Metro to view your ticket QR.',
      data: {
        type: 'ticket_ready',
        bookingId: payment.bookingId,
        ticketId: ticket.id,
        paymentReference: payment.providerRef ?? paymentReference,
        silent: '1',
      },
    });

    const validDate = ticket.validDate.toISOString().slice(0, 10);
    const dateCompact = validDate.replace(/-/g, '');
    const unsigned = `t=${ticket.id}|e=${dateCompact}|n=${ticket.nonce}`;
    const secret = process.env.QR_SECRET ?? 'dev_qr_secret';
    const signatureQr = createHmac('sha256', secret).update(unsigned).digest('base64url');
    const qr = `IMT1|${unsigned}|s=${signatureQr}`;

    return {
      received: true,
      paymentReference,
      ticketId: ticket.id,
      qr,
    };
  }

  async verifyPaystackPayment(paymentReference: string) {
    if (!paymentReference) {
      return { ok: false, reason: 'missing_reference' };
    }

    const apiKey = process.env.PAYSTACK_SECRET_KEY ?? '';
    const baseUrl = process.env.PAYSTACK_BASE_URL ?? 'https://api.paystack.co';
    if (!apiKey) {
      return { ok: false, reason: 'missing_paystack_key' };
    }

    const response = await fetch(`${baseUrl}/transaction/verify/${paymentReference}`, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
    });

    const data = await response.json();
    const status = data?.data?.status;
    if (!data?.status) {
      return { ok: false, reason: 'verify_failed', details: data };
    }

    const payment = await this.prisma.payment.findFirst({
      where: {
        provider: 'PAYSTACK',
        providerRef: paymentReference,
      },
    });

    if (!payment) {
      return { ok: false, reason: 'payment_not_found' };
    }

    if (status === 'success') {
      const amountPaid = Number(data?.data?.amount ?? 0) / 100;
      const currency = data?.data?.currency ?? payment.currency ?? 'NGN';
      const ticket = await this.completePaymentAndIssueTicket(payment.id, amountPaid || payment.amount, currency);
      if (ticket) {
        await this.notificationsService.sendToUser(ticket.userId, {
          title: 'Ticket ready',
          body: 'Your payment was confirmed. Open I-Metro to view your ticket QR.',
          data: {
            type: 'ticket_ready',
            bookingId: payment.bookingId,
            ticketId: ticket.id,
            paymentReference: payment.providerRef ?? paymentReference,
            silent: '1',
          },
        });
      }
      return {
        ok: true,
        status: 'SUCCESS',
        paymentReference,
        bookingId: payment.bookingId,
        ticketId: ticket?.id ?? null,
        ticket: ticket ?? null,
      };
    }

    return {
      ok: false,
      status: status ?? 'pending',
      paymentReference,
      bookingId: payment.bookingId,
    };
  }

  async initiatePaystackPayment(userId: string, routeId: string) {
    if (!userId || !routeId) {
      return { ok: false, reason: 'missing_user_or_route' };
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });
    if (!user) {
      return { ok: false, reason: 'user_not_found' };
    }

    if (!user.email) {
      return { ok: false, reason: 'missing_customer_email' };
    }

    const route = await this.prisma.route.findUnique({
      where: { id: routeId },
    });
    if (!route) {
      return { ok: false, reason: 'route_not_found' };
    }

    const booking = await this.prisma.booking.create({
      data: {
        userId,
        routeId,
        status: 'PENDING',
      },
    });

    const paymentReference = `IMT-PS-${Date.now()}-${randomBytes(4).toString('hex')}`;
    await this.prisma.payment.create({
      data: {
        bookingId: booking.id,
        amount: route.price,
        currency: route.currency,
        provider: 'PAYSTACK',
        providerRef: paymentReference,
        status: 'PENDING',
      },
    });

    const initResult = await this.initializePaystackTransaction({
      amount: route.price,
      currency: route.currency,
      paymentReference,
      customerEmail: user.email,
    });

    if (!initResult.ok) {
      return initResult;
    }

    return {
      ok: true,
      bookingId: booking.id,
      paymentReference,
      checkoutUrl: initResult.checkoutUrl,
      amount: route.price,
      currency: route.currency,
      route: {
        id: route.id,
        from: route.fromLocation,
        to: route.toLocation,
      },
    };
  }

  async initiateMonnifyPayment(userId: string, routeId: string) {
    if (!userId || !routeId) {
      return { ok: false, reason: 'missing_user_or_route' };
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });
    if (!user) {
      return { ok: false, reason: 'user_not_found' };
    }

    if (!user.email) {
      return { ok: false, reason: 'missing_customer_email' };
    }

    const route = await this.prisma.route.findUnique({
      where: { id: routeId },
    });
    if (!route) {
      return { ok: false, reason: 'route_not_found' };
    }

    const booking = await this.prisma.booking.create({
      data: {
        userId,
        routeId,
        status: 'PENDING',
      },
    });

    const paymentReference = `IMT-${Date.now()}-${randomBytes(4).toString('hex')}`;
    const payment = await this.prisma.payment.create({
      data: {
        bookingId: booking.id,
        amount: route.price,
        currency: route.currency,
        provider: MONNIFY_PROVIDER,
        providerRef: paymentReference,
        status: 'PENDING',
      },
    });

    const initResult = await this.initializeMonnifyTransaction({
      amount: payment.amount,
      currency: payment.currency,
      paymentReference,
      customerName: `${user.firstName ?? ''} ${user.lastName ?? ''}`.trim() || 'I-Metro Rider',
      customerEmail: user.email,
    });

    if (!initResult.ok) {
      return initResult;
    }

    return {
      ok: true,
      bookingId: booking.id,
      paymentReference,
      checkoutUrl: initResult.checkoutUrl,
      amount: payment.amount,
      currency: payment.currency,
      route: {
        id: route.id,
        from: route.fromLocation,
        to: route.toLocation,
      },
    };
  }

  async retryMonnifyPayment(userId: string, bookingId: string) {
    if (!userId || !bookingId) {
      return { ok: false, reason: 'missing_user_or_booking' };
    }

    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      include: {
        route: true,
        payment: true,
        ticket: true,
        user: true,
      },
    });

    if (!booking) {
      return { ok: false, reason: 'booking_not_found' };
    }
    if (booking.userId !== userId) {
      return { ok: false, reason: 'forbidden' };
    }
    if (booking.ticket) {
      return { ok: false, reason: 'ticket_already_issued' };
    }
    if (booking.payment?.status === 'SUCCESS') {
      return { ok: false, reason: 'payment_already_confirmed' };
    }
    if (!booking.user?.email) {
      return { ok: false, reason: 'missing_customer_email' };
    }

    const paymentReference = `IMT-${Date.now()}-${randomBytes(4).toString('hex')}`;
    const amount = booking.payment?.amount ?? booking.route.price;
    const currency = booking.payment?.currency ?? booking.route.currency ?? 'NGN';

    if (booking.payment) {
      await this.prisma.payment.update({
        where: { id: booking.payment.id },
        data: {
          provider: MONNIFY_PROVIDER,
          providerRef: paymentReference,
          status: 'PENDING',
          paidAt: null,
          amount,
          currency,
        },
      });
    } else {
      await this.prisma.payment.create({
        data: {
          bookingId: booking.id,
          amount,
          currency,
          provider: MONNIFY_PROVIDER,
          providerRef: paymentReference,
          status: 'PENDING',
        },
      });
    }

    await this.prisma.booking.update({
      where: { id: booking.id },
      data: { status: 'PENDING' },
    });

    const initResult = await this.initializeMonnifyTransaction({
      amount,
      currency,
      paymentReference,
      customerName: `${booking.user.firstName ?? ''} ${booking.user.lastName ?? ''}`.trim() || 'I-Metro Rider',
      customerEmail: booking.user.email,
    });

    if (!initResult.ok) {
      return initResult;
    }

    return {
      ok: true,
      bookingId: booking.id,
      paymentReference,
      checkoutUrl: initResult.checkoutUrl,
      amount,
      currency,
      route: {
        id: booking.route.id,
        from: booking.route.fromLocation,
        to: booking.route.toLocation,
      },
    };
  }

  async retryPaystackPayment(userId: string, bookingId: string) {
    if (!userId || !bookingId) {
      return { ok: false, reason: 'missing_user_or_booking' };
    }

    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      include: {
        route: true,
        payment: true,
        ticket: true,
        user: true,
      },
    });

    if (!booking) {
      return { ok: false, reason: 'booking_not_found' };
    }
    if (booking.userId !== userId) {
      return { ok: false, reason: 'forbidden' };
    }
    if (!booking.route) {
      return { ok: false, reason: 'route_not_found' };
    }
    if (booking.ticket) {
      return { ok: false, reason: 'ticket_already_issued' };
    }
    if (booking.payment?.status === 'SUCCESS') {
      return { ok: false, reason: 'payment_already_confirmed' };
    }
    if (!booking.user?.email) {
      return { ok: false, reason: 'missing_customer_email' };
    }

    const paymentReference = `IMT-PS-${Date.now()}-${randomBytes(4).toString('hex')}`;
    const amount = booking.payment?.amount ?? booking.route.price;
    const currency = booking.payment?.currency ?? booking.route.currency ?? 'NGN';

    if (booking.payment) {
      await this.prisma.payment.update({
        where: { id: booking.payment.id },
        data: {
          provider: 'PAYSTACK',
          providerRef: paymentReference,
          status: 'PENDING',
          paidAt: null,
          amount,
          currency,
        },
      });
    } else {
      await this.prisma.payment.create({
        data: {
          bookingId: booking.id,
          amount,
          currency,
          provider: 'PAYSTACK',
          providerRef: paymentReference,
          status: 'PENDING',
        },
      });
    }

    await this.prisma.booking.update({
      where: { id: booking.id },
      data: { status: 'PENDING' },
    });

    const initResult = await this.initializePaystackTransaction({
      amount,
      currency,
      paymentReference,
      customerEmail: booking.user.email,
    });

    if (!initResult.ok) {
      return initResult;
    }

    return {
      ok: true,
      bookingId: booking.id,
      paymentReference,
      checkoutUrl: initResult.checkoutUrl,
      amount,
      currency,
      route: {
        id: booking.route.id,
        from: booking.route.fromLocation,
        to: booking.route.toLocation,
      },
    };
  }

  private verifyMonnifySignature(rawBody: string, signature: string) {
    const secret = process.env.MONNIFY_SECRET_KEY ?? '';
    if (!secret) {
      return false;
    }
    const computed = createHmac('sha512', secret).update(rawBody).digest('hex');
    return computed.toLowerCase() === signature.toLowerCase();
  }

  private verifyPaystackSignature(rawBody: string, signature: string) {
    const secret = process.env.PAYSTACK_SECRET_KEY ?? '';
    if (!secret) {
      return false;
    }
    const computed = createHmac('sha512', secret).update(rawBody).digest('hex');
    return computed.toLowerCase() === signature.toLowerCase();
  }

  private async getMonnifyAccessToken() {
    const apiKey = process.env.MONNIFY_API_KEY ?? '';
    const secret = process.env.MONNIFY_SECRET_KEY ?? '';
    const baseUrl = process.env.MONNIFY_BASE_URL ?? 'https://api.monnify.com';

    if (!apiKey || !secret) {
      return { ok: false, reason: 'missing_monnify_keys' } as const;
    }

    const basic = Buffer.from(`${apiKey}:${secret}`).toString('base64');
    const response = await fetch(`${baseUrl}/api/v1/auth/login`, {
      method: 'POST',
      headers: {
        Authorization: `Basic ${basic}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({}),
    });

    const data = await response.json();
    const token = data?.responseBody?.accessToken;
    if (!token) {
      return { ok: false, reason: 'failed_to_get_token', details: data } as const;
    }

    return { ok: true, token } as const;
  }

  private async initializePaystackTransaction(payload: {
    amount: number;
    currency: string;
    paymentReference: string;
    customerEmail: string;
  }) {
    const apiKey = process.env.PAYSTACK_SECRET_KEY ?? '';
    const baseUrl = process.env.PAYSTACK_BASE_URL ?? 'https://api.paystack.co';
    const callbackUrl = process.env.PAYSTACK_CALLBACK_URL ?? '';
    const channelsRaw = process.env.PAYSTACK_CHANNELS ?? '';

    if (!apiKey) {
      return { ok: false, reason: 'missing_paystack_key' };
    }

    const body: Record<string, any> = {
      email: payload.customerEmail,
      amount: Math.round(payload.amount * 100),
      reference: payload.paymentReference,
      currency: payload.currency,
    };

    if (callbackUrl) {
      body.callback_url = callbackUrl;
    }

    if (channelsRaw.trim().length > 0) {
      body.channels = channelsRaw.split(',').map((value) => value.trim()).filter(Boolean);
    }

    const response = await fetch(`${baseUrl}/transaction/initialize`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    const data = await response.json();
    const checkoutUrl = data?.data?.authorization_url;
    if (!checkoutUrl) {
      return { ok: false, reason: 'init_failed', details: data };
    }

    return { ok: true, checkoutUrl };
  }

  private async completePaymentAndIssueTicket(paymentId: string, amountPaid: number, currency: string) {
    const payment = await this.prisma.payment.findUnique({
      where: { id: paymentId },
      include: { booking: true },
    });
    if (!payment) {
      return null;
    }

    const ticket = await this.prisma.$transaction(async (tx) => {
      const updated = await tx.payment.update({
        where: { id: payment.id },
        data: {
          status: 'SUCCESS',
          paidAt: new Date(),
          amount: amountPaid || payment.amount,
          currency,
        },
      });

      const booking = await tx.booking.findUnique({
        where: { id: updated.bookingId },
        include: { route: true },
      });
      if (!booking) {
        return null;
      }

      await tx.booking.update({
        where: { id: booking.id },
        data: { status: 'CONFIRMED' },
      });

      const existingTicket = await tx.ticket.findFirst({
        where: { bookingId: booking.id },
      });
      if (existingTicket) {
        return existingTicket;
      }

      return tx.ticket.create({
        data: {
          bookingId: booking.id,
          userId: booking.userId,
          routeId: booking.routeId,
          amount: updated.amount,
          currency: updated.currency,
          validDate: new Date(),
          nonce: randomBytes(8).toString('hex'),
        },
      });
    });

    return ticket;
  }

  private async initializeMonnifyTransaction(payload: {
    amount: number;
    currency: string;
    paymentReference: string;
    customerName: string;
    customerEmail: string;
  }) {
    const contractCode = process.env.MONNIFY_CONTRACT_CODE ?? '';
    const baseUrl = process.env.MONNIFY_BASE_URL ?? 'https://api.monnify.com';
    const redirectUrl = process.env.MONNIFY_REDIRECT_URL ?? '';

    if (!contractCode) {
      return { ok: false, reason: 'missing_contract_code' };
    }

    const tokenResult = await this.getMonnifyAccessToken();
    if (!tokenResult.ok) {
      return tokenResult;
    }

    const body: Record<string, any> = {
      amount: payload.amount,
      customerName: payload.customerName,
      customerEmail: payload.customerEmail,
      paymentReference: payload.paymentReference,
      paymentDescription: 'I-Metro Ticket',
      currencyCode: payload.currency,
      contractCode,
    };

    if (redirectUrl) {
      body.redirectUrl = redirectUrl;
    }

    const response = await fetch(`${baseUrl}/api/v1/merchant/transactions/init-transaction`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${tokenResult.token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    const data = await response.json();
    const checkoutUrl = data?.responseBody?.checkoutUrl;
    if (!checkoutUrl) {
      return { ok: false, reason: 'init_failed', details: data };
    }

    return { ok: true, checkoutUrl };
  }
}
