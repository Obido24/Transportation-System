import { useEffect, useMemo, useRef, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";

import HtmlScreen from "./HtmlScreen";
import editRouteHtml from "./html/edit_route.html?raw";
import { fetchWithAuth } from "../lib/api";

const wrapperClassName = "min-h-screen";

const getRouteId = (location) => {
  const params = new URLSearchParams(location.search);
  return params.get("id") || localStorage.getItem("i_metro_admin_selected_route");
};

function EditRoute() {
  const containerRef = useRef(null);
  const location = useLocation();
  const navigate = useNavigate();
  const [route, setRoute] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const routeId = useMemo(() => getRouteId(location), [location]);

  useEffect(() => {
    const load = async () => {
      if (!routeId) {
        setError("Select a route from Route Management first.");
        return;
      }
      setLoading(true);
      setError("");
      try {
        const response = await fetchWithAuth("/admin/routes");
        if (!response.ok) {
          setError("Unable to load routes.");
          return;
        }
        const routes = await response.json();
        const match = routes.find((item) => item.id === routeId);
        if (!match) {
          setError("Route not found.");
          return;
        }
        setRoute(match);
      } catch {
        setError("Unable to load route.");
      } finally {
        setLoading(false);
      }
    };

    load();
  }, [routeId]);

  useEffect(() => {
    if (!route) return;
    const container = containerRef.current;
    if (!container) return;

    const breadcrumb = Array.from(container.querySelectorAll("span")).find((node) =>
      node.textContent?.includes("Edit Route"),
    );
    if (breadcrumb) {
      breadcrumb.textContent = `Edit Route ${route.id.slice(0, 6).toUpperCase()}`;
    }

    const header = container.querySelector("h1");
    if (header) header.textContent = "Edit Route Details";

    const inputs = container.querySelectorAll("input[type='text']");
    if (inputs.length >= 2) {
      inputs[0].value = route.fromLocation;
      inputs[1].value = route.toLocation;
    }

    const priceInput = container.querySelector("input[type='text'][value='24.50']") ||
      container.querySelectorAll("input[type='text']")[2];
    if (priceInput) {
      priceInput.value = String(route.price ?? 0);
    }

    const idInput = container.querySelector("input[readonly]");
    if (idInput) idInput.value = route.id;

    const statusBadge = container.querySelector("span.bg-primary-fixed");
    if (statusBadge) {
      statusBadge.textContent = route.isActive ? "Active" : "Inactive";
    }

    const toggle = container.querySelector("input[type='checkbox']");
    if (toggle) {
      toggle.checked = route.isActive;
    }

    const discardButton = Array.from(container.querySelectorAll("button")).find(
      (button) => button.textContent?.includes("Discard"),
    );
    if (discardButton && !discardButton.dataset.bound) {
      discardButton.dataset.bound = "true";
      discardButton.addEventListener("click", () => navigate("/admin/routes"));
    }

    const saveButton = Array.from(container.querySelectorAll("button")).find(
      (button) => button.textContent?.includes("Save Changes"),
    );
    if (saveButton && !saveButton.dataset.bound) {
      saveButton.dataset.bound = "true";
      saveButton.addEventListener("click", async () => {
        setError("");
        setSuccess("");
        try {
          const fromLocation = inputs[0]?.value?.trim();
          const toLocation = inputs[1]?.value?.trim();
          const priceValue = Number(priceInput?.value ?? 0);
          const isActive = toggle ? toggle.checked : route.isActive;

          if (!fromLocation || !toLocation || !Number.isFinite(priceValue)) {
            setError("Please enter pickup, destination, and price.");
            return;
          }

          const response = await fetchWithAuth(`/admin/routes/${route.id}`, {
            method: "PATCH",
            body: JSON.stringify({
              fromLocation,
              toLocation,
              price: Math.round(priceValue),
              isActive,
            }),
          });

          if (!response.ok) {
            setError("Unable to update route.");
            return;
          }

          setSuccess("Route updated.");
          navigate("/admin/routes");
        } catch {
          setError("Unable to update route.");
        }
      });
    }
  }, [route, navigate]);

  return (
    <>
      {loading && (
        <div className="mb-4 rounded-lg bg-surface-container-low text-on-surface-variant px-4 py-2 text-sm">
          Loading route...
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
        html={editRouteHtml}
        title="Edit Route"
        containerRef={containerRef}
        wrapperClassName={wrapperClassName}
      />
    </>
  );
}

export default EditRoute;
