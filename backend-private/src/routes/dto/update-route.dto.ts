import { IsBoolean, IsInt, IsOptional, IsString, Min } from 'class-validator';

export class UpdateRouteDto {
  @IsOptional()
  @IsString()
  fromLocation?: string;

  @IsOptional()
  @IsString()
  toLocation?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  price?: number;

  @IsOptional()
  @IsString()
  currency?: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
