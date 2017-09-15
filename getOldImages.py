import json
import sys
from collections import OrderedDict
from datetime import timedelta, datetime

def sortdict(d):
    for key in sorted(d): yield d[key]

images = {}
build_branch = sys.argv[1]

for repo_image in json.load(sys.stdin)["imageIds"]:
  image_age = 0
  try:
    tag = repo_image['imageTag']
    if '-' in tag:
      branch, date = tag.split('-')
      if build_branch == branch:
        dt = datetime.strptime(date,'%Y%m%d%H%M%S')
        images[dt] = repo_image['imageDigest']
  except KeyError:
    pass

all_dated_images = OrderedDict(sorted(images.items(), key=lambda t: t[0]))
images_to_remove = list(all_dated_images.items())[:-2]

for image_to_remove in images_to_remove:
  image_date, image_sha = image_to_remove
  print str(image_date) + '|' + image_sha
