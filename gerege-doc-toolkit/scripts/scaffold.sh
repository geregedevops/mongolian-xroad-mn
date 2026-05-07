#!/usr/bin/env bash
#
# gerege-doc-toolkit/scripts/scaffold.sh
#
# Шинэ project-д blueprint-ийн folder structure-ыг хуулна.
#
# Хэрэглээ:
#   ./scripts/scaffold.sh <target-dir> [project-name]
#
# Жишээ:
#   ./scripts/scaffold.sh /path/to/new-project/documentation "My SaaS"
#   ./scripts/scaffold.sh ./documentation
#

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────
# Setup
# ─────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BLUEPRINT_DIR="${TOOLKIT_DIR}/blueprint"

# ─────────────────────────────────────────────────────────────────────────
# Help
# ─────────────────────────────────────────────────────────────────────────

usage() {
  cat <<'EOF'
gerege-doc-toolkit — Blueprint scaffold

USAGE:
    ./scripts/scaffold.sh <target-dir> [project-name]

ARGUMENTS:
    <target-dir>    Шинэ documentation/ folder үүсгэх зам
    [project-name]  Project-ийн нэр (placeholder сольж бичих)

OPTIONS:
    -h, --help            Энэ help-ийг харуулах
    --domain-name NAME    "02-domain" хавтас-ийг өөр нэрээр (e.g., "02-pki")
    --integration-name N  "05-integration" хавтас-ийг өөр нэрээр (e.g., "05-rp")
    --skip SECTIONS       Үсэглэх sections-ыг таслалаар тусгаарла
                          (e.g., --skip 09-business,05-integration)

EXAMPLES:
    # Default scaffold
    ./scripts/scaffold.sh ./documentation

    # PKI project, custom names
    ./scripts/scaffold.sh ./docs "Gerege ID" --domain-name 02-pki --integration-name 05-rp-integrator

    # Skip sections
    ./scripts/scaffold.sh ./docs "Library" --skip 01-legal,05-integration,08-audit-evidence,09-business

REQUIREMENTS:
    - Bash 4+
    - rsync эсвэл cp
EOF
}

# ─────────────────────────────────────────────────────────────────────────
# Parse args
# ─────────────────────────────────────────────────────────────────────────

TARGET_DIR=""
PROJECT_NAME=""
DOMAIN_NAME="02-domain"
INTEGRATION_NAME="05-integration"
SKIP_LIST=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage; exit 0 ;;
    --domain-name)
      DOMAIN_NAME="$2"; shift 2 ;;
    --integration-name)
      INTEGRATION_NAME="$2"; shift 2 ;;
    --skip)
      SKIP_LIST="$2"; shift 2 ;;
    -*)
      echo "✗ Үл мэдэгдэх option: $1" >&2
      usage; exit 1 ;;
    *)
      if [[ -z "${TARGET_DIR}" ]]; then
        TARGET_DIR="$1"
      elif [[ -z "${PROJECT_NAME}" ]]; then
        PROJECT_NAME="$1"
      fi
      shift ;;
  esac
done

if [[ -z "${TARGET_DIR}" ]]; then
  echo "✗ Target directory өгөгдөөгүй." >&2
  usage; exit 1
fi

if [[ -z "${PROJECT_NAME}" ]]; then
  PROJECT_NAME="$(basename "$(dirname "$(realpath "${TARGET_DIR}")")")"
  echo "ℹ Project name тодорхойгүй учир '${PROJECT_NAME}'-аар оноосон."
fi

# ─────────────────────────────────────────────────────────────────────────
# Validation
# ─────────────────────────────────────────────────────────────────────────

if [[ ! -d "${BLUEPRINT_DIR}/scaffold" ]]; then
  echo "✗ Blueprint scaffold олдсонгүй: ${BLUEPRINT_DIR}/scaffold" >&2
  exit 1
fi

if [[ -e "${TARGET_DIR}" ]] && [[ -n "$(ls -A "${TARGET_DIR}" 2>/dev/null)" ]]; then
  echo "⚠ Target directory ${TARGET_DIR} аль хэдийн оршиж буй ба хоосон биш."
  echo -n "  Хэвээр үргэлжлүүлэх үү (l existing файл хадгалагдана)? [y/N] "
  read -r answer
  if [[ "${answer}" != "y" ]] && [[ "${answer}" != "Y" ]]; then
    echo "Cancelled."
    exit 0
  fi
