import { IsBoolean, IsNumber, IsOptional, IsString } from 'class-validator';

export class CreateRouteDto {
  @IsString()
  fromLocation: string;

  @IsString()
  toLocation: string;

  @IsNumber()
  price: number;

  @IsOptional()
  @IsString()
  currency?: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
