# Asus Merlin OpenVPN Watchdog
OpenVPN Watchdog Script for Asus Merlin Routers with Multiple OpenVPN Clients running. This script will check on intervals if the OpenVPN has a remote IP using the built in Asus Merlin `/usr/sbin/gettunnelip.sh` script. The script will restart the OpenVPN Client if it does not have a remote IP for the set amount of time.

Provided as Open Source. Any Support appreciated.

<a href="https://www.buymeacoffee.com/dieskim" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>

## Installation
1. Enable JFFS and SSH on Router
2. SSH into the router with command: ssh admin@router-ip
3. Add wan-start script with command:
`vi /jffs/scripts/wan-start`
4. Add the contents of wan-start.sh
5. Make script executable with command:
`chmod a+rx /jffs/scripts/wan-start`
6. Reboot Router
7. Monitor Logs for Watchdog events.

<a href="https://www.buymeacoffee.com/dieskim" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>

## License

This project is licensed under the terms of the [GNU General Public License version 3.0 (GPL-3.0)](https://www.gnu.org/licenses/gpl-3.0.en.html).
