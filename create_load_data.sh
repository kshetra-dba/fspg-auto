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
  -H 'accept-language: en-GB,en-IN;q=0.9,en;q=0.8,te-IN;q=0.7,te;q=0.6,en-US;q=0.5' \
  -H 'cookie: MicrosoftApplicationsTelemetryDeviceId=da92a626-5291-f42a-3196-c9aeafeb29e7; MicrosoftApplicationsTelemetryFirstLaunchTime=1698045390128; rtFa=uSxBs2wJ87ETLAagOsnfpLUt0GgQHuuQgvnEGOFCA4smRUM2M0IwOUItOTc0OC00N0JBLTkwMTgtQkVFQURENDA1MjA0IzEzMzQyNTE4OTg1Nzg3NTA1MyMxM0Q5RTZBMC1FMDNDLTIwMDAtQTY4QS03QjZFRDgwMDM0MUYjS1RVVElLQSU0ME1JQ1JPU09GVC5DT00jMTk1OTI2I1ZUR0NCRVRHUERJU1FLRUhWRVNQRi0xQU1KSYK9ucqZfFCqd03q+3irKIqrPA/BMnuHnobx9CxTbUMJMLvGY57V2QX3oUFlMgVQDt5bFs/A47D+Aj9Dy3jodbvfUDYNc/WjJiSWEdH+t8h+V6f1tm2FBlsGkMu3l0tou5yDeRaN+CPf2G0UfkqxW/Zx3AOLxaIU8UBW/mJB5h5C1kWnIuWKv1hvjsVqQ1LHQxPX8huE7R3gyKFJOdObAnYt0oG4ssCSnYeTsULVhMEyuXvymuY6EK8ljIV0OBV96lchl0EpSvu6qAi9XWD44PMq2gBNT/ixgNe0OrSsY1GABexb3mnchZgxXmK98zPxUynjtutmMl3Xf7Ql3lT1NF64AAAA; SIMI=eyJzdCI6MH0=; MicrosoftApplicationsTelemetryDeviceId=da92a626-5291-f42a-3196-c9aeafeb29e7; FedAuth=77u/PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz48U1A+VjEzLDBoLmZ8bWVtYmVyc2hpcHwxMDAzMjAwMWZjMWNkODIxQGxpdmUuY29tLDAjLmZ8bWVtYmVyc2hpcHxrdHV0aWthQG1pY3Jvc29mdC5jb20sMTMzNDI1MTQwNTUwMDAwMDAwLDEzMjk4NDY2MjUzMDAwMDAwMCwxMzM0MzQxMjMxNTMxNDg3ODQsMjQwNToyMDE6YzAwODpiOGE5OmU1ZTE6NmI5Zjo1MDA5OmY2OTMsNzM5LGVjNjNiMDliLTk3NDgtNDdiYS05MDE4LWJlZWFkZDQwNTIwNCwsNDIwYTE1MzMtNzM1Ni00YTQ5LWExYTAtMWZhZGI3NWNiOWQwLDEzZDllNmEwLWUwM2MtMjAwMC1hNjhhLTdiNmVkODAwMzQxZiwwODkxZThhMC03MDdlLTIwMDAtYTkxNy1hMjc2ZDRhM2Q2ZWIsLDAsMTMzNDI5ODM5MTUyOTkyNTU4LDEzMzQzMjM5NTE1Mjk5MjU1OCwsLGV5SmpZWEJ2Ykdsa2MxOXNZWFJsWW1sdVpDSTZJbHRjSWpVNU5UWm1aalZoTFRabVpHSXRORGMzWlMwNVpEUmtMVGxtTjJReU5qSmxOamswWVZ3aVhTSXNJbmh0YzE5all5STZJbHRjSWtOUU1Wd2lYU0lzSW5odGMxOXpjMjBpT2lJeElpd2llRzF6WDJOaFpXTm9aV05yY3lJNklqRWlMQ0p3Y21WbVpYSnlaV1JmZFhObGNtNWhiV1VpT2lKcmRIVjBhV3RoUUcxcFkzSnZjMjltZEM1amIyMGlMQ0oxZEdraU9pSmhZWFpDV1UxS2NEbHJjVkZuVGpCU2NtVktaRUZCSW4wPSwyNjUwNDY3NzQzOTk5OTk5OTk5LDEzMzQyNTE4OTg1MDAwMDAwMCwyYjI5YmIxNC02YjY0LTQ2ZTktYmY2Ni1mZTU5MDhiNzFkZGMsLCwsLCwwLCwxOTU5MjYsR0FkeFdYM3FnLXBsUDRlOVhCUDF5MTZpZmpVLENKRUpjUmxtRFRqQjRDT1FvbjZyWmxTRWFyanNyb1BVYSszOFRndk10QUNOVU10aHBTSndwZVpPSkZLN0xjTHN0dFRNaXUyTVdUbkJ1VXJOeXEzanVtMkUzempNbjU1MUlmRXlUZ0pLem5Kb2VzRUR0Q3hPdkl6bThNdnphM1hIbXdmT2JBRENvOWQ0R1pocnRKSGZTMDVEM29oOXhaWEFoVExhMDl5TXpZVU1qa0hOb1J2M0dHOWN2S0ozRGc3TFp3Tm1kSnBCQ0RqQWhwYWsxSFR1V1JpbG5LL1ZOaU5oOWV1MGgvLzlQUHkxT3Vqa2dBWG9iTjN1MkhsTnM0ay9EZzNuSlloQVN5Tkh6QkZXUjAxdHVJa3M5Q202RVhTSVVlU3VwdnZ4dXQwWEkvQU9YeXB0NW1JemI1ME8vazlkUDhTYzZaM2Ewa3hVOVV0aFh6MWN3Zz09PC9TUD4=' \
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
  -H 'cookie: MicrosoftApplicationsTelemetryDeviceId=7d838d5f-6f35-4409-99ca-11488f691b17; MicrosoftApplicationsTelemetryFirstLaunchTime=; rtFa=FCB3rFeFwdJYCGDEMgFf1IkCi6E7h8XtHwdwGsILUf0mRUM2M0IwOUItOTc0OC00N0JBLTkwMTgtQkVFQURENDA1MjA0IzEzMzQyNzgxMDE4NjM0MTc4MyNGOEQyRTdBMC1DMDE5LTIwMDAtQTY4QS03QTJBRkYzQzc4MUYjS1RVVElLQSU0ME1JQ1JPU09GVC5DT00jMTk1OTI2I1ZUR0NCRVRHUERJU1FLRUhWRVNQRi0xQU1KSQA15bITcPEK5K9eteNcZhpFOHqJ9gxZaodgiq8rYK0gq8WSJhkmJq5/CoFWMqRXXHhNHggXtWUuxUsA2Ckilg7jWdsEU3mQrc09UInN/Nw8hmwKOMykB5xI8XlFh60nI6jAdqqgFN5rBtqc67b7yoMpex3lR8xZZoRkv8Q6e4bzmBYzl86SPeNIJa8X2jxDJ12aU0GKANWKrjGTnHwnCx3TyPZ02tRwhitRXBwtQRmiYVSGghKjA8H+FywbfO/3IX9MYGgY7vw/g6E0q6XMdODFi496cX3tRMZlTDmsGHe57zH2fT++s23raOwInBG9nTET0Z+Du+xSiS6PJaWipAu4AAAA; SIMI=eyJzdCI6MH0=; MicrosoftApplicationsTelemetryDeviceId=7d838d5f-6f35-4409-99ca-11488f691b17; FedAuth=77u/PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz48U1A+VjEzLDBoLmZ8bWVtYmVyc2hpcHwxMDAzMjAwMWZjMWNkODIxQGxpdmUuY29tLDAjLmZ8bWVtYmVyc2hpcHxrdHV0aWthQG1pY3Jvc29mdC5jb20sMTMzNDI3ODAyNTEwMDAwMDAwLDEzMjk4NDY2MjUzMDAwMDAwMCwxMzM0MzU0Mzk4MTU0NTYzNzYsMjQwNDpmODAxOjgwMjg6Mzo5ZDMxOjE2NWQ6ZmFiZjoxY2RhLDczOSxlYzYzYjA5Yi05NzQ4LTQ3YmEtOTAxOC1iZWVhZGQ0MDUyMDQsLDQzODFkODY3LWU1OTQtNGZhMS1hMTY3LTliMWVhYzQwMzI5ZCxmOGQyZTdhMC1jMDE5LTIwMDAtYTY4YS03YTJhZmYzYzc4MWYsOTkwZWU5YTAtOTA5ZS0yMDAwLWFhOGUtNTFiNTU0ODUwY2NmLCwwLDEzMzQzMTQwNzgxNDI5NDI3NiwxMzM0MzM5NjM4MTQyOTQyNzYsLCxleUpqWVhCdmJHbGtjMTlzWVhSbFltbHVaQ0k2SWx0Y0lqVTVOVFptWmpWaExUWm1aR0l0TkRjM1pTMDVaRFJrTFRsbU4yUXlOakpsTmprMFlWd2lYU0lzSW5odGMxOWpZeUk2SWx0Y0lrTlFNVndpWFNJc0luaHRjMTl6YzIwaU9pSXhJaXdpZUcxelgyTmhaV05vWldOcmN5STZJakVpTENKd2NtVm1aWEp5WldSZmRYTmxjbTVoYldVaU9pSnJkSFYwYVd0aFFHMXBZM0p2YzI5bWRDNWpiMjBpTENKMWRHa2lPaUpaVTBabmJtdG1lVW93UTJacVEzcHpUV0ZGVVVGQkluMD0sMjY1MDQ2Nzc0Mzk5OTk5OTk5OSwxMzM0Mjc4MTAxODAwMDAwMDAsMmIyOWJiMTQtNmI2NC00NmU5LWJmNjYtZmU1OTA4YjcxZGRjLCwsLCwsMCwsMTk1OTI2LEdBZHhXWDNxZy1wbFA0ZTlYQlAxeTE2aWZqVSxQKzVGMHJHOU1HMEpCOHlZZWgvWnZmVGJZVjVzMTJ4Ly9WejhwNHhlRzhYNFU5M1hQRVF4aVlrcmRWTVZySTV0TjRGU0tieEw5bmJJS1Z6TVdoZzlLaHgzWEc4Nll5MkMrQmJGK1Awek5uZWZ4QmVUYUZvQXBvRDdTZHk1MkU1eEJDWjEwNFVEWDJGeGtMSEJTanNxQjdNV1JHZ2JCSHFscWNKcndJVHhncDhhSkVoMXFYeTVtL1J3SzZna3ZLak01aHhOSlNMRmxXdmd1TWd1TDVjbWtqck1udjBQL1p6c0FrT3NSZVlOV1lwWG45aDNSVnpBeURhTFFrYkcySlM1eXFzQzJKVFQzUThNZmQwdVpSdy9lTkxrK2FqMFFDeUY5RHVyN0Z3UEJ3MklpVnlTSVFYTm5aNnBkMXlna2NqR2g1OU96N1c2WVU5UWovcWVCVWtRMFE9PTwvU1A+' \
  -H 'if-none-match: "{DEF71693-A9E8-418D-B94F-BCBA13056572},3"' \
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

echo "=========================== workload will run for $WORKLOAD_DURATION seconds ======================"
sleep $WORKLOAD_DURATION
echo "=========================== workload is finished ======================"

echo "=========================== kill the remaining screen sessions =================="
screen -ls | grep Detached | cut -d. -f1 | awk '{print $1}' | xargs kill
echo "=========================== screen sessions are killed =================="
