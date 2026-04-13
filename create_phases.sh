#!/bin/bash
# =============================================================
# PitReport - Gerador de Fases para Entrega
# Cria as pastas Fase1, Fase2, Fase3, Fase4 dentro de Entregas/
# =============================================================
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
DEST="$ROOT/Entregas"
FLUTTER_SRC="$ROOT/pitreport"
ADMIN_SRC="$ROOT/pitreport-admin"
TEMPLATES="$ROOT/_templates"

echo "================================================="
echo " PitReport - Criação das 4 Fases"
echo "================================================="

# Limpa e recria pasta de entregas
rm -rf "$DEST"
mkdir -p "$DEST"

# ---------------------------------------------------------
# Função auxiliar: copia projetos e limpa ficheiros de build
# ---------------------------------------------------------
copy_projects() {
  local fase="$1"
  echo ""
  echo ">>> A copiar projetos para $fase..."

  mkdir -p "$DEST/$fase"
  cp -r "$FLUTTER_SRC" "$DEST/$fase/pitreport"
  cp -r "$ADMIN_SRC"   "$DEST/$fase/pitreport-admin"

  # Remover ficheiros de build Flutter
  rm -rf "$DEST/$fase/pitreport/build"
  rm -rf "$DEST/$fase/pitreport/.dart_tool"
  rm -rf "$DEST/$fase/pitreport/.flutter-plugins"
  rm -rf "$DEST/$fase/pitreport/.flutter-plugins-dependencies"

  # Remover ficheiros de build Web Admin
  rm -rf "$DEST/$fase/pitreport-admin/node_modules"
  rm -rf "$DEST/$fase/pitreport-admin/dist"
}

# =============================================================
# FASE 1 — Autenticação
# Flutter:    RF01, RF02 (registo + login)
# Web Admin:  RF18 (login admin)
# =============================================================
copy_projects "Fase1"
echo ">>> A configurar Fase1..."

# --- Flutter: remover screens não implementadas ---
rm -f "$DEST/Fase1/pitreport/lib/screens/report_form_screen.dart"
rm -f "$DEST/Fase1/pitreport/lib/screens/report_list_screen.dart"
rm -f "$DEST/Fase1/pitreport/lib/screens/report_detail_screen.dart"
rm -f "$DEST/Fase1/pitreport/lib/screens/map_screen.dart"
rm -f "$DEST/Fase1/pitreport/lib/screens/stats_screen.dart"
rm -f "$DEST/Fase1/pitreport/lib/models/report.dart"
rm -f "$DEST/Fase1/pitreport/lib/services/firestore_service.dart"
rm -f "$DEST/Fase1/pitreport/lib/services/storage_service.dart"

# --- Flutter: sobrescrever ficheiros modificados ---
cp "$TEMPLATES/fase1_home_screen.dart"  "$DEST/Fase1/pitreport/lib/screens/home_screen.dart"
cp "$TEMPLATES/fase1_pubspec.yaml"      "$DEST/Fase1/pitreport/pubspec.yaml"

# --- Web Admin: remover páginas não implementadas ---
rm -f "$DEST/Fase1/pitreport-admin/src/pages/DashboardPage.tsx"
rm -f "$DEST/Fase1/pitreport-admin/src/pages/ReportsPage.tsx"
rm -f "$DEST/Fase1/pitreport-admin/src/pages/ReportDetailPage.tsx"
rm -f "$DEST/Fase1/pitreport-admin/src/pages/UsersPage.tsx"
rm -f "$DEST/Fase1/pitreport-admin/src/pages/AnalyticsPage.tsx"
rm -f "$DEST/Fase1/pitreport-admin/src/components/Layout.tsx"
rm -f "$DEST/Fase1/pitreport-admin/src/components/Sidebar.tsx"
rm -f "$DEST/Fase1/pitreport-admin/src/components/StatusBadge.tsx"
rm -rf "$DEST/Fase1/pitreport-admin/src/services"

# --- Web Admin: sobrescrever ficheiros modificados ---
cp "$TEMPLATES/fase1_App.tsx" "$DEST/Fase1/pitreport-admin/src/App.tsx"

echo "    Fase1 OK"

# =============================================================
# FASE 2 — Submissão de Denúncias e Sensores
# Flutter:    RF03-RF11 (formulário, câmara, GPS, bússola,
#             ML Kit deteção de rostos, ruído dB)
# Web Admin:  igual à Fase1 (só login)
# =============================================================
copy_projects "Fase2"
echo ">>> A configurar Fase2..."

