#!/usr/bin/env python
import json
import os
import sys
from ShippingPier.ShippingPier import ShippingPier

if 'WORKSPACE' not in os.environ or os.environ['WORKSPACE'].strip() == '':
    print "\nERROR: Cannot read WORKSPACE environment variable. Is this being run via Jenkins?"
    sys.exit(1)

manifest_file = os.environ['WORKSPACE'].strip() + '/cargo_manifest.json'

if not os.path.exists(manifest_file):
    print "\nWARNING: cargo_manifest.json not found in workspace. Not proceeding."
    sys.exit(0)

with open(manifest_file) as data_file:
    try:
        manifest = json.load(data_file)
    except Exception:
        print "\nWARNING: cargo_manifest.json does not contain valid JSON. Not proceeding."
        sys.exit(0)

pier = ShippingPier()
pier.add_manifest(manifest)
pier.ship()

