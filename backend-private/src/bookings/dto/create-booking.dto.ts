import { IsOptional, IsString } from 'class-validator';

export class CreateBookingDto {
  @IsString()
  userId: string;

  @IsString()
  routeId: string;

  @IsOptional()
  @IsString()
  travelDate?: string;
}
