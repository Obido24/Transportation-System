import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateAnnouncementDto } from './dto/create-announcement.dto';
import { UpdateAnnouncementDto } from './dto/update-announcement.dto';

@Injectable()
export class AnnouncementsService {
  constructor(private readonly prisma: PrismaService) {}

  private parseDate(value?: string | null) {
    if (!value) return null;
    const parsed = new Date(value);
    if (Number.isNaN(parsed.getTime())) {
      throw new BadRequestException('Invalid announcement date.');
    }
    return parsed;
  }

  private ensureDateRange(startsAt: Date | null, expiresAt: Date | null) {
    if (startsAt && expiresAt && expiresAt <= startsAt) {
      throw new BadRequestException('Announcement expiry must be later than the start time.');
    }
  }

  private createAuditLog(
    action: string,
    details: string,
    entityId: string,
    actorUserId?: string,
    ipAddress?: string,
  ) {
    return this.prisma.auditLog.create({
      data: {
        actorUserId,
        actorName: actorUserId ? 'I-Metro Admin' : 'System',
        actorRole: 'ADMIN',
        category: 'ANNOUNCEMENTS',
        action,
        details,
        entityType: 'Announcement',
        entityId,
        ipAddress,
      },
    });
  }

  async listActiveAnnouncements() {
    const now = new Date();
    return this.prisma.announcement.findMany({
      where: {
        isActive: true,
        OR: [{ startsAt: null }, { startsAt: { lte: now } }],
        AND: [{ OR: [{ expiresAt: null }, { expiresAt: { gt: now } }] }],
      },
      orderBy: [{ isPinned: 'desc' }, { createdAt: 'desc' }],
    });
  }

  async listAdminAnnouncements() {
    return this.prisma.announcement.findMany({
      orderBy: [{ isPinned: 'desc' }, { createdAt: 'desc' }],
    });
  }

  async createAnnouncement(
    payload: CreateAnnouncementDto,
    actorUserId?: string,
    ipAddress?: string,
  ) {
    const startsAt = this.parseDate(payload.startsAt);
    const expiresAt = this.parseDate(payload.expiresAt);
    this.ensureDateRange(startsAt, expiresAt);

    const announcement = await this.prisma.announcement.create({
      data: {
        title: payload.title.trim(),
        body: payload.body.trim(),
        isActive: payload.isActive ?? true,
        isPinned: payload.isPinned ?? false,
        startsAt,
        expiresAt,
        createdByUserId: actorUserId,
      },
    });

    await this.createAuditLog(
      'Create announcement',
      `Created announcement "${announcement.title}"`,
      announcement.id,
      actorUserId,
      ipAddress,
    );

    return announcement;
  }

  async updateAnnouncement(
    id: string,
    payload: UpdateAnnouncementDto,
    actorUserId?: string,
    ipAddress?: string,
  ) {
    const existing = await this.prisma.announcement.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException('Announcement not found.');
    }

    const startsAt =
      payload.startsAt === undefined ? existing.startsAt : this.parseDate(payload.startsAt);
    const expiresAt =
      payload.expiresAt === undefined ? existing.expiresAt : this.parseDate(payload.expiresAt);
    this.ensureDateRange(startsAt, expiresAt);

    const announcement = await this.prisma.announcement.update({
      where: { id },
      data: {
        title: payload.title?.trim(),
        body: payload.body?.trim(),
        isActive: payload.isActive,
        isPinned: payload.isPinned,
        startsAt,
        expiresAt,
      },
    });

    await this.createAuditLog(
      'Update announcement',
      `Updated announcement "${announcement.title}"`,
      announcement.id,
      actorUserId,
      ipAddress,
    );

    return announcement;
  }

  async deleteAnnouncement(id: string, actorUserId?: string, ipAddress?: string) {
    const existing = await this.prisma.announcement.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException('Announcement not found.');
    }

    await this.prisma.announcement.delete({ where: { id } });
    await this.createAuditLog(
      'Delete announcement',
      `Deleted announcement "${existing.title}"`,
      existing.id,
      actorUserId,
      ipAddress,
    );

    return { ok: true };
  }
}
