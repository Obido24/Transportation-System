import { Injectable } from '@nestjs/common';
import { createHmac, randomBytes } from 'crypto';
import { PrismaService } from '../prisma/prisma.service';
import { IssueTicketDto } from './dto/issue-ticket.dto';

@Injectable()
export class TicketsService {
  constructor(private readonly prisma: PrismaService) {}

  async issueTicket(payload: IssueTicketDto) {
    const { userId, routeId, amount, currency, paymentRef, validDate } = payload;

    const ticket = await this.prisma.ticket.create({
      data: {
        userId,
        routeId,
        amount,
        currency: currency ?? 'NGN',
        validDate: validDate ? new Date(validDate) : new Date(),
        nonce: randomBytes(8).toString('hex'),
      },
    });

    return this.buildQrResponse(ticket, paymentRef ?? null);
  }

  async issueTicketForBooking(bookingId: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      include: { route: true, payment: true, ticket: true },
    });

    if (!booking) {
      return { ok: false, reason: 'booking_not_found' };
    }

    if (booking.ticket) {
      return this.buildQrResponse(booking.ticket, booking.payment?.providerRef ?? null);
    }

    if (!booking.payment || booking.payment.status !== 'SUCCESS') {
      return { ok: false, reason: 'payment_not_confirmed' };
    }

    const ticket = await this.prisma.$transaction(async (tx) => {
      await tx.booking.update({
        where: { id: booking.id },
        data: { status: 'CONFIRMED' },
      });

      return tx.ticket.create({
        data: {
          bookingId: booking.id,
          userId: booking.userId,
          routeId: booking.routeId,
          amount: booking.payment?.amount ?? booking.route.price,
          currency: booking.payment?.currency ?? booking.route.currency,
          validDate: new Date(),
          nonce: randomBytes(8).toString('hex'),
        },
      });
    });

    return this.buildQrResponse(ticket, booking.payment?.providerRef ?? null);
  }

  private buildQrResponse(
    ticket: {
      id: string;
      userId: string;
      routeId: string;
      amount: number;
      currency: string;
      issuedAt: Date;
      validDate: Date;
      nonce: string;
    },
    paymentRef: string | null,
  ) {
    const validDate = ticket.validDate.toISOString().slice(0, 10);
    const dateCompact = validDate.replace(/-/g, '');
    const unsigned = `t=${ticket.id}|e=${dateCompact}|n=${ticket.nonce}`;
    const secret = process.env.QR_SECRET ?? 'dev_qr_secret';
    const signature = createHmac('sha256', secret).update(unsigned).digest('base64url');
    const qr = `IMT1|${unsigned}|s=${signature}`;

    return {
      ok: true,
      ticketId: ticket.id,
      qr,
      validDate,
      paymentRef: paymentRef ?? null,
    };
  }
}
