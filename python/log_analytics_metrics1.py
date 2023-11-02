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
from scipy import stats

# Set numpy print options to address numerical precision loss warning
np.set_printoptions(precision=6, suppress=True)

# Functions for loading and processing data

def load_config(config_file_path):
    with open(config_file_path, 'r') as config_file:
        return json.load(config_file)

#def parse_datetime(datetime_str):
#    return datetime.strptime(datetime_str, '%Y-%m-%dT%H:%M:%SZ').replace(tzinfo=timezone.utc)

def get_logical_server_names(server_names_file_path):
    with open(server_names_file_path, 'r') as server_names_file:
        return json.load(server_names_file)

def initialize_logger():
    logger = logging.getLogger('azure.monitor.query')
    logger.setLevel(logging.DEBUG)
    return logger

def initialize_query_client():
    default_credential = DefaultAzureCredential(logging_enable=True, exclude_environment_credential=True,
                                                exclude_managed_identity_credential=True,
                                                exclude_shared_token_cache_credential=True)
    return LogsQueryClient(credential=default_credential, logging_enable=True)


# Define a function to calculate the standard error and handle zero division

def calculate_standard_error(data):
    try:
        if len(data) == 0:
            return np.nan  # Handle empty dataset with NaN
        return stats.sem(data, nan_policy='omit')
    except ZeroDivisionError:
        return np.nan  # Handle division by zero with NaN


# Function to calculate mean with NaN handling
def calculate_mean(data):
    try:
        if len(data) == 0:
            return np.nan  # Handle empty dataset with NaN
        return np.mean(data)
    except RuntimeWarning:
        return np.nan  # Handle precision loss warning with NaN


# Modify your execute_query function to properly format the timespan
# def execute_query(client, workspace_id, query, start_time, end_time):
    # Calculate the timedelta between start_time and end_time
#    timespan = (start_time, end_time - start_time)

#    response = client.query_workspace(workspace_id=workspace_id, query=query, timespan(start_time, end_time), logging_enable=True)
#    return response

def execute_query(client, workspace_id, query, start_time, end_time):
    response = client.query_workspace(workspace_id=workspace_id, query=query, timespan=(start_time, end_time), logging_enable=True)
    return response

def save_dataframe_to_csv_and_excel(dataframe, server_name, filename):
    csv_filename = f"{server_name}_{filename}.csv"
    excel_filename = f"{server_name}_{filename}.xlsx"

    dataframe.to_csv(csv_filename)

    excel_writer = pd.ExcelWriter(excel_filename, engine='openpyxl')
    dataframe.to_excel(excel_writer, sheet_name=server_name)
    excel_writer.save()

    print(f"Data for server '{server_name}' has been written to {csv_filename} and {excel_filename}")

# Query Generation Functions

def generate_metric_query(metric, server_name):
    if metric == 'tup_inserted':
        return f"""AzureMetrics
                | where MetricName contains 'tup_inserted'
                | where ResourceId contains '{server_name}'
                | project TimeGenerated, Total
                | summarize TupIns=round(max(Total), 0) by bin(TimeGenerated, 5m)
                | order by TimeGenerated desc """
    elif metric == 'tup_updated':
        return f"""AzureMetrics
                | where MetricName contains 'tup_updated'
                | where ResourceId contains '{server_name}'
                | project TimeGenerated, Total
                | summarize TupUpd=round(max(Total), 0) by bin(TimeGenerated, 5m)
                | order by TimeGenerated desc """
    elif metric == 'tup_deleted':
        return f"""AzureMetrics
                | where MetricName contains 'tup_deleted'
                | where ResourceId contains '{server_name}'
                | project TimeGenerated, Total
                | summarize TupDel=round(max(Total), 0) by bin(TimeGenerated, 5m)
                | order by TimeGenerated desc """
    elif metric == 'xact_commit':
        return f"""AzureMetrics
                | where MetricName == 'xact_commit'
                | where ResourceId contains '{server_name}'
                | distinct Total, TimeGenerated
                | summarize total_xact_commit=sum(tolong(Total)) by bin(TimeGenerated, 5m)
                | extend total_xact_commit
                | order by TimeGenerated desc """
    elif metric == 'temp_files':
        return f"""AzureMetrics
                | where MetricName == 'temp_files'
                | where ResourceId contains '{server_name}'
                | serialize | extend temp_files_lastrecord=prev(Total,1)
                | project TimeGenerated, diff_temp_files = iff((tolong(Total) - tolong(temp_files_lastrecord)) <= 0, 0, (tolong(Total) - tolong(temp_files_lastrecord)))
                | summarize total_temp_files=sum(tolong(diff_temp_files)) by bin(TimeGenerated, 5m)
                | extend total_temp_files
                | order by TimeGenerated desc """
    else:
        return f"""AzureMetrics
                | where MetricName contains '{metric}'
                | where ResourceId contains '{server_name}'
                | project TimeGenerated, Average
                | summarize {metric}=round(max(Average), 0) by bin(TimeGenerated, 5m)
                | order by TimeGenerated desc """

