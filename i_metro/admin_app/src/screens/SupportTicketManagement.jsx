import { useEffect, useMemo, useState } from "react";
import { useSearchParams } from "react-router-dom";

import ExportToolbar from "../components/ExportToolbar";
import { fetchWithAuth } from "../lib/api";
import { downloadCsv, printPdf } from "../lib/exportTools";

const statusStyles = {
  OPEN: "bg-primary/10 text-primary border border-primary/20",
  IN_PROGRESS: "bg-amber-100 text-amber-800 border border-amber-200",
  RESOLVED: "bg-emerald-100 text-emerald-800 border border-emerald-200",
  PENDING: "bg-amber-100 text-amber-800 border border-amber-200",
  CONTACTED: "bg-sky-100 text-sky-800 border border-sky-200",
  APPROVED: "bg-emerald-100 text-emerald-800 border border-emerald-200",
  DECLINED: "bg-rose-100 text-rose-800 border border-rose-200",
  COMPLETED: "bg-slate-200 text-slate-700 border border-slate-300",
};

const formatDateTime = (value) => {
  if (!value) return "-";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "-";
  return new Intl.DateTimeFormat("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  }).format(date);
};

const formatDate = (value) => {
  if (!value) return "-";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "-";
  return new Intl.DateTimeFormat("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  }).format(date);
};

const supportStatusLabel = (status) => {
  switch (String(status || "").toUpperCase()) {
    case "IN_PROGRESS":
      return "In Progress";
    case "RESOLVED":
      return "Resolved";
    case "OPEN":
    default:
      return "Open";
  }
};

const busHireStatusLabel = (status) => {
  switch (String(status || "").toUpperCase()) {
    case "CONTACTED":
      return "Contacted";
    case "APPROVED":
      return "Approved";
    case "DECLINED":
      return "Declined";
    case "COMPLETED":
      return "Completed";
    case "PENDING":
    default:
      return "Pending";
  }
};

const busHireStatusOptions = ["PENDING", "CONTACTED", "APPROVED", "DECLINED", "COMPLETED"];

function SummaryCard({ title, value, note, tone = "default" }) {
  const toneMap = {
    default: "bg-white border-outline-variant/15 text-on-surface",
    primary: "bg-primary text-white border-primary/10",
    warm: "bg-secondary-container/15 text-on-surface border-secondary-container/30",
    success: "bg-emerald-50 text-emerald-900 border-emerald-200",
  };

  return (
    <div
      className={`rounded-3xl border px-5 py-5 shadow-[0px_12px_26px_rgba(25,28,29,0.05)] ${
        toneMap[tone] ?? toneMap.default
      }`}
    >
      <p className="text-xs font-semibold uppercase tracking-[0.18em] opacity-70">{title}</p>
      <p className="mt-3 text-3xl font-bold tracking-tight">{value}</p>
      <p className="mt-2 text-sm opacity-80">{note}</p>
    </div>
  );
}

function SupportTicketModal({ ticket, busy, error, onClose, onUpdateStatus }) {
  if (!ticket) return null;

  const currentStatus = String(ticket.supportStatus || "OPEN").toUpperCase();

  return (
    <div
      className="fixed inset-0 z-[60] flex items-center justify-center bg-black/50 px-4 py-8"
      onClick={onClose}
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
            <h3 className="mt-1 text-2xl font-bold text-on-surface">{ticket.subject}</h3>
            <p className="mt-1 text-sm text-on-surface-variant">
              {ticket.subtitle ?? "Incoming commuter support request"}
            </p>
          </div>
          <button
            className="rounded-full p-2 text-on-surface-variant hover:bg-surface-container-low"
            onClick={onClose}
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
                  {ticket.supportId ?? ticket.id}
                </p>
              </div>
              <div className="rounded-2xl bg-surface-container-low px-4 py-3">
                <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                  Current Status
                </p>
                <p className="mt-1 text-sm font-semibold text-on-surface">
                  {supportStatusLabel(currentStatus)}
                </p>
              </div>
              <div className="rounded-2xl bg-surface-container-low px-4 py-3">
                <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                  Submitted By
                </p>
                <p className="mt-1 text-sm font-semibold text-on-surface">
                  {ticket.name || ticket.email || ticket.phone || "I-Metro Rider"}
                </p>
              </div>
              <div className="rounded-2xl bg-surface-container-low px-4 py-3">
                <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                  Created
                </p>
                <p className="mt-1 text-sm font-semibold text-on-surface">
                  {formatDateTime(ticket.createdAt)}
                </p>
              </div>
            </div>

            <div className="rounded-2xl border border-outline-variant/15 bg-white px-4 py-4">
              <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                Full Message
              </p>
              <p className="mt-3 whitespace-pre-wrap text-sm leading-6 text-on-surface">
                {ticket.message}
              </p>
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
              {error && (
                <div className="mt-3 rounded-xl bg-error-container px-3 py-2 text-sm text-on-error-container">
                  {error}
                </div>
              )}
              <div className="mt-4 space-y-3">
                {["OPEN", "IN_PROGRESS", "RESOLVED"].map((status) => (
                  <button
                    key={status}
                    className={`w-full rounded-xl border px-4 py-3 text-left text-sm font-semibold disabled:opacity-60 ${
                      statusStyles[status] ?? statusStyles.OPEN
                    }`}
                    disabled={busy}
                    onClick={() => onUpdateStatus(ticket.supportId ?? ticket.id, status)}
                    type="button"
                  >
                    {supportStatusLabel(status)}
                  </button>
                ))}
              </div>
              <button
                className="mt-4 w-full rounded-xl bg-primary px-4 py-3 text-sm font-semibold text-on-primary hover:opacity-95 disabled:opacity-60"
                disabled={busy}
                onClick={onClose}
                type="button"
              >
                Close Ticket
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function BusHireModal({ request, busy, error, onClose, onSave }) {
  const [status, setStatus] = useState(request?.status || "PENDING");
  const [comments, setComments] = useState(request?.adminComments || "");
  const [assignedBuses, setAssignedBuses] = useState(
    Array.isArray(request?.assignedBuses) ? request.assignedBuses.join(", ") : "",
  );

  useEffect(() => {
    setStatus(request?.status || "PENDING");
    setComments(request?.adminComments || "");
    setAssignedBuses(Array.isArray(request?.assignedBuses) ? request.assignedBuses.join(", ") : "");
  }, [request]);

  if (!request) return null;

  return (
    <div
      className="fixed inset-0 z-[60] flex items-center justify-center bg-black/50 px-4 py-8"
      onClick={onClose}
      role="presentation"
    >
      <div
        className="w-full max-w-5xl rounded-3xl bg-surface-container-lowest shadow-2xl border border-outline-variant/20 overflow-hidden"
        onClick={(event) => event.stopPropagation()}
        role="presentation"
      >
        <div className="flex items-start justify-between gap-4 border-b border-outline-variant/10 px-6 py-5">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.2em] text-on-surface-variant">
              Bus Hire Request
            </p>
            <h3 className="mt-1 text-2xl font-bold text-on-surface">{request.title}</h3>
            <p className="mt-1 text-sm text-on-surface-variant">
              {request.eventType} · {formatDate(request.serviceDate)} at {request.serviceTime}
            </p>
          </div>
          <button
            className="rounded-full p-2 text-on-surface-variant hover:bg-surface-container-low"
            onClick={onClose}
            type="button"
          >
            <span className="material-symbols-outlined">close</span>
          </button>
        </div>

        <div className="grid gap-6 px-6 py-6 lg:grid-cols-[1.15fr_0.85fr]">
          <div className="space-y-5">
            <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
              {[
                ["Request ID", request.id],
                ["Date of Service", formatDate(request.serviceDate)],
                ["Time of Service", request.serviceTime],
                ["Phone Number", request.phoneNumber],
                ["WhatsApp Number", request.whatsappNumber],
                ["Email Address", request.email || "Not provided"],
                ["Pick-up Point", request.pickupPoint],
                ["Drop-off Point", request.dropoffPoint],
                ["Destination", request.destination],
                ["Number of Trips", String(request.numberOfTrips)],
                ["Buses Needed", String(request.numberOfBusesNeeded)],
                ["Status", busHireStatusLabel(request.status)],
              ].map(([label, value]) => (
                <div key={label} className="rounded-2xl bg-surface-container-low px-4 py-3">
                  <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                    {label}
                  </p>
                  <p className="mt-1 text-sm font-semibold text-on-surface">{value}</p>
                </div>
              ))}
            </div>

            <div className="rounded-2xl border border-outline-variant/15 bg-white px-4 py-4">
              <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                Additional Notes / Special Request
              </p>
              <p className="mt-3 whitespace-pre-wrap text-sm leading-6 text-on-surface">
                {request.additionalNotes || "No additional notes provided."}
              </p>
            </div>
          </div>

          <div className="space-y-4">
            <div className="rounded-2xl bg-primary/5 px-4 py-4 border border-primary/10">
              <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-primary">
                Operations Update
              </p>
              <p className="mt-2 text-sm text-on-surface-variant">
                Track request status, add feedback, and assign available buses.
              </p>
              {error && (
                <div className="mt-3 rounded-xl bg-error-container px-3 py-2 text-sm text-on-error-container">
                  {error}
                </div>
              )}
              <label className="mt-4 block">
                <span className="mb-2 block text-xs font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                  Status
                </span>
                <select
                  className="w-full rounded-xl border border-outline-variant/25 bg-white px-4 py-3 text-sm text-on-surface"
                  onChange={(event) => setStatus(event.target.value)}
                  value={status}
                >
                  {busHireStatusOptions.map((option) => (
                    <option key={option} value={option}>
                      {busHireStatusLabel(option)}
                    </option>
                  ))}
                </select>
              </label>
              <label className="mt-4 block">
                <span className="mb-2 block text-xs font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                  Assigned Buses
                </span>
                <input
                  className="w-full rounded-xl border border-outline-variant/25 bg-white px-4 py-3 text-sm text-on-surface"
                  onChange={(event) => setAssignedBuses(event.target.value)}
                  placeholder="Bus 01, Bus 04, Bus 11"
                  type="text"
                  value={assignedBuses}
                />
              </label>
              <label className="mt-4 block">
                <span className="mb-2 block text-xs font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                  Feedback / Comments
                </span>
                <textarea
                  className="min-h-[140px] w-full rounded-xl border border-outline-variant/25 bg-white px-4 py-3 text-sm text-on-surface"
                  onChange={(event) => setComments(event.target.value)}
                  placeholder="Add admin feedback, follow-up notes, or approval comments"
                  value={comments}
                />
              </label>

              <button
                className="mt-5 w-full rounded-xl bg-primary px-4 py-3 text-sm font-semibold text-on-primary hover:opacity-95 disabled:opacity-60"
                disabled={busy}
                onClick={() =>
                  onSave(request.id, {
                    status,
                    adminComments: comments,
                    assignedBuses: assignedBuses
                      .split(",")
                      .map((value) => value.trim())
                      .filter(Boolean),
                  })
                }
                type="button"
              >
                {busy ? "Saving..." : "Save Bus Hire Update"}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function SupportTable({ tickets, onOpen }) {
  return (
    <div className="overflow-hidden rounded-3xl border border-outline-variant/15 bg-white shadow-[0px_16px_32px_rgba(25,28,29,0.05)]">
      <div className="overflow-x-auto">
        <table className="min-w-full text-left">
          <thead className="bg-surface-container-low">
            <tr>
              {["Ticket ID", "Subject", "Passenger", "Priority", "Status", "Created", "Actions"].map(
                (heading) => (
                  <th
                    key={heading}
                    className="px-5 py-4 text-[11px] font-bold uppercase tracking-[0.16em] text-on-surface-variant"
                  >
                    {heading}
                  </th>
                ),
              )}
            </tr>
          </thead>
          <tbody>
            {tickets.length === 0 ? (
              <tr>
                <td className="px-5 py-8 text-center text-sm text-on-surface-variant" colSpan={7}>
                  No support tickets have been submitted yet.
                </td>
              </tr>
            ) : (
              tickets.map((ticket) => {
                const statusKey = String(ticket.supportStatus || "OPEN").toUpperCase();
                return (
                  <tr
                    key={ticket.supportId ?? ticket.id}
                    className="border-t border-outline-variant/10 hover:bg-surface-container-low/30"
                  >
                    <td className="px-5 py-4 font-mono text-xs font-semibold text-primary">{ticket.id}</td>
                    <td className="px-5 py-4">
                      <p className="text-sm font-semibold text-on-surface">{ticket.subject}</p>
                      <p className="mt-1 text-xs text-on-surface-variant">{ticket.subtitle}</p>
                    </td>
                    <td className="px-5 py-4 text-sm text-on-surface-variant">
                      {ticket.name || ticket.email || ticket.phone || "I-Metro Rider"}
                    </td>
                    <td className="px-5 py-4 text-sm font-semibold text-on-surface">{ticket.priority}</td>
                    <td className="px-5 py-4">
                      <span
                        className={`inline-flex rounded-full px-3 py-1 text-[10px] font-bold uppercase ${
                          statusStyles[statusKey] ?? statusStyles.OPEN
                        }`}
                      >
                        {supportStatusLabel(statusKey)}
                      </span>
                    </td>
                    <td className="px-5 py-4 text-sm text-on-surface-variant">
                      {formatDateTime(ticket.createdAt)}
                    </td>
                    <td className="px-5 py-4 text-right">
                      <button
                        className="rounded-full border border-outline-variant/20 px-3 py-2 text-sm font-semibold text-primary hover:bg-surface-container-low"
                        onClick={() => onOpen(ticket)}
                        type="button"
                      >
                        View
                      </button>
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function BusHireTable({ requests, onOpen }) {
  return (
    <div className="overflow-hidden rounded-3xl border border-outline-variant/15 bg-white shadow-[0px_16px_32px_rgba(25,28,29,0.05)]">
      <div className="overflow-x-auto">
        <table className="min-w-full text-left">
          <thead className="bg-surface-container-low">
            <tr>
              {["Requester", "Date", "Route / Destination", "Buses", "Status", "Assigned", "Actions"].map(
                (heading) => (
                  <th
                    key={heading}
                    className="px-5 py-4 text-[11px] font-bold uppercase tracking-[0.16em] text-on-surface-variant"
                  >
                    {heading}
                  </th>
                ),
              )}
            </tr>
          </thead>
          <tbody>
            {requests.length === 0 ? (
              <tr>
                <td className="px-5 py-8 text-center text-sm text-on-surface-variant" colSpan={7}>
                  No bus hire requests have been submitted yet.
                </td>
              </tr>
            ) : (
              requests.map((request) => {
                const statusKey = String(request.status || "PENDING").toUpperCase();
                return (
                  <tr
                    key={request.id}
                    className="border-t border-outline-variant/10 hover:bg-surface-container-low/30"
                  >
                    <td className="px-5 py-4">
                      <p className="text-sm font-semibold text-on-surface">{request.title}</p>
                      <p className="mt-1 text-xs text-on-surface-variant">{request.phoneNumber}</p>
                    </td>
                    <td className="px-5 py-4 text-sm text-on-surface-variant">
                      <div>{formatDate(request.serviceDate)}</div>
                      <div className="mt-1 text-xs">{request.serviceTime}</div>
                    </td>
                    <td className="px-5 py-4 text-sm text-on-surface-variant">
                      <p>{request.pickupPoint}</p>
                      <p className="mt-1">to {request.destination}</p>
                    </td>
                    <td className="px-5 py-4 text-sm font-semibold text-on-surface">
                      {request.numberOfBusesNeeded}
                    </td>
                    <td className="px-5 py-4">
                      <span
                        className={`inline-flex rounded-full px-3 py-1 text-[10px] font-bold uppercase ${
                          statusStyles[statusKey] ?? statusStyles.PENDING
                        }`}
                      >
                        {busHireStatusLabel(statusKey)}
                      </span>
                    </td>
                    <td className="px-5 py-4 text-sm text-on-surface-variant">
                      {Array.isArray(request.assignedBuses) && request.assignedBuses.length
                        ? request.assignedBuses.join(", ")
                        : "Unassigned"}
                    </td>
                    <td className="px-5 py-4 text-right">
                      <button
                        className="rounded-full border border-outline-variant/20 px-3 py-2 text-sm font-semibold text-primary hover:bg-surface-container-low"
                        onClick={() => onOpen(request)}
                        type="button"
                      >
                        Manage
                      </button>
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function CalendarPanel({ requests, fleetCapacity }) {
  const grouped = useMemo(() => {
    const map = new Map();
    requests.forEach((request) => {
      const key = String(request.serviceDate || "").slice(0, 10);
      if (!key) return;
      if (!map.has(key)) {
        map.set(key, []);
      }
      map.get(key).push(request);
    });
    return Array.from(map.entries())
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([dateKey, entries]) => {
        const booked = entries
          .filter((entry) => ["APPROVED", "COMPLETED"].includes(String(entry.status || "").toUpperCase()))
          .reduce((sum, entry) => sum + Number(entry.numberOfBusesNeeded || 0), 0);
        return {
          dateKey,
          entries,
          booked,
          available: Math.max(0, Number(fleetCapacity || 0) - booked),
        };
      });
  }, [fleetCapacity, requests]);

  return (
    <div className="rounded-3xl border border-outline-variant/15 bg-white p-6 shadow-[0px_16px_32px_rgba(25,28,29,0.05)]">
      <div className="flex flex-col gap-2 md:flex-row md:items-end md:justify-between">
        <div>
          <p className="text-xs font-semibold uppercase tracking-[0.18em] text-on-surface-variant">
            Calendar View
          </p>
          <h3 className="mt-1 text-2xl font-bold tracking-tight text-on-surface">
            Bus availability by service date
          </h3>
        </div>
        <div className="rounded-2xl bg-primary/5 px-4 py-3 text-sm text-on-surface">
          Fleet capacity: <span className="font-bold text-primary">{fleetCapacity}</span> buses
        </div>
      </div>

      <div className="mt-6 grid gap-4 lg:grid-cols-2 2xl:grid-cols-3">
        {grouped.length === 0 ? (
          <div className="rounded-2xl border border-dashed border-outline-variant/30 px-4 py-8 text-sm text-on-surface-variant">
            No scheduled bus hire dates yet.
          </div>
        ) : (
          grouped.map((day) => (
            <div
              key={day.dateKey}
              className="rounded-2xl border border-outline-variant/15 bg-surface-container-low p-4"
            >
              <div className="flex items-start justify-between gap-3">
                <div>
                  <p className="text-xs font-semibold uppercase tracking-[0.18em] text-on-surface-variant">
                    {formatDate(day.dateKey)}
                  </p>
                  <p className="mt-2 text-sm text-on-surface-variant">
                    {day.entries.length} request{day.entries.length === 1 ? "" : "s"} scheduled
                  </p>
                </div>
                <div className="text-right">
                  <p className="text-xs text-on-surface-variant">Booked</p>
                  <p className="text-lg font-bold text-primary">{day.booked}</p>
                  <p className="mt-1 text-xs text-on-surface-variant">Available {day.available}</p>
                </div>
              </div>

              <div className="mt-4 space-y-3">
                {day.entries.map((entry) => (
                  <div key={entry.id} className="rounded-2xl bg-white px-4 py-3 border border-outline-variant/10">
                    <div className="flex items-start justify-between gap-3">
                      <div>
                        <p className="text-sm font-semibold text-on-surface">{entry.title}</p>
                        <p className="mt-1 text-xs text-on-surface-variant">
                          {entry.serviceTime} · {entry.numberOfBusesNeeded} bus
                          {entry.numberOfBusesNeeded === 1 ? "" : "es"} · {entry.eventType}
                        </p>
                      </div>
                      <span
                        className={`inline-flex rounded-full px-2.5 py-1 text-[10px] font-bold uppercase ${
                          statusStyles[String(entry.status || "PENDING").toUpperCase()] ?? statusStyles.PENDING
                        }`}
                      >
                        {busHireStatusLabel(entry.status)}
                      </span>
                    </div>
                    <p className="mt-3 text-xs text-on-surface-variant">
                      Assigned buses:{" "}
                      <span className="font-semibold text-on-surface">
                        {Array.isArray(entry.assignedBuses) && entry.assignedBuses.length
                          ? entry.assignedBuses.join(", ")
                          : "Unassigned"}
                      </span>
                    </p>
                  </div>
                ))}
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}

function SupportTicketManagement() {
  const [searchParams, setSearchParams] = useSearchParams();
  const [activeTab, setActiveTab] = useState(searchParams.get("tab") === "busHire" ? "busHire" : "support");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [supportTickets, setSupportTickets] = useState([]);
  const [supportActivity, setSupportActivity] = useState([]);
  const [busHireItems, setBusHireItems] = useState([]);
  const [fleetCapacity, setFleetCapacity] = useState(12);
  const [selectedSupport, setSelectedSupport] = useState(null);
  const [selectedBusHire, setSelectedBusHire] = useState(null);
  const [supportActionBusy, setSupportActionBusy] = useState(false);
  const [busHireActionBusy, setBusHireActionBusy] = useState(false);
  const [supportActionError, setSupportActionError] = useState("");
  const [busHireActionError, setBusHireActionError] = useState("");

  const load = async () => {
    setLoading(true);
    setError("");
    try {
      const [ticketsRes, activityRes, busHireRes] = await Promise.all([
        fetchWithAuth("/admin/support/tickets"),
        fetchWithAuth("/admin/support/activity"),
        fetchWithAuth("/admin/bus-hire/requests"),
      ]);

      const tickets = ticketsRes.ok ? await ticketsRes.json() : [];
      const activity = activityRes.ok ? await activityRes.json() : [];
      const busHirePayload = busHireRes.ok ? await busHireRes.json() : { items: [], fleetCapacity: 12 };

      setSupportTickets(Array.isArray(tickets) ? tickets : []);
      setSupportActivity(Array.isArray(activity) ? activity : []);
      setBusHireItems(Array.isArray(busHirePayload?.items) ? busHirePayload.items : []);
      setFleetCapacity(Number(busHirePayload?.fleetCapacity || 12));
    } catch {
      setError("Unable to load customer request operations right now.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  useEffect(() => {
    setActiveTab(searchParams.get("tab") === "busHire" ? "busHire" : "support");
  }, [searchParams]);

  const supportSummary = useMemo(() => {
    const open = supportTickets.filter((ticket) => String(ticket.supportStatus || "").toUpperCase() === "OPEN").length;
    const inProgress = supportTickets.filter(
      (ticket) => String(ticket.supportStatus || "").toUpperCase() === "IN_PROGRESS",
    ).length;
    const resolved = supportTickets.filter(
      (ticket) => String(ticket.supportStatus || "").toUpperCase() === "RESOLVED",
    ).length;
    return { open, inProgress, resolved };
  }, [supportTickets]);

  const busHireSummary = useMemo(() => {
    const pending = busHireItems.filter((item) => String(item.status || "").toUpperCase() === "PENDING").length;
    const approved = busHireItems.filter((item) => String(item.status || "").toUpperCase() === "APPROVED").length;
    const completed = busHireItems.filter((item) => String(item.status || "").toUpperCase() === "COMPLETED").length;
    const upcomingBooked = busHireItems
      .filter((item) => ["APPROVED", "COMPLETED"].includes(String(item.status || "").toUpperCase()))
      .reduce((sum, item) => sum + Number(item.numberOfBusesNeeded || 0), 0);
    return { pending, approved, completed, upcomingBooked };
  }, [busHireItems]);

  const exportRows = activeTab === "support" ? supportTickets : busHireItems;
  const exportColumns =
    activeTab === "support"
      ? [
          { key: "id", label: "Ticket ID", accessor: (row) => row.id ?? "-" },
          { key: "subject", label: "Subject", accessor: (row) => row.subject ?? "-" },
          { key: "status", label: "Status", accessor: (row) => supportStatusLabel(row.supportStatus) },
          { key: "name", label: "Passenger", accessor: (row) => row.name || row.email || row.phone || "-" },
          { key: "createdAt", label: "Created", accessor: (row) => formatDateTime(row.createdAt) },
        ]
      : [
          { key: "id", label: "Request ID", accessor: (row) => row.id ?? "-" },
          { key: "title", label: "Requester", accessor: (row) => row.title ?? "-" },
          { key: "serviceDate", label: "Date", accessor: (row) => formatDate(row.serviceDate) },
          { key: "serviceTime", label: "Time", accessor: (row) => row.serviceTime ?? "-" },
          { key: "buses", label: "Buses Needed", accessor: (row) => row.numberOfBusesNeeded ?? "-" },
          { key: "status", label: "Status", accessor: (row) => busHireStatusLabel(row.status) },
        ];

  const handleCsvExport = () => {
    if (!exportRows.length) return;
    downloadCsv({
      filename: activeTab === "support" ? "i-metro-support-tickets" : "i-metro-bus-hire-requests",
      columns: exportColumns,
      rows: exportRows,
    });
  };

  const handlePdfExport = () => {
    if (!exportRows.length) return;
    printPdf({
      title:
        activeTab === "support" ? "I-Metro Support Tickets" : "I-Metro Bus Hire Requests",
      subtitle:
        activeTab === "support"
          ? "Live support queue from the admin backend"
          : "Live bus hire and charter requests from the website",
      filename: activeTab === "support" ? "i-metro-support-tickets" : "i-metro-bus-hire-requests",
      columns: exportColumns,
      rows: exportRows,
    });
  };

  const updateSupportStatus = async (supportId, status) => {
    setSupportActionBusy(true);
    setSupportActionError("");
    try {
      const response = await fetchWithAuth(`/admin/support/messages/${supportId}/status`, {
        method: "PATCH",
        body: JSON.stringify({ status }),
      });
      if (!response.ok) {
        throw new Error("Unable to update support status.");
      }
      const updated = await response.json();
      setSelectedSupport((current) =>
        current && (current.supportId ?? current.id) === supportId
          ? {
              ...current,
              supportStatus: updated.status,
              status: supportStatusLabel(updated.status),
            }
          : current,
      );
      await load();
    } catch (err) {
      setSupportActionError(err instanceof Error ? err.message : "Unable to update support status.");
    } finally {
      setSupportActionBusy(false);
    }
  };

  const updateBusHireRequest = async (requestId, payload) => {
    setBusHireActionBusy(true);
    setBusHireActionError("");
    try {
      const response = await fetchWithAuth(`/admin/bus-hire/requests/${requestId}`, {
        method: "PATCH",
        body: JSON.stringify(payload),
      });
      if (!response.ok) {
        throw new Error("Unable to update bus hire request.");
      }
      const updated = await response.json();
      setSelectedBusHire((current) =>
        current && current.id === requestId
          ? {
              ...current,
              status: updated.status,
              adminComments: updated.adminComments,
              assignedBuses: updated.assignedBuses,
            }
          : current,
      );
      await load();
    } catch (err) {
      setBusHireActionError(err instanceof Error ? err.message : "Unable to update bus hire request.");
    } finally {
      setBusHireActionBusy(false);
    }
  };

  useEffect(() => {
    const supportId = searchParams.get("supportId");
    if (!supportId || activeTab !== "support" || selectedSupport) return;

    const matchingTicket = supportTickets.find(
      (ticket) => (ticket.supportId ?? ticket.id) === supportId || ticket.id === supportId,
    );

    if (matchingTicket) {
      setSelectedSupport(matchingTicket);
    }
  }, [activeTab, searchParams, selectedSupport, supportTickets]);

  useEffect(() => {
    const requestId = searchParams.get("requestId");
    if (!requestId || activeTab !== "busHire" || selectedBusHire) return;

    const matchingRequest = busHireItems.find((item) => item.id === requestId);

    if (matchingRequest) {
      setSelectedBusHire(matchingRequest);
    }
  }, [activeTab, busHireItems, searchParams, selectedBusHire]);

  return (
    <>
      {loading && (
        <div className="mb-4 rounded-lg bg-surface-container-low text-on-surface-variant px-4 py-2 text-sm">
          Loading customer request operations...
        </div>
      )}
      {error && (
        <div className="mb-4 rounded-lg bg-error-container text-on-error-container px-4 py-2 text-sm">
          {error}
        </div>
      )}
      <ExportToolbar onCsv={handleCsvExport} onPdf={handlePdfExport} />

      <div className="space-y-6">
        <div className="rounded-[28px] bg-white border border-outline-variant/15 px-6 py-6 shadow-[0px_16px_40px_rgba(25,28,29,0.06)]">
          <div className="flex flex-col gap-5 xl:flex-row xl:items-end xl:justify-between">
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.2em] text-on-surface-variant">
                Customer Operations
              </p>
              <h1 className="mt-2 text-3xl md:text-4xl font-bold tracking-tight text-on-surface">
                Support & Bus Hire Requests
              </h1>
              <p className="mt-3 max-w-3xl text-sm md:text-base text-on-surface-variant">
                Manage commuter support tickets, review bus hire requests, and keep fleet availability visible for events and special movements.
              </p>
            </div>

            <div className="inline-flex rounded-full bg-surface-container-low p-1.5">
              {[
                { key: "support", label: "Support Tickets" },
                { key: "busHire", label: "Bus Hire Requests" },
              ].map((tab) => (
                <button
                  key={tab.key}
                  className={`rounded-full px-5 py-3 text-sm font-semibold transition-colors ${
                    activeTab === tab.key
                      ? "bg-primary text-on-primary shadow-sm"
                      : "text-on-surface-variant hover:text-primary"
                  }`}
                  onClick={() => {
                    setSearchParams({ tab: tab.key });
                    setSelectedSupport(null);
                    setSelectedBusHire(null);
                  }}
                  type="button"
                >
                  {tab.label}
                </button>
              ))}
            </div>
          </div>
        </div>

        {activeTab === "support" ? (
          <>
            <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
              <SummaryCard
                title="Open"
                value={supportSummary.open}
                note="Awaiting first response"
                tone="primary"
              />
              <SummaryCard
                title="In Progress"
                value={supportSummary.inProgress}
                note="Currently being handled"
                tone="warm"
              />
              <SummaryCard
                title="Resolved"
                value={supportSummary.resolved}
                note="Closed successfully"
                tone="success"
              />
              <SummaryCard
                title="Activity Feed"
                value={supportActivity.length}
                note="Recent queue updates"
              />
            </div>

            <SupportTable tickets={supportTickets} onOpen={setSelectedSupport} />

            <div className="rounded-3xl border border-outline-variant/15 bg-white p-6 shadow-[0px_16px_32px_rgba(25,28,29,0.05)]">
              <p className="text-xs font-semibold uppercase tracking-[0.18em] text-on-surface-variant">
                Team Activity
              </p>
              <div className="mt-5 grid gap-4 lg:grid-cols-2">
                {supportActivity.length === 0 ? (
                  <p className="text-sm text-on-surface-variant">No recent support activity yet.</p>
                ) : (
                  supportActivity.map((entry, index) => (
                    <div
                      key={`${entry.message}-${index}`}
                      className="flex gap-4 rounded-2xl bg-surface-container-low px-4 py-4"
                    >
                      <div
                        className="flex h-10 w-10 items-center justify-center rounded-full text-xs font-bold text-white"
                        style={{ background: entry.color || "#006B54" }}
                      >
                        {entry.initials}
                      </div>
                      <div>
                        <p className="text-sm text-on-surface">{entry.message}</p>
                        <p className="mt-1 text-xs text-on-surface-variant">{entry.timeAgo}</p>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>
          </>
        ) : (
          <>
            <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
              <SummaryCard
                title="Pending"
                value={busHireSummary.pending}
                note="Awaiting first call-back"
                tone="warm"
              />
              <SummaryCard
                title="Approved"
                value={busHireSummary.approved}
                note="Reserved and ready"
                tone="success"
              />
              <SummaryCard
                title="Completed"
                value={busHireSummary.completed}
                note="Closed movements"
                tone="default"
              />
              <SummaryCard
                title="Fleet Snapshot"
                value={`${busHireSummary.upcomingBooked}/${fleetCapacity}`}
                note="Booked vs total buses"
                tone="primary"
              />
            </div>

            <BusHireTable requests={busHireItems} onOpen={setSelectedBusHire} />
            <CalendarPanel requests={busHireItems} fleetCapacity={fleetCapacity} />
          </>
        )}
      </div>

      <SupportTicketModal
        busy={supportActionBusy}
        error={supportActionError}
        onClose={() => {
          setSelectedSupport(null);
          setSupportActionError("");
          setSearchParams({ tab: "support" });
        }}
        onUpdateStatus={updateSupportStatus}
        ticket={selectedSupport}
      />

      <BusHireModal
        busy={busHireActionBusy}
        error={busHireActionError}
        onClose={() => {
          setSelectedBusHire(null);
          setBusHireActionError("");
          setSearchParams({ tab: "busHire" });
        }}
        onSave={updateBusHireRequest}
        request={selectedBusHire}
      />
    </>
  );
}

export default SupportTicketManagement;
