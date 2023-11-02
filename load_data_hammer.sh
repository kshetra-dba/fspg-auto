#!/bin/bash
echo "----- cleanup the previous hammerdbcli installation --------------"
rm -Rf /root/hammerdbcli
rm -Rf /usr/local/HammerDB-3.3
mkdir -p /root/hammerdbcli
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
  -H 'cookie: MicrosoftApplicationsTelemetryDeviceId=da92a626-5291-f42a-3196-c9aeafeb29e7; MicrosoftApplicationsTelemetryFirstLaunchTime=1698045390128; rtFa=uSxBs2wJ87ETLAagOsnfpLUt0GgQHuuQgvnEGOFCA4smRUM2M0IwOUItOTc0OC00N0JBLTkwMTgtQkVFQURENDA1MjA0IzEzMzQyNTE4OTg1Nzg3NTA1MyMxM0Q5RTZBMC1FMDNDLTIwMDAtQTY4QS03QjZFRDgwMDM0MUYjS1RVVElLQSU0ME1JQ1JPU09GVC5DT00jMTk1OTI2I1ZUR0NCRVRHUERJU1FLRUhWRVNQRi0xQU1KSYK9ucqZfFCqd03q+3irKIqrPA/BMnuHnobx9CxTbUMJMLvGY57V2QX3oUFlMgVQDt5bFs/A47D+Aj9Dy3jodbvfUDYNc/WjJiSWEdH+t8h+V6f1tm2FBlsGkMu3l0tou5yDeRaN+CPf2G0UfkqxW/Zx3AOLxaIU8UBW/mJB5h5C1kWnIuWKv1hvjsVqQ1LHQxPX8huE7R3gyKFJOdObAnYt0oG4ssCSnYeTsULVhMEyuXvymuY6EK8ljIV0OBV96lchl0EpSvu6qAi9XWD44PMq2gBNT/ixgNe0OrSsY1GABexb3mnchZgxXmK98zPxUynjtutmMl3Xf7Ql3lT1NF64AAAA; SIMI=eyJzdCI6MH0=; FedAuth=77u/PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz48U1A+VjEzLDBoLmZ8bWVtYmVyc2hpcHwxMDAzMjAwMWZjMWNkODIxQGxpdmUuY29tLDAjLmZ8bWVtYmVyc2hpcHxrdHV0aWthQG1pY3Jvc29mdC5jb20sMTMzNDI1MTQwNTUwMDAwMDAwLDEzMjk4NDY2MjUzMDAwMDAwMCwxMzM0Mjk1MDk4NTc4NzUwNTMsMjQwNToyMDE6YzAwODpiOGE5OmU1ZTE6NmI5Zjo1MDA5OmY2OTMsNzM5LGVjNjNiMDliLTk3NDgtNDdiYS05MDE4LWJlZWFkZDQwNTIwNCwsNDIwYTE1MzMtNzM1Ni00YTQ5LWExYTAtMWZhZGI3NWNiOWQwLDEzZDllNmEwLWUwM2MtMjAwMC1hNjhhLTdiNmVkODAwMzQxZiwxM2Q5ZTZhMC1lMDNjLTIwMDAtYTY4YS03YjZlZDgwMDM0MWYsLDAsMTMzNDI1MjI1ODU2OTM3NjI3LDEzMzQyNzc4MTg1NjkzNzYyNywsLGV5SmpZWEJ2Ykdsa2MxOXNZWFJsWW1sdVpDSTZJbHRjSWpVNU5UWm1aalZoTFRabVpHSXRORGMzWlMwNVpEUmtMVGxtTjJReU5qSmxOamswWVZ3aVhTSXNJbmh0YzE5all5STZJbHRjSWtOUU1Wd2lYU0lzSW5odGMxOXpjMjBpT2lJeElpd2llRzF6WDJOaFpXTm9aV05yY3lJNklqRWlMQ0p3Y21WbVpYSnlaV1JmZFhObGNtNWhiV1VpT2lKcmRIVjBhV3RoUUcxcFkzSnZjMjltZEM1amIyMGlMQ0oxZEdraU9pSmhZWFpDV1UxS2NEbHJjVkZuVGpCU2NtVktaRUZCSW4wPSwyNjUwNDY3NzQzOTk5OTk5OTk5LDEzMzQyNTE4OTg1MDAwMDAwMCwyYjI5YmIxNC02YjY0LTQ2ZTktYmY2Ni1mZTU5MDhiNzFkZGMsLCwsLCwwLCwxOTU5MjYsR0FkeFdYM3FnLXBsUDRlOVhCUDF5MTZpZmpVLGlkcHFvQk5qdzdqNUR6Z3ovM1J2UmlkdlJhdmlHd0VPTlVJSVlWRVZIdWNIelUyNGNaL0xYWmNSVFlSY1N0dmZDSHJlY1p2YU45ZTRuSzVjUVN6NHpTb1U3a3hhdTd1N1hoQzBkWURaL2UraTlQejhCQ3N2NWVQblFFK3I1OWx5ZDJvWGxMK3UzdCtpTTBxQ1htM1ZiTnJDRk9ibnRoclFNSktTVFJzbGljdkVkTHRvRmxGQUdOUFdXdGoxQURCL2V3N2lxaUlTeS95THpsZEl4RTF4dW9TMWl6ZGJBOVJEaWp1d3VZU2RCMjQrNWNPSm9lTFFGbkwyTVFQS2F0Mmc4QlJLRENXVm0zZk5CR0FwUXVvVzBDZUM5M2tjZmc2SElGWlVMOWpFaVZ4czRESTNzNWRxejRKQS91alV4d3hDSWxxUlA1K0tpTXpmYThlcW85ay9Idz09PC9TUD4=' \
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
echo "--------- pg_prepare.tcl file downloaded ----------------"

#export PATH=$PATH:/usr/local/HammerDB-3.3
echo "------------- load the database with hammerdb ------------------"
chmod u+x /usr/local/HammerDB-3.3/pg_prepare.tcl
read -p "Enter the fspg hostname: " PGHOST
read -p "ENter the port:  " PGPORT
read -p "Enter the number of virtual users: " PGVUSERS
read -p "Enter the number of ware houses required: " WAREHOUSE_COUNT
read -p "Enter the fspg user name: " SUPERUSER
read -p "Enter the password: " PGPASSWORD
read -p "Enter the dataabse name: " PGDATABASE

echo "******** drop the user tpcc********************************"
PGPASSWORD=$PGPASSWORD  psql -h $PGHOST -U $SUPERUSER -p $PGPORT -d postgres -c "drop user tpcc;" 

sed -i -e "s/PGHOST/$PGHOST/g" -e "s/PGPORT/$PGPORT/g" -e "s/PGVUSERS/$PGVUSERS/g" -e "s/WAREHOUSE_COUNT/$WAREHOUSE_COUNT/g" -e "s/SUPERUSER/$SUPERUSER/g" -e "s/PGPASSWORD/$PGPASSWORD/g" -e "s/PGDATABASE/$PGDATABASE/g" /usr/local/HammerDB-3.3/pg_prepare.tcl


#/usr/local/HammerDB-3.3/hammerdbcli auto /usr/local/HammerDB-3.3/pg_prepare.tcl
cd /usr/local/HammerDB-3.3 && hammerdbcli auto /usr/local/HammerDB-3.3/pg_prepare.tcl
echo "------------- loading is completed ----------------"
