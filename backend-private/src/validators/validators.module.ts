import { Module } from '@nestjs/common';
import { ValidatorsController } from './validators.controller';
import { ValidatorsService } from './validators.service';

@Module({
  controllers: [ValidatorsController],
  providers: [ValidatorsService],
})
export class ValidatorsModule {}
