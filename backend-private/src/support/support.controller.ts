import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreatePublicSupportMessageDto } from './dto/create-public-support-message.dto';
import { CreateSupportMessageDto } from './dto/create-support-message.dto';
import { SupportService } from './support.service';

@Controller('support')
export class SupportController {
  constructor(private readonly supportService: SupportService) {}

  @Get('messages/mine')
  @UseGuards(JwtAuthGuard)
  listMyMessages(@Req() req: { user?: { userId?: string } }) {
    return this.supportService.listMessages(req.user?.userId ?? '');
  }

  @Post('messages')
  @UseGuards(JwtAuthGuard)
  createMessage(@Body() body: CreateSupportMessageDto, @Req() req: { user?: { userId?: string } }) {
    return this.supportService.createMessage(req.user?.userId ?? '', body);
  }

  @Post('messages/public')
  createPublicMessage(@Body() body: CreatePublicSupportMessageDto) {
    return this.supportService.createPublicMessage(body);
  }
}
