import { BusHireRequestStatus } from '@prisma/client';
import { IsArray, IsEnum, IsOptional, IsString } from 'class-validator';

export class UpdateBusHireRequestDto {
  @IsOptional()
  @IsEnum(BusHireRequestStatus)
  status?: BusHireRequestStatus;

  @IsOptional()
  @IsString()
  adminComments?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  assignedBuses?: string[];
}
