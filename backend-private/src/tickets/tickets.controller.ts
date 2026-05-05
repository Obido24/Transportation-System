import { Body, Controller, Post } from '@nestjs/common';
import { TicketsService } from './tickets.service';
import { IssueTicketDto } from './dto/issue-ticket.dto';

@Controller('tickets')
export class TicketsController {
  constructor(private readonly ticketsService: TicketsService) {}

  @Post('issue')
  issue(@Body() body: IssueTicketDto) {
    return this.ticketsService.issueTicket(body);
  }
}
