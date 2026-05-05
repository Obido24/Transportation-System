import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { TicketsService } from '../tickets/tickets.service';

@Injectable()
export class BookingsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly ticketsService: TicketsService,
  ) {}

  async createBooking(payload: CreateBookingDto) {
    const route = await this.prisma.route.findUnique({
      where: { id: payload.routeId },
    });
    if (!route) {
      return { ok: false, reason: 'route_not_found' };
    }

    const booking = await this.prisma.booking.create({
      data: {
        userId: payload.userId,
        routeId: payload.routeId,
        status: 'PENDING',
        travelDate: payload.travelDate ? new Date(payload.travelDate) : null,
      },
    });

    return { ok: true, bookingId: booking.id };
  }

  async getBooking(id: string) {
    return this.prisma.booking.findUnique({
      where: { id },
      include: {
        route: true,
        payment: true,
        ticket: true,
      },
    });
  }

  async listForUser(userId: string) {
    return this.prisma.booking.findMany({
      where: { userId },
      include: {
        route: true,
        payment: true,
        ticket: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async issueTicket(bookingId: string) {
    return this.ticketsService.issueTicketForBooking(bookingId);
  }
}
