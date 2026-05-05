import { IsString, MinLength } from 'class-validator';

export class CreateSupportMessageDto {
  @IsString()
  @MinLength(2)
  subject: string;

  @IsString()
  @MinLength(5)
  message: string;
}
