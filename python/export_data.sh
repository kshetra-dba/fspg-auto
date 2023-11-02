pip3 install azure-storage-blob 
pip3 install azure-identity
pip3 install azure-monitor-query
pip3 install openpyxl
pip3 install numpy
pip3 install scipy
pip3 install pandas

WORKSPACE_ID=$(cat /root/hammerauto/database.yml | grep -oP '(?<=workspace_id: ).*')
#WORKSPACE_ID=$(az monitor log-analytics workspace show --resource-group azure-test-kt --workspace-name ktutika|grep -oP '"customerId": "\K[^"]+')
#LOGICAL_SERVER_NAME=$SERVER_NAME
LOGICAL_SERVER_NAME=$(cat /root/hammerauto/database.yml | grep -oP '(?<=logical_server_name: ).*')
START_TIME=$(cat /root/hammerauto/database.yml | grep -oP '(?<=start_time: ).*')
END_TIME=$(cat /root/hammerauto/database.yml | grep -oP '(?<=end_time: ).*')
QUERY_ID1=$(cat /root/hammerauto/database.yml | grep -oP '(?<=query_id1: ).*')
QUERY_ID2=$(cat /root/hammerauto/database.yml | grep -oP '(?<=query_id2: ).*')

sed -i -e "s/WORKSPACE_ID/$WORKSPACE_ID/g" -e "s/LOGICAL_SERVER_NAME/$LOGICAL_SERVER_NAME/g" -e "s/START_TIME/$START_TIME/g" -e "s/END_TIME/$END_TIME/g" -e "s/QUERY1/$QUERY_ID1/g" -e "s/QUERY2/$QUERY_ID2/g" /root/hammerauto/python/config.json

echo  "========== starting the log insights script ============"
cd /root/hammerauto/python && python3 log_analytics_metrics1.py

