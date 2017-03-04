import logging

from ShippingPierConfig import ShippingPierConfig
from ShippingLogs.ShippingLogs import ShippingLogMixin

# Import all crane types here.
from GantryCrane.GantryCrane import GantryCrane

import os
import re
import sys


class ShippingPier(ShippingLogMixin):
    def __init__(self):
        self.cli_args = None
        self.config = None
        self.cranes = []
        self.init_config()
        self.init_logger()
        self.project_name = None
        self.deploy_env = self.config.get('ShippingPier', 'deploy_env')

        if 'DOCKER_NO_CACHE' not in os.environ or os.environ['DOCKER_NO_CACHE'].strip() == '':
            self.no_cache = False
        else:
            self.no_cache = True

    def add_crane(self, crane):
        """
        Add a crane to the pier.
        """
        self.cranes.append(crane)

    def build_crane(self, crane_class):
        """
        Build a crane.
        """
        self.logger.info('Adding {} Crane To {} Pier'.format(crane_class, self.project_name))
        crane = globals()[crane_class](self.config)
        return crane

    def init_config(self):
        """
        Initialize configuration and variables.
        """
        config = ShippingPierConfig()
        self.config = config.config

    def init_logger(self):
        """
        Initialize the logger.
        """
        logging.basicConfig(level=getattr(logging, self.config.get('ShippingPier', 'logging_level')),
                            format='%(name)s %(levelname)s %(message)s'
                            )

    def ship(self):
        """
        Deploy the pier's application(s).
        """
        for crane in self.cranes:
            crane.deploy(self.no_cache)

    def add_manifest(self, manifest):
        """
        Read a manifest file and construct the application.
        """
        self.project_name = manifest['name']
        self.check_project_name()
        self.config.set('ShippingPier', 'project_name', self.project_name)
        for crane_type, crane in manifest['cranes'].iteritems():
            new_crane = self.build_crane(crane_type)
            for container_ext, container_details in crane.iteritems():
                if self.deploy_env in container_details['deploy_env']:
                    container_name = self.project_name
                    if not container_ext == "base":
                        self.check_container_ext(container_ext)
                        container_name = self.project_name + '_' + container_ext
                    self.logger.info('Pier adding {} Container to {} Pier Crane {} [{}]'.format(container_name, self.project_name, len(self.cranes), crane_type))
                    container_type = container_details['type'] + 'ShippingContainer'
                    container = new_crane.build_container(
                        name=container_name,
                        container_type=container_type,
                        details=container_details
                    )
                    new_crane.add_container(container)
            self.add_crane(new_crane)

    def check_project_name(self):
        """
        Check if the project name exists, and is a reasonable format.
        """
        if not len(self.project_name) < 32:
            self.logger.error('ERROR: Project name should be less than 32 characters [A-Za-z0-9._-] ({})'.format(self.project_name))
            sys.exit(2)

        if not re.match("^[A-Za-z0-9._-]*$", self.project_name):
            self.logger.error('ERROR: Project name may contain only [A-Za-z0-9._-] ({})'.format(self.project_name))
            sys.exit(2)

    def check_container_ext(self, ext):
        """
        Check if the container extension exists, and is a reasonable format.
        """
        if not len(ext) < 12:
            self.logger.error('ERROR: Container extension should be less than 12 characters [A-Za-z0-9._-] ({})'.format(ext))
            sys.exit(2)

        if not re.match("^[A-Za-z0-9._-]*$", ext):
            self.logger.error('ERROR: Container extension may contain only [A-Za-z0-9._-] ({})'.format(ext))
            sys.exit(2)
