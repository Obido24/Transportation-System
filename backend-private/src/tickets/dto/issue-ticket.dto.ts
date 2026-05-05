import { IsNumber, IsOptional, IsString, IsISO8601 } from 'class-validator';

export class IssueTicketDto {
  @IsString()
  userId: string;

  @IsString()
  routeId: string;

  @IsNumber()
  amount: number;

  @IsOptional()
  @IsString()
  currency?: string;

  @IsOptional()
  @IsString()
  paymentRef?: string;

  @IsOptional()
  @IsISO8601()
  validDate?: string;
}
