import { Injectable } from '@nestjs/common';
import { createHmac, randomBytes, timingSafeEqual } from 'crypto';
import { mkdir, appendFile } from 'fs/promises';
import { dirname, join } from 'path';
import { PrismaService } from '../prisma/prisma.service';
import { ValidateQrDto } from './dto/validate-qr.dto';
import { CreateDeviceDto } from './dto/create-device.dto';

type ValidationResult = {
  valid: boolean;
  reason?: string;
  ticketId?: string;
  routeId?: string;
  userId?: string;
  validDate?: string;
  busLabel?: string;
};

@Injectable()
export class ValidatorsService {
  constructor(private readonly prisma: PrismaService) {}
  private readonly validatorLogFile = join(process.cwd(), 'data', 'validator-validation-logs.ndjson');

  async validateQr(payload: ValidateQrDto, apiKey: string): Promise<ValidationResult> {
    if (!apiKey) {
      return { valid: false, reason: 'missing_api_key' };
    }

    const apiKeyHash = this.hashApiKey(apiKey);
    const device = await this.prisma.validatorDevice.findFirst({
      where: { isActive: true, apiKeyHash },
    });

    if (!device) {
      return { valid: false, reason: 'device_not_found' };
    }

    if (!this.verifyApiKey(apiKey, device.apiKeyHash)) {
      return { valid: false, reason: 'invalid_api_key' };
    }

    await this.prisma.validatorDevice.update({
      where: { id: device.id },
      data: { lastSeenAt: new Date() },
    });

    const busLabel = this.cleanLabel(payload.busLabel);
    const qr = (payload.code ?? payload.qr)?.trim();
    if (!qr) {
      return { valid: false, reason: 'missing_qr' };
    }

    if (qr.startsWith('IMT1|')) {
      return this.validateImt1Compact(qr, device.id, busLabel);
    }

    if (qr.startsWith('IMT1.')) {
      return this.validateImt1(qr, device.id, busLabel);
    }

    if (qr.startsWith('POS1.')) {
      await this.prisma.qRValidationLog.create({
        data: {
          rawPayload: qr,
          format: 'POS1',
          isValid: false,
          reason: 'pos_format_not_supported',
          validatorDeviceId: device.id,
        },
      });
      return { valid: false, reason: 'pos_format_not_supported' };
    }

    const looseMatch = await this.validateLooseTicketIdentifier(qr, device.id, busLabel);
    if (looseMatch) {
      return looseMatch;
    }

    await this.prisma.qRValidationLog.create({
      data: {
        rawPayload: qr,
        format: 'UNKNOWN',
        isValid: false,
        reason: 'unknown_format',
        validatorDeviceId: device.id,
      },
    });
    return { valid: false, reason: 'unknown_format' };
  }

