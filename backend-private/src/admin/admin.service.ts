import { Injectable } from '@nestjs/common';
import { randomBytes, randomUUID } from 'crypto';
import { SupportStatus } from '@prisma/client';
import { mkdir, readFile, writeFile } from 'fs/promises';
import { dirname, join } from 'path';
import { PrismaService } from '../prisma/prisma.service';
import { CreateRouteDto } from '../routes/dto/create-route.dto';
import { UpdateRouteDto } from '../routes/dto/update-route.dto';

const SYSTEM_SETTINGS_FILE = join(process.cwd(), 'data', 'system-settings.json');
const BRAND_LOGO_FILE = join(process.cwd(), 'assets', 'brand', 'imetro_logo.png');
const VALIDATOR_LOG_FILE = join(process.cwd(), 'data', 'validator-validation-logs.ndjson');

type SystemSettingsNotifications = {
  emailAdminAlerts: boolean;
  slackIntegration: boolean;
  smsCriticalDelays: boolean;
  pushNotifications: boolean;
};

type SystemSettingsBranding = {
  primaryColor: string;
  logoHint: string;
  logoFileName: string;
  logoDataUrl: string;
};

type SystemSettingsRecord = {
  platformName: string;
  timezone: string;
  maintenanceMode: boolean;
  baseFareMultiplier: number;
  peakStrategy: string;
  apiKey: string;
  webhookUrl: string;
  notifications: SystemSettingsNotifications;
  branding: SystemSettingsBranding;
  lastModified: string;
  lastModifiedAt: string;
  lastModifiedBy: string;
  apiKeysRevokedAt: string | null;
};

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  private async loadDefaultBrandLogoDataUrl() {
    try {
      const buffer = await readFile(BRAND_LOGO_FILE);
      return `data:image/png;base64,${buffer.toString('base64')}`;
    } catch {
      return '';
    }
  }

  private async applyDefaultBrandLogo(settings: SystemSettingsRecord) {
    const defaultLogoDataUrl = await this.loadDefaultBrandLogoDataUrl();
    const logoDataUrl = settings.branding.logoDataUrl?.trim() || defaultLogoDataUrl;
    return {
      ...settings,
      branding: {
        ...settings.branding,
        logoHint: settings.branding.logoHint || 'I-Metro logo (PNG)',
        logoFileName: settings.branding.logoFileName || 'Logo_I-Metro.png',
        logoDataUrl,
      },
    };
  }

  private createDefaultSystemSettings(): SystemSettingsRecord {
    return {
      platformName: 'Inter-Metro Transport Solution Limited',
      timezone: 'UTC (Coordinated Universal Time)',
      maintenanceMode: false,
      baseFareMultiplier: 1.2,
      peakStrategy: 'Dynamic',
      apiKey: `vk_${randomBytes(24).toString('base64url')}`,
      webhookUrl: '',
      notifications: {
        emailAdminAlerts: true,
        slackIntegration: false,
        smsCriticalDelays: true,
        pushNotifications: true,
      },
      branding: {
        primaryColor: '#00513F',
        logoHint: 'I-Metro logo (PNG)',
        logoFileName: 'Logo_I-Metro.png',
        logoDataUrl: '',
      },
      lastModified: 'Last modified by I-Metro Admin',
      lastModifiedAt: new Date().toISOString(),
      lastModifiedBy: 'I-Metro Admin',
      apiKeysRevokedAt: null,
    };
  }

  private normalizeSystemSettings(
    settings: Partial<SystemSettingsRecord> & {
      notifications?: Partial<SystemSettingsNotifications>;
      branding?: Partial<SystemSettingsBranding>;
    },
  ): SystemSettingsRecord {
    const defaults = this.createDefaultSystemSettings();
    return {
      platformName: settings.platformName ?? defaults.platformName,
      timezone: settings.timezone ?? defaults.timezone,
      maintenanceMode: settings.maintenanceMode ?? defaults.maintenanceMode,
      baseFareMultiplier:
        typeof settings.baseFareMultiplier === 'number' && !Number.isNaN(settings.baseFareMultiplier)
          ? settings.baseFareMultiplier
          : defaults.baseFareMultiplier,
      peakStrategy: settings.peakStrategy ?? defaults.peakStrategy,
      apiKey: settings.apiKey ?? defaults.apiKey,
      webhookUrl: settings.webhookUrl ?? defaults.webhookUrl,
      notifications: {
        emailAdminAlerts: settings.notifications?.emailAdminAlerts ?? defaults.notifications.emailAdminAlerts,
        slackIntegration: settings.notifications?.slackIntegration ?? defaults.notifications.slackIntegration,
        smsCriticalDelays: settings.notifications?.smsCriticalDelays ?? defaults.notifications.smsCriticalDelays,
        pushNotifications: settings.notifications?.pushNotifications ?? defaults.notifications.pushNotifications,
      },
      branding: {
        primaryColor: settings.branding?.primaryColor ?? defaults.branding.primaryColor,
        logoHint: settings.branding?.logoHint ?? defaults.branding.logoHint,
        logoFileName: settings.branding?.logoFileName ?? defaults.branding.logoFileName,
        logoDataUrl: settings.branding?.logoDataUrl ?? defaults.branding.logoDataUrl,
      },
      lastModified: settings.lastModified ?? defaults.lastModified,
      lastModifiedAt: settings.lastModifiedAt ?? defaults.lastModifiedAt,
      lastModifiedBy: settings.lastModifiedBy ?? defaults.lastModifiedBy,
      apiKeysRevokedAt: settings.apiKeysRevokedAt ?? defaults.apiKeysRevokedAt,
    };
  }

  private async readSystemSettingsFile() {
    try {
      const raw = await readFile(SYSTEM_SETTINGS_FILE, 'utf8');
      const parsed = JSON.parse(raw) as Partial<SystemSettingsRecord>;
      return this.applyDefaultBrandLogo(this.normalizeSystemSettings(parsed));
    } catch (error: any) {
      if (error?.code === 'ENOENT') {
        const defaults = this.createDefaultSystemSettings();
        await mkdir(dirname(SYSTEM_SETTINGS_FILE), { recursive: true });
        const next = await this.applyDefaultBrandLogo(defaults);
        await writeFile(SYSTEM_SETTINGS_FILE, JSON.stringify(next, null, 2), 'utf8');
        return next;
      }
      throw error;
    }
  }

  private async writeSystemSettingsFile(settings: SystemSettingsRecord) {
    await mkdir(dirname(SYSTEM_SETTINGS_FILE), { recursive: true });
    await writeFile(SYSTEM_SETTINGS_FILE, JSON.stringify(settings, null, 2), 'utf8');
  }

  private maskApiKey(apiKey: string) {
    if (!apiKey) {
      return '';
    }
    if (apiKey.length <= 8) {
      return '********';
    }
    return `${apiKey.slice(0, 4)}${'*'.repeat(Math.max(4, apiKey.length - 8))}${apiKey.slice(-4)}`;
  }

  private isDemoUser(user: {
    role: string;
    email?: string | null;
    firstName?: string | null;
    lastName?: string | null;
  }) {
    if (user.role !== 'USER') {
      return true;
    }

    const email = (user.email ?? '').trim().toLowerCase();
    const fullName = `${user.firstName ?? ''} ${user.lastName ?? ''}`.trim().toLowerCase();

    if (!email) {
      return false;
    }

    return (
      email === 'test@i-metro.local' ||
      email.endsWith('.local') ||
      email.startsWith('demo') ||
      email.includes('demo') ||
      fullName === 'test user'
    );
  }

  private filterRealUsers<T extends { role: string; email?: string | null; firstName?: string | null; lastName?: string | null }>(
    users: T[],
  ) {
    return users.filter((user) => !this.isDemoUser(user));
  }

  private isVisiblePassengerBooking(booking: {
    user?: { role: string; email?: string | null; firstName?: string | null; lastName?: string | null } | null;
  }) {
    return !!booking.user && !this.isDemoUser(booking.user);
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

  private normalizeSearch(value: unknown) {
    return String(value ?? '').toLowerCase().trim();
  }

  private scoreSearch(candidate: unknown, query: string) {
    const haystack = this.normalizeSearch(candidate);
    const needle = this.normalizeSearch(query);
    if (!haystack || !needle) return 0;
    if (haystack === needle) return 100;
    if (haystack.startsWith(needle)) return 80;
    if (haystack.includes(needle)) return 60;
    const parts = needle.split(/\s+/).filter(Boolean);
    return parts.every((part) => haystack.includes(part)) ? 40 : 0;
  }

  private buildSearchResult(payload: {
    key: string;
    category: string;
    label: string;
    subtitle: string;
    path: string;
    score: number;
  }) {
    return payload;
  }

  async search(query: string) {
    const q = query.trim();
    if (q.length < 2) {
      return [];
    }

    const [users, merchants, routes, payments, tickets, bookings, auditLogs, settings] = await Promise.all([
      this.listUsers(),
      this.listMerchants(),
      this.listRoutes(),
      this.listPayments(),
      this.listSupportTickets(),
      this.listBookings(),
      this.listAuditLogs(),
      this.getSystemSettings(),
    ]);

    const results = [
      ...[
        {
          key: 'page-dashboard',
          category: 'Page',
          label: 'Dashboard',
          subtitle: 'Dashboard overview',
          path: '/admin/dashboard',
        },
        {
          key: 'page-users',
          category: 'Page',
          label: 'User Management',
          subtitle: 'Manage passengers',
          path: '/admin/users',
        },
        {
          key: 'page-merchants',
          category: 'Page',
          label: 'Merchant Management',
          subtitle: 'Manage operators and partners',
          path: '/admin/merchants',
        },
        {
          key: 'page-routes',
          category: 'Page',
          label: 'Route Management',
          subtitle: 'Manage transit routes',
          path: '/admin/routes',
        },
        {
          key: 'page-revenue',
          category: 'Page',
          label: 'Revenue',
          subtitle: 'Review payments and totals',
          path: '/admin/revenue',
        },
        {
          key: 'page-settings',
          category: 'Page',
          label: 'Settings',
          subtitle: 'Configure system rules',
          path: '/admin/settings',
        },
        {
          key: 'page-activity',
          category: 'Page',
          label: 'Activity',
          subtitle: 'Review audit logs',
          path: '/admin/activity',
        },
        {
          key: 'page-support',
          category: 'Page',
          label: 'Support',
          subtitle: 'Handle support tickets',
          path: '/admin/support',
        },
        {
          key: 'page-validator-logs',
          category: 'Page',
          label: 'Bus Scan Logs',
          subtitle: 'Track validator scans by bus',
          path: '/admin/validator-logs',
        },
      ]
        .map((page) => ({
          ...page,
          score:
            this.scoreSearch(page.label, q) +
            this.scoreSearch(page.subtitle, q) +
            this.scoreSearch(page.path, q),
        }))
        .filter((item) => item.score > 0),
      ...users
        .map((user) => {
          const name = `${user.firstName ?? ''} ${user.lastName ?? ''}`.trim() || user.email || user.phone || 'Unknown user';
          return this.buildSearchResult({
            key: `user-${user.id}`,
            category: 'User',
            label: name,
            subtitle: `${user.email ?? user.phone ?? user.id}`,
            path: `/admin/user-details?id=${user.id}`,
            score:
              this.scoreSearch(name, q) +
              this.scoreSearch(user.email, q) +
              this.scoreSearch(user.phone, q),
          });
        })
        .filter((item) => item.score > 0),
      ...merchants
        .map((merchant) =>
          this.buildSearchResult({
            key: `merchant-${merchant.id}`,
            category: 'Merchant',
            label: merchant.name ?? 'Merchant',
            subtitle: `${merchant.email ?? merchant.phone ?? merchant.id}`,
            path: `/admin/merchant-details?id=${merchant.id}`,
            score:
              this.scoreSearch(merchant.name, q) +
              this.scoreSearch(merchant.email, q) +
              this.scoreSearch(merchant.phone, q),
          }),
        )
        .filter((item) => item.score > 0),
      ...routes
        .map((route) => {
          const routeName = `${route.fromLocation} -> ${route.toLocation}`;
          return this.buildSearchResult({
            key: `route-${route.id}`,
            category: 'Route',
            label: routeName,
            subtitle: route.id,
            path: `/admin/routes/edit?id=${route.id}`,
            score:
              this.scoreSearch(routeName, q) +
              this.scoreSearch(route.fromLocation, q) +
              this.scoreSearch(route.toLocation, q) +
              this.scoreSearch(route.id, q),
          });
        })
        .filter((item) => item.score > 0),
      ...payments
        .map((payment) => {
          const bookingRoute = payment.booking?.route
            ? `${payment.booking.route.fromLocation} -> ${payment.booking.route.toLocation}`
            : 'Payment';
          return this.buildSearchResult({
            key: `payment-${payment.id}`,
            category: 'Payment',
            label: `${bookingRoute} (${(payment.status ?? 'PENDING').toUpperCase()})`,
            subtitle: `${payment.provider ?? 'Unknown provider'} ? ${payment.providerRef ?? payment.id}`,
            path: '/admin/revenue',
            score:
              this.scoreSearch(payment.providerRef, q) +
              this.scoreSearch(payment.id, q) +
              this.scoreSearch(payment.status, q) +
              this.scoreSearch(bookingRoute, q),
          });
        })
        .filter((item) => item.score > 0),
      ...tickets
        .map((ticket) =>
          this.buildSearchResult({
            key: `ticket-${ticket.supportId ?? ticket.id}`,
            category: 'Support',
            label: ticket.subject ?? 'Support ticket',
            subtitle: `${ticket.supportStatus ?? 'Open'} ? ${ticket.supportId ?? ticket.id}`,
            path: '/admin/support',
            score:
              this.scoreSearch(ticket.subject, q) +
              this.scoreSearch(ticket.supportStatus, q) +
              this.scoreSearch(ticket.supportId, q) +
              this.scoreSearch(ticket.id, q),
          }),
        )
        .filter((item) => item.score > 0),
      ...bookings
        .map((booking) => {
          const routeName = booking.route ? `${booking.route.fromLocation} -> ${booking.route.toLocation}` : 'Booking';
          const userName =
            [booking.user?.firstName, booking.user?.lastName].filter(Boolean).join(' ').trim() ||
            booking.user?.email ||
            booking.user?.phone ||
            'Unnamed rider';
          return this.buildSearchResult({
            key: `booking-${booking.id}`,
            category: 'Booking',
            label: `${routeName} ? ${booking.id.substring(0, 8).toUpperCase()}`,
            subtitle: `${userName} ? ${booking.status ?? 'BOOKED'}`,
            path: '/admin/revenue',
            score:
              this.scoreSearch(booking.id, q) +
              this.scoreSearch(routeName, q) +
              this.scoreSearch(userName, q) +
              this.scoreSearch(booking.status, q),
          });
        })
        .filter((item) => item.score > 0),
      ...auditLogs
        .map((log) =>
          this.buildSearchResult({
            key: `audit-${log.entityId ?? `${log.category}-${log.action}-${log.createdAt.toISOString()}`}`,
            category: 'Activity',
            label: `${log.category} ? ${log.action}`,
            subtitle: `${log.name} ? ${log.details}`,
            path: '/admin/activity',
            score:
              this.scoreSearch(log.category, q) +
              this.scoreSearch(log.action, q) +
              this.scoreSearch(log.details, q) +
              this.scoreSearch(log.name, q),
          }),
        )
        .filter((item) => item.score > 0),
      this.buildSearchResult({
        key: 'system-settings',
        category: 'Settings',
        label: 'System Settings',
        subtitle: `${settings.platformName} ? ${settings.timezone}`,
        path: '/admin/settings',
        score:
          this.scoreSearch(settings.platformName, q) +
          this.scoreSearch(settings.timezone, q) +
          this.scoreSearch(settings.webhookUrl, q) +
          this.scoreSearch(settings.branding?.logoFileName, q) +
          this.scoreSearch(settings.branding?.logoHint, q),
      }),
    ]
      .filter((item) => item.score > 0)
      .sort((a, b) => b.score - a.score)
      .slice(0, 12);

    return results;
  }

  async createRoute(payload: CreateRouteDto, actorUserId?: string, ipAddress?: string) {
    const route = await this.prisma.route.create({
      data: {
        fromLocation: payload.fromLocation,
        toLocation: payload.toLocation,
        price: payload.price,
        currency: payload.currency ?? 'NGN',
        isActive: payload.isActive ?? true,
      },
    });
    await this.recordAuditLog({
      actorUserId,
      category: 'Route',
      action: 'Created route',
      details: `${payload.fromLocation} -> ${payload.toLocation} (${payload.currency ?? 'NGN'} ${payload.price})`,
      entityType: 'Route',
      entityId: route.id,
      ipAddress,
    });
    return route;
  }

  async updateRoute(id: string, payload: UpdateRouteDto, actorUserId?: string, ipAddress?: string) {
    const route = await this.prisma.route.update({
      where: { id },
      data: {
        ...(payload.fromLocation ? { fromLocation: payload.fromLocation } : {}),
        ...(payload.toLocation ? { toLocation: payload.toLocation } : {}),
        ...(payload.price !== undefined ? { price: payload.price } : {}),
        ...(payload.currency ? { currency: payload.currency } : {}),
        ...(payload.isActive !== undefined ? { isActive: payload.isActive } : {}),
      },
    });
    await this.recordAuditLog({
      actorUserId,
      category: 'Route',
      action: 'Updated route',
      details: `Updated route ${id}`,
      entityType: 'Route',
      entityId: route.id,
      ipAddress,
    });
    return route;
  }

  async deleteRoute(id: string, actorUserId?: string, ipAddress?: string) {
    const route = await this.prisma.route.update({
      where: { id },
      data: { isActive: false },
    });
    await this.recordAuditLog({
      actorUserId,
      category: 'Route',
      action: 'Deactivated route',
      details: `Deactivated route ${route.fromLocation} -> ${route.toLocation}`,
      entityType: 'Route',
      entityId: route.id,
      ipAddress,
    });
    return route;
  }

  async listRoutes() {
    return this.prisma.route.findMany({
      orderBy: [{ fromLocation: 'asc' }, { toLocation: 'asc' }],
    });
  }

  async listUsers() {
    const users = await this.prisma.user.findMany({
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        email: true,
        phone: true,
        firstName: true,
        lastName: true,
        role: true,
        isActive: true,
        createdAt: true,
      },
    });

    return this.filterRealUsers(users);
  }

  getUser(id: string) {
    return this.prisma.user.findUnique({
      where: { id },
      include: {
        bookings: { include: { route: true, payment: true, ticket: true } },
        tickets: true,
      },
    });
  }

  listMerchants() {
    return this.prisma.merchant.findMany({
      orderBy: { createdAt: 'desc' },
    });
  }

  getMerchant(id: string) {
    return this.prisma.merchant.findUnique({
      where: { id },
      include: {
        user: true,
      },
    });
  }

  async updateMerchantStatus(
    id: string,
    isActive: boolean,
    actorUserId?: string,
    ipAddress?: string,
  ) {
    const merchant = await this.prisma.merchant.update({
      where: { id },
      data: { isActive },
      select: {
        id: true,
        isActive: true,
        updatedAt: true,
      },
    });
    await this.recordAuditLog({
      actorUserId,
      category: 'Merchant',
      action: isActive ? 'Activated merchant' : 'Deactivated merchant',
      details: `Merchant ${id} set to ${isActive ? 'active' : 'inactive'}`,
      entityType: 'Merchant',
      entityId: merchant.id,
      ipAddress,
    });
    return merchant;
  }

  listBookings() {
    return this.prisma.booking.findMany({
      orderBy: { createdAt: 'desc' },
      include: {
        user: true,
        route: true,
        payment: true,
        ticket: true,
      },
    }).then((bookings) => bookings.filter((booking) => this.isVisiblePassengerBooking(booking)));
  }

  async getDashboardSummary() {
    const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const [
      totalRoutes,
      activeRoutes,
      bookings,
      payments,
    ] = await Promise.all([
      this.prisma.route.count(),
      this.prisma.route.count({ where: { isActive: true } }),
      this.listBookings(),
      this.listPayments(),
    ]);

    const realUsers = await this.listUsers();
    const totalBookings = bookings.length;
    const bookingsLast24h = bookings.filter(
      (booking) => booking.createdAt && new Date(booking.createdAt) >= twentyFourHoursAgo,
    ).length;
    const totalUsers = realUsers.length;
    const activeUsers = realUsers.filter((user) => user.isActive).length;

    const paymentTotals = payments.reduce(
      (acc, payment) => {
        const status = (payment.status ?? 'PENDING').toUpperCase();
        const amount = Number(payment.amount ?? 0);
        acc.total += 1;
        acc[status] = (acc[status] ?? 0) + 1;
        if (status === 'SUCCESS') {
          acc.revenue += amount;
        }
        return acc;
      },
      { total: 0, PENDING: 0, SUCCESS: 0, FAILED: 0, REFUNDED: 0, revenue: 0 },
    );

    return {
      metrics: {
        totalUsers,
        activeUsers,
        totalBookings,
        bookingsLast24h,
        totalRoutes,
        activeRoutes,
      },
      paymentTotals,
      bookings,
      payments,
      recentPayments: payments.slice(0, 6),
    };
  }

  listPayments() {
    return this.prisma.payment.findMany({
      orderBy: { createdAt: 'desc' },
      include: {
        booking: {
          include: {
            user: true,
            route: true,
          },
        },
      },
    }).then((payments) =>
      payments.filter((payment) => payment.booking && this.isVisiblePassengerBooking(payment.booking)),
    );
  }

  async listAuditLogs() {
    const logs = await this.prisma.$queryRaw<
      Array<{
        createdAt: Date;
        actorName: string;
        actorRole: string;
        category: string;
        action: string;
        details: string;
        ipAddress: string | null;
        entityType: string | null;
        entityId: string | null;
      }>
    >`
      SELECT
        "createdAt",
        "actorName",
        "actorRole",
        "category",
        "action",
        "details",
        "ipAddress",
        "entityType",
        "entityId"
      FROM "AuditLog"
      ORDER BY "createdAt" DESC
      LIMIT 100
    `;

    return logs.map((log) => ({
      date: log.createdAt.toLocaleDateString('en-GB', {
        day: '2-digit',
        month: 'short',
        year: 'numeric',
      }),
      time: log.createdAt.toLocaleTimeString('en-GB', {
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
      }),
      name: log.actorName,
      role: log.actorRole,
      category: log.category,
      details: log.details,
      ipAddress: log.ipAddress ?? '-',
      avatarUrl: '',
      action: log.action,
      entityType: log.entityType,
      entityId: log.entityId,
      createdAt: log.createdAt,
    }));
  }

  listSupportTickets() {
    return this.prisma.supportMessage.findMany({
      orderBy: { createdAt: 'desc' },
      include: { user: true },
    }).then((messages) => {
      if (messages.length === 0) return [];
      return messages.map((msg) => {
        const name = msg.name ?? [msg.user?.firstName, msg.user?.lastName].filter(Boolean).join(' ').trim();
        const email = msg.email ?? msg.user?.email ?? '';
        const phone = msg.phone ?? msg.user?.phone ?? '';
        const contact = email || phone || 'I-Metro Rider';
        const subject = msg.subject ?? 'Support request';
        const snippet = msg.message ? msg.message.substring(0, 60) : '';
        const subtitleBase = contact ? `From: ${name || contact}` : 'Support request';
        const subtitle = snippet ? `${subtitleBase} - ${snippet}` : subtitleBase;
        const priority = this.inferPriority(subject, msg.message);
        const status = this.formatSupportStatus(msg.status);
        return {
          id: `#SUP-${msg.id.substring(0, 6).toUpperCase()}`,
          supportId: msg.id,
          subject,
          subtitle,
          userType: msg.userId ? 'Passenger' : 'Guest',
          priority,
          assigneeName: 'Unassigned',
          assigneeInitials: '',
          status,
          supportStatus: msg.status,
          createdAt: msg.createdAt,
          message: msg.message,
          email,
          phone,
          name: name || null,
        };
      });
    });
  }

  listSupportActivity() {
    return this.prisma.supportMessage.findMany({
      orderBy: { createdAt: 'desc' },
      take: 6,
      include: { user: true },
    }).then((messages) => {
      if (messages.length === 0) return [];
      return messages.map((msg) => {
        const name = msg.name ?? [msg.user?.firstName, msg.user?.lastName].filter(Boolean).join(' ').trim();
        const initials = name
          ? name.split(' ').filter(Boolean).slice(0, 2).map((p) => p[0]).join('').toUpperCase()
          : 'IM';
        return {
          initials,
          message: `New support message: ${msg.subject}`,
          timeAgo: this.timeAgo(msg.createdAt),
          color: '#006B54',
        };
      });
    });
  }

  listValidatorLogs() {
    return readFile(VALIDATOR_LOG_FILE, 'utf8')
      .then((content) => {
        const lines = content
          .split('\n')
          .map((line) => line.trim())
          .filter(Boolean);
        const entries = lines
          .map((line) => {
            try {
              return JSON.parse(line);
            } catch {
              return null;
            }
          })
          .filter(Boolean)
          .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
          .slice(0, 100);

        return entries.map((entry) => ({
          id: entry.id,
          rawPayload: entry.rawPayload,
          format: entry.format,
          isValid: entry.isValid,
          reason: entry.reason ?? null,
          ticketId: entry.ticketId ?? null,
          routeId: entry.routeId ?? null,
          userId: entry.userId ?? null,
          busLabel: entry.busLabel ?? null,
          validatorDeviceId: entry.validatorDeviceId ?? null,
          validatorDeviceName: entry.validatorDeviceName ?? null,
          createdAt: new Date(entry.createdAt),
          timeAgo: this.timeAgo(new Date(entry.createdAt)),
        }));
      })
      .catch(() => []);
  }

  private inferPriority(subject: string, message: string) {
    const text = `${subject} ${message}`.toLowerCase();
    if (text.includes('urgent') || text.includes('refund') || text.includes('payment')) {
      return 'Urgent';
    }
    if (text.includes('error') || text.includes('failed') || text.includes('issue')) {
      return 'High';
    }
    if (text.includes('question') || text.includes('enquiry')) {
      return 'Normal';
    }
    return 'Normal';
  }

  private formatSupportStatus(status: SupportStatus | string) {
    switch (status) {
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'RESOLVED':
        return 'Resolved';
      case 'OPEN':
      default:
        return 'Open';
    }
  }

  async updateSupportStatus(
    id: string,
    status: SupportStatus,
    actorUserId?: string,
    ipAddress?: string,
  ) {
    const supportMessage = await this.prisma.supportMessage.update({
      where: { id },
      data: { status },
      select: {
        id: true,
        status: true,
        updatedAt: true,
      },
    });
    await this.recordAuditLog({
      actorUserId,
      category: 'Support',
      action: `Set support status to ${status}`,
      details: `Support message ${id} marked as ${status.replace(/_/g, ' ')}`,
      entityType: 'SupportMessage',
      entityId: supportMessage.id,
      ipAddress,
    });
    return supportMessage;
  }

  private timeAgo(value: Date) {
    const now = Date.now();
    const diffMs = now - value.getTime();
    const mins = Math.floor(diffMs / 60000);
    if (mins < 1) return 'Just now';
    if (mins < 60) return `${mins} min${mins === 1 ? '' : 's'} ago`;
    const hours = Math.floor(mins / 60);
    if (hours < 24) return `${hours} hour${hours === 1 ? '' : 's'} ago`;
    const days = Math.floor(hours / 24);
    return `${days} day${days === 1 ? '' : 's'} ago`;
  }

  async getSystemSettings() {
    const settings = await this.readSystemSettingsFile();
    return {
      ...settings,
      apiKeyMasked: this.maskApiKey(settings.apiKey),
    };
  }

  async updateSystemSettings(
    payload: Partial<SystemSettingsRecord> & {
      revokeAllKeys?: boolean;
      notifications?: Partial<SystemSettingsNotifications>;
      branding?: Partial<SystemSettingsBranding>;
    },
    actorUserId?: string,
    ipAddress?: string,
  ) {
    const current = await this.readSystemSettingsFile();
    const actor = await this.resolveActor(actorUserId);
    const updated: SystemSettingsRecord = {
      ...current,
      platformName: payload.platformName ?? current.platformName,
      timezone: payload.timezone ?? current.timezone,
      maintenanceMode: payload.maintenanceMode ?? current.maintenanceMode,
      baseFareMultiplier:
        typeof payload.baseFareMultiplier === 'number' && !Number.isNaN(payload.baseFareMultiplier)
          ? payload.baseFareMultiplier
          : current.baseFareMultiplier,
      peakStrategy: payload.peakStrategy ?? current.peakStrategy,
      webhookUrl: payload.webhookUrl ?? current.webhookUrl,
      notifications: {
        emailAdminAlerts: payload.notifications?.emailAdminAlerts ?? current.notifications.emailAdminAlerts,
        slackIntegration: payload.notifications?.slackIntegration ?? current.notifications.slackIntegration,
        smsCriticalDelays: payload.notifications?.smsCriticalDelays ?? current.notifications.smsCriticalDelays,
        pushNotifications: payload.notifications?.pushNotifications ?? current.notifications.pushNotifications,
      },
      branding: {
        primaryColor: payload.branding?.primaryColor ?? current.branding.primaryColor,
        logoHint: payload.branding?.logoHint ?? current.branding.logoHint,
        logoFileName: payload.branding?.logoFileName ?? current.branding.logoFileName,
        logoDataUrl: payload.branding?.logoDataUrl ?? current.branding.logoDataUrl,
      },
      lastModified: `Last modified by ${actor.actorName}`,
      lastModifiedAt: new Date().toISOString(),
      lastModifiedBy: actor.actorName,
      apiKeysRevokedAt: current.apiKeysRevokedAt,
    };

    if (payload.revokeAllKeys) {
      updated.apiKey = `vk_${randomBytes(24).toString('base64url')}`;
      updated.apiKeysRevokedAt = new Date().toISOString();
    }

    const normalized = await this.applyDefaultBrandLogo(updated);
    await this.writeSystemSettingsFile(normalized);
    await this.recordAuditLog({
      actorUserId,
      category: 'System',
      action: payload.revokeAllKeys ? 'Rotated API key' : 'Updated system settings',
      details: payload.revokeAllKeys
        ? 'API key was regenerated from the admin settings screen'
        : 'System settings were updated from the admin settings screen',
      entityType: 'SystemSettings',
      entityId: 'global',
      ipAddress,
    });

    return {
      ...normalized,
      apiKeyMasked: this.maskApiKey(normalized.apiKey),
    };
  }

  async updateUserStatus(id: string, isActive: boolean, actorUserId?: string, ipAddress?: string) {
    const user = await this.prisma.user.update({
      where: { id },
      data: { isActive },
      select: {
        id: true,
        isActive: true,
      },
    });
    await this.recordAuditLog({
      actorUserId,
      category: 'User',
      action: isActive ? 'Activated user' : 'Deactivated user',
      details: `User ${id} set to ${isActive ? 'active' : 'inactive'}`,
      entityType: 'User',
      entityId: user.id,
      ipAddress,
    });
    return user;
  }
}

