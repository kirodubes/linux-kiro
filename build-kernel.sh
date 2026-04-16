#!/bin/bash
#
# KIRO Linux Kernel Build Script
# Switches between Gaming and Desktop kernel configurations
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PKGBUILD="$SCRIPT_DIR/PKGBUILD"
PKGBUILD_BACKUP="$SCRIPT_DIR/PKGBUILD.backup.$(date +%Y%m%d_%H%M%S)"

# ==============================================================================
# Configuration Presets
# ==============================================================================

# Gaming Kernel Configuration (Current/Default)
GAMING_CONFIG=(
  '_cpusched=bore'
  '_per_gov=no'
  '_tcp_bbr3=no'
  '_HZ_ticks=1000'
  '_preempt=full'
  '_hugepage=always'
)

# Desktop Kernel Configuration (Optimized for productivity)
DESKTOP_CONFIG=(
  '_cpusched=eevdf'
  '_per_gov=yes'
  '_tcp_bbr3=yes'
  '_HZ_ticks=500'
  '_preempt=lazy'
  '_hugepage=madvise'
)

# ==============================================================================
# Functions
# ==============================================================================

print_header() {
  echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║${NC}        KIRO Linux Kernel Build Configuration Script       ${BLUE}║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
}

print_menu() {
  echo -e "\n${GREEN}Select kernel configuration:${NC}\n"
  echo -e "  ${BLUE}1)${NC} Gaming Kernel"
  echo -e "     - BORE scheduler (burst responsiveness)"
  echo -e "     - 1000Hz tick rate (low latency)"
  echo -e "     - Full preemption"
  echo -e "     - THP always enabled\n"
  echo -e "  ${BLUE}2)${NC} Desktop Kernel"
  echo -e "     - EEVDF scheduler (fair scheduling)"
  echo -e "     - 500Hz tick rate (power efficient)"
  echo -e "     - Lazy preemption (balanced)"
  echo -e "     - THP madvise (predictable latency)\n"
}

print_comparison() {
  echo -e "\n${YELLOW}Configuration Comparison:${NC}\n"
  echo -e "Setting              │ Gaming      │ Desktop"
  echo -e "─────────────────────┼─────────────┼──────────────"
  echo -e "_cpusched            │ bore        │ eevdf"
  echo -e "_per_gov (perf gov)  │ no          │ yes"
  echo -e "_tcp_bbr3            │ no          │ yes"
  echo -e "_HZ_ticks            │ 1000        │ 500"
  echo -e "_preempt             │ full        │ lazy"
  echo -e "_hugepage            │ always      │ madvise"
}

validate_pkgbuild() {
  if [[ ! -f "$PKGBUILD" ]]; then
    echo -e "${RED}✗ Error: PKGBUILD not found at $PKGBUILD${NC}"
    exit 1
  fi
}

create_backup() {
  cp "$PKGBUILD" "$PKGBUILD_BACKUP"
  echo -e "${GREEN}✓${NC} Backup created: ${PKGBUILD_BACKUP}"
}

update_pkgbuild() {
  local config=("$@")
  local temp_file=$(mktemp)

  cp "$PKGBUILD" "$temp_file"

  # Update each configuration parameter
  for param in "${config[@]}"; do
    local key="${param%%=*}"
    local value="${param##*=}"

    # Use sed to replace only the specific parameter value
    # Pattern: ${_key:=oldvalue} -> ${_key:=newvalue}
    # This works by matching the key and any current value, replacing just the value
    sed -i "s/${key}:=[^}]*/${key}:=${value}/g" "$temp_file"
  done

  # Verify changes were made
  if ! diff -q "$PKGBUILD" "$temp_file" > /dev/null 2>&1; then
    cp "$temp_file" "$PKGBUILD"
    rm "$temp_file"
    return 0
  else
    rm "$temp_file"
    return 1
  fi
}

show_changes() {
  echo -e "\n${YELLOW}Changes made to PKGBUILD:${NC}\n"

  # Show only the changed lines
  diff -u "$PKGBUILD_BACKUP" "$PKGBUILD" | grep -E "^[+-].*_" | grep -v "^[+-]{3}" || true

  echo ""
}