# --- Flutter: remover screens de visualização (ainda não implementadas) ---
rm -f "$DEST/Fase2/pitreport/lib/screens/report_list_screen.dart"
rm -f "$DEST/Fase2/pitreport/lib/screens/report_detail_screen.dart"
rm -f "$DEST/Fase2/pitreport/lib/screens/map_screen.dart"
rm -f "$DEST/Fase2/pitreport/lib/screens/stats_screen.dart"

# --- Flutter: sobrescrever ficheiros modificados ---
cp "$TEMPLATES/fase2_home_screen.dart" "$DEST/Fase2/pitreport/lib/screens/home_screen.dart"
cp "$TEMPLATES/fase2_pubspec.yaml"     "$DEST/Fase2/pitreport/pubspec.yaml"

# --- Web Admin: igual à Fase1 ---
rm -f "$DEST/Fase2/pitreport-admin/src/pages/DashboardPage.tsx"
rm -f "$DEST/Fase2/pitreport-admin/src/pages/ReportsPage.tsx"
rm -f "$DEST/Fase2/pitreport-admin/src/pages/ReportDetailPage.tsx"
rm -f "$DEST/Fase2/pitreport-admin/src/pages/UsersPage.tsx"
rm -f "$DEST/Fase2/pitreport-admin/src/pages/AnalyticsPage.tsx"
rm -f "$DEST/Fase2/pitreport-admin/src/components/Layout.tsx"
rm -f "$DEST/Fase2/pitreport-admin/src/components/Sidebar.tsx"
rm -f "$DEST/Fase2/pitreport-admin/src/components/StatusBadge.tsx"
rm -rf "$DEST/Fase2/pitreport-admin/src/services"

cp "$TEMPLATES/fase1_App.tsx" "$DEST/Fase2/pitreport-admin/src/App.tsx"

echo "    Fase2 OK"

# =============================================================
# FASE 3 — Lista, Mapa, Estatísticas + Dashboard Admin
# Flutter:    RF12-RF17 (lista tempo real, mapa com filtros e
#             pins expansíveis, botão Google Maps, estatísticas)
# Web Admin:  RF19, RF20 (dashboard com KPIs e gráficos)
# =============================================================
copy_projects "Fase3"
echo ">>> A configurar Fase3..."

# --- Flutter: completo (todos os screens presentes) ---
cp "$TEMPLATES/fase3_pubspec.yaml" "$DEST/Fase3/pitreport/pubspec.yaml"
# home_screen.dart fica igual ao original (todos os 4 botões)

# --- Web Admin: remover páginas avançadas (ainda não implementadas) ---
rm -f "$DEST/Fase3/pitreport-admin/src/pages/ReportsPage.tsx"
rm -f "$DEST/Fase3/pitreport-admin/src/pages/ReportDetailPage.tsx"
rm -f "$DEST/Fase3/pitreport-admin/src/pages/UsersPage.tsx"
rm -f "$DEST/Fase3/pitreport-admin/src/pages/AnalyticsPage.tsx"
rm -f "$DEST/Fase3/pitreport-admin/src/components/StatusBadge.tsx"
rm -f "$DEST/Fase3/pitreport-admin/src/services/messages.ts"
rm -f "$DEST/Fase3/pitreport-admin/src/services/users.ts"

# --- Web Admin: sobrescrever ficheiros modificados ---
cp "$TEMPLATES/fase3_App.tsx"     "$DEST/Fase3/pitreport-admin/src/App.tsx"
cp "$TEMPLATES/fase3_Sidebar.tsx" "$DEST/Fase3/pitreport-admin/src/components/Sidebar.tsx"

echo "    Fase3 OK"

# =============================================================
# FASE 4 — Painel de Administração Completo
# Flutter:    Completo (igual ao projeto final)
# Web Admin:  RF21-RF30 (tabela, pesquisa, ordenação, feedback,
#             gestão utilizadores, análise, responsividade)
# =============================================================
copy_projects "Fase4"
echo ">>> A configurar Fase4..."
# Fase4 = projeto completo, sem alterações
echo "    Fase4 OK"

# =============================================================
echo ""
echo "================================================="
echo " Concluído! Pastas criadas em: Entregas/"
echo ""
echo "   Entregas/Fase1/  — Autenticação"
echo "   Entregas/Fase2/  — Submissão + Sensores"
echo "   Entregas/Fase3/  — Visualização + Dashboard"
echo "   Entregas/Fase4/  — Completo"
echo ""
echo " Para criar ZIPs:"
echo "   cd Entregas"
echo "   zip -r Fase1.zip Fase1/"
echo "   zip -r Fase2.zip Fase2/"
echo "   zip -r Fase3.zip Fase3/"
echo "   zip -r Fase4.zip Fase4/"
echo "================================================="
