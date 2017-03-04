"""
A generic shipping container object intended to be extended. @see DrupalShippingContainer().
"""
import sys
from ShippingPier.ShippingLogs.ShippingLogs import ShippingLogMixin


class ShippingContainer(ShippingLogMixin):
    def __init__(self, name, details, cli, config):
        self.id = None
        self.is_image = False
        self.binds = []
        self.buildargs = {}
        self.buildfails = ['returned a non-zero code']
        self.ports = []
        self.port_bindings = {}
        self.volumes = []
        self.environment = {}
        self.image_string = None

        self.name = name
        self.details = details
        self.cli = cli
        self.config = config
        self.repo_dir = self.config.get('ShippingPier', 'repo_dir')
        self.project_name = self.config.get('ShippingPier', 'project_name')

        self.check_details()
        self.set_image_string()

    def add_port_bindings(self, port_bindings):
        """Add port bindings to the container.

        Args:
            port_bindings (:obj:`list` of :obj:`dict`): A list of
        """
        for host_port, container_port in port_bindings.iteritems():
            self.ports.append(host_port)
            self.port_bindings[container_port] = host_port

    def add_environment_vars(self, environment_vars):
        """Add environment variables to the container.

        Args:
            environment_vars (:obj:`list` of :obj:`dict`):
        """
        for var_name, value in environment_vars.iteritems():
            self.environment[var_name] = value

    def add_volumes(self, volumes):
        """Add volumes to the container.

        Args:
            volumes (:obj:`list` of :obj:`str`):
        """
        self.volumes.extend(volumes)

    def build(self, no_cache = False):
        """
        Build the container from the Dockerfile.
        """
        if self.is_image is False:
            self.logger.info('Building Container {}'.format(self.name))
            self.logger.info('Build Arguments {}'.format(self.buildargs))
            response = [
                line for line in self.cli.build(
                    path=self.repo_dir,
                    rm=True,
                    pull=True,
                    tag=self.image_string,
                    buildargs=self.buildargs,
                    nocache=no_cache
                )
            ]
            for response_line in response:
                self.logger.info('Build Output : {}'.format(response_line))
                for error_string in self.buildfails:
                    if error_string.lower() in response_line.lower():
                        self.logger.error('ERROR: Docker build failed. [{}]'.format(response_line))
                        sys.exit(3)

    def check_details(self):
        """
        Check the container details for any issues.
        """
        self.check_details_type()

    def check_details_type(self):
        """
        Check if an image and tag have been specified, or a build path.
        """
        if 'build' not in self.details:
            self.is_image = True
        if self.is_image and ('image' not in self.details or self.details['image'].strip() == ''):
            self.logger.error('ERROR: An image was not specified in the manifest! [{}]'.format(self.name))
            sys.exit(3)
        if self.is_image and ('image_tag' not in self.details or self.details['image_tag'].strip() == ''):
            self.logger.error('ERROR: An image tag was not specified in the manifest! [{}]'.format(self.name))
            sys.exit(3)
        if not self.is_image and ('image' in self.details or 'image_tag' in self.details):
            self.logger.error('ERROR: If building a path, do not specify an image or tag. [{}]'.format(self.name))
            sys.exit(3)

    def create(self):
        """
        Create the container and prepare it to start.
        """
        self.logger.info('Creating Container {}'.format(self.name))
        self.id = self.cli.create_container(
            image=self.image_string,
            name=self.name,
            ports=self.ports,
            host_config=self.cli.create_host_config(
                port_bindings=self.port_bindings,
                binds=self.binds,
                restart_policy={
                    "MaximumRetryCount": 0,
                    "Name": "always"
                }
            ),
            environment=self.environment,
            volumes=self.volumes
        )

    def remove_existing(self):
        """
        Remove any existing containers previously deployed for this instance.
        """
        if len(self.cli.containers(quiet=False, all=True, filters={'name': self.name})) > 0:
            self.logger.info('Removing Apparent Existing Container {}'.format(self.name))
            try:
                self.cli.remove_container(
                    container=self.name,
                    v=False,
                    force=True
                )
            except Exception:
                pass

    def set_image_string(self):
        """
        Determine the image string to use in builds or deployments.
        """
        if self.is_image:
            self.image_string = self.details['image'] + ':' + self.details['image_tag']
        else:
            self.image_string = self.name

    def start(self):
        """
        Start the created container.
        """
        self.logger.info('Starting Container {} [{}]'.format(self.name, self.id))
        self.cli.start(self.id)

    def test_deploy(self):
        self.logger.info('No HarborMaster tests defined for {}'.format(self.name))
