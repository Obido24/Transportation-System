import { useEffect, useState } from "react";
import { authStore } from "../lib/auth";

function AuthBootstrap({ children }) {
  const [ready, setReady] = useState(false);

  useEffect(() => {
    let active = true;
    const timeout = window.setTimeout(() => {
      if (active) {
        setReady(true);
      }
    }, 4000);

    const run = async () => {
      authStore.init();
      try {
        await authStore.bootstrap();
      } finally {
        if (active) {
          window.clearTimeout(timeout);
          setReady(true);
        }
      }
    };

    run();

    return () => {
      active = false;
      window.clearTimeout(timeout);
    };
  }, []);

  if (!ready) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background text-on-background">
        <div className="flex flex-col items-center gap-3">
          <div className="w-12 h-12 rounded-full border-4 border-primary/20 border-t-primary animate-spin" />
          <p className="text-sm text-on-surface-variant">Loading admin session...</p>
        </div>
      </div>
    );
  }

  return children;
}

export default AuthBootstrap;
