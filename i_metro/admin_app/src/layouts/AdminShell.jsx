import { useEffect, useMemo, useRef, useState } from "react";
import { Link, NavLink, Outlet, useLocation, useNavigate } from "react-router-dom";

import { useAuthSession } from "../lib/auth";
import { fetchWithAuth } from "../lib/api";

const navItems = [
  { label: "Dashboard", icon: "dashboard", path: "/admin/dashboard" },
  { label: "User Management", icon: "group", path: "/admin/users" },
  { label: "Merchant Management", icon: "storefront", path: "/admin/merchants" },
  { label: "Route Management", icon: "map", path: "/admin/routes" },
  { label: "Revenue", icon: "monitoring", path: "/admin/revenue" },
  { label: "Settings", icon: "settings", path: "/admin/settings" },
  { label: "Activity", icon: "history", path: "/admin/activity" },
  { label: "Support", icon: "support_agent", path: "/admin/support" },
  { label: "Bus Scan Logs", icon: "qr_code_scanner", path: "/admin/validator-logs" },
];

function AdminShell() {
  const [isOpen, setIsOpen] = useState(false);
  const [isProfileOpen, setIsProfileOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [searchResults, setSearchResults] = useState([]);
  const [searchBusy, setSearchBusy] = useState(false);
  const [searchOpen, setSearchOpen] = useState(false);
  const [brandLogoUrl, setBrandLogoUrl] = useState("/brand/imetro_logo.png");
  const location = useLocation();
  const navigate = useNavigate();
  const session = useAuthSession();
  const searchContainerRef = useRef(null);
  const searchInputRef = useRef(null);
  const isProfilePage =
    location.pathname.startsWith("/admin/profile-menu") ||
    location.pathname.startsWith("/admin/profile-settings");
  const displayName = useMemo(() => {
    const profile = session?.profile ?? {};
    const firstName = profile.firstName?.trim();
    const lastName = profile.lastName?.trim();
    if (firstName || lastName) {
      return [firstName, lastName].filter(Boolean).join(" ");
    }
    return profile.email ?? "Administrator";
  }, [session?.profile]);
  const displayRole = useMemo(() => {
    const role = session?.profile?.role;
    if (!role) return "Admin";
    return String(role)
      .replace(/_/g, " ")
      .replace(/\b\w/g, (char) => char.toUpperCase());
  }, [session?.profile?.role]);
  const displayAvatarUrl = session?.profile?.avatarUrl ?? null;
  const displayInitials = useMemo(() => {
    const profile = session?.profile ?? {};
    const first = profile.firstName?.trim() ?? "";
    const last = profile.lastName?.trim() ?? "";
    if (first || last) {
      return `${first.charAt(0)}${last.charAt(0)}`.toUpperCase();
    }
    const fallback = profile.email ?? profile.phone ?? "A";
    return fallback.charAt(0).toUpperCase();
  }, [session?.profile]);

  useEffect(() => {
    let active = true;
    const loadBrandLogo = async () => {
      try {
        const response = await fetchWithAuth("/admin/system-settings");
        const payload = await response.json();
        const logoDataUrl = payload?.branding?.logoDataUrl?.trim();
        if (active && logoDataUrl) {
          setBrandLogoUrl(logoDataUrl);
        }
      } catch {
        if (active) {
          setBrandLogoUrl("/brand/imetro_logo.png");
        }
      }
    };

    void loadBrandLogo();

    return () => {
      active = false;
    };
  }, []);

  useEffect(() => {
    const handleKeyDown = (event) => {
      if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === "k") {
        event.preventDefault();
        searchInputRef.current?.focus();
      }
      if (event.key === "Escape") {
        setSearchOpen(false);
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, []);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (!searchContainerRef.current) return;
      if (!searchContainerRef.current.contains(event.target)) {
        setSearchOpen(false);
      }
    };

    window.addEventListener("mousedown", handleClickOutside);
    return () => window.removeEventListener("mousedown", handleClickOutside);
  }, []);

  useEffect(() => {
    const query = searchQuery.trim();
    if (query.length < 2) {
      setSearchResults([]);
      setSearchBusy(false);
      return undefined;
    }

    let active = true;
    const timeout = window.setTimeout(async () => {
      setSearchBusy(true);
      try {
        const response = await fetchWithAuth(`/admin/search?q=${encodeURIComponent(query)}`);
        const results = response.ok ? await response.json() : [];

        if (active) {
          setSearchResults(Array.isArray(results) ? results : []);
          setSearchOpen(true);
        }
      } catch {
        if (active) {
          setSearchResults([]);
        }
      } finally {
        if (active) {
          setSearchBusy(false);
        }
      }
    }, 250);

    return () => {
      active = false;
      window.clearTimeout(timeout);
    };
  }, [searchQuery]);

  const handleSelectSearchResult = (result) => {
    setSearchQuery("");
    setSearchResults([]);
    setSearchOpen(false);
    navigate(result.path);
  };

  return (
    <div className="bg-background text-on-background min-h-screen">
      {(isOpen || isProfileOpen) && (
        <button
          type="button"
          aria-label="Close overlays"
          className="fixed inset-0 z-40 bg-black/20 md:hidden"
          onClick={() => {
            setIsOpen(false);
            setIsProfileOpen(false);
          }}
        />
      )}

      <aside
        className={`flex flex-col fixed left-0 top-0 h-full py-6 bg-slate-100 dark:bg-slate-900 h-screen w-64 border-r-0 z-50 transform transition-transform duration-200 md:translate-x-0 ${
          isOpen ? "translate-x-0" : "-translate-x-full"
        } md:translate-x-0`}
      >
        <div className="flex items-center gap-3 px-4 mb-8">
          <div className="w-12 h-12 rounded-lg overflow-hidden bg-white shadow-sm border border-outline-variant/20 flex items-center justify-center">
            <img alt="I-Metro logo" className="w-full h-full object-cover" src={brandLogoUrl} />
          </div>
          <div>
            <div className="text-xl font-bold tracking-tight text-emerald-900 dark:text-emerald-50">
              I-Metro
            </div>
            <div className="text-xs text-on-surface-variant leading-none">
              Inter-Metro Transport Solution Limited
            </div>
          </div>
        </div>

        <nav className="flex-1 space-y-1 px-4">
          {navItems.map((item) => (
            <NavLink
              key={item.label}
              to={item.path}
              className={({ isActive }) =>
                [
                  "flex items-center gap-3 px-3 py-2 rounded-lg transition-colors",
                  isActive
                    ? "text-emerald-900 dark:text-emerald-400 font-semibold bg-white/50 dark:bg-slate-800/50"
                    : "text-slate-600 dark:text-slate-400 hover:bg-slate-200 dark:hover:bg-slate-800",
                ].join(" ")
              }
            >
              <span className="material-symbols-outlined" data-icon={item.icon}>
                {item.icon}
              </span>
              <span className="font-medium">{item.label}</span>
            </NavLink>
          ))}
        </nav>

        <div className="my-6 px-4">
          <button
            className="w-full bg-gradient-to-br from-primary to-primary-container text-on-primary py-3 px-4 rounded-lg flex items-center justify-center gap-2 font-medium shadow-md hover:opacity-90 transition-opacity"
            onClick={() => navigate("/admin/routes/add")}
            type="button"
          >
            <span className="material-symbols-outlined text-sm" data-icon="add">
              add
            </span>
            <span>New Route</span>
          </button>
        </div>

        <div className="mt-auto px-4 pt-4 space-y-4">
          <div className="border-t border-slate-200 dark:border-slate-800" />
          <div className="flex items-center gap-3 rounded-2xl bg-surface-container-lowest/95 backdrop-blur-md border border-outline-variant/15 px-4 py-3 shadow-lg">
            <div className="w-10 h-10 rounded-full bg-primary-container text-on-primary-container overflow-hidden flex items-center justify-center text-xs font-semibold">
              {displayAvatarUrl ? (
                <img alt={displayName} className="w-full h-full object-cover" src={displayAvatarUrl} />
              ) : (
                <span>{displayInitials}</span>
              )}
            </div>
            <div className="min-w-0">
              <p className="text-sm font-semibold text-on-surface truncate">{displayName}</p>
              <p className="text-xs text-on-surface-variant truncate">{displayRole}</p>
            </div>
          </div>
        </div>
      </aside>

      <main className="md:ml-64 min-h-screen">
        <header className="flex justify-between items-center w-full px-6 md:px-8 h-16 sticky top-0 z-40 bg-[#f8f9fa]/80 dark:bg-slate-950/80 backdrop-blur-xl shadow-[0px_10px_30px_rgba(25,28,29,0.05)]">
          <div className="flex items-center gap-4 md:gap-8">
            <button
              type="button"
              className="md:hidden p-2 rounded-lg hover:bg-surface-container-low"
              onClick={() => setIsOpen((prev) => !prev)}
              aria-label="Toggle navigation menu"
            >
              <span className="material-symbols-outlined">menu</span>
            </button>
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-md overflow-hidden bg-white border border-outline-variant/20 shadow-sm flex items-center justify-center">
                <img alt="I-Metro logo" className="w-full h-full object-cover" src={brandLogoUrl} />
              </div>
              <span className="text-xl font-bold tracking-tight text-[#00513f] dark:text-emerald-400 font-headline">
                I-Metro Bus Admin
              </span>
            </div>
            <nav className="hidden md:flex gap-6">
              <NavLink
                className="text-[#3e4944] dark:text-slate-400 hover:text-[#006b54] dark:hover:text-emerald-300 font-label text-sm font-semibold transition-all"
                to="/admin/revenue"
              >
                Analytics
              </NavLink>
              <NavLink
                className="text-[#3e4944] dark:text-slate-400 hover:text-[#006b54] dark:hover:text-emerald-300 font-label text-sm font-semibold transition-all"
                to="/admin/settings"
              >
                Configuration
              </NavLink>
              <NavLink
                className="text-[#3e4944] dark:text-slate-400 hover:text-[#006b54] dark:hover:text-emerald-300 font-label text-sm font-semibold transition-all"
                to="/admin/activity"
              >
                Logs
              </NavLink>
            </nav>
          </div>
          <div className="flex items-center gap-3 md:gap-6">
            <div ref={searchContainerRef} className="relative hidden md:block">
              <div className="relative group">
                <input
                  ref={searchInputRef}
                  className="bg-surface-container-highest border-none rounded-full px-4 py-1.5 text-sm w-80 focus:ring-2 focus:ring-primary focus:bg-surface-container-lowest transition-all"
                  onChange={(event) => {
                    setSearchQuery(event.target.value);
                    setSearchOpen(true);
                  }}
                  onFocus={() => {
                    if (searchQuery.trim().length >= 2) {
                      setSearchOpen(true);
                    }
                  }}
                  placeholder="Search users, routes, merchants..."
                  type="search"
                  value={searchQuery}
                />
                <span className="material-symbols-outlined absolute right-3 top-1.5 text-on-surface-variant text-sm">
                  search
                </span>
              </div>

              {searchOpen && (searchQuery.trim().length >= 2 || searchBusy) && (
                <div className="absolute right-0 top-12 z-50 w-[34rem] max-w-[80vw] rounded-2xl border border-outline-variant/20 bg-surface-container-lowest shadow-[0px_20px_40px_rgba(25,28,29,0.18)] overflow-hidden">
                  <div className="flex items-center justify-between px-4 py-3 border-b border-outline-variant/10">
                    <div>
                      <p className="text-xs uppercase tracking-[0.18em] text-on-surface-variant font-semibold">
                        Global Search
                      </p>
                      <p className="text-sm text-on-surface-variant">
                        {searchBusy
                          ? "Searching live admin data..."
                          : `${searchResults.length} result${searchResults.length === 1 ? "" : "s"} found`}
                      </p>
                    </div>
                    <p className="text-xs text-on-surface-variant">Press Esc to close</p>
                  </div>

                  <div className="max-h-[24rem] overflow-auto">
                    {!searchBusy && searchQuery.trim().length >= 2 && searchResults.length === 0 && (
                      <div className="px-4 py-6 text-sm text-on-surface-variant">
                        No matches found for "{searchQuery.trim()}".
                      </div>
                    )}
                    {searchResults.map((result) => (
                      <button
                        key={result.key}
                        className="w-full text-left px-4 py-3 border-b border-outline-variant/10 hover:bg-surface-container-low transition-colors"
                        onClick={() => handleSelectSearchResult(result)}
                        type="button"
                      >
                        <div className="flex items-center justify-between gap-4">
                          <div className="min-w-0">
                            <div className="mb-1 flex items-center gap-2">
                              <span className="inline-flex items-center rounded-full bg-primary-container/70 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-[0.18em] text-primary">
                                {result.category ?? "Result"}
                              </span>
                            </div>
                            <p className="font-semibold text-on-surface truncate">{result.label}</p>
                            <p className="text-xs text-on-surface-variant truncate">
                              {result.subtitle}
                            </p>
                          </div>
                          <span className="material-symbols-outlined text-on-surface-variant text-[18px]">
                            arrow_forward
                          </span>
                        </div>
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>

            <div className="flex gap-2 md:gap-4 items-center relative">
              {!isProfilePage && (
                <button
                  type="button"
                  className="w-9 h-9 rounded-full overflow-hidden bg-surface-container-high border-2 border-primary-container/20 flex items-center justify-center text-primary font-semibold text-xs"
                  onClick={() => setIsProfileOpen((prev) => !prev)}
                  aria-label="Open profile menu"
                >
                  {displayAvatarUrl ? (
                    <img
                      alt={displayName}
                      className="w-full h-full object-cover"
                      src={displayAvatarUrl}
                    />
                  ) : (
                    <span>{displayInitials}</span>
                  )}
                </button>
              )}

              {isProfileOpen && !isProfilePage && (
                <div className="absolute right-0 top-12 z-50 w-56 rounded-xl bg-surface-container-lowest shadow-[0px_10px_30px_rgba(25,28,29,0.12)] border border-outline-variant/20 overflow-hidden">
                  <div className="p-4 border-b border-outline-variant/10">
                    <p className="text-sm font-semibold text-on-surface">{displayName}</p>
                    <p className="text-xs text-on-surface-variant">{displayRole}</p>
                  </div>
                  <div className="p-2">
                    <Link
                      className="flex items-center gap-3 px-3 py-2 rounded-lg text-slate-700 hover:bg-surface-container-low transition-colors"
                      to="/admin/profile-settings"
                    >
                      <span className="material-symbols-outlined text-[20px]">
                        account_circle
                      </span>
                      <span className="text-sm font-medium">Profile Settings</span>
                    </Link>
                    <Link
                      className="flex items-center gap-3 px-3 py-2 rounded-lg text-slate-700 hover:bg-surface-container-low transition-colors"
                      to="/admin/logout"
                    >
                      <span className="material-symbols-outlined text-[20px]">logout</span>
                      <span className="text-sm font-medium">Log Out</span>
                    </Link>
                  </div>
                </div>
              )}
            </div>
          </div>
        </header>

        <div className="p-4 md:p-8 max-w-[1400px] mx-auto">
          <Outlet />
        </div>
      </main>

    </div>
  );
}

export default AdminShell;



