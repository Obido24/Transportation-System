import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { AnnouncementsModule } from '../announcements/announcements.module';

@Module({
  imports: [AnnouncementsModule],
  controllers: [AdminController],
  providers: [AdminService],
})
export class AdminModule {}
