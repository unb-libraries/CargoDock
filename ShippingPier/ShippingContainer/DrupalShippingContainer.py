"""
DrupalShippingContainer was created to specifically deploy the unblibraries/drupal docker container. It will most
certainly not be compatible with any other Drupal image.
"""
import os
import sys
from ShippingContainer import ShippingContainer
from ShippingPier.HarborMaster.HarborMasterWeb import HarborMasterWeb
from ShippingPier.HarborMaster.HarborMasterContainerSelfTest import HarborMasterContainerSelfTest


class DrupalShippingContainer(ShippingContainer):
    def create(self):
        """
        Create the Drupal container and prepare it for starting.
        """
        self.logger.info('Creating Drupal Container {}'.format(self.name))
        self.check_requirements()
        self.setup_environment()
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

    def setup_environment(self):
        """
        Setup the container and environment for the unblibraries/drupal extension image type.
        """
        try:
            new_env_vars = {
                'DRUPAL_DB_PASSWORD': self.config.get('DrupalShippingContainer', 'admin_account_pass'),
                'DRUPAL_ADMIN_ACCOUNT_PASS': self.config.get('DrupalShippingContainer', 'db_password'),
                'DRUPAL_TESTING_TOOLS': self.config.get('DrupalShippingContainer', 'testing_tools'),
                'DRUPAL_SITE_URI': self.project_name,
                'DEPLOY_ENV': self.config.get('ShippingPier', 'deploy_env'),
                'HOST_HOSTNAME': 'HOST_HOSTNAME',
                'MYSQL_PORT': self.config.get('DrupalShippingContainer', 'mysql_port'),
                'MYSQL_ROOT_PASSWORD': self.config.get('DrupalShippingContainer', 'mysql_root'),
                'NR_INSTALL_KEY': self.config.get('ShippingContainer', 'nr_install_key'),
            }

            if self.config.get('ShippingPier', 'deploy_env') in ['dev', 'stage']:
                new_env_vars['MYSQL_HOSTNAME'] = self.project_name + '_mysql'
        except:
            self.logger.error('Some configuration settings not found! {}'.format(self.name))
            sys.exit(3)

        self.environment.update(new_env_vars)

        self.add_port_bindings(
            {
                int(os.environ['JENKINS_SITE_UUID']): 80
            }
        )

        self.volumes.append(os.environ['VOLUME_MOUNT_POINT'])

        if 'HOST_VOLUME_PATH' not in os.environ or os.environ['HOST_VOLUME_PATH'].strip() == '':
            self.logger.info('Host volume path not specified; using generic volume. {}'.format(self.name))
            self.binds.append(self.name + ':' + os.environ['VOLUME_MOUNT_POINT'])
        else:
            self.logger.info('Host volume path specified; passing to volume statement. {}'.format(self.name))
            self.binds.append(os.environ['HOST_VOLUME_PATH'] + ':' + os.environ['VOLUME_MOUNT_POINT'])

    def check_requirements(self):
        """
        Check the configuration and environment variables for Drupal specific requirements.
        """
        if 'JENKINS_SITE_UUID' not in os.environ or os.environ['JENKINS_SITE_UUID'].strip() == '':
            self.logger.error('JENKINS_SITE_UUID Environment Variable Not Set! {}'.format(self.name))
            sys.exit(3)
        if 'VOLUME_MOUNT_POINT' not in os.environ or os.environ['VOLUME_MOUNT_POINT'].strip() == '':
            self.logger.error('VOLUME_MOUNT_POINT Environment Variable Not Set! {}'.format(self.name))
            sys.exit(3)

    def test_deploy(self):
        self.test_deploy_web_reachable()
        self.test_stderr()
        self.test_deploy_drupal_tests()

    def test_deploy_web_reachable(self):
        harbor_master = HarborMasterWeb(self)
        harbor_master.port = int(os.environ['JENKINS_SITE_UUID'])
        harbor_master.host = 'localhost'
        harbor_master.url = '/user/login'
        harbor_master.retries = 5
        harbor_master.sleep = 90
        harbor_master.check_string('Log in')

    def test_deploy_drupal_tests(self):
        harbor_master = HarborMasterContainerSelfTest(self)
        harbor_master.run_tests()

    def test_stderr(self):
        harbor_master = HarborMasterContainerSelfTest(self)
        harbor_master.strings_stderr_output(
            [
                'validating the config synchronization'
            ]
        )

    def build(self):
        if self.config.get('ShippingPier', 'deploy_env') in ['dev', 'stage']:
            self.buildargs['COMPOSER_DEPLOY_DEV'] = 'dev'
        super(DrupalShippingContainer, self).build()
