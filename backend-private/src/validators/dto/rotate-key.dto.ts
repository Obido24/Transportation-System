import { IsString } from 'class-validator';

export class RotateKeyDto {
  @IsString()
  deviceId: string;
}
