#!/usr/bin/env bash
# Deploi Agent Skills — Install Script
# Usage: curl -fsSL https://raw.githubusercontent.com/Deploi-Cloud/deploi-agent-skills/main/scripts/install.sh | bash

set -euo pipefail

REPO="Deploi-Cloud/deploi-agent-skills"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[deploi]${NC} $1"; }
success() { echo -e "${GREEN}[deploi]${NC} $1"; }
error() { echo -e "${RED}[deploi]${NC} $1"; }

# Skill files to download
SKILLS=(
  "skills/deploi-server/SKILL.md"
  "skills/deploi-server/references/api-helper.md"
  "skills/deploi-server/references/server-registry.md"
  "skills/deploi-ops/SKILL.md"
  "skills/deploi-ops/references/deploy.md"
  "skills/deploi-ops/references/domains-dns.md"
  "skills/deploi-ops/references/ssl-https.md"
  "skills/deploi-ops/references/firewall.md"
  "skills/deploi-ops/references/databases.md"
  "skills/deploi-ops/references/billing.md"
)

detect_environment() {
  if [ -d ".claude" ] || command -v claude &>/dev/null; then
    echo "claude-code"
  elif [ -d ".cursor" ]; then
    echo "cursor"
  elif [ -d ".vscode" ]; then
    echo "vscode"
  else
    echo "generic"
  fi
}

download_file() {
  local url="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  if command -v curl &>/dev/null; then
    curl -fsSL "$url" -o "$dest"
  elif command -v wget &>/dev/null; then
    wget -q "$url" -O "$dest"
  else
    error "Neither curl nor wget found. Please install one and try again."
    exit 1
  fi
}

install_skills() {
  local target_dir="$1"

  info "Installing Deploi skills to ${target_dir}..."

  for skill in "${SKILLS[@]}"; do
    local url="${BASE_URL}/${skill}"
    local dest="${target_dir}/${skill}"
    info "  Downloading ${skill}..."
    download_file "$url" "$dest"
  done

  success "Skills installed to ${target_dir}/"
}

# --- Main ---

echo ""
echo "    ◇"
echo "   ◇ ◇        Deploi Agent Skills"
echo "  ◇   ◇       Installer"
echo "   ◇ ◇        deploi.no"
echo "    ◇"
echo ""

ENV=$(detect_environment)
info "Detected environment: ${ENV}"

case "$ENV" in
  claude-code)
    # Install to .claude/skills/ for Claude Code
    INSTALL_DIR=".claude"
    install_skills "$INSTALL_DIR"
    success ""
    success "Claude Code setup complete!"
    info "The skills are now available in your project."
    info "Claude Code will automatically detect skills in .claude/skills/"
    ;;

  cursor)
    # Install to .cursor/rules/ (Cursor's convention)
    INSTALL_DIR=".cursor/rules"
    install_skills "$INSTALL_DIR"
    success ""
    success "Cursor setup complete!"
    info "Skills installed to .cursor/rules/skills/"
    ;;

  *)
    # Generic: install to project root
    INSTALL_DIR="."
    install_skills "$INSTALL_DIR"
    success ""
    success "Installation complete!"
    info "Skills installed to ./skills/"
    info "Add the SKILL.md files to your agent's context or system prompt."
    ;;
esac

echo ""
info "Next steps:"
info "  1. Sign up at https://deploi.no if you haven't already"
info "  2. Add DEPLOI_USERNAME and DEPLOI_ACCOUNT_PASSWORD to your .env"
info "  3. Ask your AI agent to create a Deploi server"
echo ""
