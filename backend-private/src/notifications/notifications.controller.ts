import { Body, Controller, Delete, Param, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { NotificationsService } from './notifications.service';
import { RegisterDeviceDto } from './dto/register-device.dto';

@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Post('devices')
  @UseGuards(JwtAuthGuard)
  registerDevice(@Req() req: any, @Body() body: RegisterDeviceDto) {
    return this.notificationsService.registerDevice(req.user?.userId, body);
  }

  @Delete('devices/:token')
  @UseGuards(JwtAuthGuard)
  unregisterDevice(@Req() req: any, @Param('token') token: string) {
    return this.notificationsService.unregisterDevice(req.user?.userId, token);
  }

  @Post('test')
  @UseGuards(JwtAuthGuard)
  sendTest(@Req() req: any) {
    return this.notificationsService.sendToUser(req.user?.userId, {
      title: 'I-Metro',
      body: 'Push notifications are configured.',
      data: { type: 'test' },
    });
  }
}
