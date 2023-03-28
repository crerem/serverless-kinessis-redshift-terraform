import base64
import json

print('Loading function')


def lambda_handler(event, context):
    output = []
    print(event)

    for record in event['records']:

        payload = base64.b64decode(record['data']).decode('utf-8')
        payload_json = json.loads(payload)

		#adding extra details
        payload_json['EXTRA2']= float(payload_json['fuel_consumption'])*float(payload_json['lap_time'])
       
        
        payload_string = json.dumps(payload_json)
        
        output_record = {
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': base64.b64encode(payload_string.encode('utf-8')).decode('utf-8')
        }
        output.append(output_record)

    print('Successfully processed {} records.'.format(len(event['records'])))

    return {'records': output}
