#!/usr/bin/env bash
set -euo pipefail

die() { echo "ERROR: $*" >&2; exit 1; }

require_root() {
  [[ "${EUID}" -eq 0 ]] || die "Run as root (use sudo)."
}

require_root

SYSTEMD_ETC="/etc/systemd/system"
UNIT_BASE="pihole-group-toggle"

echo "Removing all managed timers (ignoring config)..."

managed_units=()

# Find all schedule.conf files with our ownership marker
while IFS= read -r -d '' f; do
  grep -Fxq '# Managed by pihole-toggle' "$f" || continue

  rel="${f#${SYSTEMD_ETC}/}"
  unit="${rel%.d/schedule.conf}"  # pihole-group-toggle@action:group.timer
  managed_units+=("$unit")
done < <(
  find "$SYSTEMD_ETC" -type f \
    -path "${SYSTEMD_ETC}/${UNIT_BASE}@*.timer.d/schedule.conf" \
    -print0 2>/dev/null
)

if ((${#managed_units[@]} == 0)); then
  echo "No managed timers found."
else
  for unit in "${managed_units[@]}"; do
    echo "Disabling timer: $unit"
    systemctl disable --now "$unit" || true
    rm -rf "${SYSTEMD_ETC}/${unit}.d"
  done
fi

echo "Removing installed files..."

rm -f /usr/local/sbin/pihole-toggle
rm -f /usr/local/sbin/pihole-group-toggle
rm -f "${SYSTEMD_ETC}/${UNIT_BASE}@.service"
rm -f "${SYSTEMD_ETC}/${UNIT_BASE}@.timer"

systemctl daemon-reload

echo
echo "Uninstall complete."
echo
echo "NOTE:"
echo "  The configuration file was NOT removed:"
echo "    /etc/pihole-group-toggle.conf"
echo
echo "  Remove it manually if you do not plan to reinstall:"
echo "    sudo rm /etc/pihole-group-toggle.conf"
