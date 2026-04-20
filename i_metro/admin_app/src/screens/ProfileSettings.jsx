import { useEffect, useMemo, useState } from "react";
import { Link, useNavigate } from "react-router-dom";

import { changeAdminPassword, updateAdminProfile } from "../lib/api";
import { authStore, useAuthSession } from "../lib/auth";

const fieldClassName =
  "w-full rounded-2xl bg-surface-container-highest border border-outline-variant/20 px-4 py-3 text-on-surface focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all outline-none";

const labelClassName =
  "text-xs font-semibold uppercase tracking-[0.18em] text-on-surface-variant";

const readProfileName = (profile) =>
  [profile?.firstName?.trim(), profile?.lastName?.trim()].filter(Boolean).join(" ") ||
  profile?.email ||
  "Administrator";

function ProfileSettings() {
  const navigate = useNavigate();
  const session = useAuthSession();
  const profile = useMemo(() => session?.profile ?? {}, [session?.profile]);
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [profileMessage, setProfileMessage] = useState("");
  const [passwordMessage, setPasswordMessage] = useState("");
  const [loadingProfile, setLoadingProfile] = useState(false);
  const [loadingPassword, setLoadingPassword] = useState(false);

  useEffect(() => {
    setFirstName(profile.firstName ?? "");
    setLastName(profile.lastName ?? "");
    setEmail(profile.email ?? "");
    setPhone(profile.phone ?? "");
  }, [profile.firstName, profile.lastName, profile.email, profile.phone]);

  const displayName = readProfileName(profile);
  const displayRole =
    profile.role
      ? String(profile.role)
          .replace(/_/g, " ")
          .replace(/\b\w/g, (char) => char.toUpperCase())
      : "Admin";

  const handleProfileSave = async (event) => {
    event.preventDefault();
    setProfileMessage("");
    setPasswordMessage("");

    setLoadingProfile(true);
    try {
      const result = await updateAdminProfile({
        firstName: firstName.trim() || null,
        lastName: lastName.trim() || null,
        email: email.trim() || null,
        phone: phone.trim() || null,
      });

      if (result?.ok && result?.user) {
        authStore.setProfile(result.user);
        setProfileMessage("Profile updated successfully.");
        return;
      }

      setProfileMessage("Unable to update profile right now.");
    } catch {
      setProfileMessage("Unable to update profile right now.");
    } finally {
      setLoadingProfile(false);
    }
  };

  const handlePasswordSave = async (event) => {
    event.preventDefault();
    setProfileMessage("");
    setPasswordMessage("");

    if (!currentPassword || !newPassword || !confirmPassword) {
      setPasswordMessage("Please complete all password fields.");
      return;
    }

    if (newPassword !== confirmPassword) {
      setPasswordMessage("New password and confirmation do not match.");
      return;
    }

    setLoadingPassword(true);
    try {
      const result = await changeAdminPassword({
        currentPassword,
        newPassword,
      });

      if (result?.ok) {
        setPasswordMessage("Password changed successfully.");
        setCurrentPassword("");
        setNewPassword("");
        setConfirmPassword("");
        return;
      }

      setPasswordMessage("Unable to change password right now.");
    } catch {
      setPasswordMessage("Unable to change password right now.");
    } finally {
      setLoadingPassword(false);
    }
  };

  return (
    <div className="min-h-screen bg-surface text-on-surface">
      <div className="mx-auto max-w-6xl px-4 py-6 md:px-8">
        <div className="mb-6 flex items-center justify-between gap-4 rounded-2xl bg-surface-container-lowest border border-outline-variant/10 px-5 py-4 shadow-sm">
          <div>
            <p className="text-xs uppercase tracking-[0.2em] text-on-surface-variant font-semibold">
              Profile Settings
            </p>
            <h1 className="text-2xl font-bold tracking-tight text-[#00513f] dark:text-emerald-400">
              I-Metro Bus Admin
            </h1>
          </div>
          <div className="flex gap-2">
            <Link
              className="rounded-full bg-surface-container-low px-4 py-2 text-sm font-semibold text-on-surface hover:bg-surface-container-high transition-colors"
              to="/admin/profile-menu"
            >
              Back to profile
            </Link>
            <button
              className="rounded-full bg-primary px-4 py-2 text-sm font-semibold text-on-primary hover:opacity-90 transition-colors"
              onClick={() => navigate("/admin/dashboard")}
              type="button"
            >
              Dashboard
            </button>
          </div>
        </div>

        <div className="grid gap-6 xl:grid-cols-[1.1fr_0.9fr]">
          <section className="rounded-3xl bg-surface-container-lowest border border-outline-variant/10 p-6 md:p-8 shadow-[0px_10px_30px_rgba(25,28,29,0.06)]">
            <div className="flex items-center justify-between gap-4">
              <div>
                <p className="text-xs uppercase tracking-[0.18em] text-on-surface-variant font-semibold">
                  Account Details
                </p>
                <h2 className="mt-1 text-xl font-bold text-on-surface">Update your profile</h2>
              </div>
              <span className="rounded-full bg-primary-fixed-dim/15 px-3 py-1 text-xs font-semibold text-primary">
                {displayRole}
              </span>
            </div>

            <form className="mt-6 space-y-5" onSubmit={handleProfileSave}>
              <div className="grid gap-5 md:grid-cols-2">
                <label className="space-y-2">
                  <span className={labelClassName}>First Name</span>
                  <input
                    className={fieldClassName}
                    onChange={(event) => setFirstName(event.target.value)}
                    placeholder="First name"
                    value={firstName}
                  />
                </label>
                <label className="space-y-2">
                  <span className={labelClassName}>Last Name</span>
                  <input
                    className={fieldClassName}
                    onChange={(event) => setLastName(event.target.value)}
                    placeholder="Last name"
                    value={lastName}
                  />
                </label>
              </div>

              <div className="grid gap-5 md:grid-cols-2">
                <label className="space-y-2">
                  <span className={labelClassName}>Email</span>
                  <input
                    className={fieldClassName}
                    onChange={(event) => setEmail(event.target.value)}
                    placeholder="Email address"
                    type="email"
                    value={email}
                  />
                </label>
                <label className="space-y-2">
                  <span className={labelClassName}>Phone</span>
                  <input
                    className={fieldClassName}
                    onChange={(event) => setPhone(event.target.value)}
                    placeholder="Phone number"
                    value={phone}
                  />
                </label>
              </div>

              <div className="rounded-2xl bg-surface-container-low p-4">
                <p className="text-sm font-semibold text-on-surface">{displayName}</p>
                <p className="text-sm text-on-surface-variant">
                  This information powers the shell header, dropdown, and account summaries.
                </p>
              </div>

              {profileMessage && (
                <div className="rounded-2xl bg-primary-fixed-dim/15 px-4 py-3 text-sm text-primary">
                  {profileMessage}
                </div>
              )}

              <div className="flex items-center justify-end gap-3">
                <Link
                  className="rounded-full px-4 py-2 text-sm font-semibold text-on-surface-variant hover:bg-surface-container-low transition-colors"
                  to="/admin/profile-menu"
                >
                  Cancel
                </Link>
                <button
                  className="rounded-full bg-primary px-5 py-2.5 text-sm font-semibold text-on-primary disabled:opacity-70"
                  disabled={loadingProfile}
                  type="submit"
                >
                  {loadingProfile ? "Saving..." : "Save profile"}
                </button>
              </div>
            </form>
          </section>

          <section className="rounded-3xl bg-surface-container-lowest border border-outline-variant/10 p-6 md:p-8 shadow-[0px_10px_30px_rgba(25,28,29,0.06)]">
            <div className="flex items-center justify-between gap-4">
              <div>
                <p className="text-xs uppercase tracking-[0.18em] text-on-surface-variant font-semibold">
                  Security
                </p>
                <h2 className="mt-1 text-xl font-bold text-on-surface">Change password</h2>
              </div>
            </div>

            <form className="mt-6 space-y-5" onSubmit={handlePasswordSave}>
              <label className="space-y-2 block">
                <span className={labelClassName}>Current password</span>
                <input
                  className={fieldClassName}
                  onChange={(event) => setCurrentPassword(event.target.value)}
                  type="password"
                  value={currentPassword}
                />
              </label>
              <label className="space-y-2 block">
                <span className={labelClassName}>New password</span>
                <input
                  className={fieldClassName}
                  onChange={(event) => setNewPassword(event.target.value)}
                  type="password"
                  value={newPassword}
                />
              </label>
              <label className="space-y-2 block">
                <span className={labelClassName}>Confirm new password</span>
                <input
                  className={fieldClassName}
                  onChange={(event) => setConfirmPassword(event.target.value)}
                  type="password"
                  value={confirmPassword}
                />
              </label>

              {passwordMessage && (
                <div
                  className={`rounded-2xl px-4 py-3 text-sm ${
                    passwordMessage.toLowerCase().includes("success")
                      ? "bg-emerald-100 text-emerald-800"
                      : "bg-error-container text-on-error-container"
                  }`}
                >
                  {passwordMessage}
                </div>
              )}

              <div className="flex items-center justify-end gap-3">
                <Link
                  className="rounded-full px-4 py-2 text-sm font-semibold text-on-surface-variant hover:bg-surface-container-low transition-colors"
                  to="/admin/activity"
                >
                  Review activity
                </Link>
                <button
                  className="rounded-full bg-primary px-5 py-2.5 text-sm font-semibold text-on-primary disabled:opacity-70"
                  disabled={loadingPassword}
                  type="submit"
                >
                  {loadingPassword ? "Updating..." : "Change password"}
                </button>
              </div>
            </form>
          </section>
        </div>
      </div>
    </div>
  );
}

export default ProfileSettings;
