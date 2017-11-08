#!/usr/bin/env python
"""Read a list of AWS ECR images from stdin and return a list of hashes that are
older than --num-to-keep in --branch."""
import json
import sys
from collections import OrderedDict
from datetime import timedelta, datetime
from optparse import OptionParser

def sortdict(d):
    """Sort a dictionary by element value."""
    for key in sorted(d): yield d[key]

parser = OptionParser()
parser.add_option("-b", "--branch", dest="branch",
                  help="Image branch to target (dev, prod)")
parser.add_option("-n", "--num-to-keep", dest="num_to_keep",
                  help="The number of historical images to keep")

(options, args) = parser.parse_args()
if not options.branch:
    parser.error('Image branch not specified')
if not options.num_to_keep:
    parser.error('Number of images to keep not specified')

images = {}
for repo_image in json.load(sys.stdin)["imageIds"]:
  image_age = 0
  try:
    tag = repo_image['imageTag']
    if '-' in tag:
      branch, date = tag.split('-')
      if options.branch == branch:
        dt = datetime.strptime(date,'%Y%m%d%H%M%S')
        images[dt] = repo_image['imageDigest']
  except KeyError:
    pass

all_dated_images = OrderedDict(sorted(images.items(), key=lambda t: t[0]))
images_to_remove = list(all_dated_images.items())[:-int(int(options.num_to_keep) + 1)]

for image_to_remove in images_to_remove:
  image_date, image_sha = image_to_remove
  print str(image_date) + '|' + image_sha
