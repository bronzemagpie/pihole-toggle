#!/usr/bin/env bash
set -euo pipefail

die() { echo "ERROR: $*" >&2; exit 1; }

require_root() {
  [[ "${EUID}" -eq 0 ]] || die "Run as root (use sudo)."
}

require_root


# Install scripts
install -m 0755 -o root -g root bin/pihole-group-toggle /usr/local/sbin/pihole-group-toggle
install -m 0755 -o root -g root bin/pihole-toggle       /usr/local/sbin/pihole-toggle

# Install systemd units
install -m 0644 -o root -g root systemd/pihole-group-toggle@.service /etc/systemd/system/pihole-group-toggle@.service
install -m 0644 -o root -g root systemd/pihole-group-toggle@.timer   /etc/systemd/system/pihole-group-toggle@.timer

# Install config (do not overwrite)
if [[ ! -f /etc/pihole-group-toggle.conf ]]; then
  install -m 0644 -o root -g root conf/pihole-group-toggle.conf.example /etc/pihole-group-toggle.conf
  echo "Created /etc/pihole-group-toggle.conf"
else
  echo "Keeping existing /etc/pihole-group-toggle.conf"
fi

# Reload systemd
systemctl daemon-reload

cat <<'EOF'
Installation complete.

Next steps:
  1) Edit config:
       sudo pihole-toggle configure
  2) See schedule in a list:
       pihole-toggle list
  3) Check systemd timer status:
       pihole-toggle status
  4) Sync changes to add and enable new timers, remove deletions
	sudo pihole-toggle sync

To remove all timers but keep the tool installed:
  - Set SCHEDULES=()
  - Run: sudo pihole-toggle sync
EOF
