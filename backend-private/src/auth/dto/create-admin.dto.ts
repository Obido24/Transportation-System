import { IsEmail, IsIn, IsOptional, IsString, MinLength } from 'class-validator';

export class CreateAdminDto {
  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsString()
  @MinLength(6)
  password: string;

  @IsOptional()
  @IsString()
  firstName?: string;

  @IsOptional()
  @IsString()
  lastName?: string;

  @IsOptional()
  @IsIn(['ADMIN', 'MERCHANT'])
  role?: 'ADMIN' | 'MERCHANT';

  @IsString()
  bootstrapSecret: string;
}
