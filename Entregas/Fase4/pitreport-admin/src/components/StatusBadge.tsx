import type { ReportStatus } from "../types";

const config: Record<ReportStatus, { label: string; className: string }> = {
  pending: {
    label: "Pendente",
    className: "bg-yellow-100 text-yellow-800 border border-yellow-200",
  },
  in_progress: {
    label: "Em progresso",
    className: "bg-blue-100 text-blue-800 border border-blue-200",
  },
  resolved: {
    label: "Resolvido",
    className: "bg-green-100 text-green-800 border border-green-200",
  },
};

export default function StatusBadge({ status }: { status: ReportStatus }) {
  const { label, className } = config[status] ?? config.pending;
  return (
    <span className={`inline-block text-xs font-medium px-2.5 py-1 rounded-full ${className}`}>
      {label}
    </span>
  );
}
