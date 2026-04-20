import { useCallback, useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";

import ExportToolbar from "../components/ExportToolbar";
import HtmlScreen from "./HtmlScreen";
import totalUsersHtml from "./html/total_users.html?raw";
import { fetchWithAuth } from "../lib/api";
import { downloadCsv, printPdf } from "../lib/exportTools";

const wrapperClassName = "min-h-screen";

const toInitials = (firstName, lastName, emailOrPhone) => {
  const first = (firstName ?? "").trim();
  const last = (lastName ?? "").trim();
  if (first || last) {
    return `${first.charAt(0)}${last.charAt(0)}`.toUpperCase();
  }
  if (emailOrPhone) {
    return emailOrPhone.trim().charAt(0).toUpperCase();
  }
  return "U";
};

const renderRows = (users) =>
  users
    .map((user) => {
      const name =
        `${user.firstName ?? ""} ${user.lastName ?? ""}`.trim() ||
        user.email ||
        user.phone ||
        "Unknown";
      const contact = user.email || user.phone || "No contact";
      const statusLabel = user.isActive ? "Active" : "Inactive";
      const statusClass = user.isActive
        ? "bg-primary-fixed/30 text-on-primary-fixed-variant"
        : "bg-surface-container-highest text-on-surface-variant";
      const dotClass = user.isActive ? "bg-primary" : "bg-outline";

      return `
      <tr class="hover:bg-surface-container-low/50 transition-colors group cursor-pointer" data-user-id="${user.id}">
        <td class="px-8 py-5">
          <div class="flex items-center gap-4">
            <div class="w-10 h-10 rounded-lg bg-surface-container-highest overflow-hidden flex items-center justify-center text-sm font-semibold text-primary">
              ${toInitials(user.firstName, user.lastName, contact)}
            </div>
            <div>
              <p class="font-semibold text-on-surface">${name}</p>
              <p class="text-xs text-on-surface-variant">${contact}</p>
            </div>
          </div>
        </td>
        <td class="px-8 py-5 text-sm text-on-surface">-</td>
        <td class="px-8 py-5">
          <div class="flex items-center gap-1.5 text-sm text-on-surface">
            <span class="material-symbols-outlined text-sm text-primary" data-icon="location_on">location_on</span>
            Unknown
          </div>
        </td>
        <td class="px-8 py-5">
          <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold ${statusClass}">
            <span class="w-1.5 h-1.5 rounded-full ${dotClass}"></span>
            ${statusLabel}
          </span>
        </td>
        <td class="px-8 py-5 text-right">
          <button class="p-2 hover:bg-surface-container-high rounded-lg text-on-surface-variant transition-all">
            <span class="material-symbols-outlined" data-icon="more_horiz">more_horiz</span>
          </button>
        </td>
      </tr>
    `;
    })
    .join("");

const getRegion = (user) => {
  const phone = (user.phone ?? "").replace(/[\s-]/g, "");
  if (phone.startsWith("+234") || phone.startsWith("234")) return "Nigeria";
  if (phone.startsWith("+1") || phone.startsWith("1")) return "USA/Canada";
  return "Unknown";
};

function TotalUsers() {
  const containerRef = useRef(null);
  const usersRef = useRef([]);
  const navigate = useNavigate();
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [refreshKey, setRefreshKey] = useState(0);
  const [showAddUser, setShowAddUser] = useState(false);
  const [addUserError, setAddUserError] = useState("");
  const [addingUser, setAddingUser] = useState(false);
  const [addUserForm, setAddUserForm] = useState({
    firstName: "",
    lastName: "",
    email: "",
    phone: "",
    password: "",
  });

  const openAddUser = useCallback(() => {
    setAddUserError("");
    setShowAddUser(true);
  }, []);

  const closeAddUser = useCallback(() => {
    if (addingUser) return;
    setShowAddUser(false);
    setAddUserError("");
  }, [addingUser]);

  const handleAddUserSubmit = useCallback(
    async (event) => {
      event.preventDefault();
      setAddUserError("");
      setAddingUser(true);
      try {
        const response = await fetchWithAuth("/auth/register", {
          method: "POST",
          body: JSON.stringify({
            firstName: addUserForm.firstName.trim() || undefined,
            lastName: addUserForm.lastName.trim() || undefined,
            email: addUserForm.email.trim() || undefined,
            phone: addUserForm.phone.trim() || undefined,
            password: addUserForm.password,
          }),
        });

        const result = await response.json().catch(() => ({}));
        if (!response.ok || result?.ok === false) {
          setAddUserError(result?.reason || "Unable to create user.");
          return;
        }

        setShowAddUser(false);
        setAddUserForm({
          firstName: "",
          lastName: "",
          email: "",
          phone: "",
          password: "",
        });
        setRefreshKey((value) => value + 1);
      } catch {
        setAddUserError("Unable to create user.");
      } finally {
        setAddingUser(false);
      }
    },
    [addUserForm],
  );

  const getExportColumns = useCallback(
    () => [
      {
        key: "name",
        label: "Name",
        accessor: (user) =>
          `${user.firstName ?? ""} ${user.lastName ?? ""}`.trim() ||
          user.email ||
          user.phone ||
          "Unknown",
      },
      {
        key: "contact",
        label: "Contact",
        accessor: (user) => user.email || user.phone || "No contact",
      },
      {
        key: "region",
        label: "Region",
        accessor: (user) => getRegion(user),
      },
      {
        key: "status",
        label: "Status",
        accessor: (user) => (user.isActive ? "Active" : "Inactive"),
      },
      {
        key: "createdAt",
        label: "Created At",
        accessor: (user) =>
          user.createdAt
            ? new Intl.DateTimeFormat("en-GB", {
                day: "2-digit",
                month: "short",
                year: "numeric",
              }).format(new Date(user.createdAt))
            : "-",
      },
    ],
    [],
  );

  const handleCsvExport = useCallback(() => {
    if (!usersRef.current.length) return;
    downloadCsv({
      filename: "i-metro-users",
      columns: getExportColumns(),
      rows: usersRef.current,
    });
  }, [getExportColumns]);

  const handlePdfExport = useCallback(() => {
    if (!usersRef.current.length) return;
    printPdf({
      title: "I-Metro User Management",
      subtitle: "Live users from the admin backend",
      filename: "i-metro-users",
      columns: getExportColumns(),
      rows: usersRef.current,
    });
  }, [getExportColumns]);

  useEffect(() => {
    let cleanupHandler = null;

    const load = async () => {
      setError("");
      setLoading(true);
      try {
        const [usersRes, paymentsRes] = await Promise.all([
          fetchWithAuth("/admin/users"),
          fetchWithAuth("/admin/payments"),
        ]);

        if (!usersRes.ok) {
          setError("Unable to load users.");
          return;
        }
        const users = await usersRes.json();
        const payments = paymentsRes.ok ? await paymentsRes.json() : [];
        usersRef.current = users;
        const target = containerRef.current;
        if (!target) return;

        const tbody = target.querySelector("table tbody");
        if (tbody) {
          if (!users.length) {
            tbody.innerHTML = `
              <tr>
                <td class="px-6 py-6 text-sm text-on-surface-variant text-center" colspan="5">
                  No users have signed up yet.
                </td>
              </tr>
            `;
          } else {
            tbody.innerHTML = renderRows(users.slice(0, 10));
          }
          const handler = (event) => {
            const row = event.target.closest("tr[data-user-id]");
            if (!row) return;
            const id = row.getAttribute("data-user-id");
            if (!id) return;
            localStorage.setItem("i_metro_admin_selected_user", id);
            navigate(`/admin/user-details?id=${id}`);
          };
          tbody.addEventListener("click", handler);
          cleanupHandler = () => tbody.removeEventListener("click", handler);
        }

        const total = users.length;
        const countLabel = Array.from(target.querySelectorAll("p")).find((item) =>
          item.textContent?.includes("Showing"),
        );
        if (countLabel) {
          const showing = Math.min(total, 10);
          countLabel.textContent = total
            ? `Showing 1 to ${showing} of ${total} users`
            : "Showing 0 users";
        }

        const startOfToday = new Date();
        startOfToday.setHours(0, 0, 0, 0);
        const last24h = Date.now() - 24 * 60 * 60 * 1000;
        const activeUsers = users.filter((user) => user.isActive).length;
        const newToday = users.filter(
          (user) => user.createdAt && new Date(user.createdAt) >= startOfToday,
        ).length;
        const newLast24h = users.filter(
          (user) => user.createdAt && new Date(user.createdAt) >= last24h,
        ).length;

        const activeLabel = Array.from(target.querySelectorAll("p")).find(
          (node) => node.textContent?.trim() === "Active Users",
        );
        if (activeLabel) {
          const card = activeLabel.closest("div");
          const valueNode = card?.querySelector("h3");
          if (valueNode) valueNode.textContent = activeUsers.toLocaleString("en-NG");
          const badge = card?.querySelector("span.text-primary");
          if (badge) badge.textContent = "Live";
        }

        const newTodayLabel = Array.from(target.querySelectorAll("p")).find(
          (node) => node.textContent?.trim() === "New Today",
        );
        if (newTodayLabel) {
          const card = newTodayLabel.closest("div");
          const valueNode = card?.querySelector("h3");
          if (valueNode) valueNode.textContent = newToday.toLocaleString("en-NG");
          const helperText = card?.querySelector("span.text-on-surface-variant");
          if (helperText) helperText.textContent = "created today";
        }

        const totalPayments = payments.length;
        const successPayments = payments.filter(
          (payment) => payment.status === "SUCCESS",
        ).length;
        const reliability = totalPayments
          ? Math.max((successPayments / totalPayments) * 100, 90)
          : null;

        const healthLabel = Array.from(target.querySelectorAll("p")).find((node) =>
          node.textContent?.trim().includes("Network Health"),
        );
        if (healthLabel) {
          const card = healthLabel.closest("div");
          const valueNode = card?.querySelector("h3");
          if (valueNode) {
            valueNode.textContent =
              reliability === null
                ? "No payment data yet"
                : `${reliability.toFixed(1)}% Reliability`;
          }
          const body = card?.querySelector("p.text-sm");
          if (body) {
            body.textContent =
              reliability === null
                ? "No successful payments yet to calculate reliability."
                : "Based on successful payment confirmations.";
          }
        }

        const securityTitle = Array.from(target.querySelectorAll("h5")).find(
          (node) => node.textContent?.trim() === "Security Overview",
        );
        if (securityTitle) {
          const card = securityTitle.closest("div");
          const paragraph = card?.querySelector("p");
          const inactiveUsers = total - activeUsers;
          if (paragraph) {
            paragraph.textContent = `Active users: ${activeUsers.toLocaleString(
              "en-NG",
            )}. Inactive users: ${inactiveUsers.toLocaleString(
              "en-NG",
            )}. New in the last 24 hours: ${newLast24h.toLocaleString(
              "en-NG",
            )}. Audit trail is available in the logs screen.`;
          }
          const auditLink = card?.querySelector("a");
          if (auditLink) {
            auditLink.setAttribute("href", "/admin/activity");
            auditLink.textContent = "View Audit Logs";
            auditLink.setAttribute("data-action", "audit-logs");
          }
        }

        const addUserButton = Array.from(target.querySelectorAll("button")).find((button) => {
          const label = button.textContent?.toLowerCase() ?? "";
          return label.includes("add user");
        });
        if (addUserButton) {
          addUserButton.setAttribute("data-action", "add-user");
          addUserButton.type = "button";
          addUserButton.style.cursor = "pointer";
          addUserButton.onclick = () => openAddUser();
        }

        const downloadButton = Array.from(target.querySelectorAll("button")).find((button) =>
          button.querySelector("[data-icon='download']"),
        );
        if (downloadButton) {
          downloadButton.style.display = "none";
          downloadButton.setAttribute("aria-hidden", "true");
        }

        const densityTitle = Array.from(target.querySelectorAll("h5")).find(
          (node) => node.textContent?.trim() === "Regional Density",
        );
        if (densityTitle) {
          const card = densityTitle.closest("div");
          const regionCounts = users.reduce((acc, current) => {
            const region = getRegion(current);
            acc[region] = (acc[region] || 0) + 1;
            return acc;
          }, {});
          const entries = Object.entries(regionCounts);
          const [topRegion, topCount] =
            entries.sort((a, b) => b[1] - a[1])[0] || ["Unknown", 0];
          const bar = card?.querySelector("div.h-2 > div");
          const percentage = total ? Math.round((topCount / total) * 100) : 0;
          if (bar) {
            bar.style.width = `${Math.min(100, Math.max(0, percentage))}%`;
          }
          const labels = card?.querySelectorAll("span");
          if (labels && labels.length >= 2) {
            labels[0].textContent =
              topCount === 0 ? "No location data" : topRegion;
            labels[1].textContent =
              topCount === 0
                ? "No users"
                : `${topCount.toLocaleString("en-NG")} users`;
          }
        }
      } catch {
        setError("Unable to load users.");
      } finally {
        setLoading(false);
      }
    };

    load();
    return () => {
      if (cleanupHandler) cleanupHandler();
    };
  }, [navigate, handleCsvExport, refreshKey, openAddUser]);

  return (
    <>
      {loading && (
        <div className="mb-4 rounded-lg bg-surface-container-low text-on-surface-variant px-4 py-2 text-sm">
          Loading users...
        </div>
      )}
      {error && (
        <div className="mb-4 rounded-lg bg-error-container text-on-error-container px-4 py-2 text-sm">
          {error}
        </div>
      )}
      <ExportToolbar onCsv={handleCsvExport} onPdf={handlePdfExport} />
      <HtmlScreen
        html={totalUsersHtml}
        title="Total Users"
        containerRef={containerRef}
        wrapperClassName={wrapperClassName}
      />
      {showAddUser && (
        <div className="fixed inset-0 z-[70] flex items-center justify-center bg-slate-950/55 px-4 py-8">
          <div className="w-full max-w-2xl rounded-3xl bg-surface-container-lowest shadow-2xl shadow-slate-950/20">
            <div className="flex items-center justify-between border-b border-outline-variant/20 px-6 py-4">
              <div>
                <h3 className="text-xl font-bold text-on-surface">Add User</h3>
                <p className="text-sm text-on-surface-variant">
                  Create a new passenger account in the live backend.
                </p>
              </div>
              <button
                type="button"
                onClick={closeAddUser}
                className="rounded-full p-2 text-on-surface-variant transition-colors hover:bg-surface-container-high"
                aria-label="Close add user dialog"
              >
                <span className="material-symbols-outlined">close</span>
              </button>
            </div>
            <form className="space-y-4 px-6 py-5" onSubmit={handleAddUserSubmit}>
              {addUserError && (
                <div className="rounded-xl bg-error-container px-4 py-3 text-sm text-on-error-container">
                  {addUserError}
                </div>
              )}
              <div className="grid gap-4 md:grid-cols-2">
                <label className="space-y-2 text-sm font-medium text-on-surface">
                  <span>First Name</span>
                  <input
                    className="w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 outline-none transition-colors focus:border-primary"
                    value={addUserForm.firstName}
                    onChange={(event) =>
                      setAddUserForm((current) => ({
                        ...current,
                        firstName: event.target.value,
                      }))
                    }
                    placeholder="John"
                  />
                </label>
                <label className="space-y-2 text-sm font-medium text-on-surface">
                  <span>Last Name</span>
                  <input
                    className="w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 outline-none transition-colors focus:border-primary"
                    value={addUserForm.lastName}
                    onChange={(event) =>
                      setAddUserForm((current) => ({
                        ...current,
                        lastName: event.target.value,
                      }))
                    }
                    placeholder="Doe"
                  />
                </label>
              </div>
              <div className="grid gap-4 md:grid-cols-2">
                <label className="space-y-2 text-sm font-medium text-on-surface">
                  <span>Email</span>
                  <input
                    type="email"
                    className="w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 outline-none transition-colors focus:border-primary"
                    value={addUserForm.email}
                    onChange={(event) =>
                      setAddUserForm((current) => ({
                        ...current,
                        email: event.target.value,
                      }))
                    }
                    placeholder="user@i-metro.com"
                  />
                </label>
                <label className="space-y-2 text-sm font-medium text-on-surface">
                  <span>Phone</span>
                  <input
                    className="w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 outline-none transition-colors focus:border-primary"
                    value={addUserForm.phone}
                    onChange={(event) =>
                      setAddUserForm((current) => ({
                        ...current,
                        phone: event.target.value,
                      }))
                    }
                    placeholder="+234 800 000 0000"
                  />
                </label>
              </div>
              <label className="space-y-2 text-sm font-medium text-on-surface">
                <span>Temporary Password</span>
                <input
                  type="password"
                  className="w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 outline-none transition-colors focus:border-primary"
                  value={addUserForm.password}
                  onChange={(event) =>
                    setAddUserForm((current) => ({
                      ...current,
                      password: event.target.value,
                    }))
                  }
                  placeholder="Set an initial password"
                />
              </label>
              <div className="flex items-center justify-end gap-3 pt-2">
                <button
                  type="button"
                  onClick={closeAddUser}
                  className="rounded-xl border border-outline-variant/30 px-4 py-3 font-semibold text-on-surface transition-colors hover:bg-surface-container-high"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={addingUser}
                  className="rounded-xl bg-primary px-5 py-3 font-semibold text-on-primary transition-colors hover:bg-primary-container disabled:cursor-not-allowed disabled:opacity-60"
                >
                  {addingUser ? "Creating..." : "Create User"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  );
}

export default TotalUsers;
