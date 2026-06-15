import { Injectable } from '@nestjs/common';
import { BusHireRequestStatus } from '@prisma/client';
import { randomUUID } from 'crypto';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBusHireRequestDto } from './dto/create-bus-hire-request.dto';
import { UpdateBusHireRequestDto } from './dto/update-bus-hire-request.dto';

@Injectable()
export class BusHireService {
  constructor(private readonly prisma: PrismaService) {}

  private getExecutiveDirectorWhatsAppNumber() {
    return (
      process.env.EXECUTIVE_DIRECTOR_WHATSAPP ??
      process.env.BUS_HIRE_WHATSAPP_TO ??
      '2347070050444'
    )
      .replace(/\D/g, '')
      .trim();
  }

  private getFleetCapacity() {
    const parsed = Number(process.env.BUS_HIRE_TOTAL_BUSES ?? 12);
    return Number.isFinite(parsed) && parsed > 0 ? parsed : 12;
  }

  private formatStatus(status: BusHireRequestStatus) {
    return status
      .toLowerCase()
      .replace(/_/g, ' ')
      .replace(/\b\w/g, (char) => char.toUpperCase());
  }

  private async resolveActor(userId?: string) {
    if (!userId) {
      return {
        actorUserId: null,
        actorName: 'System',
        actorRole: 'SYSTEM',
      };
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        firstName: true,
        lastName: true,
        email: true,
        role: true,
      },
    });

    const name =
      `${user?.firstName ?? ''} ${user?.lastName ?? ''}`.trim() ||
      user?.email ||
      'I-Metro Admin';

    return {
      actorUserId: userId,
      actorName: name,
      actorRole: user?.role ?? 'ADMIN',
    };
  }

  private async recordAuditLog(payload: {
    actorUserId?: string;
    category: string;
    action: string;
    details: string;
    entityType?: string;
    entityId?: string;
    ipAddress?: string;
  }) {
    const actor = await this.resolveActor(payload.actorUserId);
    return this.prisma.$executeRaw`
      INSERT INTO "AuditLog" (
        "id",
        "actorUserId",
        "actorName",
        "actorRole",
        "category",
        "action",
        "details",
        "entityType",
        "entityId",
        "ipAddress",
        "createdAt"
      ) VALUES (
        ${randomUUID()},
        ${actor.actorUserId},
        ${actor.actorName},
        ${actor.actorRole},
        ${payload.category},
        ${payload.action},
        ${payload.details},
        ${payload.entityType ?? null},
        ${payload.entityId ?? null},
        ${payload.ipAddress ?? null},
        NOW()
      )
    `;
  }

  private toServiceDate(dateOfService: string) {
    const parsed = new Date(`${dateOfService}T00:00:00.000Z`);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  private buildWhatsAppMessage(record: {
    id: string;
    fullNameOrOrg: string;
    phoneNumber: string;
    whatsappNumber: string;
    email: string | null;
    pickupPoint: string;
    dropoffPoint: string;
    destination: string;
    serviceDate: Date;
    serviceTime: string;
    numberOfTrips: number;
    numberOfBuses: number;
    eventType: string;
    additionalNotes: string | null;
  }) {
    const lines = [
      'New I-Metro Bus Hire / Charter Request',
      `Request ID: ${record.id}`,
      `Name / Organization: ${record.fullNameOrOrg}`,
      `Phone Number: ${record.phoneNumber}`,
      `WhatsApp Number: ${record.whatsappNumber}`,
      `Email Address: ${record.email || 'Not provided'}`,
      `Pick-up Point: ${record.pickupPoint}`,
      `Drop-off Point: ${record.dropoffPoint}`,
      `Destination / Event Location: ${record.destination}`,
      `Date of Service: ${record.serviceDate.toISOString().slice(0, 10)}`,
      `Time of Service: ${record.serviceTime}`,
      `Number of Trips: ${record.numberOfTrips}`,
      `Number of Buses Needed: ${record.numberOfBuses}`,
      `Type of Event / Purpose: ${record.eventType}`,
      `Additional Notes / Special Request: ${record.additionalNotes || 'None'}`,
    ];

    return encodeURIComponent(lines.join('\n'));
  }

  async createPublicRequest(payload: CreateBusHireRequestDto) {
    const serviceDate = this.toServiceDate(payload.dateOfService);
    if (!serviceDate) {
      return { ok: false, reason: 'invalid_service_date' };
    }

    const record = await this.prisma.busHireRequest.create({
      data: {
        fullNameOrOrg: payload.fullNameOrOrganization.trim(),
        phoneNumber: payload.phoneNumber.trim(),
        whatsappNumber: payload.whatsappNumber.trim(),
        email: payload.emailAddress?.trim() || null,
        pickupPoint: payload.pickupPoint.trim(),
        dropoffPoint: payload.dropoffPoint.trim(),
        destination: payload.destinationOrEventLocation.trim(),
        serviceDate,
        serviceTime: payload.timeOfService.trim(),
        numberOfTrips: payload.numberOfTrips,
        numberOfBuses: payload.numberOfBusesNeeded,
        eventType: payload.typeOfEventOrPurpose.trim(),
        additionalNotes: payload.additionalNotesOrSpecialRequest?.trim() || null,
      },
    });

    const whatsappNumber = this.getExecutiveDirectorWhatsAppNumber();
    const whatsappUrl = whatsappNumber
      ? `https://wa.me/${whatsappNumber}?text=${this.buildWhatsAppMessage(record)}`
      : null;

    return {
      ok: true,
      id: record.id,
      status: record.status,
      notice:
        'Thank you for requesting I-Metro Bus Service. Our team will review your request and contact you shortly.',
      whatsappUrl,
    };
  }

  async listAdminRequests() {
    const items = await this.prisma.busHireRequest.findMany({
      orderBy: [{ serviceDate: 'asc' }, { createdAt: 'desc' }],
    });

    return {
      ok: true,
      fleetCapacity: this.getFleetCapacity(),
      items: items.map((item) => ({
        id: item.id,
        title: item.fullNameOrOrg,
        phoneNumber: item.phoneNumber,
        whatsappNumber: item.whatsappNumber,
        email: item.email,
        pickupPoint: item.pickupPoint,
        dropoffPoint: item.dropoffPoint,
        destination: item.destination,
        serviceDate: item.serviceDate,
        serviceTime: item.serviceTime,
        numberOfTrips: item.numberOfTrips,
        numberOfBusesNeeded: item.numberOfBuses,
        eventType: item.eventType,
        additionalNotes: item.additionalNotes,
        status: item.status,
        statusLabel: this.formatStatus(item.status),
        adminComments: item.adminComments,
        assignedBuses: item.assignedBuses,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      })),
    };
  }

  async updateAdminRequest(
    id: string,
    payload: UpdateBusHireRequestDto,
    actorUserId?: string,
    ipAddress?: string,
  ) {
    const updated = await this.prisma.busHireRequest.update({
      where: { id },
      data: {
        ...(payload.status ? { status: payload.status } : {}),
        ...(payload.adminComments !== undefined
          ? { adminComments: payload.adminComments?.trim() || null }
          : {}),
        ...(payload.assignedBuses !== undefined
          ? {
              assignedBuses: payload.assignedBuses
                .map((bus) => bus.trim())
                .filter(Boolean),
            }
          : {}),
      },
    });

    const changeSummary = [
      payload.status ? `status set to ${this.formatStatus(payload.status)}` : null,
      payload.adminComments !== undefined ? 'comments updated' : null,
      payload.assignedBuses !== undefined
        ? `assigned buses: ${
            updated.assignedBuses.length ? updated.assignedBuses.join(', ') : 'cleared'
          }`
        : null,
    ]
      .filter(Boolean)
      .join('; ');

    await this.recordAuditLog({
      actorUserId,
      category: 'Bus Hire',
      action: 'Updated bus hire request',
      details: `${updated.fullNameOrOrg} on ${updated.serviceDate.toISOString().slice(0, 10)} - ${changeSummary || 'request updated'}`,
      entityType: 'BusHireRequest',
      entityId: updated.id,
      ipAddress,
    });

    return {
      ok: true,
      id: updated.id,
      status: updated.status,
      statusLabel: this.formatStatus(updated.status),
      adminComments: updated.adminComments,
      assignedBuses: updated.assignedBuses,
      updatedAt: updated.updatedAt,
    };
  }
}
