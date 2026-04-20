import { Navigate, Outlet, useLocation } from "react-router-dom";
import { authStore } from "../lib/auth";

function RequireAuth() {
  const location = useLocation();
  const token = authStore.get();
  const expired = authStore.isExpired();

  if (!token || expired) {
    authStore.clear();
    return (
      <Navigate
        to="/admin/login"
        replace
        state={{ from: { pathname: location.pathname, search: location.search, hash: location.hash } }}
      />
    );
  }

  return <Outlet />;
}

export default RequireAuth;