ask_build() {
  echo -e "\n${BLUE}Configuration complete!${NC}"
  echo ""
  read -p "Do you want to build the kernel now? (Y/n) " -r
  echo
  if [[ -z $REPLY || $REPLY =~ ^[Yy]$ ]]; then
    return 0
  else
    return 1
  fi
}

ask_interactive_config() {
  echo -e "\n${BLUE}Additional Options:${NC}\n"
  read -p "Do you want to run 'nconfig' for manual kernel configuration? (y/N) " -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    sed -i 's/: "${_makenconfig:=no}"/: "${_makenconfig:=yes}"/g' "$PKGBUILD"
    echo -e "${GREEN}✓${NC} nconfig enabled - you'll be prompted during build"
  else
    sed -i 's/: "${_makenconfig:=yes}"/: "${_makenconfig:=no}"/g' "$PKGBUILD"
    echo -e "${GREEN}✓${NC} nconfig disabled - build will skip manual config"
  fi
}

start_build() {
  echo -e "\n${BLUE}Starting kernel build...${NC}"
  echo -e "${YELLOW}⏱ This will take 30-60 minutes${NC}\n"

  cd "$SCRIPT_DIR"
  makepkg -si --skippgpcheck
}

show_verification_commands() {
  echo -e "\n${GREEN}═══════════════════════════════════════════════════════════${NC}"
  echo -e "${GREEN}Build complete! Verify your kernel with these commands:${NC}\n"
  echo -e "  ${BLUE}# Check kernel version${NC}"
  echo -e "  uname -r\n"
  echo -e "  ${BLUE}# Verify scheduler${NC}"
  echo -e "  cat /proc/sched_debug | grep -E 'BORE|EEVDF'\n"
  echo -e "  ${BLUE}# Verify tick rate${NC}"
  echo -e "  zcat /proc/config.gz | grep CONFIG_HZ=\n"
  echo -e "  ${BLUE}# Verify preemption${NC}"
  echo -e "  zcat /proc/config.gz | grep CONFIG_PREEMPT\n"
  echo -e "  ${BLUE}# Verify THP mode${NC}"
  echo -e "  cat /sys/kernel/mm/transparent_hugepage/enabled\n"
}

# ==============================================================================
# Main Script
# ==============================================================================

main() {
  print_header
  validate_pkgbuild

  print_menu
  print_comparison

  # Get user choice
  read -p "Enter your choice (1 or 2): " choice

  case $choice in
    1)
      echo -e "\n${BLUE}Configuring for Gaming Kernel...${NC}"
      create_backup

      if update_pkgbuild "${GAMING_CONFIG[@]}"; then
        show_changes
        echo -e "${GREEN}✓ Gaming kernel configuration applied${NC}"
      else
        echo -e "${YELLOW}⚠ No changes needed (already on gaming config)${NC}"
        rm "$PKGBUILD_BACKUP"
      fi
      ;;
    2)
      echo -e "\n${BLUE}Configuring for Desktop Kernel...${NC}"
      create_backup

      if update_pkgbuild "${DESKTOP_CONFIG[@]}"; then
        show_changes
        echo -e "${GREEN}✓ Desktop kernel configuration applied${NC}"
      else
        echo -e "${YELLOW}⚠ No changes needed (already on desktop config)${NC}"
        rm "$PKGBUILD_BACKUP"
      fi
      ;;
    *)
      echo -e "${RED}✗ Invalid choice. Please enter 1 or 2.${NC}"
      exit 1
      ;;
  esac

  # Ask about interactive config
  ask_interactive_config

  # Ask about building
  if ask_build; then
    start_build
    show_verification_commands
  else
    echo -e "\n${YELLOW}Build skipped. Run the following when ready:${NC}"
    echo -e "  cd $SCRIPT_DIR"
    echo -e "  makepkg -si --skippgpcheck\n"
  fi
}

# Run main function
main "$@"
