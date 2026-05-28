import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { compare, hash } from 'bcryptjs';
import * as nodemailer from 'nodemailer';
import { createHash, randomBytes } from 'crypto';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { CreateAdminDto } from './dto/create-admin.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  async registerUser(payload: RegisterDto) {
    if (!payload.email && !payload.phone) {
      return { ok: false, reason: 'missing_contact' };
    }

    if (payload.email) {
      const exists = await this.prisma.user.findUnique({ where: { email: payload.email } });
      if (exists) {
        return { ok: false, reason: 'email_in_use' };
      }
    }

    if (payload.phone) {
      const exists = await this.prisma.user.findUnique({ where: { phone: payload.phone } });
      if (exists) {
        return { ok: false, reason: 'phone_in_use' };
      }
    }

    const passwordHash = await hash(payload.password, 10);
    const user = await this.prisma.user.create({
      data: {
        email: payload.email ?? null,
        phone: payload.phone ?? null,
        passwordHash,
        firstName: payload.firstName ?? null,
        lastName: payload.lastName ?? null,
        role: 'USER',
      },
    });

    return this.signToken(user.id, user.role);
  }

  async createAdmin(payload: CreateAdminDto) {
    const secret = process.env.ADMIN_BOOTSTRAP_SECRET ?? '';
    if (!secret || payload.bootstrapSecret !== secret) {
      return { ok: false, reason: 'invalid_bootstrap_secret' };
    }

    if (!payload.email && !payload.phone) {
      return { ok: false, reason: 'missing_contact' };
    }

    const role = payload.role ?? 'ADMIN';

    if (payload.email) {
      const exists = await this.prisma.user.findUnique({ where: { email: payload.email } });
      if (exists) {
        return { ok: false, reason: 'email_in_use' };
      }
    }

    if (payload.phone) {
      const exists = await this.prisma.user.findUnique({ where: { phone: payload.phone } });
      if (exists) {
        return { ok: false, reason: 'phone_in_use' };
      }
    }

    const passwordHash = await hash(payload.password, 10);
    const user = await this.prisma.user.create({
      data: {
        email: payload.email ?? null,
        phone: payload.phone ?? null,
        passwordHash,
        firstName: payload.firstName ?? null,
        lastName: payload.lastName ?? null,
        role,
      },
    });

    if (role === 'MERCHANT') {
      await this.prisma.merchant.create({
        data: {
          name: `${payload.firstName ?? ''} ${payload.lastName ?? ''}`.trim() || 'Merchant',
          email: payload.email ?? null,
          phone: payload.phone ?? null,
          userId: user.id,
        },
      });
    }

    return this.signToken(user.id, user.role);
  }

  async login(payload: LoginDto) {
    const login = payload.emailOrPhone;
    const user = await this.prisma.user.findFirst({
      where: {
        OR: [{ email: login }, { phone: login }],
      },
    });

    if (!user || !user.passwordHash) {
      return { ok: false, reason: 'invalid_credentials' };
    }

    const valid = await compare(payload.password, user.passwordHash);
    if (!valid) {
      return { ok: false, reason: 'invalid_credentials' };
    }

    return this.signToken(user.id, user.role);
  }

  async getProfile(userId: string) {
    if (!userId) {
      return { ok: false, reason: 'missing_user' };
    }
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        phone: true,
        firstName: true,
        lastName: true,
        role: true,
        createdAt: true,
      },
    });
    if (!user) {
      return { ok: false, reason: 'user_not_found' };
    }
    return { ok: true, user };
  }

  async updateProfile(userId: string, payload: UpdateProfileDto) {
    if (!userId) {
      return { ok: false, reason: 'missing_user' };
    }

    if (payload.email) {
      const exists = await this.prisma.user.findFirst({
        where: { email: payload.email, NOT: { id: userId } },
      });
      if (exists) {
        return { ok: false, reason: 'email_in_use' };
      }
    }

    if (payload.phone) {
      const exists = await this.prisma.user.findFirst({
        where: { phone: payload.phone, NOT: { id: userId } },
      });
      if (exists) {
        return { ok: false, reason: 'phone_in_use' };
      }
    }

    const user = await this.prisma.user.update({
      where: { id: userId },
      data: {
        firstName: payload.firstName ?? undefined,
        lastName: payload.lastName ?? undefined,
        email: payload.email ?? undefined,
        phone: payload.phone ?? undefined,
      },
      select: {
        id: true,
        email: true,
        phone: true,
        firstName: true,
        lastName: true,
        role: true,
        createdAt: true,
      },
    });

    return { ok: true, user };
  }

  async changePassword(userId: string, payload: ChangePasswordDto) {
    if (!userId) {
      return { ok: false, reason: 'missing_user' };
    }
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user || !user.passwordHash) {
      return { ok: false, reason: 'user_not_found' };
    }

    const valid = await compare(payload.currentPassword, user.passwordHash);
    if (!valid) {
      return { ok: false, reason: 'invalid_current_password' };
    }

    const passwordHash = await hash(payload.newPassword, 10);
    await this.prisma.user.update({
      where: { id: userId },
      data: { passwordHash },
    });

    return { ok: true };
  }

  async requestPasswordReset(payload: ForgotPasswordDto) {
    const email = payload.email.trim().toLowerCase();
    const user = await this.prisma.user.findUnique({
      where: { email },
      select: { id: true, email: true, passwordHash: true, firstName: true },
    });

    if (!user || !user.email || !user.passwordHash) {
      return {
        ok: true,
        message: 'If the email exists, a reset code has been sent.',
      };
    }

    const code = this.generateResetCode();
    const codeHash = this.hashResetCode(code);
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

    await this.prisma.passwordReset.upsert({
      where: { userId: user.id },
      update: {
        codeHash,
        expiresAt,
      },
      create: {
        userId: user.id,
        codeHash,
        expiresAt,
      },
    });

    const sent = await this.sendResetCodeEmail({
      to: user.email,
      name: user.firstName ?? 'I-Metro rider',
      code,
      expiresAt,
    });

    if (!sent.ok) {
      if (process.env.NODE_ENV !== 'production') {
        return {
          ok: false,
          message:
            sent.reason === 'email_not_configured'
              ? 'Reset email is not configured on this server yet.'
              : 'Unable to send the reset email right now.',
          debugCode: code,
        };
      }
      return {
        ok: false,
        reason: sent.reason ?? 'email_delivery_failed',
        message:
          sent.reason === 'email_not_configured'
            ? 'Reset email is not configured on this server yet.'
            : 'Unable to send the reset email right now. Please try again later.',
      };
    }

    return {
      ok: true,
      message: 'If the email exists, a reset code has been sent.',
    };
  }

  async resetPassword(payload: ResetPasswordDto) {
    const email = payload.email.trim().toLowerCase();
    const code = payload.code.trim().toUpperCase();
    const user = await this.prisma.user.findUnique({
      where: { email },
      select: { id: true, email: true, passwordHash: true },
    });

    if (!user || !user.passwordHash) {
      return { ok: false, reason: 'user_not_found' };
    }

    const reset = await this.prisma.passwordReset.findUnique({
      where: { userId: user.id },
    });

    if (!reset) {
      return { ok: false, reason: 'reset_code_not_found' };
    }

    if (reset.expiresAt.getTime() < Date.now()) {
      await this.prisma.passwordReset.deleteMany({ where: { userId: user.id } });
      return { ok: false, reason: 'reset_code_expired' };
    }

    const codeHash = this.hashResetCode(code);
    if (codeHash !== reset.codeHash) {
      return { ok: false, reason: 'invalid_reset_code' };
    }

    const passwordHash = await hash(payload.newPassword, 10);
    await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: user.id },
        data: { passwordHash },
      }),
      this.prisma.passwordReset.deleteMany({ where: { userId: user.id } }),
    ]);

    return { ok: true };
  }

  private signToken(userId: string, role: string) {
    const payload = { sub: userId, role };
    const token = this.jwtService.sign(payload);
    return {
      ok: true,
      accessToken: token,
      userId,
      role,
    };
  }

  private generateResetCode() {
    return randomBytes(4).toString('hex').toUpperCase();
  }

  private hashResetCode(code: string) {
    return createHash('sha256').update(code.trim().toUpperCase()).digest('hex');
  }

  private async sendResetCodeEmail(payload: {
    to: string;
    name: string;
    code: string;
    expiresAt: Date;
  }) {
    const host = process.env.SMTP_HOST?.trim();
    const port = Number(process.env.SMTP_PORT ?? 587);
    const user = process.env.SMTP_USER?.trim();
    const pass = process.env.SMTP_PASS?.trim();
    const from = process.env.SMTP_FROM?.trim() || user;

    if (!host || !port || !user || !pass || !from) {
      return { ok: false, reason: 'email_not_configured' };
    }

    const transport = nodemailer.createTransport({
      host,
      port,
      secure: port === 465,
      auth: {
        user,
        pass,
      },
    });

    try {
      await transport.sendMail({
        from,
        to: payload.to,
        subject: 'I-Metro password reset code',
        text: [
          `Hello ${payload.name},`,
          '',
          `We received a request to reset your I-Metro password.`,
          `Your reset code is: ${payload.code}`,
          '',
          `This code expires at ${payload.expiresAt.toLocaleString()}.`,
          '',
          'If you did not request this, you can safely ignore this email.',
        ].join('\n'),
      });
    } catch {
      return { ok: false, reason: 'email_delivery_failed' };
    }

    return { ok: true };
  }
}
