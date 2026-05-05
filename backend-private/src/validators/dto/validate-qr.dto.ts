import { IsOptional, IsString } from 'class-validator';

export class ValidateQrDto {
  @IsOptional()
  @IsString()
  code?: string;

  @IsOptional()
  @IsString()
  qr?: string;

  @IsOptional()
  @IsString()
  deviceId?: string;

  @IsOptional()
  @IsString()
  timestamp?: string;

  @IsOptional()
  @IsString()
  busLabel?: string;
}
