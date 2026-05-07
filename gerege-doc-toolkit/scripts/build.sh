#!/usr/bin/env bash
#
# gerege-doc-toolkit/scripts/build.sh
#
# Markdown source-ыг Гэрэгэ Системс ХХК-ийн стандарт template-аар
# .docx (Word) формат руу хөрвүүлнэ.
#
# Хэрэглээ:
#   ./scripts/build.sh <input>                        # input нь файл / фолдер
#   ./scripts/build.sh -o <out_dir> <input>            # custom output dir
#   ./scripts/build.sh -h                              # help
#
# Жишээ:
#   ./scripts/build.sh examples/                       # бүх example-ыг
#   ./scripts/build.sh docs/policy.md                  # нэг файл
#   ./scripts/build.sh -o /tmp/out docs/                # custom output
#

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────
# Setup
# ─────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

TEMPLATE="${TOOLKIT_DIR}/template/gerege-document-template.docx"
LUA_FILTER="${SCRIPT_DIR}/cover-page.lua"
DEFAULT_OUTPUT="dist"

# ─────────────────────────────────────────────────────────────────────────
# Help
# ─────────────────────────────────────────────────────────────────────────

usage() {
  cat <<'EOF'
gerege-doc-toolkit — Markdown → DOCX builder

USAGE:
    ./scripts/build.sh [OPTIONS] <input>

ARGUMENTS:
    <input>             .md файл эсвэл .md файлуудтай фолдер

OPTIONS:
    -o, --output DIR    Output фолдер (default: ./dist)
    -t, --template FILE Custom template файл
    -f, --filter FILE   Custom Lua filter
    -v, --verbose       Pandoc-ийн warning-уудыг харуулах
    -h, --help          Энэ help-ийг харуулах

EXAMPLES:
    ./scripts/build.sh examples/
    ./scripts/build.sh -o /tmp/out docs/policy.md
    ./scripts/build.sh --output build/docs docs/

REQUIREMENTS:
    pandoc 3.0+   (brew install pandoc)
EOF
}

# ─────────────────────────────────────────────────────────────────────────
# Parse args
# ─────────────────────────────────────────────────────────────────────────

OUTPUT_DIR="${DEFAULT_OUTPUT}"
VERBOSE=0
INPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage; exit 0
      ;;
    -o|--output)
      OUTPUT_DIR="$2"; shift 2
      ;;
    -t|--template)
      TEMPLATE="$2"; shift 2
      ;;
    -f|--filter)
      LUA_FILTER="$2"; shift 2
      ;;
    -v|--verbose)
      VERBOSE=1; shift
      ;;
    -*)
      echo "✗ Үл мэдэгдэх option: $1" >&2
      echo "  Help: ./scripts/build.sh --help" >&2
      exit 1
      ;;
    *)
      if [[ -z "${INPUT}" ]]; then
        INPUT="$1"
      else
        echo "✗ Олон input өгөгдсөн: '${INPUT}' ба '$1'" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

if [[ -z "${INPUT}" ]]; then
  echo "✗ Input өгөгдөөгүй." >&2
  usage
  exit 1
fi

# ─────────────────────────────────────────────────────────────────────────
# Validate
# ─────────────────────────────────────────────────────────────────────────

if ! command -v pandoc >/dev/null 2>&1; then
  echo "✗ pandoc олдсонгүй." >&2
  echo "  Суулгах: brew install pandoc  (macOS)" >&2
  echo "          sudo apt install pandoc  (Ubuntu)" >&2
  exit 1
fi

if [[ ! -f "${TEMPLATE}" ]]; then
  echo "✗ Template файл олдсонгүй: ${TEMPLATE}" >&2
  exit 1
fi

if [[ ! -f "${LUA_FILTER}" ]]; then
  echo "✗ Lua filter олдсонгүй: ${LUA_FILTER}" >&2
  exit 1
fi

if [[ ! -e "${INPUT}" ]]; then
  echo "✗ Input олдсонгүй: ${INPUT}" >&2
  exit 1
fi

# ─────────────────────────────────────────────────────────────────────────
# Pandoc args
# ─────────────────────────────────────────────────────────────────────────

PANDOC_ARGS=(
  --from=gfm+tex_math_dollars+yaml_metadata_block
  --to=docx
  --standalone
  --reference-doc="${TEMPLATE}"
  --lua-filter="${LUA_FILTER}"
)

if [[ "${VERBOSE}" -eq 0 ]]; then
  PANDOC_QUIET="2>/dev/null"
else
  PANDOC_QUIET=""
fi

# ─────────────────────────────────────────────────────────────────────────
# Convert function
# ─────────────────────────────────────────────────────────────────────────

convert_one() {
  local md="$1"
  local rel="$2"
  local out="${OUTPUT_DIR}/${rel%.md}.docx"

  mkdir -p "$(dirname "${out}")"

  if [[ "${VERBOSE}" -eq 1 ]]; then
    pandoc "${PANDOC_ARGS[@]}" "${md}" -o "${out}"
  else
    pandoc "${PANDOC_ARGS[@]}" "${md}" -o "${out}" 2>/dev/null
  fi
}

# ─────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────

count=0
fail=0

if [[ -f "${INPUT}" ]]; then
  # Single file
  if [[ "${INPUT}" != *.md ]]; then
    echo "✗ Markdown (.md) файл биш: ${INPUT}" >&2
    exit 1
  fi
  if convert_one "${INPUT}" "$(basename "${INPUT}")"; then
    out="${OUTPUT_DIR}/$(basename "${INPUT%.md}").docx"
    echo "✓ ${INPUT}  →  ${out}"
    count=1
  else
    echo "✗ ${INPUT}" >&2
    fail=1
  fi

elif [[ -d "${INPUT}" ]]; then
  # Folder — recursive
  base="${INPUT%/}"
  while IFS= read -r -d '' md; do
    rel="${md#${base}/}"

    # Skip output directory if nested + special folders
    case "${rel}" in
      "${OUTPUT_DIR}/"*) continue ;;
      */node_modules/*) continue ;;
      */.git/*) continue ;;
      # Template files contain unfilled <<TBD>> placeholders that
      # break YAML parse. User copy-аад placeholder сольсны дараа build.
      */templates/*) continue ;;
      templates/*) continue ;;
    esac

    if convert_one "${md}" "${rel}"; then
      out="${OUTPUT_DIR}/${rel%.md}.docx"
      echo "✓ ${rel}"
      count=$((count + 1))
    else
      echo "✗ ${rel}" >&2
      fail=$((fail + 1))
    fi
  done < <(find "${base}" -type f -name "*.md" -print0)
else
  echo "✗ Файл/фолдер биш: ${INPUT}" >&2
  exit 1
fi

# ─────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────

echo ""
if [[ ${fail} -eq 0 ]]; then
  echo "✓ ${count} document Gerege template-аар хөрвүүлсэн"
else
  echo "⚠ ${count} амжилттай, ${fail} амжилтгүй"
fi
echo "  Output: ${OUTPUT_DIR}/"
echo "  Template: $(basename "${TEMPLATE}")"

if [[ ${fail} -gt 0 ]]; then
  exit 1
fi
