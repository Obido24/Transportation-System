import { IsEmail, IsInt, IsOptional, IsString, Min, MinLength } from 'class-validator';

export class CreateBusHireRequestDto {
  @IsString()
  @MinLength(2)
  fullNameOrOrganization: string;

  @IsString()
  @MinLength(7)
  phoneNumber: string;

  @IsString()
  @MinLength(7)
  whatsappNumber: string;

  @IsOptional()
  @IsEmail()
  emailAddress?: string;

  @IsString()
  @MinLength(2)
  pickupPoint: string;

  @IsString()
  @MinLength(2)
  dropoffPoint: string;

  @IsString()
  @MinLength(2)
  destinationOrEventLocation: string;

  @IsString()
  dateOfService: string;

  @IsString()
  @MinLength(2)
  timeOfService: string;

  @IsInt()
  @Min(1)
  numberOfTrips: number;

  @IsInt()
  @Min(1)
  numberOfBusesNeeded: number;

  @IsString()
  @MinLength(2)
  typeOfEventOrPurpose: string;

  @IsOptional()
  @IsString()
  additionalNotesOrSpecialRequest?: string;
}
