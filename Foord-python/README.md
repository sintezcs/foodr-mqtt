# MQTT Demo - python client for AWS IoT

This is a simple python client for AWS IoT. It is based on the AWS IoT SDK for Python.

## Installation

Create a virtual environment and install the requirements:

```bash
$ python -m virtualenv venv && source venv/bin/activate
$ pip install -r requirements.txt
```

## Configuration
- Download the required AWS certificates from the AWS IoT console
- Copy .env.sample to .env and edit the values to match your AWS IoT configuration.


## Running the client

```bash
$ python main.py
```
