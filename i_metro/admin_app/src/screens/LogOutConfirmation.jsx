import { useNavigate } from "react-router-dom";
import { authStore } from "../lib/auth";
import { useAuthSession } from "../lib/auth";

function LogOutConfirmation() {
  const navigate = useNavigate();
  const session = useAuthSession();
  const profile = session?.profile ?? {};
  const displayName =
    [profile.firstName?.trim(), profile.lastName?.trim()].filter(Boolean).join(" ") ||
    profile.email ||
    "Administrator";
  const displayRole = profile.role ?? "Admin";
  const avatarUrl = profile.avatarUrl ?? null;
  const initials = (() => {
    const first = profile.firstName?.trim() ?? "";
    const last = profile.lastName?.trim() ?? "";
    if (first || last) {
      return `${first.charAt(0)}${last.charAt(0)}`.toUpperCase();
    }
    const fallback = profile.email ?? profile.phone ?? "A";
    return fallback.charAt(0).toUpperCase();
  })();

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div
        className="absolute inset-0 bg-on-surface/10 backdrop-blur-md"
        onClick={() => navigate(-1)}
        role="presentation"
      ></div>
      <div className="relative w-full max-w-md bg-surface-container-lowest rounded-xl shadow-[0px_10px_30px_rgba(25,28,29,0.05)] overflow-hidden">
        <div className="bg-surface-container-low px-6 py-4 flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-error-container flex items-center justify-center text-error">
            <span className="material-symbols-outlined text-[20px]">logout</span>
          </div>
          <h2 className="text-lg font-bold text-on-surface tracking-tight">
            System Session
          </h2>
        </div>
        <div className="p-8 text-center">
          <div className="mb-6 flex justify-center">
            <div className="relative">
              <div className="w-20 h-20 rounded-full overflow-hidden object-cover shadow-sm ring-4 ring-surface-container-low bg-primary-container text-on-primary-container flex items-center justify-center text-lg font-semibold">
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
              <div className="absolute -bottom-1 -right-1 w-6 h-6 bg-primary-fixed-dim rounded-full flex items-center justify-center text-on-primary-fixed ring-4 ring-surface-container-lowest">
                <span className="material-symbols-outlined text-[14px]">
                  verified
                </span>
              </div>
            </div>
          </div>
          <h3 className="text-2xl font-bold text-on-surface mb-3 tracking-tight">
            Are you sure you want to log out?
          </h3>
          <p className="text-sm font-semibold text-primary mb-2">{displayName}</p>
          <p className="text-xs uppercase tracking-[0.2em] text-on-surface-variant mb-4">
            {displayRole}
          </p>
          <p className="text-on-surface-variant body-md leading-relaxed px-4">
            You are currently managing active transit routes. Logging out will
            end your current administrative session.
          </p>
        </div>
        <div className="p-6 pt-0 flex gap-3">
          <button
            className="flex-1 px-6 py-3.5 rounded-lg text-primary font-semibold hover:bg-surface-container-low transition-colors duration-200"
            onClick={() => navigate(-1)}
            type="button"
          >
            Cancel
          </button>
          <button
            className="flex-1 px-6 py-3.5 rounded-lg bg-gradient-to-br from-primary to-primary-container text-on-primary font-semibold shadow-lg shadow-primary/10 active:scale-[0.98] transition-all duration-150"
            onClick={() => {
              authStore.clear();
              navigate("/admin/login", { replace: true });
            }}
            type="button"
          >
            Confirm
          </button>
        </div>
        <div className="h-1 bg-surface-container-highest w-full opacity-50"></div>
      </div>
    </div>
  );
}

export default LogOutConfirmation;
