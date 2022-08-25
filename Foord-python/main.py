import json
import logging
import os

from awscrt.mqtt import QoS
from awsiot import mqtt_connection_builder
from dotenv import load_dotenv

load_dotenv() # take environment variables from .env.


DEVICE_ID = os.getenv('DEVICE_ID')
CLIENT_ID = os.getenv('CLIENT_ID', 'foodr-python')
ENDPOINT = os.getenv('ENDPOINT')
CERT_FILE = os.getenv('CERT_FILE')
KEY_FILE = os.getenv('KEY_FILE')
CA_FILE = os.getenv('CA_FILE')
TIMEOUT = int(os.getenv('TIMEOUT', 5))
RETAIN = bool(int(os.getenv('RETAIN', 1)))

COMMAND_TOPIC = f'foodr/device/{DEVICE_ID}/command'
RESPONSE_TOPIC = f'foodr/device/{DEVICE_ID}/response'


logger = logging.getLogger(__name__)

logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)


def build_mqtt_connection():
    return mqtt_connection_builder.mtls_from_path(
            endpoint=ENDPOINT,
            cert_filepath=CERT_FILE,
            pri_key_filepath=KEY_FILE,
            client_id=CLIENT_ID,
    )


def subscribe_callback(topic, payload, **kwargs):
    logger.info(f'Received message on topic {topic}:\n {payload}')
    logger.info(f'Sending a response to response topic: {RESPONSE_TOPIC}')
    command = json.loads(payload.decode())
    response = {
        'command_uid': command.get('command_uid'),
        'command': 'pong',
    }
    mqtt_connection.publish(RESPONSE_TOPIC, json.dumps(response), qos=QoS.AT_LEAST_ONCE, retain=RETAIN)
    logger.info('Sent response.')


mqtt_connection = build_mqtt_connection()


if __name__ == '__main__':
    logger.info('Connecting to AWS IoT...')
    mqtt_connection.connect().result(TIMEOUT)
    logger.info('Connected.')
    logger.info('Subscribing to command topic...')
    res, _ = mqtt_connection.subscribe(COMMAND_TOPIC, qos=QoS.AT_LEAST_ONCE, callback=subscribe_callback)
    res.result(TIMEOUT)
    logger.info('Subscribed to command topic: {}'.format(COMMAND_TOPIC))
    input('App is running. Press Enter to exit.\n')
