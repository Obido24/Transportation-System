import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { HealthModule } from './health/health.module';
import { ValidatorsModule } from './validators/validators.module';
import { TicketsModule } from './tickets/tickets.module';
import { RoutesModule } from './routes/routes.module';
import { PaymentsModule } from './payments/payments.module';
import { AuthModule } from './auth/auth.module';
import { BookingsModule } from './bookings/bookings.module';
import { AdminModule } from './admin/admin.module';
import { NotificationsModule } from './notifications/notifications.module';
import { SupportModule } from './support/support.module';

@Module({
  imports: [
    PrismaModule,
    HealthModule,
    ValidatorsModule,
    TicketsModule,
    RoutesModule,
    PaymentsModule,
    AuthModule,
    BookingsModule,
    NotificationsModule,
    AdminModule,
    SupportModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
