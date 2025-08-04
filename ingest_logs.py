from elasticsearch import Elasticsearch, helpers
import os
import json
import pendulum
import re
import sys
import copy


es_workshop = Elasticsearch(
    'http://localhost:9200',
    http_auth=('elastic', 'elastic@123'),
    retry_on_timeout=True,
    request_timeout=60
)
NOW = pendulum.now()
#elastic_logs = 'workshop.ndjson'
file_path  = sys.argv[1]
print(file_path)
if os.path.exists(file_path):
    print("Found Workshop Log File")
    elastic_logs = file_path
else:
    print("Input Correct File Path")
    raise

def set_date_time(json_item_copy):
  split_index = json_item_copy['_index'].split('.ds-')[1]
  parsed_index = re.findall(r'(.*)-\d\d\d\d.\d\d.\d\d-(.*)', split_index)
  index_date = f"{parsed_index[0][0]}"

  #Set Log Time to today with proper ISO 8601 format
  current_timestamp = pendulum.parse(json_item_copy['_source']['@timestamp'])
  try:
    new_timestamp = current_timestamp.set(day=NOW.day - 1, year=NOW.year, month=NOW.month)
  except Exception as e:
    new_timestamp = current_timestamp.set(day=NOW.day, year=NOW.year, month=NOW.month)
  
  # Format as proper ISO 8601 with 'T' separator
  return index_date, new_timestamp.to_iso8601_string()


def batch_trace_logs(workshop_logs):
    i=0
    count=0
    for item in workshop_logs:
        count +=1
        if i == 10000:
            print(f"Bulk Indexed {count} logs")
            i = 0
        json_item = json.loads(copy.deepcopy(item))
        if 'sysmon' in json_item['_index']:
            new_index, new_timestamp = set_date_time(json_item)
            json_item['_source']['@timestamp'] = new_timestamp
            yield {"_index": new_index, "_source": json_item['_source'],'_op_type': "create"}
            i +=1
        else:
            new_index, new_timestamp = set_date_time(json_item)
            json_item['_source']['@timestamp'] = new_timestamp
            yield {"_index": new_index, "_source": json_item['_source'],'_op_type': "create"}
            i +=1

#Delete Data Streams
print("Deleting Existing Indicies")
response = input("Delete existing data streams? (y/N): ")
if response.lower() == 'y':
    try:
        # Get existing data streams
        data_streams = es_workshop.indices.get_data_stream(name='logs-*')
        if 'data_streams' in data_streams and data_streams['data_streams']:
            print(f"Found {len(data_streams['data_streams'])} data streams to delete:")
            for stream in data_streams['data_streams']:
                print(f"  - {stream['name']}")
            
            # Delete each data stream individually
            for stream in data_streams['data_streams']:
                try:
                    es_workshop.indices.delete_data_stream(name=stream['name'])
                    print(f"✅ Deleted: {stream['name']}")
                except Exception as e:
                    print(f"⚠️  Failed to delete {stream['name']}: {e}")
        else:
            print("ℹ️  No existing data streams found to delete")
    except Exception as e:
        print(f"⚠️  Error checking data streams: {e}")
        print("   Continuing with ingestion...")
else:
    print("Skipping Data Stream Deletion")


helpers.bulk(es_workshop, batch_trace_logs(open(elastic_logs)), request_timeout=60)

