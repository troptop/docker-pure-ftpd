#!/bin/bash
echo "Pure-FTPD config directory initialization"
PureFTPPath="/etc/pure-ftpd/"
PureFTPConfDirectory="conf/"
PureFTPAuthDirectory="auth/"

echo "Check the run.sh mode (FILEMODE or NOT FILEMODE that's the question)"
if [ "$FILEMODE" == "" ] || [ "$FILEMODE" == "TRUE" ] || [ "$FILEMODE" == "true" ] ;
then
	echo "FILEMODE TRUE"
	FILEMODE=true
else 
	echo "FILEMODE FALSE"
	FILEMODE=false
fi

echo "Check if the pure-ftpd conf directory exists ($PureFTPPath$PureFTPConfDirectory)"
if [ -d "$PureFTPPath$PureFTPConfDirectory" ];
then
	echo "OK"

	if [ "$FILEMODE" == "false" ];
	then
		echo "START : Generate pureftp config file from the docker environment"
		echo "PureFTPD BOOLEAN PARAMETERS"
		echo "BOOLEAN Environment values Control"
		# BOOLEAN PARAMETERS
		BOOL="ALLOWANONYMOUSFXP ALLOWDOTFILES ALLOWUSERFXP ANONYMOUSCANCREATEDIRS ANONYMOUSCANTUPLOAD ANONYMOUSONLY ANTIWAREZ AUTORENAME BROKENCLIENTSCOMPATIBILITY CALLUPLOADSCRIPT CHROOTEVERYONE CREATEHOMEDIR CUSTOMERPROOF DAEMONIZE DISPLAYDOTFILES DONTRESOLVE IPV4ONLY IPV6ONLY KEEPALLFILES LOGPID NATMODE NOANONYMOUS NOCHMOD NORENAME PAMAUTHENTICATION PROHIBITDOTFILESREAD PROHIBITDOTFILESWRITE UNIXAUTHENTICATION VERBOSELOG";
		
		for i in $BOOL; do
			eval y='$'$i
			if [ ! -z $y ]; 
			then
				case $y in 
					"no" | "No" | "yes" | "Yes" | "1" | "0" | "off" | "Off" | "on" | "On" )
					;;
					*)
					eval $i="No" ;;
				esac
			fi
			echo -n "$i ->"
			eval y='$'$i
			echo $y
		done
		
		echo "BOOLEAN Config file creation"

		BOOLCONF="AllowAnonymousFXP AllowDotFiles AllowUserFXP AnonymousCanCreateDirs AnonymousCantUpload AnonymousOnly AntiWarez AutoRename BrokenClientsCompatibility CallUploadScript ChrootEveryone CreateHomeDir CustomerProof Daemonize DisplayDotFiles DontResolve IPV4Only IPV6Only KeepAllFiles LogPID NATmode NoAnonymous NoChmod NoRename PAMAuthentication ProhibitDotFilesRead ProhibitDotFilesWrite UnixAuthentication VerboseLog"
		
		for file in $BOOLCONF; do
			bool=$(echo "$file" | tr [:lower:] [:upper:])
		        eval y='$'$bool
		        if [ "$y" != "" ] ;
		        then
				echo "$y" > "$PureFTPPath$PureFTPConfDirectory$file"
				echo "Add value $y to $PureFTPPath$PureFTPConfDirectory$file"
		        else
		                if [ -f "$PureFTPPath$PureFTPConfDirectory$file" ];
		                then
		                        rm -f "$PureFTPPath$PureFTPConfDirectory$file"
					echo "Delete file $PureFTPPath$PureFTPConfDirectory$file"
				fi
		        fi
		done
		
		
		
		echo "PureFTPD ONE NUMBER PARAMETERS"
		echo "One Number Environment values Control"
		# ONE NUMBER PARAMETERS
		ONENUMBER="MAXCLIENTSNUMBER MAXCLIENTSPERIP MAXDISKUSAGE MAXIDLETIME MAXLOAD MINUID TLS TRUSTEDGID"
		for i in $ONENUMBER; do
		        eval y='$'$i
		        if [ ! -z $y ];
			then
				re='^[0-9]+$'
				if ! [[ $y =~ $re ]] ; then
		   			echo "ERROR: $y is not a number" ;
					eval $i=''
		   			echo "ERROR: $y is reseted to null" ;
				fi
			fi
		done
		
		
		echo "ONE NUMBER Config file creation"
		ONENUMBERCONF="MaxClientsNumber MaxClientsPerIP MaxDiskUsage MaxIdleTime MaxLoad MinUID TLS TrustedGID"
		for file in $ONENUMBERCONF; do
		        bool=$(echo "$file" | tr [:lower:] [:upper:])
		        eval y='$'$bool
		        if [ "$y" != "" ];
		        then
		                echo $y > "$PureFTPPath$PureFTPConfDirectory$file"
				echo "Add value $y to $PureFTPPath$PureFTPConfDirectory$file"
		        else
		                if [ -f "$PureFTPPath$PureFTPConfDirectory$file" ];
		                then
		                        rm -f "$PureFTPPath$PureFTPConfDirectory$file"
					echo "Delete file $PureFTPPath$PureFTPConfDirectory$file"
				fi
		        fi
		done
		
		echo "Other Config file creation"
		if [ "$TLSCIPHERSUITE" != "" ]; then
			TLSCIPHERSUITE='ALL:!aNULL:!SSLv3'
		fi
		# OTHER PARAMETER WITHOUT CONTROL
		OTHERCONF="TLSCipherSuite AnonymousRatio LimitRecursion PassivePortRange PerUserLimits Quota UserRatio AnonymousBandwidth UserBandwidth Umask AltLog Bind ForcePassiveIP SyslogFacility FSCharset ClientCharset TrustedIP FortunesFile LDAPConfigFile MySQLConfigFile PGSQLConfigFile PureDB ExtAuth"
		
		for file in $OTHERCONF; do
		        bool=$(echo "$file" | tr [:lower:] [:upper:])
		        eval y='$'$bool
		        if [ "$y" != "" ];
		        then
		                echo $y > "$PureFTPPath$PureFTPConfDirectory$file"
				echo "Add value $y to $PureFTPPath$PureFTPConfDirectory$file"
			else
				if [ -f "$PureFTPPath$PureFTPConfDirectory$file" ];
				then
					rm -f "$PureFTPPath$PureFTPConfDirectory$file"
					echo "Delete file $PureFTPPath$PureFTPConfDirectory$file"
				fi
		        fi
		done

		echo -n "PUREDB parameter existing check "
		# PUREDB AUTH LINK
		if [ "$PUREDB" != "" ]; then
			echo "-> OK"
			echo -n "PUREDB file existing check "
			if [ -d "$PureFTPPath$PureFTPAuthDirectory" ] && [ -f "$PureFTPPath$PureFTPConfDirectory""PureDB" ];
			then	
				echo "-> OK ($PureFTPPath$PureFTPConfDirectory""PureDB)" 
				$(cd "$PureFTPPath$PureFTPAuthDirectory" && ln -sf '../conf/PureDB' '20PureDB')
				echo "Symbolic Link created from $PureFTPPath$PureFTPConfDirectory""PureDB to $PureFTPPath$PureFTPAuthDirectory"'20PureDB'
			else
				echo "-> NOK"
			fi
		else
			echo "-> NOK"
			echo 'Default PUREDB path setup /etc/pure-ftpd/pureftpd.pdb'
			PUREDB='/etc/pure-ftpd/pureftpd.pdb'
		fi	


		# PASSWD FILE

		echo -n "PASSWDPATH parameter existing check "
		if [ "$PASSWDPATH" != "" ]; then
			echo "-> OK"
			echo -n "PASSWDPATH file existing check "
			if [ -f $PASSWDPATH ];then
				echo "-> OK ($PASSWDPATH)"
				echo "Generate the pdb file to $PUREDB (dont forget to add '$PUREDB' in $PureFTPPath$PureFTPConfDirectory""PureDB)" 
				pure-pw mkdb $PUREDB -f $PASSWDPATH
			else
				echo "-> NOK"
			fi
		else
			echo "-> NOK"
		fi
	fi
else
	echo "$PureFTPPath$PureFTPConfDirectory does not exist";
fi



