import { Link } from "react-router-dom";
import { useMemo } from "react";

import HtmlScreen from "./HtmlScreen";
import { useAuthSession } from "../lib/auth";

import adminSignUpHtml from "./html/admin_sign_up.html?raw";
import AdminLogin from "./AdminLogin";
import forgotPasswordHtml from "./html/forgot_password.html?raw";
import emailVerificationHtml from "./html/email_verification.html?raw";
import twoFactorHtml from "./html/two_factor_authentication.html?raw";
import resetPasswordHtml from "./html/reset_password.html?raw";
import resetSuccessHtml from "./html/reset_success.html?raw";
import DashboardMain from "./DashboardMain";
import TotalUsers from "./TotalUsers";
import UserDetails from "./UserDetails";
import MerchantList from "./MerchantList";
import MerchantDetails from "./MerchantDetails";
import AvailableRoutes from "./AvailableRoutes";
import AddRoute from "./AddRoute";
import EditRoute from "./EditRoute";
import AuditActivityLogs from "./AuditActivityLogs";
import SupportTicketManagement from "./SupportTicketManagement";
import SystemSettings from "./SystemSettings";
import RevenueDashboard from "./RevenueDashboard";
import ValidatorLogs from "./ValidatorLogs";
import LogOutConfirmation from "./LogOutConfirmation";
import ProfileSettings from "./ProfileSettings";
import ValidatorWeb from "./ValidatorWeb";

const getInitials = (profile) => {
  const first = profile?.firstName?.trim() ?? "";
  const last = profile?.lastName?.trim() ?? "";
  if (first || last) {
    return `${first.charAt(0)}${last.charAt(0)}`.toUpperCase();
  }
  const fallback = profile?.email ?? profile?.phone ?? "A";
  return fallback.charAt(0).toUpperCase();
};

const formatRole = (role) => {
  if (!role) return "Admin";
  return String(role)
    .replace(/_/g, " ")
    .replace(/\b\w/g, (char) => char.toUpperCase());
};

