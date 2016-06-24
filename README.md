# CargoDock
## Container Deployment Suite
CargoDock constructs, bundles and deploys docker driven applications from metadata, deploying them to multiple environments. Typically triggered by Jenkins, it provides a simple, consistent method to orchestrate docker application for development, testing and production deployment.

## Components
CargoDock is comprised of four core components:

* ```ShippingPier``` : Orchestrates the deployment process. Each Pier can contain several cranes. Controlled by a proprietary [cargo_manifest.json](https://github.com/unb-libraries/CargoDock/blob/master/cargo_manifest.json.example) file to control deployment across enviroments.
* ```GantryCrane``` : Manages and deploys ShippingContainer objects.
* ```ShippingContainer``` : Self-aware, categorized objects that define how they are deployed. Examples are included for Drupal and MySQL.
* ```HarborMaster``` : Responsible for post-deployment testing of containers.

## Example Use

```
from ShippingPier.ShippingPier import ShippingPier

pier = ShippingPier()
pier.add_manifest(manifest)
pier.ship()
```

## License
- CargoDock is licensed under the MIT License:
  - http://opensource.org/licenses/mit-license.html
- Attribution is not required, but much appreciated:
  - `CargoDock by UNB Libraries`
