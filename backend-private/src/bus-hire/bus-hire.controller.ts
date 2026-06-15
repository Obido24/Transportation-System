import { Body, Controller, Post } from '@nestjs/common';
import { BusHireService } from './bus-hire.service';
import { CreateBusHireRequestDto } from './dto/create-bus-hire-request.dto';

@Controller('bus-hire')
export class BusHireController {
  constructor(private readonly busHireService: BusHireService) {}

  @Post('requests/public')
  createPublicRequest(@Body() body: CreateBusHireRequestDto) {
    return this.busHireService.createPublicRequest(body);
  }
}