def generate_custom_metric_query(server_name, query_id, start_time, end_time):
    return f"""AzureDiagnostics
            | where Category contains "PostgreSQLFlexQueryStoreRuntime"
            | where ResourceId contains '{server_name}'
            | where Userid_d != 10
            | where Queryid_d == {query_id}
            | project End_time_t, Queryid_d, Meantime=Mean_time_d/1000, Calls_d
            | order by End_time_t desc """

print("*************************************************")
print("After execution of generate_metric_query function")
print("*************************************************")

# Data Analysis Functions

def analyze_custom_metrics(logical_server_names, columns_to_custom, query_ids, results_custom_file):
    results_df = pd.DataFrame(columns=['LogicalServer', 'QueryID', 'Statistic', 'Value'])

    for logical_server_name in logical_server_names:
        for column_name in columns_to_custom:
            for query_id in query_ids:
            
                results_df = results_df.append({
                    'LogicalServer': f'{"*" * 60}',
                    'QueryID': '',
                    'Statistic': '',
                    'Value': ''
                }, ignore_index=True)
                # Insert asterisks before the header line
                results_df = results_df.append({
#                    'LogicalServer': f'{"*" * 60}',
                    'QueryID': f'*** {logical_server_name} *** Query ID:{query_id} *** {column_name} ***',
#                    'Statistic': '',
#                    'Value': ''
                }, ignore_index=True)

                results_df = results_df.append({
                    'LogicalServer': f'{"*" * 60}',
                    'QueryID': '',
                    'Statistic': '',
                    'Value': ''
                }, ignore_index=True)

                file_path = f'{logical_server_name}_custom_metrics_{query_id}.csv'
                df = pd.read_csv(file_path)

                if len(df[column_name]) == 0:
                    statistic_value = 0.1  # Handle the case when the dataset is empty
                else:
                    # Calculate the standard error with the modified function
                    statistic_value = calculate_standard_error(df[column_name].dropna())

                added_statistics = []

                # Add the statistics you want to calculate here, similar to the previous data analysis function
                statistics_to_calculate = [
                    ('Mean :', calculate_mean),
                     ('Standard Error :', calculate_standard_error),  # Use the custom standard error function
#                    ('Standard Error :', lambda x: stats.sem(x, nan_policy='omit')),
                    ('Median :', np.median),
#                    ('Mode :', lambda x: stats.mode(x, nan_policy='omit', keepdims=False)),
#                    ('Mode :', lambda x: stats.mode(x, nan_policy='omit')[0][0]),
#                    ('Standard Deviation :', np.std),
#                    ('Sample Variance :', calculate_variance),  # Use the custom variance calculation
#                    ('Sample Variance :', np.var),
#                    ('Kurtosis :', calculate_kurtosis),
#                    ('Skewness :', stats.skew),
#                    ('Range :', lambda x: np.ptp(x) if len(x) > 1 else 0),
#                    ('Minimum :', np.min),
#                    ('Maximum :', np.max),
#                    ('Sum :', np.sum),
#                    ('Count :', len),
                    ('95th Percentile :', lambda x: np.percentile(x, 95)),
                    ('99th Percentile :', lambda x: np.percentile(x, 99))
                ]
                
                for statistic_name, statistic_func in statistics_to_calculate:
                    if statistic_name not in added_statistics:
                        if "Percentile" not in statistic_name:
                            data = df[column_name].dropna()
                            if len(data) == 0:
                                statistic_value = np.nan  # Handle the case when the dataset is empty
                            else:
                                statistic_value = statistic_func(data)
                                if isinstance(statistic_value, (int, float)):
                                    statistic_value = f'{statistic_value:.2f}'  # Format the numeric value to two decimal places
                        elif "Percentile" in statistic_name:
                            data = df[column_name].dropna()
                            if len(data) == 0:
                                statistic_value = np.nan  # Handle the case when the dataset is empty
                            else:
                                percentile_value = statistic_func(data)
                                statistic_value = f'{percentile_value:.2f}'  # Format the percentile value to two decimal places

                    results_df = results_df.append({
                                    'Statistic': f'{statistic_name}',
                                    'Value': statistic_value
                                }, ignore_index=True)
                    added_statistics.append(statistic_name)

