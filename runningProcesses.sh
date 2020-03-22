for server in $(cat hosts)
do
echo "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
echo "---------------------("$server")---------------------" 
con $server /bin/bash << test_run

if [ -f /opt/standards/pai/marker/pai_version.txt ]
then
	echo "PAI LE Environment"
	if [ ! -f /usr/sbin/pai ]
	then
		/opt/standards/pai/bin/pai status
	else
		/usr/sbin/pai status
	fi
elif [ \$(ls /opt/jas/iap/repository/*/*/pai_version.txt | wc -l) -ge 1 ] || [ -f /opt/jas/iap/repository/pai_version.txt ] 
then
	echo "PAI J2EE Environment"
	case \$(ls /usr/local/bin/ebisctl.* | wc -l) in
                0) echo ">> ebisctl file not found on server. Checking via systemctl script"
                   systemctl | grep -i websphere
                   echo ">> If no output, kindly perform manual checks on server." ;;
		1) /usr/local/bin/ebisctl.* status ;;
		*) echo ">> More than one ebisctl file found."
			for myvar in \$(ls /usr/local/bin/ebisctl.*)
			do
			echo \$myvar 
			\$myvar status
			done ;;
	esac
else
	echo ">> Unable to find PAI installed on server."
	echo ">> Checking running processes on server...."
	case \$(ps -ef | grep java | grep -v grep | wc -l)\$(ps -ef | grep httpd | grep -v grep | wc -l) in
        	00) echo ">> No running java or httpd processes on server." ;;
        	0*) echo ">> No running java processes. Found running httpd processes on server :"
                    echo "--------------------------------------------"
               	    ps -ef | grep httpd | grep -v grep 
                    echo "--------------------------------------------" ;;
        	*0) echo ">> No running httpd processes. Found running java processes on server :"
                    echo "--------------------------------------------"
                    ps -ef | grep java | grep -v grep
                    echo "--------------------------------------------" ;;
        	*)  echo ">> Found both java and httpd processes running on server :"
                    echo "--------------------------------------------"
                    echo "Running java processes :"
                    ps -ef | grep java | grep -v grep
                    echo "--------------------------------------------"
                    echo "Running httpd processes :"
                    ps -ef | grep httpd | grep -v grep
                    echo "--------------------------------------------" ;;
	esac	
fi

echo "----------------------------------------------------"

if [ -f /sysmgmt/opt/logviewer/etc/LogViewer.xml ]
then
	/sysmgmt/opt/logviewer/bin/logviewer status
else
        echo "Logviewer not installed on server."
fi

test_run
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
echo -e "\n"
done 2>/transfer/eapp/MWE_Q1_2020/logs/$1/stderr/stderr_$2_`date +'%H.%M'`.log | tee /transfer/eapp/MWE_Q1_2020/logs/$1/output_$2_`date +'%H.%M'`.log
