import os
import requests


jenkins_trigger_url = os.getenv('JENKINS_TRIGGER_URL')
requests.post(jenkins_trigger_url)
