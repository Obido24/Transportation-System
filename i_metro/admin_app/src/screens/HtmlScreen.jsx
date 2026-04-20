import { useEffect, useMemo } from "react";

const linkMap = [
  { match: "revenue", path: "/admin/revenue" },
  { match: "settings", path: "/admin/settings" },
  { match: "activity", path: "/admin/activity" },
  { match: "support", path: "/admin/support" },
  { match: "user management", path: "/admin/users" },
  { match: "route management", path: "/admin/routes" },
  { match: "merchant management", path: "/admin/merchants" },
  { match: "routes", path: "/admin/routes" },
  { match: "merchants", path: "/admin/merchants" },
  { match: "security", path: "/admin/security" },
  { match: "log out", path: "/admin/logout" },
  { match: "login", path: "/admin/login" },
  { match: "sign in", path: "/admin/login" },
  { match: "sign up", path: "/admin/signup" },
  { match: "forgot password", path: "/admin/forgot-password" },
  { match: "reset password", path: "/admin/reset-password" },
  { match: "verify", path: "/admin/email-verification" },
];

const mapAnchors = (html, stripShell) => {
  if (typeof window === "undefined") {
    return html;
  }

  const parser = new DOMParser();
  const doc = parser.parseFromString(html, "text/html");
  if (stripShell) {
    doc.querySelectorAll("aside").forEach((node) => node.remove());
    doc.querySelectorAll("main > header").forEach((node) => node.remove());
    Array.from(doc.body.children).forEach((child) => {
      if (child.tagName === "HEADER") {
        child.remove();
      }
    });
  }

  const anchors = doc.querySelectorAll("a");

  anchors.forEach((anchor) => {
    const text =
      anchor.textContent?.replace(/\s+/g, " ").trim().toLowerCase() ?? "";
    const mapped = linkMap.find((entry) => text.includes(entry.match));
    if (mapped) {
      anchor.setAttribute("href", mapped.path);
    }
  });

  if (stripShell) {
    const main = doc.querySelector("main");
    if (main) {
      return main.innerHTML;
    }
  }

  return doc.body.innerHTML;
};

function HtmlScreen({
  html,
  title,
  layout = "admin",
  wrapperClassName,
  containerRef,
}) {
  const stripShell = layout === "admin";
  const processed = useMemo(
    () => mapAnchors(html, stripShell),
    [html, stripShell],
  );

  useEffect(() => {
    if (title) {
      document.title = title;
    }
  }, [title]);

  return (
    <div
      ref={containerRef}
      className={wrapperClassName}
      dangerouslySetInnerHTML={{ __html: processed }}
    />
  );
}

export default HtmlScreen;
