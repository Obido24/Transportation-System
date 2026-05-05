import { Body, Controller, Get, Patch, Post, Req, UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { CreateAdminDto } from './dto/create-admin.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { ChangePasswordDto } from './dto/change-password.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  register(@Body() body: RegisterDto) {
    return this.authService.registerUser(body);
  }

  @Post('login')
  login(@Body() body: LoginDto) {
    return this.authService.login(body);
  }

  @Post('admin/create')
  createAdmin(@Body() body: CreateAdminDto) {
    return this.authService.createAdmin(body);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  me(@Req() req: any) {
    return this.authService.getProfile(req.user?.userId);
  }

  @Patch('me')
  @UseGuards(JwtAuthGuard)
  updateProfile(@Req() req: any, @Body() body: UpdateProfileDto) {
    return this.authService.updateProfile(req.user?.userId, body);
  }

  @Post('change-password')
  @UseGuards(JwtAuthGuard)
  changePassword(@Req() req: any, @Body() body: ChangePasswordDto) {
    return this.authService.changePassword(req.user?.userId, body);
  }
}
