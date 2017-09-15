import json
import sys
from datetime import timedelta, datetime

for repo_image in json.load(sys.stdin)["imageIds"]:
  image_age = 0
  try:
    tag = repo_image['imageTag']
    if '-' in tag:
      branch, date = tag.split('-')
      dt = datetime.strptime(date,'%Y%m%d%H%M%S')
      if dt < datetime.now() + timedelta(days = -3):
        print str(dt) + '|' + repo_image['imageDigest']
  except KeyError:
    pass
