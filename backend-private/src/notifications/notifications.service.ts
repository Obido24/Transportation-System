import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDeviceDto } from './dto/register-device.dto';
import * as admin from 'firebase-admin';
import { readFileSync } from 'fs';

@Injectable()
export class NotificationsService {
  private fcmReady = false;
  private fcmChecked = false;

  constructor(private readonly prisma: PrismaService) {}

  async registerDevice(userId: string, dto: RegisterDeviceDto) {
    if (!userId) {
      return { ok: false, reason: 'missing_user' };
    }
    const token = dto.token?.trim();
    if (!token) {
      return { ok: false, reason: 'missing_token' };
    }
    const platform = dto.platform?.trim() || 'unknown';

    await this.prisma.pushDevice.upsert({
      where: { token },
      update: { userId, platform, deviceId: dto.deviceId ?? null },
      create: { userId, token, platform, deviceId: dto.deviceId ?? null },
    });

    return { ok: true };
  }

  async unregisterDevice(userId: string, token: string) {
    if (!userId || !token) {
      return { ok: false, reason: 'missing_params' };
    }
    await this.prisma.pushDevice.deleteMany({
      where: { userId, token },
    });
    return { ok: true };
  }

  async sendToUser(userId: string, payload: { title: string; body: string; data?: Record<string, string> }) {
    const devices = await this.prisma.pushDevice.findMany({ where: { userId } });
    if (devices.length == 0) {
      return { ok: false, reason: 'no_devices' };
    }
    if (!this.ensureFcmReady()) {
      return { ok: false, reason: 'fcm_not_configured' };
    }

    const tokens = devices.map((device) => device.token);
    const result = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: { title: payload.title, body: payload.body },
      data: payload.data ?? {},
    });

    return { ok: true, success: result.successCount, failure: result.failureCount };
  }

  private ensureFcmReady() {
    if (this.fcmChecked) {
      return this.fcmReady;
    }
    this.fcmChecked = true;

    try {
      const jsonEnv = process.env.FCM_SERVICE_ACCOUNT_JSON;
      const path = process.env.FCM_SERVICE_ACCOUNT_PATH;

      let serviceAccount: any | null = null;
      if (jsonEnv && jsonEnv.trim().length > 0) {
        serviceAccount = JSON.parse(jsonEnv);
      } else if (path && path.trim().length > 0) {
        const raw = readFileSync(path, 'utf-8');
        serviceAccount = JSON.parse(raw);
      }

      if (!serviceAccount) {
        this.fcmReady = false;
        return false;
      }

      if (admin.apps.length == 0) {
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
        });
      }
      this.fcmReady = true;
    } catch (_) {
      this.fcmReady = false;
    }

    return this.fcmReady;
  }
}
