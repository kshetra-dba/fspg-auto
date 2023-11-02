import os
import json
import pandas as pd
import logging
from datetime import datetime, timezone
from azure.monitor.query import LogsQueryClient, LogsQueryStatus
from azure.identity import DefaultAzureCredential
from azure.core.exceptions import HttpResponseError
import openpyxl
import numpy as np
import yaml
from scipy import stats

with open('database.yml', 'r') as file:
    content = yaml.safe_load(file)
logical_server_names = content['analytics']['logical_server_name']
query_ids = content['analytics']['query_id']
start_time = datetime.strptime(content['analytics']['start_time'])
end_time = datetime.strptime(print(content['analytics']['end_time'])

csv_filename = f"pg-rd-norestart-16vc_metrics_output.csv"
excel_filename = f"pg-rd-norestart-16vc_metrics_output.xlsx"

dataframe.to_csv(csv_filename)

excel_writer = pd.ExcelWriter(excel_filename, engine='openpyxl')
dataframe.to_excel(excel_writer, sheet_name=server_name)
excel_writer.save()

 print(f"Data for server '{server_name}' has been written to {csv_filename} and {excel_filename}")

"""
def process_metrics_for_server(client, workspace_id, server_name, metrics, start_time, end_time):
    result_df = None

    for metric in metrics:
        query = generate_metric_query(metric, server_name)
        response = execute_query(client, workspace_id, query, start_time, end_time)
        
        if response.status == LogsQueryStatus.SUCCESS:
            data = response.tables[0]
            metric_df = pd.DataFrame(data=data.rows, columns=data.columns)
            metric_df["TimeGenerated"] = pd.to_datetime(metric_df["TimeGenerated"])
            metric_df.set_index("TimeGenerated", inplace=True)
            metric_df.index = metric_df.index.tz_localize(None)
            if result_df is None:
                result_df = metric_df
            else:
                result_df = pd.concat([result_df, metric_df.rename(columns={metric: f"{metric}"})], axis=1, sort=False)

    return result_df





def main():



for server_name in logical_server_names:
        result_metrics_df = process_metrics_for_server(client, workspace_id, server_name, metrics_to_query, start_time, end_time)
        #save_dataframe_to_csv_and_excel(result_metrics_df, server_name, "metrics_output")

"""
