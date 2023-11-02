az upgrade -y
az login

SERVER_NAME=$(grep -A1 'fspg:' /root/hammerauto/database.yml | tail -n1); SERVER_NAME=${SERVER_NAME//*server_name: /}
LOCATION=$(grep -A2 'fspg:' /root/hammerauto/database.yml | tail -n1); LOCATION=${LOCATION//*location: /}
RESOURCE_GROUP=$(grep -A3 'fspg:' /root/hammerauto/database.yml | tail -n1); RESOURCE_GROUP=${RESOURCE_GROUP//*resource_group: /}
SKU=$(grep -A4 'fspg:' /root/hammerauto/database.yml | tail -n1); SKU=${SKU//*sku: /}
TIER=$(grep -A5 'fspg:' /root/hammerauto/database.yml | tail -n1); TIER=${TIER//*tier: /}
VERSION=$(grep -A6 'fspg:' /root/hammerauto/database.yml | tail -n1); VERSION=${VERSION//*version: /}
STORAGE_SIZE=$(grep -A7 'fspg:' /root/hammerauto/database.yml | tail -n1); STORAGE_SIZE=${STORAGE_SIZE//*storage_size: /}
LOGIN_USER=$(grep -A8 'fspg:' /root/hammerauto/database.yml | tail -n1); LOGIN_USER=${LOGIN_USER//*login_user: /}
PASSWORD=$(grep -A9 'fspg:' /root/hammerauto/database.yml | tail -n1); PASSWORD=${PASSWORD//*password: /}
SUBSCRIPTION=$(grep -A10 'fspg:' /root/hammerauto/database.yml | tail -n1); SUBSCRIPTION=${SUBSCRIPTION//*subscription: /}

az account set -s $SUBSCRIPTION

echo "Server creation is starting......"
date
az postgres flexible-server show --resource-group $RESOURCE_GROUP --name $SERVER_NAME
SERVER_EXIST=$?
if [ $SERVER_EXIST -ne 0 ] ; then
        az postgres flexible-server create --location $LOCATION --resource-group $RESOURCE_GROUP \
  --name $SERVER_NAME  --admin-user $LOGIN_USER --admin-password $PASSWORD \
  --sku-name $SKU --tier $TIER --public-access 0.0.0.0-255.255.255.255 --storage-size $STORAGE_SIZE \
  --tags "key=value" --version $VERSION --high-availability Disabled --zone 1
          echo "server creation is finished"
          date
          #sleep 600
          echo "############################# server creation has finished ######################################"
          az postgres flexible-server parameter set --name pg_qs.query_capture_mode --value ALL --resource-group $RESOURCE_GROUP --server-name $SERVER_NAME
          az postgres flexible-server parameter set --name pg_qs.store_query_plans --value ON --resource-group $RESOURCE_GROUP --server-name $SERVER_NAME
          az postgres flexible-server parameter set --name pgms_wait_sampling.query_capture_mode --value ALL --resource-group $RESOURCE_GROUP --server-name $SERVER_NAME
	  az postgres flexible-server parameter set --name metrics.collector_database_activity --value ON --resource-group $RESOURCE_GROUP --server-name $SERVER_NAME
          #az monitor diagnostic-settings create
	  az monitor diagnostic-settings create --resource /subscriptions/$SUBSCRIPTION/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.DBforPostgreSQL/flexibleServers/$SERVER_NAME --name myDiagnosticSetting --logs '[{"category": "PostgreSQLLogs", "enabled": true},{"category": "PostgreSQLFlexSessions", "enabled": true},{"category": "PostgreSQLFlexQueryStoreRuntime", "enabled": true},{"category": "PostgreSQLFlexQueryStoreWaitStats", "enabled": true},{"category": "PostgreSQLFlexTableStats", "enabled": true},{"category": "PostgreSQLFlexDatabaseXacts", "enabled": true}]' --metrics '[{"category": "AllMetrics", "enabled": true}]' --workspace /subscriptions/$SUBSCRIPTION/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/ktutika
else
        echo "#################### server already exists . Proceeding with next step hammerdbcli installation #################"

fi


echo "----- cleanup the previous hammerdbcli installation --------------"
rm -Rf /root/hammerdbcli
rm -Rf /usr/local/HammerDB-3.3
mkdir -p /root/hammerdbcli

#echo "moving the database.yml file"
#cp -rp /root/hammerauto/database.yml /root/hammerdbcli

echo "---------------- download hammerdb cli files ---------------------"
wget -P /root/hammerdbcli https://github.com/TPC-Council/HammerDB/releases/download/v3.3/HammerDB-3.3-Linux-x86-64-Install
chmod u+x /root/hammerdbcli/HammerDB-3.3-Linux-x86-64-Install
export PATH=$PATH:/root/hammerdbcli

echo "---------------- install hammerdbcli in silent mode ---------------------"
HammerDB-3.3-Linux-x86-64-Install --mode silent

echo "---------------- download the tcl file ---------------------"
curl 'https://microsoftapc-my.sharepoint.com/personal/ktutika_microsoft_com/_layouts/15/download.aspx?SourceUrl=%2Fpersonal%2Fktutika%5Fmicrosoft%5Fcom%2FDocuments%2Fdbtune%2Faz%2FNew%20Text%20Document%2Etxt' \
  -H 'authority: microsoftapc-my.sharepoint.com' \
  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'cookie: MicrosoftApplicationsTelemetryDeviceId=7d838d5f-6f35-4409-99ca-11488f691b17; MicrosoftApplicationsTelemetryFirstLaunchTime=; SIMI=eyJzdCI6MH0=; MicrosoftApplicationsTelemetryDeviceId=7d838d5f-6f35-4409-99ca-11488f691b17; rtFa=FCB3rFeFwdJYCGDEMgFf1IkCi6E7h8XtHwdwGsILUf0mRUM2M0IwOUItOTc0OC00N0JBLTkwMTgtQkVFQURENDA1MjA0IzEzMzQzMjAwNDkwODA0OTAzMCMwMjYzRTlBMC03MDRCLTIwMDAtQUE4RS01NUFFOTY5Mjk1MEIjS1RVVElLQSU0ME1JQ1JPU09GVC5DT00jMTk1OTI2I1ZUR0NCRVRHUERJU1FLRUhWRVNQRi0xQU1KScigfI9n9SHai6esS0JSCrrVbWVJ/tBpUYLVOS6+pkm5KNeP8/etYqmAtvim4sc85NStNbg48dPgkhqdJD7XAk/xjATsNt1Lp574SHItMSsU9ZDNIfOkUQmnVZG53jPSe5adC9cUrJq4VNEefbNUXA/j0gDVLKPW/lwboiVNIxerXHaBJuiC+Jed4saDesLrwzFqh1xTXuncFGpkaAu74FlLum5sgrlWaYNFPjatMDgErTe+yWLLLP//JXREmBhpBEvSDZmEkHXtTi8EK+C83h/MI7C6lwL+DOq92Osf/AjNxNcGg2v4gXE6SxgEWQiuc9f5e4YiPX+7qImMBLvmYS64AAAA; MSFPC=GUID=632ae5a3f9fe42179166c422daaefc4b&HASH=632a&LV=202212&V=4&LU=1671699099644; FedAuth=77u/PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz48U1A+VjEzLDBoLmZ8bWVtYmVyc2hpcHwxMDAzMjAwMWZjMWNkODIxQGxpdmUuY29tLDAjLmZ8bWVtYmVyc2hpcHxrdHV0aWthQG1pY3Jvc29mdC5jb20sMTMzNDMxOTg1MjgwMDAwMDAwLDEzMjk4NDY2MjUzMDAwMDAwMCwxMzM0MzY1MjgzMTc4OTQzOTEsMjQwNDpmODAxOjgwMjg6MzphOWJhOjgxZmQ6YjdjMDo1ZDIyLDczOSxlYzYzYjA5Yi05NzQ4LTQ3YmEtOTAxOC1iZWVhZGQ0MDUyMDQsLDQzODFkODY3LWU1OTQtNGZhMS1hMTY3LTliMWVhYzQwMzI5ZCwwMjYzZTlhMC03MDRiLTIwMDAtYWE4ZS01NWFlOTY5Mjk1MGIsNjg3NmU5YTAtZDA2MS0yMDAwLWFhOGUtNWI1OTdlYWU2MDk1LCwwLDEzMzQzMjQ5NDMwMjAzNDAzMCwxMzM0MzUwNTAzMDIwMzQwMzAsLCxleUpqWVhCdmJHbGtjMTlzWVhSbFltbHVaQ0k2SWx0Y0lqVTVOVFptWmpWaExUWm1aR0l0TkRjM1pTMDVaRFJrTFRsbU4yUXlOakpsTmprMFlWd2lYU0lzSW5odGMxOWpZeUk2SWx0Y0lrTlFNVndpWFNJc0luaHRjMTl6YzIwaU9pSXhJaXdpZUcxelgyTmhaV05vWldOcmN5STZJakVpTENKd2NtVm1aWEp5WldSZmRYTmxjbTVoYldVaU9pSnJkSFYwYVd0aFFHMXBZM0p2YzI5bWRDNWpiMjBpTENKMWRHa2lPaUl0VldwMVdrSnhVV0V3Y1Vac2NUbDVkbmRSYVVGQkluMD0sMjY1MDQ2Nzc0Mzk5OTk5OTk5OSwxMzM0MzIwMDQ5MDAwMDAwMDAsMmIyOWJiMTQtNmI2NC00NmU5LWJmNjYtZmU1OTA4YjcxZGRjLCwsLCwsMCwsMTk1OTI2LEdBZHhXWDNxZy1wbFA0ZTlYQlAxeTE2aWZqVSxtUG5EbTlMTkd5L2VML1dISkNxS2VxL0s4MFV4YS9wekJKUnhOLys0UVdXdTlhVE1LajBqWUJTeVY3Z2libExzeTFmTUVBbERGMzc3MnAxRFp3SlQ3OUN3SFAxcDJJb1dMTEpONXhRQ0poUG1JUVc3RThkR0d6RnRINEJ5ZGNXV1ZBc29tWnNXQTBxUVhEQmJiTDlFbi9jczNXSFdBQVIxK2tXLzlSK09jM1RLaEU5R2RTN21NYVRlSi96Qi9RK3ZsZCs5UlZjVWRGaCtWaWR5TmEvQzFsK0p2OEJVNTBPdThiOWoyakw1ZmJnQUJDN2lKMS9rWGdCZlFVdHVtTms1VzN1UHJQbGU2S0pvOVJ0TVJBd1lRL3prWjdGYjBYdWF1VmpmUnZ1cFl4V2JLNUZzMGh2SGpVbEpJWHlXYVhpOStwWFZsMkJEYXVhdGp1aGloYUlMNUE9PTwvU1A+; ai_session=MNwaa70TCycgH4ph0XhDFV|1698747469310|1698747469310' \
  -H 'referer: https://microsoftapc-my.sharepoint.com/personal/ktutika_microsoft_com/_layouts/15/onedrive.aspx?id=%2Fpersonal%2Fktutika%5Fmicrosoft%5Fcom%2FDocuments%2Fdbtune%2Faz%2FNew%20Text%20Document%2Etxt&parent=%2Fpersonal%2Fktutika%5Fmicrosoft%5Fcom%2FDocuments%2Fdbtune%2Faz&ga=1' \
  -H 'sec-ch-ua: "Chromium";v="118", "Google Chrome";v="118", "Not=A?Brand";v="99"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"' \
  -H 'sec-fetch-dest: iframe' \
  -H 'sec-fetch-mode: navigate' \
  -H 'sec-fetch-site: same-origin' \
  -H 'sec-fetch-user: ?1' \
  -H 'service-worker-navigation-preload: true' \
  -H 'upgrade-insecure-requests: 1' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36' \
  --compressed --output /usr/local/HammerDB-3.3/pg_prepare.tcl
sleep 5

PGHOST=$(grep -A1 'hammer:' /root/hammerauto/database.yml | tail -n1); PGHOST=${PGHOST//*pghost: /}
PGPORT=$(grep -A2 'hammer:' /root/hammerauto/database.yml | tail -n1); PGPORT=${PGPORT//*pgport: /}
PGVUSERS=$(grep -A3 'hammer:' /root/hammerauto/database.yml | tail -n1); PGVUSERS=${PGVUSERS//*pgvusers: /}
WAREHOUSE_COUNT=$(grep -A4 'hammer:' /root/hammerauto/database.yml | tail -n1); WAREHOUSE_COUNT=${WAREHOUSE_COUNT//*warehouse_count: /}
SUPERUSER=$(grep -A5 'hammer:' /root/hammerauto/database.yml | tail -n1); SUPERUSER=${SUPERUSER//*superuser: /}
PGPASSWORD=$(grep -A6 'hammer:' /root/hammerauto/database.yml | tail -n1); PGPASSWORD=${PGPASSWORD//*pgpassword: /}
PGDATABASE=$(grep -A7 'hammer:' /root/hammerauto/database.yml | tail -n1); PGDATABASE=${PGDATABASE//*pgdatabase: /}


echo "******** drop the db owned by user tpcc and then drop user tpcc********************************"
export PGPASSWORD=$PGPASSWORD
#BAD_DBNAME=(`psql -h $PGHOST -p 5432 -t -U $SUPERUSER -d postgres -c "select datname from pg_database where datdba = (select usesysid from pg_user where usename='tpcc')"`)
#echo $BAD_DBNAME

psql -h $PGHOST -U $SUPERUSER -p $PGPORT -d postgres -c "drop database if exists $PGDATABASE;"
sleep 30
psql -h $PGHOST -U $SUPERUSER -p $PGPORT -d postgres -c "drop user tpcc;"

echo "old database and user tpcc are dropped"
echo "****** set the parameters in the tcl file **********"
sed -i -e "s/PGHOST/$PGHOST/g" -e "s/PGPORT/$PGPORT/g" -e "s/PGVUSERS/$PGVUSERS/g" -e "s/WAREHOUSE_COUNT/$WAREHOUSE_COUNT/g" -e "s/SUPERUSER/$SUPERUSER/g" -e "s/PGPASSWORD/$PGPASSWORD/g" -e "s/PGDATABASE/$PGDATABASE/g" /usr/local/HammerDB-3.3/pg_prepare.tcl

export PATH=$PATH:/usr/local/HammerDB-3.3
echo "****** Execute hammerdbcli to load the data on to a database **********"
cd /usr/local/HammerDB-3.3 && hammerdbcli auto /usr/local/HammerDB-3.3/pg_prepare.tcl
echo "------------- loading is completed ----------------"

echo "---------------- down load the workload files -----------------------------"
curl 'https://microsoftapc-my.sharepoint.com/personal/ktutika_microsoft_com/_layouts/15/download.aspx?SourceUrl=%2Fpersonal%2Fktutika%5Fmicrosoft%5Fcom%2FDocuments%2Fdbtune%2FLatest%2Fhammerauto%2Ezip' \
  -H 'authority: microsoftapc-my.sharepoint.com' \
  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'cookie: MicrosoftApplicationsTelemetryDeviceId=7d838d5f-6f35-4409-99ca-11488f691b17; MicrosoftApplicationsTelemetryFirstLaunchTime=; SIMI=eyJzdCI6MH0=; MicrosoftApplicationsTelemetryDeviceId=7d838d5f-6f35-4409-99ca-11488f691b17; rtFa=FCB3rFeFwdJYCGDEMgFf1IkCi6E7h8XtHwdwGsILUf0mRUM2M0IwOUItOTc0OC00N0JBLTkwMTgtQkVFQURENDA1MjA0IzEzMzQzMjAwNDkwODA0OTAzMCMwMjYzRTlBMC03MDRCLTIwMDAtQUE4RS01NUFFOTY5Mjk1MEIjS1RVVElLQSU0ME1JQ1JPU09GVC5DT00jMTk1OTI2I1ZUR0NCRVRHUERJU1FLRUhWRVNQRi0xQU1KScigfI9n9SHai6esS0JSCrrVbWVJ/tBpUYLVOS6+pkm5KNeP8/etYqmAtvim4sc85NStNbg48dPgkhqdJD7XAk/xjATsNt1Lp574SHItMSsU9ZDNIfOkUQmnVZG53jPSe5adC9cUrJq4VNEefbNUXA/j0gDVLKPW/lwboiVNIxerXHaBJuiC+Jed4saDesLrwzFqh1xTXuncFGpkaAu74FlLum5sgrlWaYNFPjatMDgErTe+yWLLLP//JXREmBhpBEvSDZmEkHXtTi8EK+C83h/MI7C6lwL+DOq92Osf/AjNxNcGg2v4gXE6SxgEWQiuc9f5e4YiPX+7qImMBLvmYS64AAAA; MSFPC=GUID=632ae5a3f9fe42179166c422daaefc4b&HASH=632a&LV=202212&V=4&LU=1671699099644; FedAuth=77u/PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz48U1A+VjEzLDBoLmZ8bWVtYmVyc2hpcHwxMDAzMjAwMWZjMWNkODIxQGxpdmUuY29tLDAjLmZ8bWVtYmVyc2hpcHxrdHV0aWthQG1pY3Jvc29mdC5jb20sMTMzNDMxOTg1MjgwMDAwMDAwLDEzMjk4NDY2MjUzMDAwMDAwMCwxMzM0MzY1MjgzMTc4OTQzOTEsMjQwNDpmODAxOjgwMjg6MzphOWJhOjgxZmQ6YjdjMDo1ZDIyLDczOSxlYzYzYjA5Yi05NzQ4LTQ3YmEtOTAxOC1iZWVhZGQ0MDUyMDQsLDQzODFkODY3LWU1OTQtNGZhMS1hMTY3LTliMWVhYzQwMzI5ZCwwMjYzZTlhMC03MDRiLTIwMDAtYWE4ZS01NWFlOTY5Mjk1MGIsNjg3NmU5YTAtZDA2MS0yMDAwLWFhOGUtNWI1OTdlYWU2MDk1LCwwLDEzMzQzMjQ5NDMwMjAzNDAzMCwxMzM0MzUwNTAzMDIwMzQwMzAsLCxleUpqWVhCdmJHbGtjMTlzWVhSbFltbHVaQ0k2SWx0Y0lqVTVOVFptWmpWaExUWm1aR0l0TkRjM1pTMDVaRFJrTFRsbU4yUXlOakpsTmprMFlWd2lYU0lzSW5odGMxOWpZeUk2SWx0Y0lrTlFNVndpWFNJc0luaHRjMTl6YzIwaU9pSXhJaXdpZUcxelgyTmhaV05vWldOcmN5STZJakVpTENKd2NtVm1aWEp5WldSZmRYTmxjbTVoYldVaU9pSnJkSFYwYVd0aFFHMXBZM0p2YzI5bWRDNWpiMjBpTENKMWRHa2lPaUl0VldwMVdrSnhVV0V3Y1Vac2NUbDVkbmRSYVVGQkluMD0sMjY1MDQ2Nzc0Mzk5OTk5OTk5OSwxMzM0MzIwMDQ5MDAwMDAwMDAsMmIyOWJiMTQtNmI2NC00NmU5LWJmNjYtZmU1OTA4YjcxZGRjLCwsLCwsMCwsMTk1OTI2LEdBZHhXWDNxZy1wbFA0ZTlYQlAxeTE2aWZqVSxtUG5EbTlMTkd5L2VML1dISkNxS2VxL0s4MFV4YS9wekJKUnhOLys0UVdXdTlhVE1LajBqWUJTeVY3Z2libExzeTFmTUVBbERGMzc3MnAxRFp3SlQ3OUN3SFAxcDJJb1dMTEpONXhRQ0poUG1JUVc3RThkR0d6RnRINEJ5ZGNXV1ZBc29tWnNXQTBxUVhEQmJiTDlFbi9jczNXSFdBQVIxK2tXLzlSK09jM1RLaEU5R2RTN21NYVRlSi96Qi9RK3ZsZCs5UlZjVWRGaCtWaWR5TmEvQzFsK0p2OEJVNTBPdThiOWoyakw1ZmJnQUJDN2lKMS9rWGdCZlFVdHVtTms1VzN1UHJQbGU2S0pvOVJ0TVJBd1lRL3prWjdGYjBYdWF1VmpmUnZ1cFl4V2JLNUZzMGh2SGpVbEpJWHlXYVhpOStwWFZsMkJEYXVhdGp1aGloYUlMNUE9PTwvU1A+' \
  -H 'if-none-match: "{C889B364-DA48-4AA4-99CE-0C18CDEAE363},3"' \
  -H 'referer: https://microsoftapc-my.sharepoint.com/personal/ktutika_microsoft_com/_layouts/15/onedrive.aspx?id=%2Fpersonal%2Fktutika%5Fmicrosoft%5Fcom%2FDocuments%2Fdbtune%2FLatest%2Fhammerauto%2Ezip&parent=%2Fpersonal%2Fktutika%5Fmicrosoft%5Fcom%2FDocuments%2Fdbtune%2FLatest&ga=1' \
  -H 'sec-ch-ua: "Chromium";v="118", "Google Chrome";v="118", "Not=A?Brand";v="99"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"' \
  -H 'sec-fetch-dest: iframe' \
  -H 'sec-fetch-mode: navigate' \
  -H 'sec-fetch-site: same-origin' \
  -H 'sec-fetch-user: ?1' \
  -H 'service-worker-navigation-preload: true' \
  -H 'upgrade-insecure-requests: 1' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36' \
  --compressed --output /usr/local/HammerDB-3.3/workloadfiles.zip

cd /usr/local/HammerDB-3.3 && unzip workloadfiles.zip


echo "----------------- create the new three tables and compile procedure ---------------------"
export PGPASSWORD=$PGPASSWORD
psql -h $PGHOST -U $SUPERUSER -p $PGPORT -d $PGDATABASE -f /usr/local/HammerDB-3.3/hammerauto/hammerdbtune_threetables.sql
psql -h $PGHOST -U $SUPERUSER -p $PGPORT -d $PGDATABASE -f /usr/local/HammerDB-3.3/hammerauto/upsert_procedure.sql

PGDATABASE=$(grep -A2 'workload:' /root/hammerauto/database.yml | tail -n1); PGDATABASE=${PGDATABASE//*pgdatabase: /}
LOGIN_USER=$(grep -A3 'workload:' /root/hammerauto/database.yml | tail -n1); LOGIN_USER=${LOGIN_USER//*login_user: /}
PGPASSWORD=$(grep -A4 'workload:' /root/hammerauto/database.yml | tail -n1); PGPASSWORD=${PGPASSWORD//*pgpassword: /}
WORKLOAD_DURATION=$(grep -A5 'workload:' /root/hammerauto/database.yml | tail -n1); WORKLOAD_DURATION=${WORKLOAD_DURATION//*workload_duration: /}
WORKLOAD_TYPE=$(grep -A6 'workload:' /root/hammerauto/database.yml | tail -n1); WORKLOAD_TYPE=${WORKLOAD_TYPE//*workload_type: /}
VCORE=$(grep -A7 'workload:' /root/hammerauto/database.yml | tail -n1); VCORE=${VCORE//*vcore: /}

chmod u+x /usr/local/HammerDB-3.3/hammerauto/*.sh

sed -i -e "s/PGHOST/$PGHOST/g" -e "s/LOGIN_USER/$LOGIN_USER/g" -e "s/PGPASSWORD/$PGPASSWORD/g" -e "s/WORKLOAD_DURATION/$WORKLOAD_DURATION/g" -e "s/PGDATABASE/$PGDATABASE/g" /usr/local/HammerDB-3.3/hammerauto/*.sh
export PGPASSWORD=$PGPASSWORD

echo "initialize pgbench"
pgbench -i -h $PGHOST -p 5432 -U $SUPERUSER -d $PGDATABASE
echo "=========================== workload will run for $WORKLOAD_DURATION seconds ======================"
start_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [[ $WORKLOAD_TYPE == "read" && $VCORE == 8 ]] ; then
        echo "Initiating load on read heavy 8 v core server"
        cd  /usr/local/HammerDB-3.3/hammerauto && bash read_heavy_script-8.sh
elif [[ $WORKLOAD_TYPE == "read" && $VCORE == 16 ]]; then
        echo "Initiating load on read heavy 16 v core server"
        cd  /usr/local/HammerDB-3.3/hammerauto && bash read_heavy_script-16.sh
elif [[ $WORKLOAD_TYPE == "write" && $VCORE == 8 ]]; then
        echo "Initiating load on write heavy 8 v core server"
        cd  /usr/local/HammerDB-3.3/hammerauto && bash write_heavy_script-8.sh
elif [[ $WORKLOAD_TYPE == "write" && $VCORE == 16 ]]; then
        echo "Initiating load on write heavy 16 v core server"
        cd  /usr/local/HammerDB-3.3/hammerauto && bash write_heavy_script-16.sh
elif [[ $WORKLOAD_TYPE == "mixed" && $VCORE == 8 ]]; then
        echo "Initiating load on mixed heavy 8 v core server"
        cd  /usr/local/HammerDB-3.3/hammerauto && bash mixed_heavy_script-8.sh
else
        echo "Initiating load on mixed heavy 16 v core server"
        cd  /usr/local/HammerDB-3.3/hammerauto && bash mixed_heavy_script-16.sh
fi

sleep $WORKLOAD_DURATION

echo "=========================== workload is finished ======================"
end_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "=========================== kill the remaining screen sessions =================="
screen -ls | grep Detached | cut -d. -f1 | awk '{print $1}' | xargs kill
echo "=========================== screen sessions are killed =================="

echo "============= wait for all the log analytics data to reflect - 15 minutes ====================== "
sleep 900

echo "============= fetching log analytic insights ============="
######################################################################
#pip3 install azure-storage-blob
#pip3 install azure-identity
#pip3 install azure-monitor-query
#pip3 install openpyxl
#pip3 install numpy
#pip3 install scipy
#pip3 install pandas==1.2.4

WORKSPACE_ID=$(cat /root/hammerauto/database.yml | grep -oP '(?<=workspace_id: ).*')
LOGICAL_SERVER_NAME=$SERVER_NAME
START_TIME=$start_time
END_TIME=$end_time

export PGPASSWORD=$PGPASSWORD

QUERY_IDS=$(psql -h $PGHOST -p 5432 -U $SUPERUSER -d azure_sys -t -c  "SELECT distinct(query_id),mean_time FROM azure_sys.query_store.qs_view ORDER BY mean_time DESC LIMIT 5;")

QUERY_ID1=$(echo $QUERY_IDS|awk '{print $1}')
QUERY_ID2=$(echo $QUERY_IDS|awk '{print $4}')
QUERY_ID3=$(echo $QUERY_IDS|awk '{print $7}')
QUERY_ID4=$(echo $QUERY_IDS|awk '{print $10}')
QUERY_ID5=$(echo $QUERY_IDS|awk '{print $13}')


sed -i -e "s/WORKSPACE_ID/$WORKSPACE_ID/g" -e "s/LOGICAL_SERVER_NAME/$LOGICAL_SERVER_NAME/g" -e "s/QUERY1/$QUERY_ID1/g" -e "s/QUERY2/$QUERY_ID2/g" -e "s/QUERY3/$QUERY_ID3/g" -e "s/QUERY4/$QUERY_ID4/g" -e "s/QUERY5/$QUERY_ID5/g" -e "s/START_TIME/$START_TIME/g" -e "s/END_TIME/$END_TIME/g"  /root/hammerauto/python/config.json

echo  "========== starting the log insights script ============"
cd /root/hammerauto/python && python3 log_analytics_metrics1.py


