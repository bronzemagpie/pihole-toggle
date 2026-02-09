pihole-toggle
=============

pihole-toggle is a small systemd-based tool for scheduling the enable and disable
state of existing Pi-hole groups.

It does not create Pi-hole groups, blocklists, or regex rules.
It only toggles groups that already exist.


What it does
------------

- Enables or disables existing Pi-hole groups on a schedule
- Uses systemd timers for reliability
- Keeps configuration in a single file
- Allows all timers to be removed without uninstalling the tool


Requirements
------------

- Pi-hole installed and working
- systemd (Raspberry Pi OS / Debian-based systems)
- Group names must not contain spaces


Install
-------

Clone the repository and run the installer:

git clone <repo-url>
cd pihole-toggle
sudo ./install.sh

The installer:
- installs required dependencies
- installs scripts into /usr/local/sbin
- installs systemd unit templates
- creates /etc/pihole-group-toggle.conf if it does not exist
- does not enable any timers automatically


Configure
---------

Create Pi-hole groups first using the Pi-hole web UI.

Then edit the configuration file:

sudo pihole-toggle configure

Configuration file location:

/etc/pihole-group-toggle.conf

Each entry defines:
- a group name
- an action (enable or disable)
- a systemd OnCalendar schedule

Example:

SCHEDULES=(
  "kids disable *-*-* 22:00:00"
  "kids enable  *-*-* 07:00:00"
)

Each entry in SHEDULES must beign with exactly two spaces.
Two leading spaces are required for correct parsing.


Review Configuration - See Your Timers
--------------------

See a list of the timers entered into the configuration file

sudo pihole-list


Apply timers
------------

Create or update timers based on the configuration:

sudo pihole-toggle apply

This writes systemd timer drop-ins and enables the timers.


Alternatively, use the sync command:

sudo pihole-toggle sync

This automatically adds and removes timers and handles enable or disable.


Check status
------------

Show timers managed by this tool:

sudo pihole-toggle status

Timers use an ownership marker to ensure they may be written and removed safely.


Remove timers but keep the tool
-------------------------------

To remove all managed timers while keeping pihole-toggle installed:

Empty the configuration

SCHEDULES=()

Then run:

sudo pihole-toggle prune 

Alternatively, use the sync command:

sudo pihole-toggle sync

This automatically adds and removes timers and handles enable and disable.


Safety notes
------------

- Group names must already exist in Pi-hole
- Group names must not contain spaces
- Schedules must follow the format described for correct parsing
- This tool modifies Pi-hole’s database via the supported schema
- Only timers explicitly marked as managed by pihole-toggle are removed


License
-------

MIT License
