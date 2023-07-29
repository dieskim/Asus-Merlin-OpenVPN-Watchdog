#!/bin/sh

# set how often to check connection in seconds - 150 seconds = 2.5 min
WATCHDOG_SLEEP_SEC=150

logger "vpn watchdog" "startup - sleeping ${WATCHDOG_SLEEP_SEC} seconds"

# vpn_client_remote_ip_check - checks vpn client remote ip - waits for remote ip and restarts if needed
vpn_client_remote_ip_check(){
	VPN_CLIENT_ID_PASSED=$1
	# run remote ip check
	sh /usr/sbin/gettunnelip.sh "${VPN_CLIENT_ID_PASSED}"
	sleep 5		
	REMOTE_IP=$(nvram get vpn_client${VPN_CLIENT_ID_PASSED}_rip)
	if expr "$REMOTE_IP" : "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$" >/dev/null; 
	then
		logger "vpn watchdog" "vpnclient${VPN_CLIENT_ID_PASSED} - connected with remote ip: $REMOTE_IP"
	else
		logger "vpn watchdog" "vpnclient${VPN_CLIENT_ID_PASSED} - connected - remote ip not set - waiting 60 seconds and running ip check - remote ip: $REMOTE_IP"
		sleep 60
		# run remote ip check
		sh /usr/sbin/gettunnelip.sh "${VPN_CLIENT_ID_PASSED}"
		sleep 5		
		REMOTE_IP=$(nvram get vpn_client${VPN_CLIENT_ID_PASSED}_rip)
		if expr "$REMOTE_IP" : "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$" >/dev/null; 
		then
			logger "vpn watchdog" "vpnclient${VPN_CLIENT_ID_PASSED} - connected with remote ip: $REMOTE_IP"
		else
			logger "vpn watchdog" "vpnclient${VPN_CLIENT_ID_PASSED} - no remote ip: $REMOTE_IP - restarting"
			vpn_client_remote_restart ${VPN_CLIENT_ID_PASSED}
		fi
	fi
}

# vpn_client_remote_restart - restarts vpn client
vpn_client_remote_restart(){
	VPN_CLIENT_ID_PASSED=$1
	sleep 5
	STOP=$(service stop_vpnclient${VPN_CLIENT_ID_PASSED})
	sleep 30
	START=$(service start_vpnclient${VPN_CLIENT_ID_PASSED})
}

# MAIN WHILE TO CHECK VPN CLIENTS AT INTERVAL
while sleep $WATCHDOG_SLEEP_SEC
do
	VPN_CLIENTS_ENABLED=$(nvram get vpn_clientx_eas | sed 's/,/ /g')	# checks for vpn clients with Automatic start at boot time = Yes
	logger "vpn watchdog" "checking state of enabled vpnclients - ${VPN_CLIENTS_ENABLED}" 
	# loop over vpn clients
	for i in $VPN_CLIENTS_ENABLED
    do
      	VPN_CLIENT_ID=$i
      	CONNECTION_STATE=$(nvram get vpn_client${VPN_CLIENT_ID}_state)
		#pidof vpnclient4 - check PID if needed in future?
		if [ $CONNECTION_STATE = "2" ] 				# CONNECTED - check remote IP here
		then
			vpn_client_remote_ip_check ${VPN_CLIENT_ID} & 		# & at end allows command to be executed in background
		else
			if [ $CONNECTION_STATE = "1" ]			# CONNECTING - wait
			then
				logger "vpn watchdog" "vpnclient${VPN_CLIENT_ID} - connecting - waiting until next check"	
			else									# OTHER STATE - restart
				logger "vpn watchdog" "vpnclient${VPN_CLIENT_ID} - disconnected - restarting"
				vpn_client_remote_restart ${VPN_CLIENT_ID} &	# & at end allows command to be executed in background	
			fi
		fi
    done
done 2>&1 &