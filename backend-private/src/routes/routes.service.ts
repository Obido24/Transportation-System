import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateRouteDto } from './dto/create-route.dto';
import { UpdateRouteDto } from './dto/update-route.dto';

@Injectable()
export class RoutesService {
  constructor(private readonly prisma: PrismaService) {}

  async listRoutes() {
    return this.prisma.route.findMany({
      where: { isActive: true },
      orderBy: [{ fromLocation: 'asc' }, { toLocation: 'asc' }],
    });
  }

  async createRoute(payload: CreateRouteDto) {
    return this.prisma.route.create({
      data: {
        fromLocation: payload.fromLocation,
        toLocation: payload.toLocation,
        price: payload.price,
        currency: payload.currency ?? 'NGN',
      },
    });
  }

  async updateRoute(id: string, payload: UpdateRouteDto) {
    return this.prisma.route.update({
      where: { id },
      data: {
        ...(payload.fromLocation ? { fromLocation: payload.fromLocation } : {}),
        ...(payload.toLocation ? { toLocation: payload.toLocation } : {}),
        ...(payload.price !== undefined ? { price: payload.price } : {}),
        ...(payload.currency ? { currency: payload.currency } : {}),
        ...(payload.isActive !== undefined ? { isActive: payload.isActive } : {}),
      },
    });
  }

  async deleteRoute(id: string) {
    return this.prisma.route.update({
      where: { id },
      data: { isActive: false },
    });
  }

  async seedDefaultRoutes() {
    const routes = [
      { fromLocation: 'Nyanya', toLocation: 'Banex', price: 600 },
      { fromLocation: 'Banex', toLocation: 'Nyanya', price: 600 },
      { fromLocation: 'Nyanya', toLocation: 'Berga', price: 600 },
      { fromLocation: 'Berga', toLocation: 'Nyanya', price: 600 },
      { fromLocation: 'Area1', toLocation: 'Nyanya', price: 600 },
      { fromLocation: 'Nyanyan', toLocation: 'Area1', price: 600 },
    ];

    const created: string[] = [];
    for (const route of routes) {
      const exists = await this.prisma.route.findFirst({
        where: {
          fromLocation: route.fromLocation,
          toLocation: route.toLocation,
          price: route.price,
        },
      });
      if (!exists) {
        const result = await this.prisma.route.create({
          data: {
            ...route,
            currency: 'NGN',
          },
        });
        created.push(result.id);
      }
    }

    return {
      createdCount: created.length,
      createdIds: created,
    };
  }
}
