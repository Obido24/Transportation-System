import { Injectable } from '@nestjs/common';
import nodemailer from 'nodemailer';
import { PrismaService } from '../prisma/prisma.service';
import { CreateSupportMessageDto } from './dto/create-support-message.dto';

@Injectable()
export class SupportService {
  constructor(private readonly prisma: PrismaService) {}

  async createMessage(userId: string, payload: CreateSupportMessageDto) {
    if (!userId) {
      return { ok: false, reason: 'unauthorized' };
    }

    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      return { ok: false, reason: 'user_not_found' };
    }

    const record = await this.prisma.supportMessage.create({
      data: {
        userId,
        name: `${user.firstName ?? ''} ${user.lastName ?? ''}`.trim() || null,
        email: user.email ?? null,
        phone: user.phone ?? null,
        subject: payload.subject,
        message: payload.message,
      },
    });

    const emailResult = await this.sendSupportEmail({
      id: record.id,
      subject: record.subject,
      message: record.message,
      name: record.name,
      email: record.email,
      phone: record.phone,
    });

    return {
      ok: true,
      id: record.id,
      status: record.status,
      notice: 'Complaint delivered to customer service.',
      emailSent: emailResult.ok,
      emailReason: emailResult.ok ? null : emailResult.reason,
    };
  }

  async listMessages(userId: string) {
    if (!userId) {
      return { ok: false, reason: 'unauthorized', items: [] };
    }

    const items = await this.prisma.supportMessage.findMany({
      where: { userId },
      orderBy: [{ updatedAt: 'desc' }, { createdAt: 'desc' }],
      select: {
        id: true,
        subject: true,
        message: true,
        status: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    return { ok: true, items };
  }

  private async sendSupportEmail(payload: {
    id: string;
    subject: string;
    message: string;
    name?: string | null;
    email?: string | null;
    phone?: string | null;
  }) {
    const host = process.env.SMTP_HOST ?? '';
    const port = Number(process.env.SMTP_PORT ?? 0);
    const user = process.env.SMTP_USER ?? '';
    const pass = process.env.SMTP_PASS ?? '';
    const from = process.env.SMTP_FROM ?? 'I-Metro <no-reply@i-metro.com>';
    const to = process.env.SUPPORT_EMAIL_TO ?? '';

    if (!host || !port || !to) {
      return { ok: false, reason: 'missing_email_config' };
    }

    const transporter = nodemailer.createTransport({
      host,
      port,
      secure: port === 465,
      auth: user && pass ? { user, pass } : undefined,
    });

    const subject = `[I-Metro Support] ${payload.subject}`;
    const lines = [
      `Support Ticket: ${payload.id}`,
      `From: ${payload.name ?? 'I-Metro user'}`,
      `Email: ${payload.email ?? 'Not provided'}`,
      `Phone: ${payload.phone ?? 'Not provided'}`,
      '',
      'Message:',
      payload.message,
    ];

    await transporter.sendMail({
      from,
      to,
      subject,
      text: lines.join('\n'),
    });

    return { ok: true };
  }
}
