import { useCallback, useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";

import ExportToolbar from "../components/ExportToolbar";
import HtmlScreen from "./HtmlScreen";
import availableRoutesHtml from "./html/available_routes.html?raw";
import { fetchWithAuth } from "../lib/api";
import { downloadCsv, printPdf } from "../lib/exportTools";

const wrapperClassName = "min-h-screen";

const formatCurrency = (value) => {
  if (value === null || value === undefined) return "-";
  const amount = Number(value);
  if (Number.isNaN(amount)) return "-";
  return `NGN ${amount.toLocaleString("en-NG", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })}`;
};

const renderRows = (routes) =>
  routes
    .map((route) => {
      const statusLabel = route.isActive ? "Active" : "Inactive";
      const statusClass = route.isActive
        ? "bg-emerald-100 text-emerald-800"
        : "bg-slate-100 text-slate-600";
      const dotClass = route.isActive ? "bg-emerald-600" : "bg-slate-400";
      const routeId = route.id.replace(/-/g, "").slice(0, 6).toUpperCase();
      return `
      <tr class="hover:bg-surface-container-low/30 transition-colors" data-route-id="${route.id}">
        <td class="px-8 py-6">
          <span class="font-mono text-xs font-semibold px-2 py-1 bg-surface-container-high rounded text-on-surface">RT-${routeId}</span>
        </td>
        <td class="px-8 py-6">
          <div class="flex flex-col">
            <span class="font-bold text-on-surface">${route.fromLocation}</span>
            <span class="text-xs text-on-surface-variant">Pickup</span>
          </div>
        </td>
        <td class="px-8 py-6">
          <div class="flex flex-col">
            <span class="font-bold text-on-surface">${route.toLocation}</span>
            <span class="text-xs text-on-surface-variant">Destination</span>
          </div>
        </td>
        <td class="px-8 py-6">
          <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full ${statusClass} text-xs font-bold">
            <span class="w-1.5 h-1.5 rounded-full ${dotClass}"></span>
            ${statusLabel}
          </span>
        </td>
        <td class="px-8 py-6 text-right">
          <span class="font-bold text-on-surface">${formatCurrency(
            route.price,
            route.currency ?? "NGN",
          )}</span>
        </td>
        <td class="px-8 py-6 text-right">
          <div class="flex items-center justify-end gap-2">
            <button class="p-2 hover:bg-surface-container rounded-full transition-colors text-on-surface-variant" data-action="edit">
              <span class="material-symbols-outlined" data-icon="edit">edit</span>
            </button>
            <button class="p-2 hover:bg-surface-container rounded-full transition-colors text-on-surface-variant" data-action="delete">
              <span class="material-symbols-outlined" data-icon="delete">delete</span>
            </button>
          </div>
        </td>
      </tr>
    `;
    })
    .join("");

function AvailableRoutes() {
  const containerRef = useRef(null);
  const routesRef = useRef([]);
  const tableHandlerRef = useRef(null);
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const getExportColumns = useCallback(() => [
    {
      key: "routeId",
      label: "Route ID",
      accessor: (route) =>
        route.__summary
          ? "TOTAL"
          : `RT-${route.id.replace(/-/g, "").slice(0, 6).toUpperCase()}`,
    },
    {
      key: "fromLocation",
      label: "Pickup Point",
      accessor: (route) => (route.__summary ? "Grand total" : route.fromLocation || "-"),
    },
    {
      key: "toLocation",
      label: "Destination",
      accessor: (route) => (route.__summary ? "-" : route.toLocation || "-"),
    },
    {
      key: "status",
      label: "Status",
      accessor: (route) => (route.__summary ? "-" : route.isActive ? "Active" : "Inactive"),
    },
    {
      key: "price",
      label: "Price",
      accessor: (route) => formatCurrency(route.price, route.currency ?? "NGN"),
    },
  ], []);

  const loadRoutes = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const response = await fetchWithAuth("/admin/routes");
      if (!response.ok) {
        setError("Unable to load routes.");
        return;
      }
      const routes = await response.json();
      routesRef.current = routes;
      const target = containerRef.current;
      if (!target) return;

      const activeCount = routes.filter((route) => route.isActive).length;
      const inactiveCount = routes.length - activeCount;
      const totalFare = routes.reduce((sum, route) => sum + (Number(route.price) || 0), 0);
      const averageFare = routes.length ? totalFare / routes.length : 0;

      const setText = (selector, value) => {
        const node = target.querySelector(selector);
        if (node) {
          node.textContent = value;
        }
      };

      setText(
        "[data-route-summary]",
        routes.length
          ? `Manage ${routes.length} live routes from the backend.`
          : "No live routes yet. Add the first route to start service.",
      );
      setText("[data-route-total-count]", routes.length.toLocaleString("en-NG"));
      setText("[data-route-active-count]", activeCount.toLocaleString("en-NG"));
      setText("[data-route-inactive-count]", inactiveCount.toLocaleString("en-NG"));
      setText("[data-route-average-fare]", formatCurrency(averageFare));
      setText(
        "[data-route-pagination]",
        routes.length
          ? `Showing all ${routes.length} live routes from the backend.`
          : "Showing 0 live routes from the backend.",
      );
      setText("[data-route-insight='active-count']", activeCount.toLocaleString("en-NG"));
      setText("[data-route-insight='inactive-count']", inactiveCount.toLocaleString("en-NG"));
      setText(
        "[data-route-insight='summary']",
        routes.length
          ? `${activeCount} active and ${inactiveCount} inactive routes. Average fare ${formatCurrency(averageFare)}.`
          : "No routes yet. Add the first route to start service.",
      );

      const activeBar = target.querySelector("[data-route-active-bar]");
      if (activeBar) {
        const percent = routes.length ? Math.round((activeCount / routes.length) * 100) : 0;
        activeBar.style.width = `${percent}%`;
      }

      const tbody = target.querySelector("table tbody");
      if (tbody) {
        if (tableHandlerRef.current) {
          tbody.removeEventListener("click", tableHandlerRef.current);
          tableHandlerRef.current = null;
        }
        if (!routes.length) {
          tbody.innerHTML = `
            <tr>
              <td class="px-8 py-10 text-sm text-on-surface-variant text-center" colspan="6">
                No live routes yet. Add the first route to start service.
              </td>
            </tr>
          `;
        } else {
          tbody.innerHTML = renderRows(routes);
        }
        const handler = async (event) => {
          const row = event.target.closest("tr[data-route-id]");
          if (!row) return;
          const id = row.getAttribute("data-route-id");
          if (!id) return;
          if (event.target.closest("button[data-action='edit']")) {
            localStorage.setItem("i_metro_admin_selected_route", id);
            navigate(`/admin/routes/edit?id=${id}`);
            return;
          }
          if (event.target.closest("button[data-action='delete']")) {
            const confirmed = window.confirm("Delete this route?");
            if (!confirmed) return;
            const delResponse = await fetchWithAuth(`/admin/routes/${id}`, {
              method: "DELETE",
            });
            if (delResponse.ok) {
              window.dispatchEvent(new Event("i-metro:routes-updated"));
            }
          }
        };
        tbody.addEventListener("click", handler);
        tableHandlerRef.current = handler;
      }

      const addButtons = Array.from(target.querySelectorAll("button")).filter(
        (button) =>
          button.dataset.action === "add-route" ||
          button.textContent?.includes("Add New Transit Route") ||
          button.textContent?.includes("New Route"),
      );
      addButtons.forEach((button) => {
        if (!button.dataset.bound) {
          button.dataset.bound = "true";
          button.addEventListener("click", () => navigate("/admin/routes/add"));
        }
      });

      const exportButton = Array.from(target.querySelectorAll("button")).find((button) =>
        button.querySelector("[data-icon='download']"),
      );
      if (exportButton) {
        exportButton.style.display = "none";
        exportButton.setAttribute("aria-hidden", "true");
      }
    } catch {
      setError("Unable to load routes.");
    } finally {
      setLoading(false);
    }
  }, [navigate]);

  const handleCsvExport = useCallback(() => {
    if (!routesRef.current.length) return;
    const total = routesRef.current.reduce((sum, route) => sum + (Number(route.price) || 0), 0);
    downloadCsv({
      filename: "i-metro-routes",
      columns: getExportColumns(),
      rows: [...routesRef.current, { __summary: true, price: total }],
    });
  }, [getExportColumns]);

  const handlePdfExport = useCallback(() => {
    if (!routesRef.current.length) return;
    const total = routesRef.current.reduce((sum, route) => sum + (Number(route.price) || 0), 0);
    printPdf({
      title: "I-Metro Route Management",
      subtitle: "Live route list from the admin backend",
      filename: "i-metro-routes",
      columns: getExportColumns(),
      rows: [...routesRef.current, { __summary: true, price: total }],
    });
  }, [getExportColumns]);

  useEffect(() => {
    const mountedContainer = containerRef.current;
    void loadRoutes();
    const refreshHandler = () => {
      void loadRoutes();
    };
    window.addEventListener("i-metro:routes-updated", refreshHandler);
    return () => {
      const tbody = mountedContainer?.querySelector("table tbody");
      if (tbody && tableHandlerRef.current) {
        tbody.removeEventListener("click", tableHandlerRef.current);
        tableHandlerRef.current = null;
      }
      window.removeEventListener("i-metro:routes-updated", refreshHandler);
    };
  }, [loadRoutes]);

  return (
    <>
      {loading && (
        <div className="mb-4 rounded-lg bg-surface-container-low text-on-surface-variant px-4 py-2 text-sm">
          Loading routes...
        </div>
      )}
      {error && (
        <div className="mb-4 rounded-lg bg-error-container text-on-error-container px-4 py-2 text-sm">
          {error}
        </div>
      )}
      <ExportToolbar onCsv={handleCsvExport} onPdf={handlePdfExport} />
      <HtmlScreen
        html={availableRoutesHtml}
        title="Route Management"
        containerRef={containerRef}
        wrapperClassName={wrapperClassName}
      />
    </>
  );
}

export default AvailableRoutes;