fi

# ─────────────────────────────────────────────────────────────────────────
# Copy
# ─────────────────────────────────────────────────────────────────────────

mkdir -p "${TARGET_DIR}"

echo ""
echo "▸ Blueprint-ыг хуулж байна..."
echo "  Source: ${BLUEPRINT_DIR}/scaffold"
echo "  Target: ${TARGET_DIR}"
echo ""

# Skip helper (bash 3 compatible — string contains check)
_should_skip() {
  case ",${SKIP_LIST}," in
    *,"$1",*) return 0 ;;
    *)        return 1 ;;
  esac
}

count=0
skipped=0

# Copy each section
for src_path in "${BLUEPRINT_DIR}/scaffold"/*; do
  basename="$(basename "${src_path}")"

  # Skip check
  if _should_skip "${basename}"; then
    echo "  ⏭  ${basename} (skipped)"
    skipped=$((skipped + 1))
    continue
  fi

  # Rename special folders
  target_name="${basename}"
  if [[ "${basename}" == "02-domain" ]]; then
    target_name="${DOMAIN_NAME}"
  elif [[ "${basename}" == "05-integration" ]]; then
    target_name="${INTEGRATION_NAME}"
  fi

  target_path="${TARGET_DIR}/${target_name}"

  if [[ -d "${src_path}" ]]; then
    mkdir -p "${target_path}"
    cp -r "${src_path}/." "${target_path}/"
  else
    cp "${src_path}" "${target_path}"
  fi

  echo "  ✓ ${basename}  →  ${target_name}"
  count=$((count + 1))
done

# ─────────────────────────────────────────────────────────────────────────
# Replace placeholder
# ─────────────────────────────────────────────────────────────────────────

echo ""
echo "▸ Placeholder-ийг сольж байна..."
echo "  <PROJECT_NAME>  →  ${PROJECT_NAME}"

# macOS sed-аас Linux sed-ийн difference handle
if [[ "$(uname)" == "Darwin" ]]; then
  SED_INPLACE=(-i "")
else
  SED_INPLACE=(-i)
fi

find "${TARGET_DIR}" -type f -name "*.md" -print0 \
  | while IFS= read -r -d '' file; do
      sed "${SED_INPLACE[@]}" "s|<PROJECT_NAME>|${PROJECT_NAME}|g" "${file}"
    done

echo "  ✓ Done"

# ─────────────────────────────────────────────────────────────────────────
# Show next steps
# ─────────────────────────────────────────────────────────────────────────

echo ""
echo "✓ Scaffold амжилттай!"
echo ""
echo "  Sections үүсгэсэн:  ${count}"
echo "  Skipped:            ${skipped}"
echo "  Target:             ${TARGET_DIR}"
echo ""
echo "Дараагийн алхмууд:"
echo ""
echo "  1. README.md болон 00-PLAN.md-ыг өөрийн project-та тохируулах:"
echo "     \$EDITOR ${TARGET_DIR}/README.md"
echo "     \$EDITOR ${TARGET_DIR}/00-PLAN.md"
echo ""
echo "  2. Section-уудаас шаардлагагүйг устгах:"
echo "     rm -rf ${TARGET_DIR}/<section-not-needed>"
echo ""
echo "  3. Эхний docs-ыг templates-аас copy:"
echo "     cp ${BLUEPRINT_DIR}/templates/policy.md \\"
echo "        ${TARGET_DIR}/01-legal/privacy-notice.md"
echo ""
echo "  4. Word-руу хөрвүүлэх:"
echo "     ${SCRIPT_DIR}/build.sh ${TARGET_DIR}/"
echo ""
echo "📚 Blueprint guide: ${BLUEPRINT_DIR}/README.md"
echo "📚 Architecture:    ${BLUEPRINT_DIR}/ARCHITECTURE.md"
echo "📚 Templates:       ${BLUEPRINT_DIR}/templates/README.md"
