import { useEffect, useRef, useState } from "react";

import ExportToolbar from "../components/ExportToolbar";
import HtmlScreen from "./HtmlScreen";
import supportTicketsHtml from "./html/support_ticket_management.html?raw";
import { fetchWithAuth } from "../lib/api";
import { downloadCsv, printPdf } from "../lib/exportTools";

const wrapperClassName = "min-h-screen";

const formatDateTime = (value) => {
  if (!value) return "-";
  const date = new Date(value);
  return new Intl.DateTimeFormat("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  }).format(date);
};

const priorityStyles = {
  Urgent: "text-error",
  High: "text-amber-600",
  Low: "text-on-surface-variant",
};

const statusStyles = {
  Open: "bg-primary/10 text-primary border border-primary/20",
  "In Progress": "bg-amber-100 text-amber-800 border border-amber-200",
  Resolved: "bg-emerald-100 text-emerald-800 border border-emerald-200",
  Pending: "bg-amber-100 text-amber-800 border border-amber-200",
  New: "bg-tertiary-container/10 text-tertiary-container border border-tertiary-container/20",
  Closed: "bg-surface-container text-on-surface-variant border border-outline-variant/30",
};

const statusKey = (ticket) => {
  const raw = ticket.supportStatus ?? ticket.status ?? "";
  return raw.toString().toUpperCase().replace(/\s+/g, "_");
};

const sortOptions = [
  { key: "NEWEST", label: "Newest" },
  { key: "OLDEST", label: "Oldest" },
  { key: "PRIORITY", label: "Priority" },
];

const priorityRank = {
  Urgent: 3,
  High: 2,
  Normal: 1,
  Low: 0,
};

const renderRows = (tickets) =>
  tickets
    .map((ticket) => {
      const priorityClass = priorityStyles[ticket.priority] ?? "text-on-surface-variant";
      const statusClass = statusStyles[ticket.status] ?? statusStyles.Pending;
      const assignee = ticket.assigneeName ?? "Unassigned";
      const initials = ticket.assigneeInitials || "";
      const supportId = ticket.supportId ?? ticket.id;
      return `
      <tr class="hover:bg-surface-container-low/30 transition-colors" data-support-id="${supportId}">
        <td class="px-6 py-5 font-mono text-xs font-semibold text-primary">${ticket.id}</td>
        <td class="px-6 py-5">
          <div class="flex flex-col">
            <span class="text-sm font-bold text-on-surface">${ticket.subject}</span>
            <span class="text-[11px] text-on-surface-variant">${ticket.subtitle ?? ""}</span>
          </div>
        </td>
        <td class="px-6 py-5 text-center">
          <span class="px-3 py-1 bg-secondary-container/30 text-on-secondary-container rounded-full text-[10px] font-bold uppercase">${
            ticket.userType ?? "Passenger"
          }</span>
        </td>
        <td class="px-6 py-5">
          <span class="flex items-center gap-1.5 text-xs font-semibold ${priorityClass}">
            <span class="material-symbols-outlined text-[16px]" data-icon="error" data-weight="fill" style="font-variation-settings: 'FILL' 1;">error</span>
            ${ticket.priority}
          </span>
        </td>
        <td class="px-6 py-5">
          <div class="flex items-center gap-2">
            <div class="w-6 h-6 rounded-full bg-primary-container text-[10px] flex items-center justify-center text-white">
              ${initials || ""}
            </div>
            <span class="text-xs font-medium">${assignee}</span>
          </div>
        </td>
        <td class="px-6 py-5">
          <span class="px-2 py-1 ${statusClass} rounded text-[10px] font-bold uppercase">${
            ticket.status
          }</span>
        </td>
        <td class="px-6 py-5 text-right">
          <div class="flex justify-end gap-2">
            <button class="p-2 hover:bg-surface-container-high rounded-full transition-colors group" title="View Details" data-action="view">
              <span class="material-symbols-outlined text-[18px] text-on-surface-variant group-hover:text-primary" data-icon="visibility">visibility</span>
            </button>
            <button class="p-2 hover:bg-surface-container-high rounded-full transition-colors group" title="Update Status" data-action="status">
              <span class="material-symbols-outlined text-[18px] text-on-surface-variant group-hover:text-primary" data-icon="more_horiz">more_horiz</span>
            </button>
          </div>
        </td>
      </tr>
    `;
    })
    .join("");

const renderActivity = (items) =>
  items
    .map((item) => {
      return `
      <div class="flex gap-4">
        <div class="flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center text-white text-xs" style="background:${
          item.color || "#006B54"
        }">${item.initials}</div>
        <div class="flex flex-col">
          <p class="text-sm text-on-surface">${item.message}</p>
          <span class="text-[10px] text-on-surface-variant">${item.timeAgo}</span>
        </div>
      </div>
    `;
    })
    .join("");

function SupportTicketManagement() {
  const containerRef = useRef(null);
  const reloadRef = useRef(null);
  const ticketsRef = useRef([]);
  const selectedTicketRef = useRef(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [detailError, setDetailError] = useState("");
  const [detailLoading, setDetailLoading] = useState(false);
  const [selectedTicket, setSelectedTicket] = useState(null);

  const getExportColumns = () => [
    { key: "id", label: "Ticket ID", accessor: (ticket) => ticket.id ?? "-" },
    { key: "subject", label: "Subject", accessor: (ticket) => ticket.subject ?? "-" },
    { key: "userType", label: "User Type", accessor: (ticket) => ticket.userType ?? "Passenger" },
    { key: "priority", label: "Priority", accessor: (ticket) => ticket.priority ?? "-" },
    { key: "assignee", label: "Assignee", accessor: (ticket) => ticket.assigneeName ?? "Unassigned" },
    { key: "status", label: "Status", accessor: (ticket) => ticket.status ?? "Open" },
    {
      key: "createdAt",
      label: "Created At",
      accessor: (ticket) =>
        ticket.createdAt
          ? formatDateTime(ticket.createdAt)
          : "-",
    },
  ];

  const handleCsvExport = () => {
    if (!ticketsRef.current.length) return;
    downloadCsv({
      filename: "i-metro-support-tickets",
      columns: getExportColumns(),
      rows: ticketsRef.current,
    });
  };

  const handlePdfExport = () => {
    if (!ticketsRef.current.length) return;
    printPdf({
      title: "I-Metro Support Tickets",
      subtitle: "Live support queue from the admin backend",
      filename: "i-metro-support-tickets",
      columns: getExportColumns(),
      rows: ticketsRef.current,
    });
  };

  const openTicket = (ticket) => {
    setDetailError("");
    setSelectedTicket(ticket);
  };

  const closeTicket = () => {
    setSelectedTicket(null);
    setDetailError("");
  };

  useEffect(() => {
    selectedTicketRef.current = selectedTicket;
  }, [selectedTicket]);

  const updateSupportStatus = async (supportId, status) => {
    if (!supportId || !status) return;
    setDetailLoading(true);
    setDetailError("");
    try {
      const response = await fetchWithAuth(`/admin/support/messages/${supportId}/status`, {
        method: "PATCH",
        body: JSON.stringify({ status }),
      });
      if (!response.ok) {
        setDetailError("Unable to update support status.");
        return;
      }
      const updated = await response.json();
      setSelectedTicket((current) =>
        current && (current.supportId ?? current.id) === supportId
          ? {
              ...current,
              supportStatus: updated.status,
              status:
                updated.status === "IN_PROGRESS"
                  ? "In Progress"
                  : updated.status === "RESOLVED"
                    ? "Resolved"
                    : "Open",
            }
          : current,
      );
      await reloadRef.current?.();
    } catch {
      setDetailError("Unable to update support status.");
    } finally {
      setDetailLoading(false);
    }
  };

  useEffect(() => {
    let cleanupFilter = null;

    const load = async () => {
      setLoading(true);
      setError("");
      try {
        const [ticketsRes, activityRes] = await Promise.all([
          fetchWithAuth("/admin/support/tickets"),
          fetchWithAuth("/admin/support/activity"),
        ]);

        if (!ticketsRes.ok) {
          setError("Unable to load support tickets.");
          return;
        }

        const tickets = await ticketsRes.json();
        ticketsRef.current = tickets;
        const activity = activityRes.ok ? await activityRes.json() : [];
        if (selectedTicketRef.current) {
          const match = tickets.find(
            (ticket) =>
              (ticket.supportId ?? ticket.id) ===
              (selectedTicketRef.current.supportId ?? selectedTicketRef.current.id),
          );
          if (match) {
            setSelectedTicket(match);
          }
        }

        const container = containerRef.current;
        if (!container) return;

        const summaryCards = container.querySelectorAll("div.text-3xl");
        if (summaryCards.length >= 4) {
          const openCount = tickets.filter((ticket) => statusKey(ticket) === "OPEN").length;
          const inProgressCount = tickets.filter(
            (ticket) => statusKey(ticket) === "IN_PROGRESS",
          ).length;
          const resolvedCount = tickets.filter(
            (ticket) => statusKey(ticket) === "RESOLVED",
          ).length;
          const now = Date.now();
          const overdueCount = tickets.filter((ticket) => {
            if (!ticket.createdAt) return false;
            const ageMs = now - new Date(ticket.createdAt).getTime();
            return ageMs > 24 * 60 * 60 * 1000 && statusKey(ticket) !== "RESOLVED";
          }).length;
          summaryCards[0].textContent = openCount.toLocaleString("en-NG");
          summaryCards[1].textContent = inProgressCount.toLocaleString("en-NG");
          summaryCards[2].textContent = resolvedCount.toLocaleString("en-NG");
          summaryCards[3].textContent = overdueCount.toLocaleString("en-NG");
        }

        const tableBody = container.querySelector("table tbody");
        const filterGroup = container.querySelector("[data-filter-group='support-status']");
        const filterButtons = filterGroup
          ? Array.from(filterGroup.querySelectorAll("button[data-filter]"))
          : [];
        const sortButton = container.querySelector("[data-sort-button]");
        const sortLabel = sortButton?.querySelector("[data-sort-label]");
        let currentSortIndex = 0;

        const applySort = (list) => {
          const sortKey = sortOptions[currentSortIndex]?.key ?? "NEWEST";
          const sorted = [...list];
          if (sortKey === "OLDEST") {
            sorted.sort((a, b) => {
              const aTime = a.createdAt ? new Date(a.createdAt).getTime() : 0;
              const bTime = b.createdAt ? new Date(b.createdAt).getTime() : 0;
              return aTime - bTime;
            });
          } else if (sortKey === "PRIORITY") {
            sorted.sort((a, b) => {
              const aRank = priorityRank[a.priority] ?? 0;
              const bRank = priorityRank[b.priority] ?? 0;
              return bRank - aRank;
            });
          } else {
            sorted.sort((a, b) => {
              const aTime = a.createdAt ? new Date(a.createdAt).getTime() : 0;
              const bTime = b.createdAt ? new Date(b.createdAt).getTime() : 0;
              return bTime - aTime;
            });
          }
          return sorted;
        };
        const countLabel = Array.from(container.querySelectorAll("span")).find((node) =>
          node.textContent?.includes("Showing"),
        );
        const updateCountLabel = (count) => {
          if (countLabel) {
            countLabel.textContent = count
              ? `Showing 1-${Math.min(count, 10)} of ${count}`
              : "Showing 0";
          }
        };
        const applyFilter = (filter) => {
          if (!tableBody) return;
          const normalized = (filter ?? "ALL").toUpperCase();
          const filtered =
            normalized === "ALL"
              ? tickets
              : tickets.filter((ticket) => statusKey(ticket) === normalized);
          const sorted = applySort(filtered);
          tableBody.innerHTML = filtered.length
            ? renderRows(sorted)
            : `
              <tr>
                <td class="px-6 py-6 text-sm text-on-surface-variant text-center" colspan="7">
                  No support tickets match this status.
                </td>
              </tr>
            `;
          updateCountLabel(filtered.length);
        };

        let cleanupTable = null;
        if (tableBody) {
          const handler = (event) => {
            const row = event.target.closest("tr[data-support-id]");
            if (!row) return;
            const supportId = row.getAttribute("data-support-id");
            if (!supportId) return;
            const ticket = ticketsRef.current.find(
              (item) => (item.supportId ?? item.id) === supportId,
            );
            if (!ticket) return;
            if (event.target.closest("button[data-action='view']")) {
              openTicket(ticket);
              return;
            }
            if (event.target.closest("button[data-action='status']")) {
              openTicket(ticket);
            }
          };
          tableBody.addEventListener("click", handler);
          cleanupTable = () => tableBody.removeEventListener("click", handler);
        }

        if (filterButtons.length) {
          const setActive = (filter) => {
            filterButtons.forEach((button) => {
              const isActive = button.dataset.filter === filter;
              button.classList.toggle("bg-primary", isActive);
              button.classList.toggle("text-on-primary", isActive);
              button.classList.toggle("text-on-surface-variant", !isActive);
              button.classList.toggle("hover:bg-surface-container-low", !isActive);
            });
          };
          const handler = (event) => {
            const button = event.target.closest("button[data-filter]");
            if (!button) return;
            const filter = button.dataset.filter ?? "ALL";
            setActive(filter);
            applyFilter(filter);
          };
          filterGroup.addEventListener("click", handler);
          cleanupFilter = () => {
            filterGroup.removeEventListener("click", handler);
            if (cleanupTable) cleanupTable();
          };
          setActive("ALL");
          applyFilter("ALL");
        } else if (tableBody) {
          const sorted = applySort(tickets);
          tableBody.innerHTML = tickets.length
            ? renderRows(sorted)
            : `
              <tr>
                <td class="px-6 py-6 text-sm text-on-surface-variant text-center" colspan="7">
                  No support tickets have been submitted yet.
                </td>
              </tr>
            `;
          updateCountLabel(tickets.length);
        }

        if (sortButton && sortLabel) {
          const updateSortLabel = () => {
            sortLabel.textContent = sortOptions[currentSortIndex]?.label ?? "Newest";
          };
          updateSortLabel();
          const sortHandler = () => {
            currentSortIndex = (currentSortIndex + 1) % sortOptions.length;
            updateSortLabel();
            applyFilter(
              filterButtons.find((button) => button.classList.contains("bg-primary"))
                ?.dataset.filter ?? "ALL",
            );
          };
          sortButton.addEventListener("click", sortHandler);
          const prevCleanup = cleanupFilter;
          cleanupFilter = () => {
            sortButton.removeEventListener("click", sortHandler);
            if (cleanupTable) cleanupTable();
            if (prevCleanup) prevCleanup();
          };
        }

        const activityTitle = Array.from(container.querySelectorAll("h3")).find(
          (node) => node.textContent?.trim() === "Team Activity",
        );
        if (activityTitle) {
          const list = activityTitle.parentElement?.querySelector("div.space-y-6");
          if (list) {
            list.innerHTML = activity.length
              ? renderActivity(activity)
              : "<div class='text-sm text-on-surface-variant'>No team activity yet.</div>";
          }
        }

        if (!reloadRef.current) {
          reloadRef.current = load;
        }
      } catch {
        setError("Unable to load support tickets.");
      } finally {
        setLoading(false);
      }
    };

    reloadRef.current = load;
    load();

    return () => {
      reloadRef.current = null;
      if (cleanupFilter) cleanupFilter();
    };
  }, []);

  return (
    <>
      {loading && (
        <div className="mb-4 rounded-lg bg-surface-container-low text-on-surface-variant px-4 py-2 text-sm">
          Loading support tickets...
        </div>
      )}
      {error && (
        <div className="mb-4 rounded-lg bg-error-container text-on-error-container px-4 py-2 text-sm">
          {error}
        </div>
      )}
      <ExportToolbar onCsv={handleCsvExport} onPdf={handlePdfExport} />
      <HtmlScreen
        html={supportTicketsHtml}
        title="Support Ticket Management"
        containerRef={containerRef}
        wrapperClassName={wrapperClassName}
      />
      {selectedTicket && (
        <div
          className="fixed inset-0 z-[60] flex items-center justify-center bg-black/50 px-4 py-8"
          onClick={closeTicket}
          role="presentation"
        >
          <div
            className="w-full max-w-3xl rounded-3xl bg-surface-container-lowest shadow-2xl border border-outline-variant/20 overflow-hidden"
            onClick={(event) => event.stopPropagation()}
            role="presentation"
          >
            <div className="flex items-start justify-between gap-4 border-b border-outline-variant/10 px-6 py-5">
              <div>
                <p className="text-xs font-semibold uppercase tracking-[0.2em] text-on-surface-variant">
                  Support Message Details
                </p>
                <h3 className="mt-1 text-2xl font-bold text-on-surface">
                  {selectedTicket.subject}
                </h3>
                <p className="mt-1 text-sm text-on-surface-variant">
                  {selectedTicket.subtitle ?? "Incoming commuter support request"}
                </p>
              </div>
              <button
                className="rounded-full p-2 text-on-surface-variant hover:bg-surface-container-low"
                onClick={closeTicket}
                type="button"
              >
                <span className="material-symbols-outlined">close</span>
              </button>
            </div>

            <div className="grid gap-6 px-6 py-6 lg:grid-cols-[1.2fr_0.8fr]">
              <div className="space-y-5">
                <div className="grid gap-4 sm:grid-cols-2">
                  <div className="rounded-2xl bg-surface-container-low px-4 py-3">
                    <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                      Support ID
                    </p>
                    <p className="mt-1 font-mono text-sm font-semibold text-on-surface">
                      {selectedTicket.supportId ?? selectedTicket.id}
                    </p>
                  </div>
                  <div className="rounded-2xl bg-surface-container-low px-4 py-3">
                    <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                      Current Status
                    </p>
                    <p className="mt-1 text-sm font-semibold text-on-surface">
                      {selectedTicket.status}
                    </p>
                  </div>
                  <div className="rounded-2xl bg-surface-container-low px-4 py-3">
                    <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                      Submitted By
                    </p>
                    <p className="mt-1 text-sm font-semibold text-on-surface">
                      {selectedTicket.name ||
                        selectedTicket.email ||
                        selectedTicket.phone ||
                        "I-Metro Rider"}
                    </p>
                  </div>
                  <div className="rounded-2xl bg-surface-container-low px-4 py-3">
                    <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                      Created
                    </p>
                    <p className="mt-1 text-sm font-semibold text-on-surface">
                      {formatDateTime(selectedTicket.createdAt)}
                    </p>
                  </div>
                </div>

                <div className="rounded-2xl border border-outline-variant/15 bg-white px-4 py-4">
                  <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                    Full Message
                  </p>
                  <p className="mt-3 whitespace-pre-wrap text-sm leading-6 text-on-surface">
                    {selectedTicket.message}
                  </p>
                </div>

                <div className="rounded-2xl bg-surface-container-low px-4 py-4">
                  <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                    Contact Details
                  </p>
                  <div className="mt-3 grid gap-3 sm:grid-cols-2">
                    <div>
                      <p className="text-xs text-on-surface-variant">Email</p>
                      <p className="text-sm font-semibold text-on-surface">
                        {selectedTicket.email || "-"}
                      </p>
                    </div>
                    <div>
                      <p className="text-xs text-on-surface-variant">Phone</p>
                      <p className="text-sm font-semibold text-on-surface">
                        {selectedTicket.phone || "-"}
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="space-y-4">
                <div className="rounded-2xl bg-primary/5 px-4 py-4 border border-primary/10">
                  <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-primary">
                    Status Actions
                  </p>
                  <p className="mt-2 text-sm text-on-surface-variant">
                    Move this ticket through the support flow.
                  </p>
                  {detailError && (
                    <div className="mt-3 rounded-xl bg-error-container px-3 py-2 text-sm text-on-error-container">
                      {detailError}
                    </div>
                  )}
                  <div className="mt-4 space-y-3">
                    <button
                      className="w-full rounded-xl border border-outline-variant/20 bg-white px-4 py-3 text-left text-sm font-semibold text-on-surface hover:bg-surface-container-low disabled:opacity-60"
                      disabled={detailLoading}
                      onClick={() => updateSupportStatus(selectedTicket.supportId ?? selectedTicket.id, "OPEN")}
                      type="button"
                    >
                      Open
                    </button>
                    <button
                      className="w-full rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-left text-sm font-semibold text-amber-800 hover:bg-amber-100 disabled:opacity-60"
                      disabled={detailLoading}
                      onClick={() =>
                        updateSupportStatus(
                          selectedTicket.supportId ?? selectedTicket.id,
                          "IN_PROGRESS",
                        )
                      }
                      type="button"
                    >
                      In Progress
                    </button>
                    <button
                      className="w-full rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-left text-sm font-semibold text-emerald-800 hover:bg-emerald-100 disabled:opacity-60"
                      disabled={detailLoading}
                      onClick={() =>
                        updateSupportStatus(
                          selectedTicket.supportId ?? selectedTicket.id,
                          "RESOLVED",
                        )
                      }
                      type="button"
                    >
                      Resolved
                    </button>
                  </div>
                  <button
                    className="mt-4 w-full rounded-xl bg-primary px-4 py-3 text-sm font-semibold text-on-primary hover:opacity-95 disabled:opacity-60"
                    disabled={detailLoading}
                    onClick={closeTicket}
                    type="button"
                  >
                    Close Ticket
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
}

export default SupportTicketManagement;
