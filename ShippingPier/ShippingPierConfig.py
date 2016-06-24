import ConfigParser
import os
import requests
import sys
from docker import Client as DockerClient
from optparse import OptionParser, OptionGroup
from ShippingLogs.ShippingLogs import ShippingLogMixin


class ShippingPierConfig(ShippingLogMixin):

    def __init__(self):
        self.config = ConfigParser.SafeConfigParser()
        self.option_parser = OptionParser()

        self.init_options()
        (self.options, self.cli_args) = self.option_parser.parse_args()
        self.check_options()
        self.read_config_file()
        self.set_config_from_options()
        self.set_config_from_env()
        self.check_config()

    def check_config(self):
        """
        Check the configuration for acceptable values.
        """
        self.check_config_repo_dir()

    def check_config_repo_dir(self):
        """
        Check if the repo dir seems to be a Docker driven project.
        """
        if not self.config.has_option('ShippingPier', 'repo_dir'):
            self.option_parser.print_help()
            print "\nERROR: The project repository was not specified! (--repo-dir)"
            sys.exit(2)

        repo_dir = self.config.get('ShippingPier', 'repo_dir')

        if not os.path.exists(repo_dir) or not os.path.exists(os.path.join(repo_dir, 'Dockerfile')):
            self.option_parser.print_help()
            print "\nERROR: The project repository does not seem to be valid! (--repo-dir)"
            sys.exit(2)

    def check_options(self):
        """
        Check the CLI options for acceptable values.
        """
        self.check_options_config_file()
        self.check_options_deploy_env()

    def check_options_config_file(self):
        """
        Check if the configuration file specified exists.
        """
        if self.options.config_filepath is None or not os.path.exists(self.options.config_filepath):
            self.option_parser.print_help()
            print "\nERROR: Cannot read configuration file! (--config)"
            sys.exit(2)

    def check_options_deploy_env(self):
        """
        Check the deploy environment for a non-standard value.
        """
        if self.options.deploy_env not in ['dev', 'stage', 'prod']:
            self.option_parser.print_help()
            print "\nERROR: Deploy environment must be one of ['dev', 'stage', 'prod']! (--deploy-env)"
            sys.exit(2)

    def init_options(self):
        """
        Initialize the CLI options.
        """
        group = OptionGroup(self.option_parser, 'ShippingPier')

        group.add_option(
            "-c", "--config",
            dest="config_filepath",
            default='',
            help="The full path to the configuration file to use.",
        )
        group.add_option(
            "-e", "--deploy-env",
            dest="deploy_env",
            default='prod',
            help="The environment type to build. One of ['dev', 'stage', 'prod'].",
        )
        group.add_option(
            "-d", "--repo-dir",
            dest="repo_dir",
            default='',
            help="The directory containing the repository to deploy.",
        )
        group.add_option(
            "-H", "--docker-host",
            dest="docker_api_host",
            default='',
            help="The docker endpoint host used to deploy the pier.",
        )
        group.add_option(
            "-p", "--docker-port",
            dest="docker_api_port",
            default='',
            help="The docker endpoint port used to deploy the pier.",
        )

        self.option_parser.add_option_group(group)

    def read_config_file(self):
        """
        Read the configuration file.
        """
        self.config.read(self.options.config_filepath)

    def set_config_from_options(self):
        """
        CLI options must trump config file values, so override any config values with options provided.
        """
        for option_key, option_value in self.options.__dict__.items():
            if option_value is not '':
                self.config.set('ShippingPier', option_key, option_value)

    def set_config_from_env(self):
        """
        Check environment for configuration values and apply them, overwriting passed and conf file values.
        """
        for var, value in os.environ.iteritems():
            if var.startswith("CargoDock_"):
                var_name_data = var.split('_')
                package_name = var_name_data[1]
                del var_name_data[0:2]
                variable_name = '_'.join(var_name_data)
                self.config.set(package_name, variable_name, value)

