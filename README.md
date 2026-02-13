pihole-toggle
=============

pihole-toggle is a small systemd-based tool for scheduling the enable and disable state of existing Pi-hole groups.

It does not create Pi-hole groups, blocklists, or regex rules. It only toggles groups that already exist.


What it does
------------

- Enables or disables existing Pi-hole groups on a schedule
- Uses systemd timers for reliability
- Keeps configuration in a single file
- Allows timers with a pihole-toggle ownership marker to enabled/added or disabled/removed automatically


Requirements
------------

- Pi-hole installed and working
- systemd (Raspberry Pi OS / Debian-based systems)
- Group names must not contain spaces


Install
-------

Clone the repository and run the installer:

```bash
git clone https://github.com/bronzemagpie/pihole-toggle.git
cd pihole-toggle
sudo ./install.sh
```

The installer:
- installs scripts into /usr/local/sbin
- installs systemd unit templates
- creates `/etc/pihole-group-toggle.conf` if it does not exist
- does not enable any timers automatically


Configure
---------

Create Pi-hole groups first using the Pi-hole web UI.

_GROUP NAMES MUST NOT CONTAIN SPACES_.

Edit the configuration file. This command will open `/etc/pihole-group-toggle.conf` in your deafult editor (likely `nano`):

```bash
sudo pihole-toggle configure
```

Configuration file location: `/etc/pihole-group-toggle.conf`

Each entry defines:
- a group name
- an action (enable or disable)
- a systemd OnCalendar schedule

Example:

```
SCHEDULES=(
  "kids disable *-*-* 22:00:00"
  "kids enable  *-*-* 07:00:00"
)
```

Each entry in `SHEDULES` must beign with exactly two spaces. Two leading spaces are required for correct parsing.

The format is standard calednar event syntax: `DayOfWeek Year-Month-Day Hour:Minute:Second`

The Arch Wiki has a great overview of the format if you need it (see 4.2) https://wiki.archlinux.org/title/Systemd/Timers


Review Configuration - See Your Timers
--------------------

See a list of the timers entered into the configuration file.

```bash
pihole-toggle list
```

This is not a list of *active* timers. What displays is a parsed list of the timers entered into `/etc/pihole-group-toggle.conf`.

Useful for confirming groups and times were parsed correctly.


Sync config changes
-------------------

After configuration, run the sync command to automatically enable and add new timers, or disable and remove deleted timers.

```bash
sudo pihole-toggle sync
```


Check status
------------

Show timers managed by this pihole-toggle:
```bash
pihole-toggle status
```
Timers use an ownership marker to ensure they may be written and removed safely.



Apply timers
------------

Create or update timers based on the configuration:

```bash
sudo pihole-toggle apply
```
This writes systemd timer drop-ins and enables the timers.

Alternatively, use the sync command.



Remove timers
-------------------------------

To remove all managed timers, empty the configuration:

`SCHEDULES=()`

Then run:
```bash
sudo pihole-toggle prune 
```

Alternatively, use the sync command.


Disable and remove all active timers
------------------------------------
```bash
sudo pihole-toggle purge 
```
will disable and remove all active timers, even if they are listed in .conf

Timers will not activate again unless you run apply or sync.

The script:

- Finds all timers marked `# Managed by pihole-toggle`
- Disables those timers, regardless of what is listed in the configuration file
- Removes their systemd drop-in directories
- Deletes the installed service and timer templates
- Removes the pihole-toggle executables from `/usr/local/sbin`
- Reloads systemd to clear the removed units

The configuration file at `/etc/pihole-group-toggle.conf` is not removed. This allows you to reinstall the tool later without recreating your schedules.

To remove the configuration file as well:

```
sudo rm /etc/pihole-group-toggle.conf
```

Run the uninstall script from the repository directory:

```
sudo ./uninstall.sh
```

The script is safe to run multiple times.


Safety notes
------------

- Group names must already exist in Pi-hole
- Group names must not contain spaces
- Schedules must follow the format described for correct parsing
- This tool modifies Pi-hole’s database via the supported schema
- Only timers explicitly marked as managed by pihole-toggle are ever disabled/removed


License
-------

MIT License
