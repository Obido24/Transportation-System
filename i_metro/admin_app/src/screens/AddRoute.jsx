import { useCallback, useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";

import HtmlScreen from "./HtmlScreen";
import addRouteHtml from "./html/add_route.html?raw";
import { fetchWithAuth } from "../lib/api";

const wrapperClassName = "min-h-screen";

const formatCurrency = (value) => {
  const amount = Number(value);
  if (!Number.isFinite(amount)) {
    return "NGN 0";
  }
  return `NGN ${amount.toLocaleString("en-NG", {
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  })}`;
};

function AddRoute() {
  const containerRef = useRef(null);
  const navigate = useNavigate();
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [loading, setLoading] = useState(false);
  const [statsLoading, setStatsLoading] = useState(true);

  const updatePreview = useCallback(() => {
    const container = containerRef.current;
    if (!container) return;

    const fromLocation = container.querySelector('[data-setting="from-location"]')?.value?.trim() ?? "";
    const toLocation = container.querySelector('[data-setting="to-location"]')?.value?.trim() ?? "";
    const priceRaw = container.querySelector('[data-setting="price"]')?.value ?? "";
    const price = Number(priceRaw);

    const previewRoute = container.querySelector('[data-setting="preview-route"]');
    const previewPrice = container.querySelector('[data-setting="preview-price"]');

    if (previewRoute) {
      previewRoute.textContent =
        fromLocation && toLocation ? `${fromLocation} → ${toLocation}` : "No route entered yet";
    }
    if (previewPrice) {
      previewPrice.textContent = Number.isFinite(price) && price >= 0 ? formatCurrency(price) : "NGN 0";
    }
  }, []);

  const loadRouteStats = useCallback(async () => {
    setStatsLoading(true);
    try {
      const response = await fetchWithAuth("/admin/routes");
      if (!response.ok) {
        throw new Error("Unable to load routes.");
      }
      const routes = await response.json();
      const totalRoutes = routes.length;
      const activeRoutes = routes.filter((route) => route.isActive).length;
      const averageFare = totalRoutes
        ? Math.round(routes.reduce((sum, route) => sum + (Number(route.price) || 0), 0) / totalRoutes)
        : 0;
      const activePercent = totalRoutes ? Math.round((activeRoutes / totalRoutes) * 100) : 0;

      const container = containerRef.current;
      if (!container) return;

      const totalNode = container.querySelector('[data-setting="route-total"]');
      const activeNode = container.querySelector('[data-setting="route-active"]');
      const averageNode = container.querySelector('[data-setting="route-average"]');
      const barNode = container.querySelector('[data-setting="route-activity-bar"]');
      const noteNode = container.querySelector('[data-setting="route-note"]');
      const recentList = container.querySelector('[data-setting="recent-routes"]');

      if (totalNode) totalNode.textContent = totalRoutes.toLocaleString("en-NG");
      if (activeNode) activeNode.textContent = activeRoutes.toLocaleString("en-NG");
      if (averageNode) averageNode.textContent = formatCurrency(averageFare);
      if (barNode) barNode.style.width = `${Math.min(100, Math.max(0, activePercent))}%`;
      if (noteNode) {
        noteNode.textContent = totalRoutes
          ? `${activeRoutes} of ${totalRoutes} routes are currently active in the backend.`
          : "No routes have been created yet.";
      }
      if (recentList) {
        const liveRoutes = routes.slice(0, 3);
        recentList.innerHTML = liveRoutes.length
          ? liveRoutes
              .map((route) => `<li>${route.fromLocation} → ${route.toLocation} · ${formatCurrency(route.price)}</li>`)
              .join("")
          : "<li>No live routes to display.</li>";
      }
    } catch {
      const container = containerRef.current;
      if (container) {
        const noteNode = container.querySelector('[data-setting="route-note"]');
        const recentList = container.querySelector('[data-setting="recent-routes"]');
        if (noteNode) noteNode.textContent = "Unable to load live route stats right now.";
        if (recentList) recentList.innerHTML = "<li>Backend data unavailable.</li>";
      }
    } finally {
      setStatsLoading(false);
    }
  }, []);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return undefined;

    const form = container.querySelector("form");
    if (!form) return undefined;

    const handleSubmit = async (event) => {
      event.preventDefault();
      setError("");
      setSuccess("");

      const fromLocation = container.querySelector('[data-setting="from-location"]')?.value?.trim() ?? "";
      const toLocation = container.querySelector('[data-setting="to-location"]')?.value?.trim() ?? "";
      const priceRaw = container.querySelector('[data-setting="price"]')?.value ?? "";
      const price = Number(priceRaw);

      if (!fromLocation || !toLocation || !Number.isFinite(price) || price < 0) {
        setError("Please enter a pickup, destination, and valid NGN price.");
        return;
      }

      setLoading(true);
      try {
        const response = await fetchWithAuth("/admin/routes", {
          method: "POST",
          body: JSON.stringify({
            fromLocation,
            toLocation,
            price: Math.round(price),
            currency: "NGN",
            isActive: true,
          }),
        });

        const result = await response.json().catch(() => ({}));
        if (!response.ok) {
          setError(result?.message ?? "Unable to create route.");
          return;
        }

        setSuccess("Route created successfully.");
        window.dispatchEvent(new Event("i-metro:routes-updated"));
        await loadRouteStats();
        navigate("/admin/routes");
      } catch {
        setError("Unable to create route.");
      } finally {
        setLoading(false);
      }
    };

    const handleInput = () => updatePreview();
    const handleDiscard = () => {
      form.reset();
      updatePreview();
      setSuccess("");
      setError("");
    };
    const handleNewRoute = () => {
      container.querySelector('[data-setting="from-location"]')?.focus();
    };

    const discardButton = container.querySelector('[data-action="discard"]');
    const newRouteButton = container.querySelector('[data-action="new-route"]');
    const inputs = [
      container.querySelector('[data-setting="from-location"]'),
      container.querySelector('[data-setting="to-location"]'),
      container.querySelector('[data-setting="price"]'),
    ].filter(Boolean);

    form.addEventListener("submit", handleSubmit);
    inputs.forEach((input) => input.addEventListener("input", handleInput));
    if (discardButton) discardButton.addEventListener("click", handleDiscard);
    if (newRouteButton) newRouteButton.addEventListener("click", handleNewRoute);

    updatePreview();
    void loadRouteStats();

    return () => {
      form.removeEventListener("submit", handleSubmit);
      inputs.forEach((input) => input.removeEventListener("input", handleInput));
      if (discardButton) discardButton.removeEventListener("click", handleDiscard);
      if (newRouteButton) newRouteButton.removeEventListener("click", handleNewRoute);
    };
  }, [navigate, loadRouteStats, updatePreview]);

  return (
    <>
      {statsLoading && (
        <div className="mb-4 rounded-lg bg-surface-container-low text-on-surface-variant px-4 py-2 text-sm">
          Loading live route data...
        </div>
      )}
      {loading && (
        <div className="mb-4 rounded-lg bg-surface-container-low text-on-surface-variant px-4 py-2 text-sm">
          Saving route...
        </div>
      )}
      {error && (
        <div className="mb-4 rounded-lg bg-error-container text-on-error-container px-4 py-2 text-sm">
          {error}
        </div>
      )}
      {success && (
        <div className="mb-4 rounded-lg bg-primary-fixed/20 text-primary px-4 py-2 text-sm">
          {success}
        </div>
      )}
      <HtmlScreen
        html={addRouteHtml}
        title="Add Route"
        containerRef={containerRef}
        wrapperClassName={wrapperClassName}
      />
    </>
  );
}

export default AddRoute;
