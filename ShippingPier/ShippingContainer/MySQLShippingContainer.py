"""
DrupalShippingContainer was created to specifically deploy the mysql docker container. It will most certainly not be
compatible with any other container image.
"""
from ShippingContainer import ShippingContainer


class MySQLShippingContainer(ShippingContainer):

    def create(self):
        """
        Create the MySQL container and prepare it for starting.
        """
        self.logger.info('Creating MySQL Container {}'.format(self.name))
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
        Setup the container and environment for the MySQL image type.
        """
        new_env_vars = {
            'MYSQL_ROOT_PASSWORD': self.config.get('MySQLShippingContainer', 'mysql_root'),
        }

        self.environment.update(new_env_vars)

        self.volumes.append('/var/lib/mysql')
        self.binds.append(self.name + ':/var/lib/mysql')
