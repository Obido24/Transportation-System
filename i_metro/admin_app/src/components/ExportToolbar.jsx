import { useEffect, useRef, useState } from "react";

function ExportToolbar({ onCsv, onPdf, csvLabel = "Export CSV", pdfLabel = "Export PDF" }) {
  const rootRef = useRef(null);
  const [open, setOpen] = useState(false);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (!rootRef.current?.contains(event.target)) {
        setOpen(false);
      }
    };
    const handleEscape = (event) => {
      if (event.key === "Escape") {
        setOpen(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    document.addEventListener("keydown", handleEscape);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
      document.removeEventListener("keydown", handleEscape);
    };
  }, []);

  if (!onCsv && !onPdf) return null;

  if (onCsv && !onPdf) {
    return (
      <div className="mb-4">
        <button
          type="button"
          onClick={onCsv}
          className="inline-flex items-center gap-2 rounded-xl border border-outline-variant/20 bg-surface-container-lowest px-4 py-2.5 text-sm font-semibold text-on-surface hover:bg-surface-container-low transition-colors shadow-sm"
        >
          <span className="material-symbols-outlined text-[18px]">download</span>
          {csvLabel}
        </button>
      </div>
    );
  }

  if (onPdf && !onCsv) {
    return (
      <div className="mb-4">
        <button
          type="button"
          onClick={onPdf}
          className="inline-flex items-center gap-2 rounded-xl border border-outline-variant/20 bg-surface-container-lowest px-4 py-2.5 text-sm font-semibold text-on-surface hover:bg-surface-container-low transition-colors shadow-sm"
        >
          <span className="material-symbols-outlined text-[18px]">picture_as_pdf</span>
          {pdfLabel}
        </button>
      </div>
    );
  }

  return (
    <div ref={rootRef} className="relative mb-4 inline-flex">
      <button
        type="button"
        onClick={() => setOpen((value) => !value)}
        className="inline-flex items-center gap-2 rounded-xl border border-outline-variant/20 bg-surface-container-lowest px-4 py-2.5 text-sm font-semibold text-on-surface hover:bg-surface-container-low transition-colors shadow-sm"
        aria-expanded={open}
        aria-haspopup="menu"
      >
        <span className="material-symbols-outlined text-[18px]">download</span>
        Export
        <span className={`material-symbols-outlined text-[18px] transition-transform ${open ? "rotate-180" : ""}`}>
          keyboard_arrow_down
        </span>
      </button>

      {open && (
        <div
          className="absolute left-0 top-full z-20 mt-2 min-w-44 overflow-hidden rounded-xl border border-outline-variant/20 bg-surface-container-lowest shadow-xl"
          role="menu"
        >
          <button
            type="button"
            className="flex w-full items-center gap-2 px-4 py-3 text-left text-sm font-medium text-on-surface hover:bg-surface-container-low transition-colors"
            onClick={() => {
              setOpen(false);
              onPdf();
            }}
            role="menuitem"
          >
            <span className="material-symbols-outlined text-[18px]">picture_as_pdf</span>
            {pdfLabel}
          </button>
          <button
            type="button"
            className="flex w-full items-center gap-2 px-4 py-3 text-left text-sm font-medium text-on-surface hover:bg-surface-container-low transition-colors"
            onClick={() => {
              setOpen(false);
              onCsv();
            }}
            role="menuitem"
          >
            <span className="material-symbols-outlined text-[18px]">download</span>
            {csvLabel}
          </button>
        </div>
      )}
    </div>
  );
}

export default ExportToolbar;
