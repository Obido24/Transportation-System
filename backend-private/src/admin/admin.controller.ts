import { Body, Controller, Delete, Get, Param, Patch, Post, Query, Req, UseGuards } from '@nestjs/common';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UpdateUserStatusDto } from './dto/update-user-status.dto';
import { UpdateSupportStatusDto } from './dto/update-support-status.dto';
import { CreateRouteDto } from '../routes/dto/create-route.dto';
import { UpdateRouteDto } from '../routes/dto/update-route.dto';
import { AnnouncementsService } from '../announcements/announcements.service';
import { CreateAnnouncementDto } from '../announcements/dto/create-announcement.dto';
import { UpdateAnnouncementDto } from '../announcements/dto/update-announcement.dto';

@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('ADMIN')
export class AdminController {
  constructor(
    private readonly adminService: AdminService,
    private readonly announcementsService: AnnouncementsService,
  ) {}

  @Get('users')
  listUsers() {
    return this.adminService.listUsers();
  }

  @Get('users/:id')
  getUser(@Param('id') id: string) {
    return this.adminService.getUser(id);
  }

  @Patch('users/:id/status')
  updateUserStatus(@Param('id') id: string, @Body() body: UpdateUserStatusDto, @Req() req: any) {
    return this.adminService.updateUserStatus(id, body.isActive, req.user?.userId, req.ip);
  }

  @Get('merchants')
  listMerchants() {
    return this.adminService.listMerchants();
  }

  @Get('merchants/:id')
  getMerchant(@Param('id') id: string) {
    return this.adminService.getMerchant(id);
  }

  @Patch('merchants/:id/status')
  updateMerchantStatus(@Param('id') id: string, @Body() body: { isActive: boolean }, @Req() req: any) {
    return this.adminService.updateMerchantStatus(id, body.isActive, req.user?.userId, req.ip);
  }

  @Get('bookings')
  listBookings() {
    return this.adminService.listBookings();
  }

  @Get('payments')
  listPayments() {
    return this.adminService.listPayments();
  }

  @Get('dashboard/summary')
  getDashboardSummary() {
    return this.adminService.getDashboardSummary();
  }

  @Get('search')
  search(@Query('q') query: string) {
    return this.adminService.search(query);
  }

  @Get('audit-logs')
  listAuditLogs() {
    return this.adminService.listAuditLogs();
  }

  @Get('support/tickets')
  listSupportTickets() {
    return this.adminService.listSupportTickets();
  }

  @Get('support/activity')
  listSupportActivity() {
    return this.adminService.listSupportActivity();
  }

  @Get('validator/logs')
  listValidatorLogs() {
    return this.adminService.listValidatorLogs();
  }

  @Get('routes')
  listRoutes() {
    return this.adminService.listRoutes();
  }

  @Post('routes')
  createRoute(@Body() body: CreateRouteDto, @Req() req: any) {
    return this.adminService.createRoute(body, req.user?.userId, req.ip);
  }

  @Patch('routes/:id')
  updateRoute(@Param('id') id: string, @Body() body: UpdateRouteDto, @Req() req: any) {
    return this.adminService.updateRoute(id, body, req.user?.userId, req.ip);
  }

  @Delete('routes/:id')
  removeRoute(@Param('id') id: string, @Req() req: any) {
    return this.adminService.deleteRoute(id, req.user?.userId, req.ip);
  }

  @Patch('support/messages/:id/status')
  updateSupportStatus(@Param('id') id: string, @Body() body: UpdateSupportStatusDto, @Req() req: any) {
    return this.adminService.updateSupportStatus(id, body.status, req.user?.userId, req.ip);
  }

  @Get('system-settings')
  getSystemSettings() {
    return this.adminService.getSystemSettings();
  }

  @Patch('system-settings')
  updateSystemSettings(@Body() body: Record<string, any>, @Req() req: any) {
    return this.adminService.updateSystemSettings(body, req.user?.userId, req.ip);
  }

  @Get('announcements')
  listAnnouncements() {
    return this.announcementsService.listAdminAnnouncements();
  }

  @Post('announcements')
  createAnnouncement(@Body() body: CreateAnnouncementDto, @Req() req: any) {
    return this.announcementsService.createAnnouncement(body, req.user?.userId, req.ip);
  }

  @Patch('announcements/:id')
  updateAnnouncement(@Param('id') id: string, @Body() body: UpdateAnnouncementDto, @Req() req: any) {
    return this.announcementsService.updateAnnouncement(id, body, req.user?.userId, req.ip);
  }

  @Delete('announcements/:id')
  deleteAnnouncement(@Param('id') id: string, @Req() req: any) {
    return this.announcementsService.deleteAnnouncement(id, req.user?.userId, req.ip);
  }
}
