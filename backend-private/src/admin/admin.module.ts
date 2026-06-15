import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { AnnouncementsModule } from '../announcements/announcements.module';
import { BusHireModule } from '../bus-hire/bus-hire.module';

@Module({
  imports: [AnnouncementsModule, BusHireModule],
  controllers: [AdminController],
  providers: [AdminService],
})
export class AdminModule {}
