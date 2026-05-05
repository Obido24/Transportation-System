import { IsOptional, IsString } from 'class-validator';

export class MonnifyWebhookDto {
  @IsOptional()
  @IsString()
  eventType?: string;

  @IsOptional()
  eventData?: Record<string, any>;
}
