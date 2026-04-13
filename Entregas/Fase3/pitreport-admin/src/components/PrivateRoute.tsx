import { Navigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import type { ReactNode } from "react";

export default function PrivateRoute({ children }: { children: ReactNode }) {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen bg-navy flex items-center justify-center">
        <span className="text-white text-sm">A carregar...</span>
      </div>
    );
  }

  return user ? <>{children}</> : <Navigate to="/login" replace />;
}
