import 'package:flutter/material.dart';

import 'screens/user_screens.dart';
import 'screens/admin_screens.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const createAccount = '/create-account';
  static const home = '/home';
  static const booking = '/booking';
  static const ticketDetails = '/ticket-details';
  static const afterBooking = '/after-booking';
  static const completedRides = '/completed-rides';
  static const notifications = '/notifications';
  static const profile = '/profile';
  static const profileSettings = '/profile-settings';
  static const changePassword = '/change-password';
  static const hamburgerMenu = '/hamburger-menu';
  static const contactUs = '/contact-us';
  static const policy = '/policy';
  static const logout = '/logout';

  static const adminLogin = '/admin/login';
  static const adminSignup = '/admin/signup';
  static const adminForgotPassword = '/admin/forgot-password';
  static const adminEmailVerification = '/admin/email-verification';
  static const admin2fa = '/admin/2fa';
  static const adminResetPassword = '/admin/reset-password';
  static const adminResetSuccess = '/admin/reset-success';
  static const adminDashboard = '/admin/dashboard';
  static const adminTotalUsers = '/admin/total-users';
  static const adminAvailableRoutes = '/admin/available-routes';
  static const adminAddRoute = '/admin/add-route';
  static const adminEditRoute = '/admin/edit-route';
  static const adminUserDetails = '/admin/user-details';
  static const adminMerchantDetails = '/admin/merchant-details';
  static const adminUserDropdown = '/admin/user-dropdown';
  static const adminLogoutConfirmation = '/admin/logout-confirmation';
  static const adminAuditActivityLogs = '/admin/audit-activity-logs';
  static const adminSupportTicketManagement = '/admin/support-ticket-management';
  static const adminSystemSettings = '/admin/system-settings';
  static const adminRevenueDashboard = '/admin/revenue-dashboard';

  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashOnboardingScreen(),
    login: (context) => const LoginScreen(),
    createAccount: (context) => const CreateAccountScreen(),
    home: (context) => const HomeScreen(),
    booking: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      String? initialRouteId;
      if (args is Map) {
        initialRouteId = args['routeId']?.toString();
      }
      return BookingScreen(initialRouteId: initialRouteId);
    },
    ticketDetails: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      String? bookingId;
      String? paymentReference;
      String? provider;
      bool showSuccess = false;
      if (args is Map) {
        bookingId = args['bookingId']?.toString();
        paymentReference = args['paymentReference']?.toString();
        provider = args['provider']?.toString();
        showSuccess = args['justVerified'] == true;
      }
      return TicketDetailsLoaderScreen(
        bookingId: bookingId,
        paymentReference: paymentReference,
        provider: provider ?? 'MONNIFY',
        showSuccess: showSuccess,
      );
    },
    afterBooking: (context) => const AfterBookingScreen(),
    completedRides: (context) => const CompletedRidesScreen(),
    notifications: (context) => const NotificationsScreen(),
    profile: (context) => const ProfileScreen(),
    profileSettings: (context) => const ProfileSettingsScreen(),
    changePassword: (context) => const ChangePasswordScreen(),
    hamburgerMenu: (context) => const HamburgerMenuScreen(),
    contactUs: (context) => const ContactUsScreen(),
    policy: (context) => const PolicyScreen(),
    logout: (context) => const LogoutScreen(),
    adminLogin: (context) => const AdminLoginScreen(),
    adminSignup: (context) => const AdminSignupScreen(),
    adminForgotPassword: (context) => const AdminForgotPasswordScreen(),
    adminEmailVerification: (context) => const AdminEmailVerificationScreen(),
    admin2fa: (context) => const AdminTwoFactorScreen(),
    adminResetPassword: (context) => const AdminResetPasswordScreen(),
    adminResetSuccess: (context) => const AdminResetSuccessScreen(),
    adminDashboard: (context) => const AdminDashboardScreen(),
    adminTotalUsers: (context) => const AdminTotalUsersScreen(),
    adminAvailableRoutes: (context) => const AdminAvailableRoutesScreen(),
    adminAddRoute: (context) => const AdminAddRouteScreen(),
    adminEditRoute: (context) => const AdminEditRouteScreen(),
    adminUserDetails: (context) => const AdminUserDetailsScreen(),
    adminMerchantDetails: (context) => const AdminMerchantDetailsScreen(),
    adminUserDropdown: (context) => const AdminUserDropdownScreen(),
    adminLogoutConfirmation: (context) => const AdminLogoutConfirmationScreen(),
    adminAuditActivityLogs: (context) => const AdminAuditActivityLogsScreen(),
    adminSupportTicketManagement: (context) => const AdminSupportTicketManagementScreen(),
    adminSystemSettings: (context) => const AdminSystemSettingsScreen(),
    adminRevenueDashboard: (context) => const AdminRevenueDashboardScreen(),
  };
}
