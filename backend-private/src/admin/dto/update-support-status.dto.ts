import { SupportStatus } from '@prisma/client';
import { IsEnum } from 'class-validator';

export class UpdateSupportStatusDto {
  @IsEnum(SupportStatus)
  status: SupportStatus;
}
