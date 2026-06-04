import { useEffect, useMemo, useState } from "react";

import { fetchWithAuth } from "../lib/api";

const emptyForm = {
  id: null,
  title: "",
  body: "",
  isActive: true,
  isPinned: false,
  startsAt: "",
  expiresAt: "",
};

const toneClassNames = {
  success: "bg-primary-fixed-dim/15 text-primary",
  error: "bg-error-container text-on-error-container",
  info: "bg-surface-container-low text-on-surface-variant",
};

const formatDateTime = (value) => {
  if (!value) return "Not scheduled";
  return new Intl.DateTimeFormat("en-NG", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(new Date(value));
};

const toInputDateTime = (value) => {
  if (!value) return "";
  const date = new Date(value);
  const pad = (segment) => String(segment).padStart(2, "0");
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(
    date.getHours(),
  )}:${pad(date.getMinutes())}`;
};

const toApiDateTime = (value) => {
  if (!value) return null;
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) return null;
  return parsed.toISOString();
};

function AdminAnnouncements() {
  const [announcements, setAnnouncements] = useState([]);
  const [form, setForm] = useState(emptyForm);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState("");
  const [messageTone, setMessageTone] = useState("info");

  const activeCount = useMemo(
    () => announcements.filter((announcement) => announcement.isActive).length,
    [announcements],
  );
  const pinnedCount = useMemo(
    () => announcements.filter((announcement) => announcement.isPinned).length,
    [announcements],
  );

  const showMessage = (text, tone = "info") => {
    setMessage(text);
    setMessageTone(tone);
  };

  const loadAnnouncements = async () => {
    setLoading(true);
    try {
      const response = await fetchWithAuth("/admin/announcements");
      const payload = await response.json();
      if (!response.ok) {
        throw new Error(payload?.message ?? "Unable to load announcements.");
      }
      setAnnouncements(Array.isArray(payload) ? payload : []);
      showMessage("Announcements synced with the live backend.", "success");
    } catch (error) {
      showMessage(error.message || "Unable to load announcements.", "error");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void loadAnnouncements();
  }, []);

  const resetForm = () => {
    setForm(emptyForm);
  };

  const handleChange = (field, value) => {
    setForm((current) => ({
      ...current,
      [field]: value,
    }));
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    if (saving) return;

    const payload = {
      title: form.title.trim(),
      body: form.body.trim(),
      isActive: form.isActive,
      isPinned: form.isPinned,
      startsAt: toApiDateTime(form.startsAt),
      expiresAt: toApiDateTime(form.expiresAt),
    };

    if (!payload.title || !payload.body) {
      showMessage("Title and announcement body are required.", "error");
      return;
    }

    setSaving(true);
    try {
      const isEditing = Boolean(form.id);
      const response = await fetchWithAuth(
        isEditing ? `/admin/announcements/${form.id}` : "/admin/announcements",
        {
          method: isEditing ? "PATCH" : "POST",
          body: JSON.stringify(payload),
        },
      );
      const result = await response.json();
      if (!response.ok) {
        throw new Error(result?.message ?? "Unable to save announcement.");
      }
      showMessage(
        isEditing ? "Announcement updated successfully." : "Announcement published successfully.",
        "success",
      );
      resetForm();
      await loadAnnouncements();
    } catch (error) {
      showMessage(error.message || "Unable to save announcement.", "error");
    } finally {
      setSaving(false);
    }
  };

  const handleEdit = (announcement) => {
    setForm({
      id: announcement.id,
      title: announcement.title ?? "",
      body: announcement.body ?? "",
      isActive: Boolean(announcement.isActive),
      isPinned: Boolean(announcement.isPinned),
      startsAt: toInputDateTime(announcement.startsAt),
      expiresAt: toInputDateTime(announcement.expiresAt),
    });
    showMessage(`Editing "${announcement.title}".`, "info");
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const handleDelete = async (announcement) => {
    const confirmed = window.confirm(
      `Delete "${announcement.title}"? This will remove it from the rider app.`,
    );
    if (!confirmed) return;

    try {
      const response = await fetchWithAuth(`/admin/announcements/${announcement.id}`, {
        method: "DELETE",
      });
      const payload = await response.json();
      if (!response.ok) {
        throw new Error(payload?.message ?? "Unable to delete announcement.");
      }
      showMessage("Announcement deleted.", "success");
      if (form.id === announcement.id) {
        resetForm();
      }
      await loadAnnouncements();
    } catch (error) {
      showMessage(error.message || "Unable to delete announcement.", "error");
    }
  };

  const handleQuickUpdate = async (announcement, updates) => {
    try {
      const response = await fetchWithAuth(`/admin/announcements/${announcement.id}`, {
        method: "PATCH",
        body: JSON.stringify(updates),
      });
      const payload = await response.json();
      if (!response.ok) {
        throw new Error(payload?.message ?? "Unable to update announcement.");
      }
      showMessage(`"${announcement.title}" updated.`, "success");
      await loadAnnouncements();
    } catch (error) {
      showMessage(error.message || "Unable to update announcement.", "error");
    }
  };

  return (
    <div className="space-y-6">
      {message ? (
        <div className={`rounded-2xl px-4 py-3 text-sm font-medium ${toneClassNames[messageTone]}`}>
          {saving ? "Saving announcement..." : message}
        </div>
      ) : null}

      <section className="rounded-3xl border border-outline-variant/10 bg-surface-container-lowest p-6 shadow-[0px_10px_30px_rgba(25,28,29,0.06)]">
        <div className="flex flex-col gap-6 lg:flex-row lg:items-start lg:justify-between">
          <div className="max-w-2xl">
            <p className="text-xs font-bold uppercase tracking-[0.2em] text-on-surface-variant">
              Rider communications
            </p>
            <h1 className="mt-2 text-4xl font-bold tracking-tight text-on-surface">
              Announcements
            </h1>
            <p className="mt-3 text-base leading-7 text-on-surface-variant">
              Publish service updates here and they will appear in the rider app home banner and
              announcements feed.
            </p>
          </div>

          <div className="grid gap-4 sm:grid-cols-3 lg:min-w-[440px]">
            <div className="rounded-2xl bg-surface-container-low p-4">
              <p className="text-xs font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                Total
              </p>
              <p className="mt-3 text-3xl font-bold text-on-surface">{announcements.length}</p>
            </div>
            <div className="rounded-2xl bg-surface-container-low p-4">
              <p className="text-xs font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                Active
              </p>
              <p className="mt-3 text-3xl font-bold text-on-surface">{activeCount}</p>
            </div>
            <div className="rounded-2xl bg-surface-container-low p-4">
              <p className="text-xs font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                Pinned
              </p>
              <p className="mt-3 text-3xl font-bold text-on-surface">{pinnedCount}</p>
            </div>
          </div>
        </div>
      </section>

      <div className="grid gap-6 xl:grid-cols-[420px_1fr]">
        <section className="rounded-3xl border border-outline-variant/10 bg-surface-container-lowest p-6 shadow-[0px_10px_30px_rgba(25,28,29,0.06)]">
          <div className="flex items-start justify-between gap-4">
            <div>
              <h2 className="text-xl font-bold text-on-surface">
                {form.id ? "Edit announcement" : "Publish announcement"}
              </h2>
              <p className="mt-1 text-sm text-on-surface-variant">
                Keep riders informed about route changes, fares, and service notices.
              </p>
            </div>
            {form.id ? (
              <button
                className="rounded-full bg-surface-container-low px-4 py-2 text-xs font-semibold text-on-surface-variant hover:bg-surface-container-high"
                onClick={resetForm}
                type="button"
              >
                Cancel edit
              </button>
            ) : null}
          </div>

          <form className="mt-6 space-y-4" onSubmit={handleSubmit}>
            <label className="block space-y-2">
              <span className="text-xs font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                Title
              </span>
              <input
                className="w-full rounded-2xl border border-outline-variant/20 bg-surface px-4 py-3 text-sm text-on-surface outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/15"
                maxLength={120}
                onChange={(event) => handleChange("title", event.target.value)}
                placeholder="Service update"
                value={form.title}
              />
            </label>

            <label className="block space-y-2">
              <span className="text-xs font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                Announcement body
              </span>
              <textarea
                className="min-h-[160px] w-full rounded-2xl border border-outline-variant/20 bg-surface px-4 py-3 text-sm leading-6 text-on-surface outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/15"
                maxLength={3000}
                onChange={(event) => handleChange("body", event.target.value)}
                placeholder="Tell riders exactly what they need to know."
                value={form.body}
              />
            </label>

            <div className="grid gap-4 sm:grid-cols-2">
              <label className="block space-y-2">
                <span className="text-xs font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                  Starts at
                </span>
                <input
                  className="w-full rounded-2xl border border-outline-variant/20 bg-surface px-4 py-3 text-sm text-on-surface outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/15"
                  onChange={(event) => handleChange("startsAt", event.target.value)}
                  type="datetime-local"
                  value={form.startsAt}
                />
              </label>
              <label className="block space-y-2">
                <span className="text-xs font-bold uppercase tracking-[0.18em] text-on-surface-variant">
                  Expires at
                </span>
                <input
                  className="w-full rounded-2xl border border-outline-variant/20 bg-surface px-4 py-3 text-sm text-on-surface outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/15"
                  onChange={(event) => handleChange("expiresAt", event.target.value)}
                  type="datetime-local"
                  value={form.expiresAt}
                />
              </label>
            </div>

            <div className="grid gap-3 sm:grid-cols-2">
              <label className="flex items-center gap-3 rounded-2xl bg-surface-container-low px-4 py-3">
                <input
                  checked={form.isActive}
                  className="h-4 w-4 accent-[var(--color-primary)]"
                  onChange={(event) => handleChange("isActive", event.target.checked)}
                  type="checkbox"
                />
                <span className="text-sm font-medium text-on-surface">Visible to riders</span>
              </label>
              <label className="flex items-center gap-3 rounded-2xl bg-surface-container-low px-4 py-3">
                <input
                  checked={form.isPinned}
                  className="h-4 w-4 accent-[var(--color-primary)]"
                  onChange={(event) => handleChange("isPinned", event.target.checked)}
                  type="checkbox"
                />
                <span className="text-sm font-medium text-on-surface">Pin to the top</span>
              </label>
            </div>

            <div className="flex flex-wrap gap-3 pt-2">
              <button
                className="inline-flex items-center justify-center rounded-2xl bg-primary px-5 py-3 text-sm font-semibold text-on-primary transition hover:opacity-95 disabled:cursor-not-allowed disabled:opacity-60"
                disabled={saving}
                type="submit"
              >
                {form.id ? "Save changes" : "Publish announcement"}
              </button>
              <button
                className="inline-flex items-center justify-center rounded-2xl bg-surface-container-low px-5 py-3 text-sm font-semibold text-on-surface-variant transition hover:bg-surface-container-high"
                onClick={() => void loadAnnouncements()}
                type="button"
              >
                Refresh list
              </button>
            </div>
          </form>
        </section>

        <section className="rounded-3xl border border-outline-variant/10 bg-surface-container-lowest p-6 shadow-[0px_10px_30px_rgba(25,28,29,0.06)]">
          <div className="flex items-center justify-between gap-4">
            <div>
              <h2 className="text-xl font-bold text-on-surface">Published announcements</h2>
              <p className="mt-1 text-sm text-on-surface-variant">
                These are the notices your riders can see in the app.
              </p>
            </div>
            {loading ? (
              <span className="text-sm font-medium text-on-surface-variant">Loading...</span>
            ) : null}
          </div>

          <div className="mt-6 space-y-4">
            {!announcements.length && !loading ? (
              <div className="rounded-2xl border border-dashed border-outline-variant/25 bg-surface-container-low px-5 py-10 text-center text-sm text-on-surface-variant">
                No announcements yet. Publish the first one and it will show up in the rider app.
              </div>
            ) : null}

            {announcements.map((announcement) => (
              <article
                className="rounded-2xl border border-outline-variant/10 bg-surface-container-low p-5"
                key={announcement.id}
              >
                <div className="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
                  <div className="min-w-0 flex-1">
                    <div className="flex flex-wrap items-center gap-2">
                      {announcement.isPinned ? (
                        <span className="rounded-full bg-primary-fixed-dim/20 px-3 py-1 text-[11px] font-bold uppercase tracking-[0.18em] text-primary">
                          Pinned
                        </span>
                      ) : null}
                      <span
                        className={`rounded-full px-3 py-1 text-[11px] font-bold uppercase tracking-[0.18em] ${
                          announcement.isActive
                            ? "bg-emerald-100 text-emerald-800"
                            : "bg-surface text-on-surface-variant"
                        }`}
                      >
                        {announcement.isActive ? "Active" : "Hidden"}
                      </span>
                    </div>
                    <h3 className="mt-3 text-xl font-bold text-on-surface">{announcement.title}</h3>
                    <p className="mt-2 whitespace-pre-wrap text-sm leading-6 text-on-surface-variant">
                      {announcement.body}
                    </p>
                    <div className="mt-4 grid gap-3 text-xs text-on-surface-variant sm:grid-cols-3">
                      <div>
                        <p className="font-bold uppercase tracking-[0.16em]">Created</p>
                        <p className="mt-1">{formatDateTime(announcement.createdAt)}</p>
                      </div>
                      <div>
                        <p className="font-bold uppercase tracking-[0.16em]">Starts</p>
                        <p className="mt-1">{formatDateTime(announcement.startsAt)}</p>
                      </div>
                      <div>
                        <p className="font-bold uppercase tracking-[0.16em]">Expires</p>
                        <p className="mt-1">{formatDateTime(announcement.expiresAt)}</p>
                      </div>
                    </div>
                  </div>

                  <div className="flex flex-wrap gap-2 lg:w-[260px] lg:justify-end">
                    <button
                      className="rounded-full bg-white px-4 py-2 text-xs font-semibold text-on-surface shadow-sm hover:bg-surface"
                      onClick={() => handleEdit(announcement)}
                      type="button"
                    >
                      Edit
                    </button>
                    <button
                      className="rounded-full bg-white px-4 py-2 text-xs font-semibold text-on-surface shadow-sm hover:bg-surface"
                      onClick={() =>
                        handleQuickUpdate(announcement, { isPinned: !announcement.isPinned })
                      }
                      type="button"
                    >
                      {announcement.isPinned ? "Unpin" : "Pin"}
                    </button>
                    <button
                      className="rounded-full bg-white px-4 py-2 text-xs font-semibold text-on-surface shadow-sm hover:bg-surface"
                      onClick={() =>
                        handleQuickUpdate(announcement, { isActive: !announcement.isActive })
                      }
                      type="button"
                    >
                      {announcement.isActive ? "Hide" : "Activate"}
                    </button>
                    <button
                      className="rounded-full bg-error-container px-4 py-2 text-xs font-semibold text-on-error-container hover:opacity-90"
                      onClick={() => void handleDelete(announcement)}
                      type="button"
                    >
                      Delete
                    </button>
                  </div>
                </div>
              </article>
            ))}
          </div>
        </section>
      </div>
    </div>
  );
}

export default AdminAnnouncements;