#                for statistic_name, statistic_func in statistics_to_calculate:
#                    if statistic_name not in added_statistics:
#                        if "Percentile" not in statistic_name:
#                            statistic_value = statistic_func(df[column_name].dropna())
#                            if isinstance(statistic_value, (int, float)):
#                               statistic_value = f'{statistic_value:.5f}'  # Format the numeric value to two decimal places
#                        else:
#                            # Calculate the percentile value
#                            percentile_value = statistic_func(df[column_name].dropna())
#                            statistic_value = f"{percentile_value:.5f}"  # Format the percentile value to two decimal places

#                        results_df = results_df.append({
#                            'Column': column_name,
#                            'Statistic': f'{statistic_name}',
#                            'Value': statistic_value
#                        }, ignore_index=True)
#                        added_statistics.append(statistic_name)

    results_df.to_csv(results_custom_file, sep='\t', index=False, header=False)

print("**************************************************")
print("After execution of analyze_custom_metrics function")
print("**************************************************")


def analyze_and_save_results(logical_server_names, columns_to_analyze, results_file):
    results_df = pd.DataFrame(columns=['LogicalServer', 'Column', 'Statistic', 'Value'])

    for logical_server_name in logical_server_names:
        for column_name in columns_to_analyze:
            results_df = results_df.append({
                'LogicalServer': f'{"*" * 60}',
                'Column': '',
                'Statistic': '',
                'Value': ''
            }, ignore_index=True)
            # Insert asterisks before the header line
            results_df = results_df.append({
#                'LogicalServer': f'{"*" * 60}',
                'Column': f'*** {logical_server_name} *** {column_name} ***',
#                'Statistic': '',
#                'Value': ''
            }, ignore_index=True)

            results_df = results_df.append({
                'LogicalServer': f'{"*" * 60}',
                'Column': '',
                'Statistic': '',
                'Value': ''
            }, ignore_index=True)

            file_path = f'{logical_server_name}_metrics_output.csv'
            df = pd.read_csv(file_path)
            added_statistics = []

            # Add the statistics you want to calculate here, similar to the previous data analysis function
            statistics_to_calculate = [
                ('Mean :', calculate_mean),
                ('Standard Error :', calculate_standard_error),  # Use the custom standard error function
#                ('Standard Error :', lambda x: stats.sem(x, nan_policy='omit')),
                ('Median :', np.median),
#                ('Mode :', lambda x: stats.mode(x, nan_policy='omit', keepdims=False)),
#                ('Mode :', lambda x: stats.mode(x, nan_policy='omit')[0][0]),
#                ('Standard Deviation :', np.std),
#                ('Sample Variance :', calculate_variance),  # Use the custom variance calculation
#                ('Sample Variance :', np.var),
#                ('Kurtosis :', calculate_kurtosis),
#                ('Skewness :', stats.skew),
#                ('Range :', lambda x: np.ptp(x) if len(x) > 1 else 0),
#                ('Minimum :', np.min),
#                ('Maximum :', np.max),
#                ('Sum :', np.sum),
#                ('Count :', len),
                ('95th Percentile :', lambda x: np.percentile(x, 95)),
                ('99th Percentile :', lambda x: np.percentile(x, 99))
            ]

            for statistic_name, statistic_func in statistics_to_calculate:
                if statistic_name not in added_statistics:
                    if "Percentile" not in statistic_name:
                        data = df[column_name].dropna()
                        if len(data) == 0:
                            statistic_value = np.nan  # Handle the case when the dataset is empty
                        else:
                            statistic_value = statistic_func(data)
                            if isinstance(statistic_value, (int, float)):
                                statistic_value = f'{statistic_value:.2f}'  # Format the numeric value to two decimal places
                    elif "Percentile" in statistic_name:
                        data = df[column_name].dropna()
                        if len(data) == 0:
                            statistic_value = np.nan  # Handle the case when the dataset is empty
                        else:
                            percentile_value = statistic_func(data)
                            statistic_value = f'{percentile_value:.2f}'  # Format the percentile value to two decimal places

                results_df = results_df.append({
                    'Statistic': f'{statistic_name}',
                    'Value': statistic_value
                }, ignore_index=True)
                added_statistics.append(statistic_name)

#            for statistic_name, statistic_func in statistics_to_calculate:
#                if statistic_name not in added_statistics:
#                    if "Percentile" not in statistic_name:
#                        statistic_value = statistic_func(df[column_name].dropna())
#                        if isinstance(statistic_value, (int, float)):
#                            statistic_value = f'{statistic_value:.5f}'  # Format the numeric value to two decimal places
#                    else:
#                        # Calculate the percentile value
#                        percentile_value = statistic_func(df[column_name].dropna())
#                        statistic_value = f"{percentile_value:.5f}"  # Format the percentile value to two decimal places

