import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { BookingsService } from './bookings.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('bookings')
export class BookingsController {
  constructor(private readonly bookingsService: BookingsService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  create(@Body() body: CreateBookingDto) {
    return this.bookingsService.createBooking(body);
  }

  @Get(':id')
  get(@Param('id') id: string) {
    return this.bookingsService.getBooking(id);
  }

  @Get('user/:userId')
  @UseGuards(JwtAuthGuard)
  listForUser(@Param('userId') userId: string) {
    return this.bookingsService.listForUser(userId);
  }

  @Post(':id/issue-ticket')
  @UseGuards(JwtAuthGuard)
  issueTicket(@Param('id') id: string) {
    return this.bookingsService.issueTicket(id);
  }
}
