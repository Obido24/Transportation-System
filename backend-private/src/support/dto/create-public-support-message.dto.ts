import { IsEmail, IsOptional, IsString, MinLength } from 'class-validator';

export class CreatePublicSupportMessageDto {
  @IsOptional()
  @IsString()
  @MinLength(2)
  name?: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  @MinLength(7)
  phone?: string;

  @IsString()
  @MinLength(2)
  subject: string;

  @IsString()
  @MinLength(5)
  message: string;
}