  async listDevices() {
    return this.prisma.validatorDevice.findMany({
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        name: true,
        isActive: true,
        lastSeenAt: true,
        createdAt: true,
      },
    });
  }

  async createDevice(payload: CreateDeviceDto) {
    const apiKey = this.generateApiKey();
    const apiKeyHash = this.hashApiKey(apiKey);

    const device = await this.prisma.validatorDevice.create({
      data: {
        name: payload.name,
        apiKeyHash,
      },
    });

    return {
      id: device.id,
      name: device.name,
      apiKey,
    };
  }

  async rotateDeviceKey(deviceId: string) {
    const device = await this.prisma.validatorDevice.findUnique({
      where: { id: deviceId },
    });

    if (!device) {
      return { ok: false, reason: 'device_not_found' };
    }

    const apiKey = this.generateApiKey();
    const apiKeyHash = this.hashApiKey(apiKey);

    await this.prisma.validatorDevice.update({
      where: { id: deviceId },
      data: { apiKeyHash },
    });

    return { ok: true, apiKey };
  }

  private async validateImt1(qr: string, validatorDeviceId: string, busLabel?: string): Promise<ValidationResult> {
    const parts = qr.split('.');
    if (parts.length !== 3) {
      await this.logFailure(qr, 'IMT1', 'malformed', validatorDeviceId, undefined, busLabel);
      return { valid: false, reason: 'malformed' };
    }

    const payloadB64 = parts[1];
    const signatureB64 = parts[2];
    const secret = process.env.QR_SECRET ?? 'dev_qr_secret';
    const expected = createHmac('sha256', secret).update(payloadB64).digest('base64url');

    if (expected !== signatureB64) {
      await this.logFailure(qr, 'IMT1', 'invalid_signature', validatorDeviceId, undefined, busLabel);
      return { valid: false, reason: 'invalid_signature' };
    }

    let decoded: any;
    try {
      const json = Buffer.from(payloadB64, 'base64url').toString('utf8');
      decoded = JSON.parse(json);
    } catch {
      await this.logFailure(qr, 'IMT1', 'invalid_payload', validatorDeviceId, undefined, busLabel);
      return { valid: false, reason: 'invalid_payload' };
    }

    if (decoded?.typ !== 'ticket' || decoded?.v !== 1) {
      await this.logFailure(qr, 'IMT1', 'invalid_payload', validatorDeviceId, undefined, busLabel);
      return { valid: false, reason: 'invalid_payload' };
    }

    const ticketId = decoded.ticketId as string | undefined;
    if (!ticketId) {
      await this.logFailure(qr, 'IMT1', 'missing_ticket', validatorDeviceId, undefined, busLabel);
      return { valid: false, reason: 'missing_ticket' };
    }

    const ticket = await this.prisma.ticket.findUnique({
      where: { id: ticketId },
    });

    if (!ticket) {
      await this.logFailure(qr, 'IMT1', 'ticket_not_found', validatorDeviceId, undefined, busLabel);
      return { valid: false, reason: 'ticket_not_found' };
    }

    if (ticket.usedAt) {
      await this.logFailure(qr, 'IMT1', 'already_used', validatorDeviceId, ticket.id, busLabel);
      return { valid: false, reason: 'already_used', ticketId: ticket.id, busLabel };
    }

    if (ticket.revokedAt) {
      await this.logFailure(qr, 'IMT1', 'revoked', validatorDeviceId, ticket.id, busLabel);
      return { valid: false, reason: 'revoked', ticketId: ticket.id, busLabel };
    }

    const validDate = ticket.validDate;
    const now = new Date();
    if (now.toDateString() !== validDate.toDateString()) {
      await this.logFailure(qr, 'IMT1', 'expired', validatorDeviceId, ticket.id, busLabel);
      return { valid: false, reason: 'expired', ticketId: ticket.id, busLabel };
    }

    await this.prisma.$transaction(async (tx) => {
      const fresh = await tx.ticket.findUnique({ where: { id: ticket.id } });
      if (!fresh || fresh.usedAt) {
        throw new Error('Ticket already used');
      }
      await tx.ticket.update({
        where: { id: ticket.id },
        data: { usedAt: new Date() },
      });
      await tx.qRValidationLog.create({
        data: {
          rawPayload: qr,
          format: 'IMT1',
          isValid: true,
          ticketId: ticket.id,
          validatorDeviceId,
        },
      });
    });

    await this.appendValidatorTrace({
      rawPayload: qr,
      format: 'IMT1',
      isValid: true,
      ticketId: ticket.id,
      validatorDeviceId,
      busLabel,
      routeId: ticket.routeId,
      userId: ticket.userId,
    });

    return {
      valid: true,
      ticketId: ticket.id,
      routeId: ticket.routeId,
      userId: ticket.userId,
      validDate: ticket.validDate.toISOString(),
      busLabel,
    };
  }

  private async validateImt1Compact(qr: string, validatorDeviceId: string, busLabel?: string): Promise<ValidationResult> {
    const parts = qr.split('|');
    if (parts.length < 5 || parts[0] !== 'IMT1') {
      await this.logFailure(qr, 'IMT1', 'malformed', validatorDeviceId, undefined, busLabel);
      return { valid: false, reason: 'malformed' };
    }

    const values: Record<string, string> = {};
    parts.slice(1).forEach((part) => {
      const [key, ...rest] = part.split('=');
      if (!key || rest.length === 0) return;
      values[key] = rest.join('=');
    });

    const ticketId = values.t;
    const expiry = values.e;
    const nonce = values.n;
    const signature = values.s;

    if (!ticketId || !expiry || !nonce || !signature) {
      await this.logFailure(qr, 'IMT1', 'missing_fields', validatorDeviceId, undefined, busLabel);
      return { valid: false, reason: 'missing_fields' };
    }

    const unsigned = `t=${ticketId}|e=${expiry}|n=${nonce}`;
    const secret = process.env.QR_SECRET ?? 'dev_qr_secret';
    const expected = createHmac('sha256', secret).update(unsigned).digest('base64url');
    try {
      if (!timingSafeEqual(Buffer.from(expected), Buffer.from(signature))) {
        await this.logFailure(qr, 'IMT1', 'invalid_signature', validatorDeviceId, undefined, busLabel);
        return { valid: false, reason: 'invalid_signature' };
      }
    } catch {
      await this.logFailure(qr, 'IMT1', 'invalid_signature', validatorDeviceId, undefined, busLabel);
      return { valid: false, reason: 'invalid_signature' };
    }

    const expDate = this.parseCompactDate(expiry);
    if (!expDate) {
      await this.logFailure(qr, 'IMT1', 'invalid_payload', validatorDeviceId, undefined, busLabel);
      return { valid: false, reason: 'invalid_payload' };
    }

    const ticket = await this.prisma.ticket.findUnique({
      where: { id: ticketId },
    });

    if (!ticket) {
      await this.logFailure(qr, 'IMT1', 'ticket_not_found', validatorDeviceId, undefined, busLabel);
      return { valid: false, reason: 'ticket_not_found' };
    }

    if (ticket.usedAt) {
      await this.logFailure(qr, 'IMT1', 'already_used', validatorDeviceId, ticket.id, busLabel);
      return { valid: false, reason: 'already_used', ticketId: ticket.id, busLabel };
    }

    if (ticket.revokedAt) {
      await this.logFailure(qr, 'IMT1', 'revoked', validatorDeviceId, ticket.id, busLabel);
      return { valid: false, reason: 'revoked', ticketId: ticket.id, busLabel };
    }

    const now = new Date();
    if (!this.isSameDay(now, expDate) || !this.isSameDay(now, ticket.validDate)) {
      await this.logFailure(qr, 'IMT1', 'expired', validatorDeviceId, ticket.id, busLabel);
      return { valid: false, reason: 'expired', ticketId: ticket.id, busLabel };
    }

    await this.prisma.$transaction(async (tx) => {
      const fresh = await tx.ticket.findUnique({ where: { id: ticket.id } });
      if (!fresh || fresh.usedAt) {
        throw new Error('Ticket already used');
      }
      await tx.ticket.update({
        where: { id: ticket.id },
        data: { usedAt: new Date() },
      });
      await tx.qRValidationLog.create({
        data: {
          rawPayload: qr,
          format: 'IMT1',
          isValid: true,
          ticketId: ticket.id,
          validatorDeviceId,
        },
      });
    });

    await this.appendValidatorTrace({
      rawPayload: qr,
      format: 'IMT1',
      isValid: true,
      ticketId: ticket.id,
      validatorDeviceId,
      busLabel,
      routeId: ticket.routeId,
      userId: ticket.userId,
    });

    return {
      valid: true,
      ticketId: ticket.id,
      routeId: ticket.routeId,
      userId: ticket.userId,
      validDate: ticket.validDate.toISOString(),
      busLabel,
    };
  }

  private async validateLooseTicketIdentifier(qr: string, validatorDeviceId: string, busLabel?: string): Promise<ValidationResult | null> {
    if (this.looksLikeUuid(qr)) {
      const ticket = await this.prisma.ticket.findUnique({
        where: { id: qr },
      });
      if (ticket) {
        return this.validateLooseTicketRecord(qr, 'TICKET_ID', validatorDeviceId, ticket, busLabel);
      }
    }

    const payment = await this.prisma.payment.findFirst({
      where: { providerRef: qr },
      include: {
        booking: {
          include: {
            ticket: true,
          },
        },
      },
    });

    if (payment?.booking?.ticket) {
      return this.validateLooseTicketRecord(qr, 'PAYMENT_REF', validatorDeviceId, payment.booking.ticket, busLabel);
    }

    return null;
  }

  private async validateLooseTicketRecord(
    qr: string,
    format: string,
    validatorDeviceId: string,
    ticket: {
      id: string;
      routeId: string;
      userId: string;
      validDate: Date;
      usedAt: Date | null;
      revokedAt: Date | null;
    },
    busLabel?: string,
  ): Promise<ValidationResult> {
    if (ticket.usedAt) {
      await this.logFailure(qr, format, 'already_used', validatorDeviceId, ticket.id, busLabel);
      return { valid: false, reason: 'already_used', ticketId: ticket.id, busLabel };
    }

    if (ticket.revokedAt) {
      await this.logFailure(qr, format, 'revoked', validatorDeviceId, ticket.id, busLabel);
      return { valid: false, reason: 'revoked', ticketId: ticket.id, busLabel };
    }

    const now = new Date();
    if (now.toDateString() !== ticket.validDate.toDateString()) {
      await this.logFailure(qr, format, 'expired', validatorDeviceId, ticket.id, busLabel);
      return { valid: false, reason: 'expired', ticketId: ticket.id, busLabel };
    }

    await this.prisma.$transaction(async (tx) => {
      const fresh = await tx.ticket.findUnique({ where: { id: ticket.id } });
      if (!fresh || fresh.usedAt) {
        throw new Error('Ticket already used');
      }
      await tx.ticket.update({
        where: { id: ticket.id },
        data: { usedAt: new Date() },
      });
      await tx.qRValidationLog.create({
        data: {
          rawPayload: qr,
          format,
          isValid: true,
          ticketId: ticket.id,
          validatorDeviceId,
        },
      });
    });

    await this.appendValidatorTrace({
      rawPayload: qr,
      format: 'IMT1',
      isValid: true,
      ticketId: ticket.id,
      validatorDeviceId,
      busLabel,
      routeId: ticket.routeId,
      userId: ticket.userId,
    });

    return {
      valid: true,
      ticketId: ticket.id,
      routeId: ticket.routeId,
      userId: ticket.userId,
      validDate: ticket.validDate.toISOString(),
      busLabel,
    };
  }

  private looksLikeUuid(value: string) {
    return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value);
  }

  private parseCompactDate(value: string) {
    if (!/^\d{8}$/.test(value)) return null;
    const year = Number(value.slice(0, 4));
    const month = Number(value.slice(4, 6));
    const day = Number(value.slice(6, 8));
    if (!year || !month || !day) return null;
    return new Date(year, month - 1, day);
  }

  private isSameDay(a: Date, b: Date) {
    return (
      a.getFullYear() === b.getFullYear() &&
      a.getMonth() === b.getMonth() &&
      a.getDate() === b.getDate()
    );
  }

  private async logFailure(qr: string, format: string, reason: string, validatorDeviceId: string, ticketId?: string, busLabel?: string) {
    await this.prisma.qRValidationLog.create({
      data: {
        rawPayload: qr,
        format,
        isValid: false,
        reason,
        ticketId,
        validatorDeviceId,
      },
    });
    await this.appendValidatorTrace({
      rawPayload: qr,
      format,
      isValid: false,
      reason,
      ticketId,
      validatorDeviceId,
      busLabel,
    });
  }

  private cleanLabel(value?: string | null) {
    const trimmed = value?.trim();
    return trimmed ? trimmed.slice(0, 80) : undefined;
  }

  private async appendValidatorTrace(entry: {
    rawPayload: string;
    format: string;
    isValid: boolean;
    reason?: string;
    ticketId?: string;
    validatorDeviceId?: string;
    busLabel?: string;
    routeId?: string;
    userId?: string;
  }) {
    const dir = dirname(this.validatorLogFile);
    await mkdir(dir, { recursive: true });
    await appendFile(
      this.validatorLogFile,
      `${JSON.stringify({
        ...entry,
        createdAt: new Date().toISOString(),
      })}\n`,
      'utf8',
    );
  }

  private generateApiKey() {
    return `vk_${randomBytes(24).toString('hex')}`;
  }

  private hashApiKey(apiKey: string) {
    const secret = process.env.VALIDATOR_KEY_SECRET ?? 'dev_validator_secret';
    return createHmac('sha256', secret).update(apiKey).digest('hex');
  }

  private verifyApiKey(apiKey: string, hash: string) {
    const computed = this.hashApiKey(apiKey);
    try {
      return timingSafeEqual(Buffer.from(computed), Buffer.from(hash));
    } catch {
      return false;
    }
  }
}
