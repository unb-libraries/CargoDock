from docker import Client as DockerClient
from ShippingPier.ShippingLogs.ShippingLogs import ShippingLogMixin

# Import all container types here.
from ShippingPier.ShippingContainer.ShippingContainer import ShippingContainer
from ShippingPier.ShippingContainer.DrupalShippingContainer import DrupalShippingContainer
from ShippingPier.ShippingContainer.MySQLShippingContainer import MySQLShippingContainer


class GantryCrane(ShippingLogMixin):
    def __init__(self, config):
        self.cli = None
        self.containers = []
        self.network = None

        self.config = config
        self.repo_dir = self.config.get('ShippingPier', 'repo_dir')
        self.project_name = self.config.get('ShippingPier', 'project_name')
        self.connect()

    def add_container(self, container):
        """
        Add a container to this crane.
        """
        self.containers.append(container)

    def build_container(self, name, container_type, details):
        """
        Add a container to this crane.
        """
        container = globals()[container_type](name, details, self.cli, self.config)
        return container

    def build_all(self, no_cache = False):
        """
        Add a container to this crane.
        """
        for container in self.containers:
            container.build(no_cache)

    def build_docker_uri(self):
        self.config.get('ShippingPier', 'docker_api_protocol') + '://'\
            + self.config.get('ShippingPier', 'docker_api_host')\
            + ':' + self.config.get('ShippingPier', 'docker_api_port')

    def connect(self):
        """
        Connect to the docker endpoint.
        """
        self.cli = DockerClient(
            self.build_docker_uri()
        )
        self.cli.create_host_config(restart_policy={"Name": 'always'})

    def create_network(self):
        """
        Create a network for the project if it does not already exist.
        """
        if len(self.cli.networks(names=[self.project_name])) == 0:
            self.logger.info('Creating Docker Network {}'.format(self.project_name))
            self.cli.create_network(
                name=self.project_name,
                driver='bridge'
            )

    def remove_network(self):
        """
        Remove the project's network.
        """
        if self.project_name in self.cli.networks():
            self.logger.info('Removing Docker Network {}'.format(self.project_name))
            self.cli.remove_network(net_id=self.project_name)

    def deploy(self, no_cache = False):
        """
        Deploy and start the containers serviced by this crane.
        """
        self.create_network()
        self.build_all(no_cache)
        self.prepare_all()
        self.start_all()
        self.test_all()

    def connect_to_network(self, container):
        """
        Connect a container to this project's network.
        """
        self.logger.info('Connecting Container {} to Network {}'.format(container.name, self.project_name))
        self.cli.connect_container_to_network(
            container=container.name,
            net_id=self.project_name
        )

    def start_all(self):
        """
        Start all containers serviced by this crane.
        """
        for container in self.containers:
            container.start()

    def test_all(self):
        """
        Start all containers serviced by this crane.
        """
        for container in self.containers:
            container.test_deploy()

    def prepare_all(self):
        """
        Prepare and create containers serviced by this crane.
        """
        for container in self.containers:
            container.remove_existing()
            container.create()
            self.connect_to_network(container)
