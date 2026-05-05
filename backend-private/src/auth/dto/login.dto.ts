import { IsString, MinLength } from 'class-validator';

export class LoginDto {
  @IsString()
  emailOrPhone: string;

  @IsString()
  @MinLength(6)
  password: string;
}
