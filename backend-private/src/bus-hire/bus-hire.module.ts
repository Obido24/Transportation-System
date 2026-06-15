import { Module } from '@nestjs/common';
import { BusHireController } from './bus-hire.controller';
import { BusHireService } from './bus-hire.service';

@Module({
  controllers: [BusHireController],
  providers: [BusHireService],
  exports: [BusHireService],
})
export class BusHireModule {}
