import { Body, Controller, Post, Headers, Get, UseGuards } from '@nestjs/common';
import { ValidatorsService } from './validators.service';
import { ValidateQrDto } from './dto/validate-qr.dto';
import { CreateDeviceDto } from './dto/create-device.dto';
import { RotateKeyDto } from './dto/rotate-key.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/roles.decorator';

@Controller('validators')
export class ValidatorsController {
  constructor(private readonly validatorsService: ValidatorsService) {}

  @Post('validate-qr')
  validateQr(@Body() body: ValidateQrDto, @Headers('x-api-key') apiKey?: string) {
    return this.validatorsService.validateQr(body, apiKey ?? '');
  }

  @Get('devices')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  listDevices() {
    return this.validatorsService.listDevices();
  }

  @Post('devices')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  createDevice(@Body() body: CreateDeviceDto) {
    return this.validatorsService.createDevice(body);
  }

  @Post('devices/rotate-key')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  rotateKey(@Body() body: RotateKeyDto) {
    return this.validatorsService.rotateDeviceKey(body.deviceId);
  }
}