export const AdminSignUp = () => (
  <HtmlScreen
    html={adminSignUpHtml}
    title="Admin Sign Up"
    layout="auth"
    wrapperClassName="bg-surface font-body text-on-surface antialiased min-h-screen flex items-center justify-center p-4 md:p-8"
  />
);
export { AdminLogin };
export const ForgotPassword = () => (
  <HtmlScreen
    html={forgotPasswordHtml}
    title="Forgot Password"
    layout="auth"
    wrapperClassName="bg-surface text-on-surface flex items-center justify-center min-h-screen p-6 overflow-hidden"
  />
);
export const EmailVerification = () => (
  <HtmlScreen
    html={emailVerificationHtml}
    title="Email Verification"
    layout="auth"
    wrapperClassName="bg-surface text-on-surface min-h-screen flex flex-col md:flex-row overflow-hidden"
  />
);
export const TwoFactor = () => (
  <HtmlScreen
    html={twoFactorHtml}
    title="Two Factor Authentication"
    layout="auth"
    wrapperClassName="bg-surface font-body text-on-surface antialiased min-h-screen flex items-center justify-center p-6 relative overflow-hidden"
  />
);
export const ResetPassword = () => (
  <HtmlScreen
    html={resetPasswordHtml}
    title="Reset Password"
    layout="auth"
    wrapperClassName="bg-surface font-body text-on-surface selection:bg-primary-fixed-dim selection:text-on-primary-fixed min-h-screen"
  />
);
export const ResetSuccess = () => (
  <HtmlScreen
    html={resetSuccessHtml}
    title="Password Reset Success"
    layout="auth"
    wrapperClassName="bg-surface text-on-surface flex items-center justify-center min-h-screen p-6 relative overflow-hidden"
  />
);
export { DashboardMain };
export { TotalUsers };
export { UserDetails };
export { MerchantList, MerchantDetails };
export { AvailableRoutes, AddRoute, EditRoute };
export { ValidatorWeb };
export const ProfileMenu = () => {
  const session = useAuthSession();
  const profile = useMemo(() => session?.profile ?? {}, [session?.profile]);
  const displayName = useMemo(
    () =>
      [profile.firstName?.trim(), profile.lastName?.trim()].filter(Boolean).join(" ") ||
      profile.email ||
      "Administrator",
    [profile.email, profile.firstName, profile.lastName],
  );
  const displayRole = useMemo(() => formatRole(profile.role), [profile.role]);
  const avatarUrl = profile.avatarUrl ?? null;
  const initials = useMemo(() => getInitials(profile), [profile]);

  return (
    <div className="min-h-screen bg-surface text-on-surface">
      <div className="mx-auto max-w-6xl px-4 py-6 md:px-8">
        <div className="grid gap-6 lg:grid-cols-[280px_1fr]">
          <aside className="rounded-3xl bg-surface-container-lowest border border-outline-variant/10 p-4 md:p-5 shadow-[0px_10px_30px_rgba(25,28,29,0.06)]">
            <div className="flex items-center gap-3 px-2 mb-8">
              <div className="w-10 h-10 rounded-lg bg-primary-container flex items-center justify-center text-on-primary">
                <span className="material-symbols-outlined" data-icon="subway">
                  subway
                </span>
              </div>
              <div>
                <h1 className="text-xl font-bold tracking-tight text-emerald-900 dark:text-emerald-50 leading-none">
                  I-Metro Bus Admin
                </h1>
                <p className="text-[10px] uppercase tracking-widest text-on-surface-variant font-medium">
                  Inter-Metro Transport Solution Limited
                </p>
              </div>
            </div>
            <nav className="space-y-1">
              <Link
                className="flex items-center gap-3 px-4 py-3 text-emerald-900 dark:text-emerald-400 font-semibold bg-white/50 dark:bg-slate-800/50 rounded-lg scale-[0.98] transition-all"
                to="/admin/dashboard"
              >
                <span className="material-symbols-outlined" data-icon="dashboard">
                  dashboard
                </span>
                <span className="font-headline text-sm">Dashboard</span>
              </Link>
              <Link
                className="flex items-center gap-3 px-4 py-3 text-slate-600 dark:text-slate-400 hover:bg-slate-200 dark:hover:bg-slate-800 transition-colors rounded-lg"
                to="/admin/users"
              >
                <span className="material-symbols-outlined" data-icon="group">
                  group
                </span>
                <span className="font-headline text-sm">User Management</span>
              </Link>
              <Link
                className="flex items-center gap-3 px-4 py-3 text-slate-600 dark:text-slate-400 hover:bg-slate-200 dark:hover:bg-slate-800 transition-colors rounded-lg"
                to="/admin/merchants"
              >
                <span className="material-symbols-outlined" data-icon="storefront">
                  storefront
                </span>
                <span className="font-headline text-sm">Merchant Management</span>
              </Link>
              <Link
                className="flex items-center gap-3 px-4 py-3 text-slate-600 dark:text-slate-400 hover:bg-slate-200 dark:hover:bg-slate-800 transition-colors rounded-lg"
                to="/admin/routes"
              >
                <span className="material-symbols-outlined" data-icon="map">
                  map
                </span>
                <span className="font-headline text-sm">Route Management</span>
              </Link>
            </nav>
            <div className="mt-auto pt-6 border-t border-slate-200 dark:border-slate-800 space-y-1 mt-6">
              <Link
                className="flex items-center gap-3 px-4 py-2 text-slate-600 dark:text-slate-400 hover:bg-slate-200 dark:hover:bg-slate-800 transition-colors rounded-lg text-sm"
                to="/admin/profile-menu"
              >
                <span className="material-symbols-outlined text-sm" data-icon="account_circle">
                  account_circle
                </span>
                <span>Profile</span>
              </Link>
              <Link
                className="flex items-center gap-3 px-4 py-2 text-slate-600 dark:text-slate-400 hover:bg-slate-200 dark:hover:bg-slate-800 transition-colors rounded-lg text-sm"
                to="/admin/settings"
              >
                <span className="material-symbols-outlined text-sm" data-icon="settings">
                  settings
                </span>
                <span>Settings</span>
              </Link>
            </div>
          </aside>

          <main className="rounded-3xl bg-surface-container-lowest border border-outline-variant/10 shadow-[0px_10px_30px_rgba(25,28,29,0.06)] overflow-hidden">
            <div className="flex justify-between items-center px-6 md:px-8 h-20 bg-slate-50/80 dark:bg-slate-950/80 backdrop-blur-lg border-b border-outline-variant/10">
              <div>
                <p className="text-xs uppercase tracking-[0.2em] text-on-surface-variant font-semibold">
                  Profile Menu
                </p>
                <h2 className="text-xl md:text-2xl font-bold tracking-tight text-[#00513f] dark:text-emerald-400">
                  I-Metro Bus Admin
                </h2>
              </div>
              <Link
                className="inline-flex items-center gap-2 rounded-full bg-surface-container-low px-4 py-2 text-sm font-semibold text-primary hover:bg-surface-container-high transition-colors"
                to="/admin/logout"
              >
                <span className="material-symbols-outlined text-[18px]">logout</span>
                Log out
              </Link>
            </div>

            <div className="p-6 md:p-8">
              <div className="grid gap-6 xl:grid-cols-[1.2fr_0.8fr]">
                <section className="rounded-3xl bg-surface-container-low p-6 md:p-8">
                  <div className="flex flex-col md:flex-row md:items-center gap-5">
                    <div className="w-20 h-20 md:w-24 md:h-24 rounded-2xl overflow-hidden bg-primary-container text-on-primary-container flex items-center justify-center font-bold text-2xl shadow-sm">
                      {avatarUrl ? (
                        <img
                          alt={displayName}
                          className="w-full h-full object-cover"
                          src={avatarUrl}
                        />
                      ) : (
                        <span>{initials}</span>
                      )}
                    </div>
                    <div className="min-w-0">
                      <p className="text-xs uppercase tracking-[0.2em] text-on-surface-variant font-semibold">
                        Signed in as
                      </p>
                      <h3 className="text-2xl md:text-3xl font-bold tracking-tight text-on-surface truncate">
                        {displayName}
                      </h3>
                      <p className="mt-1 text-sm text-on-surface-variant">{displayRole}</p>
                      <div className="mt-4 flex flex-wrap gap-2">
                        <span className="inline-flex items-center rounded-full bg-primary-fixed-dim/15 px-3 py-1 text-xs font-semibold text-primary">
                          {profile.email ?? profile.phone ?? "No contact saved"}
                        </span>
                        {profile.createdAt && (
                          <span className="inline-flex items-center rounded-full bg-surface-container-high px-3 py-1 text-xs font-semibold text-on-surface-variant">
                            Joined {new Date(profile.createdAt).toLocaleDateString("en-NG")}
                          </span>
                        )}
                      </div>
                    </div>
                  </div>

                  <div className="mt-8 grid gap-4 sm:grid-cols-3">
                    {[
                      { label: "Account", value: "Active" },
                      { label: "Role", value: displayRole },
                      { label: "Session", value: session?.isExpired ? "Expired" : "Live" },
                    ].map((item) => (
                      <div key={item.label} className="rounded-2xl bg-surface-container-high p-4">
                        <p className="text-xs uppercase tracking-widest text-on-surface-variant">
                          {item.label}
                        </p>
                        <p className="mt-2 text-sm font-semibold text-on-surface">{item.value}</p>
                      </div>
                    ))}
                  </div>
                </section>

                <section className="rounded-3xl bg-surface-container-low p-6 md:p-8">
                  <h3 className="text-lg font-bold text-on-surface tracking-tight">
                    Quick Actions
                  </h3>
                  <div className="mt-5 space-y-3">
                    <Link
                      className="flex items-center justify-between rounded-2xl bg-surface-container-high px-4 py-4 hover:bg-surface-container-highest transition-colors"
                      to="/admin/profile-settings"
                    >
                      <div>
                        <p className="font-semibold text-on-surface">Profile Settings</p>
                        <p className="text-sm text-on-surface-variant">
                          Update your admin details and preferences.
                        </p>
                      </div>
                      <span className="material-symbols-outlined text-on-surface-variant">
                        chevron_right
                      </span>
                    </Link>
                    <Link
                      className="flex items-center justify-between rounded-2xl bg-surface-container-high px-4 py-4 hover:bg-surface-container-highest transition-colors"
                      to="/admin/activity"
                    >
                      <div>
                        <p className="font-semibold text-on-surface">Recent Activity</p>
                        <p className="text-sm text-on-surface-variant">
                          Review your latest admin actions.
                        </p>
                      </div>
                      <span className="material-symbols-outlined text-on-surface-variant">
                        chevron_right
                      </span>
                    </Link>
                    <Link
                      className="flex items-center justify-between rounded-2xl bg-surface-container-high px-4 py-4 hover:bg-surface-container-highest transition-colors"
                      to="/admin/logout"
                    >
                      <div>
                        <p className="font-semibold text-error">Log Out</p>
                        <p className="text-sm text-on-surface-variant">
                          End the current admin session securely.
                        </p>
                      </div>
                      <span className="material-symbols-outlined text-error">logout</span>
                    </Link>
                  </div>
                </section>
              </div>
            </div>
          </main>
        </div>
      </div>
    </div>
  );
};
export { LogOutConfirmation };
export { AuditActivityLogs };
export { SupportTicketManagement };
export { ProfileSettings };
export { SystemSettings };
export { RevenueDashboard };
export { ValidatorLogs };
