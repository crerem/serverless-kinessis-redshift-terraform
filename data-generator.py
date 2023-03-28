import requests
import json
import time
import random
import base64

# Define the API endpoint and Stream Name - change these with your values
api_endpoint    =   "https://7mj85ah60d.execute-api.us-west-1.amazonaws.com/SG12-Serverless-processing-event-production-stage/streams"
stream_name     =   "sg12-kinesis-firehose-extended-s3-stream"


# Define the F1 telemetry data
f1_telemetry_data = {
    "speed": 200.0,
    "rpm": 15000,
    "gear": 7,
    "throttle": 0.85,
    "brakes": 0.25,
    "steering_angle": -0.2,
    "suspension": {
        "ride_height": 40,
        "damper_settings": {
            "front_left": 8,
            "front_right": 8,
            "rear_left": 6,
            "rear_right": 6
        }
    },
    "temperatures": {
        "engine": 120,
        "brakes": {
            "front_left": 250,
            "front_right": 240,
            "rear_left": 200,
            "rear_right": 190
        },
        "tires": {
            "front_left": 85,
            "front_right": 87,
            "rear_left": 90,
            "rear_right": 89
        }
    },
    "pressures": {
        "engine": 4.2,
        "brakes": {
            "front_left": 18,
            "front_right": 17,
            "rear_left": 16,
            "rear_right": 15
        },
        "tires": {
            "front_left": 1.7,
            "front_right": 1.8,
            "rear_left": 1.9,
            "rear_right": 1.8
        }
    },
    "fuel_consumption": 2.4,
    "lap_time": 75.6
}

# Define the duration of the data collection in seconds
duration = 220

# Loop over the duration, sending the telemetry data every second
for i in range(duration):

    print(f"Iteration {i+1}")

    # Add natural randomness to the telemetry data
    f1_telemetry_data["speed"] += random.uniform(-5, 5)
    f1_telemetry_data["rpm"] += random.randint(-50, 50)
    f1_telemetry_data["gear"] = random.randint(1, 8)
    f1_telemetry_data["throttle"] += random.uniform(-0.05, 0.05)
    f1_telemetry_data["brakes"] += random.uniform(-0.05, 0.05)
    f1_telemetry_data["steering_angle"] += random.uniform(-0.1, 0.1)
    f1_telemetry_data["suspension"]["ride_height"] += random.uniform(-0.5, 0.5)
    for damper in f1_telemetry_data["suspension"]["damper_settings"]:
        f1_telemetry_data["suspension"]["damper_settings"][damper] += random.uniform(-0.5, 0.5)
    f1_telemetry_data["temperatures"]["engine"] += random.uniform(-5, 5)
    for brake in f1_telemetry_data["temperatures"]["brakes"]:
        f1_telemetry_data["temperatures"]["brakes"][brake] += random.uniform(-5, 5)
    for tire in f1_telemetry_data["temperatures"]["tires"]:
        f1_telemetry_data["temperatures"]["tires"][tire] += random.uniform(-5, 5)

    # Send the telemetry data to the API
    
   
    f1_telemetry_data_string =json.dumps(f1_telemetry_data)

    data =base64.b64encode(f1_telemetry_data_string.encode('utf-8')).decode('utf-8');

    payload = {
    "DeliveryStreamName": stream_name,
    "Record": {
        "Data": data
        }
    }

    headers = {
        'Content-Type': 'application/json'
    }

    response = requests.put(api_endpoint,  data=json.dumps(payload), headers=headers)

    print(response.status_code)
    print(response.content)


    #response = requests.post(api_endpoint, data=json.dumps(f1_telemetry_data))

    #print (data)
    # Wait for 1 second before sending the next telemetry data
    time.sleep(1)