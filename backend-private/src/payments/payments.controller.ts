import { Body, Controller, Post, Headers, Req, UseGuards } from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { MonnifyWebhookDto } from './dto/monnify-webhook.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post('monnify/webhook')
  monnifyWebhook(
    @Body() body: MonnifyWebhookDto,
    @Headers('monnify-signature') signature?: string,
    @Req() req?: { rawBody?: string },
  ) {
    return this.paymentsService.handleMonnifyWebhook(body, signature, req?.rawBody ?? '');
  }

  @Post('monnify/verify')
  verifyMonnify(@Body('paymentReference') paymentReference: string) {
    return this.paymentsService.verifyMonnifyPayment(paymentReference);
  }

  @Post('paystack/webhook')
  paystackWebhook(
    @Body() body: any,
    @Headers('x-paystack-signature') signature?: string,
    @Req() req?: { rawBody?: string },
  ) {
    return this.paymentsService.handlePaystackWebhook(body, signature, req?.rawBody ?? '');
  }

  @Post('paystack/verify')
  verifyPaystack(@Body('paymentReference') paymentReference: string) {
    return this.paymentsService.verifyPaystackPayment(paymentReference);
  }

  @Post('paystack/initiate')
  @UseGuards(JwtAuthGuard)
  initiatePaystack(@Body() body: { userId: string; routeId: string }) {
    return this.paymentsService.initiatePaystackPayment(body.userId, body.routeId);
  }

  @Post('monnify/initiate')
  @UseGuards(JwtAuthGuard)
  initiateMonnify(@Body() body: { userId: string; routeId: string }) {
    return this.paymentsService.initiateMonnifyPayment(body.userId, body.routeId);
  }

  @Post('monnify/retry')
  @UseGuards(JwtAuthGuard)
  retryMonnify(@Body('bookingId') bookingId: string, @Req() req: { user?: { userId?: string } }) {
    return this.paymentsService.retryMonnifyPayment(req.user?.userId ?? '', bookingId);
  }

  @Post('paystack/retry')
  @UseGuards(JwtAuthGuard)
  retryPaystack(@Body('bookingId') bookingId: string, @Req() req: { user?: { userId?: string } }) {
    return this.paymentsService.retryPaystackPayment(req.user?.userId ?? '', bookingId);
  }
}
