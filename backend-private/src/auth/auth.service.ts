import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { compare, hash } from 'bcryptjs';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { CreateAdminDto } from './dto/create-admin.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { ChangePasswordDto } from './dto/change-password.dto';

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
}
