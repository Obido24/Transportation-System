import { Navigate, Route, Routes } from "react-router-dom";

import {
  AddRoute,
  AdminLogin,
  AdminSignUp,
  AuditActivityLogs,
  AvailableRoutes,
  DashboardMain,
  EditRoute,
  EmailVerification,
  ForgotPassword,
  LogOutConfirmation,
  MerchantList,
  MerchantDetails,
  ProfileMenu,
  ProfileSettings,
  ResetPassword,
  ResetSuccess,
  RevenueDashboard,
  SupportTicketManagement,
  SystemSettings,
  TotalUsers,
  TwoFactor,
  UserDetails,
  ValidatorWeb,
  ValidatorLogs,
} from "./screens";
import AdminShell from "./layouts/AdminShell";
import RequireAuth from "./routes/RequireAuth";

function App() {
  return (
    <Routes>
      <Route path="/" element={<Navigate to="/admin/login" replace />} />
      <Route path="/validator" element={<ValidatorWeb />} />
      <Route path="/admin/login" element={<AdminLogin />} />
      <Route path="/admin/signup" element={<AdminSignUp />} />
      <Route path="/admin/forgot-password" element={<ForgotPassword />} />
      <Route path="/admin/email-verification" element={<EmailVerification />} />
      <Route path="/admin/2fa" element={<TwoFactor />} />
      <Route path="/admin/reset-password" element={<ResetPassword />} />
      <Route path="/admin/reset-success" element={<ResetSuccess />} />
      <Route element={<RequireAuth />}>
        <Route element={<AdminShell />}>
          <Route path="/admin/dashboard" element={<DashboardMain />} />
          <Route path="/admin/users" element={<TotalUsers />} />
          <Route path="/admin/user-details" element={<UserDetails />} />
          <Route path="/admin/merchants" element={<MerchantList />} />
          <Route path="/admin/merchant-details" element={<MerchantDetails />} />
          <Route path="/admin/routes" element={<AvailableRoutes />} />
          <Route path="/admin/routes/add" element={<AddRoute />} />
          <Route path="/admin/routes/edit" element={<EditRoute />} />
          <Route path="/admin/profile-menu" element={<ProfileMenu />} />
          <Route path="/admin/profile-settings" element={<ProfileSettings />} />
          <Route path="/admin/logout" element={<LogOutConfirmation />} />
          <Route path="/admin/activity" element={<AuditActivityLogs />} />
          <Route path="/admin/support" element={<SupportTicketManagement />} />
          <Route path="/admin/settings" element={<SystemSettings />} />
          <Route path="/admin/revenue" element={<RevenueDashboard />} />
          <Route path="/admin/validator-logs" element={<ValidatorLogs />} />
        </Route>
      </Route>
      <Route path="*" element={<Navigate to="/admin/login" replace />} />
    </Routes>
  );
}

export default App;