#                    results_df = results_df.append({
#                        'Column': column_name,
#                        'Statistic': f'{statistic_name}',
#                        'Value': statistic_value
#                    }, ignore_index=True)
#                    added_statistics.append(statistic_name)

    results_df.to_csv(results_file, sep='\t', index=False, header=False)

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

def process_custom_metrics_for_server(client, workspace_id, server_name, metrics_cust, query_ids, start_time, end_time):
    for metric in metrics_cust:
        for query_id in query_ids:

            query = generate_custom_metric_query(server_name, query_id, start_time, end_time)

            response = execute_query(client, workspace_id, query, start_time, end_time)

            print(f'start time :{start_time}')
            print(f'End   time :{end_time}')

            if response.status == LogsQueryStatus.SUCCESS:
                data = response.tables[0]
                metric_df = pd.DataFrame(data=data.rows, columns=data.columns)
                metric_df["End_time_t"] = pd.to_datetime(metric_df["End_time_t"])
                metric_df.set_index("End_time_t", inplace=True)
                metric_df.index = metric_df.index.tz_localize(None)

#                print(f'Metric Data : {metric_df}')

                file_path = f'{server_name}_custom_metrics_{query_id}.csv'
                metric_df.to_csv(file_path)

print("*************************************************************")
print("After Execution of process_custom_metrics_for_server function")
print("*************************************************************")

def main():
    config = load_config('config.json')
    logical_server_names = config.get("logical_server_name", [])
    query_ids = config.get("query_id", [])
    logger = initialize_logger()
    client = initialize_query_client()
    
    start_time = datetime.strptime(config.get('start_time'), "%Y-%m-%dT%H:%M:%SZ")
    end_time = datetime.strptime(config.get('end_time'), "%Y-%m-%dT%H:%M:%SZ")


    # start_time = parse_datetime(config["start_time"])
    # end_time = parse_datetime(config["end_time"])

    print("Start Date:", start_time)
    print("End Date:", end_time)
    print(start_time)
    print(end_time)


    workspace_id = config["workspace_id"]
    metrics_to_query = config["metrics"]
    metrics_to_custom = config["metrics_cust"]
    columns_to_custom = ['Meantime', 'Calls_d']  # Define the custom columns to analyze
    columns_to_analyze = ['cpu_percent', 'memory_percent', 'iops', 'disk_iops_consumed_percentage', 'total_xact_commit', 'storage_percent', 'total_temp_files', 'active_connections', 'TupIns', 'TupUpd', 'TupDel']
    merged_results = pd.DataFrame(columns=['LogicalServer', 'Column', 'Statistic', 'Value'])

    server_names_str = ', '.join(logical_server_names)
    
    print("-------------------------------------------------------------")
    print(f'Data collection and analysis reporting is carried out for server names: {server_names_str}')
    print("-------------------------------------------------------------")
    
    print("-------------------------------------------------------------")
    print(f'Start Date Time : {start_time}')
    print("-------------------------------------------------------------")
    
    print("-------------------------------------------------------------")
    print(f'End Date Time : {end_time}')
    print("-------------------------------------------------------------")
    
    print("-------------------------------------------------------------")
    print(f'Query Ids : {query_ids}')
    print("-------------------------------------------------------------")
    
    for server_name in logical_server_names:
        result_metrics_df = process_metrics_for_server(client, workspace_id, server_name, metrics_to_query, start_time, end_time)
        save_dataframe_to_csv_and_excel(result_metrics_df, server_name, "metrics_output")
        process_custom_metrics_for_server(client, workspace_id, server_name, metrics_to_custom, query_ids, start_time, end_time)

        results_file = f'data_analysis_results.txt'  # Define results_file

        results_custom_file = 'data_analysis_custom.txt'  # Define the path to results_custom_file

        analyze_and_save_results(logical_server_names, columns_to_analyze, results_file)
        analyze_custom_metrics(logical_server_names, columns_to_custom, query_ids, results_custom_file)


        # Merge results_file and results_custom_file into a single DataFrame
        results_file_path = f'{results_file}'
        results_custom_file_path = f'{results_custom_file}'
        df_results = pd.read_csv(results_file_path, delimiter='\t', names=['LogicalServer', 'Column', 'Statistic', 'Value'])
        df_results_custom = pd.read_csv(results_custom_file_path, delimiter='\t', names=['LogicalServer', 'Column', 'Statistic', 'Value'])
        merged_results = pd.concat([merged_results, df_results, df_results_custom], ignore_index=True)

    # Save the merged results to a single file
    merged_results.to_csv('merged_data_analysis_results.txt', sep='\t', index=False, header=False)


if __name__ == "__main__":
    main()


