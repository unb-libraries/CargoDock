"""
A generic deployed container testing object.
"""
from ShippingPier.ShippingLogs.ShippingLogs import ShippingLogMixin


class HarborMaster(ShippingLogMixin):
    def __init__(self, container):
        self.container = container
        self.logger.info('Creating Harbor Master for {}'.format(self.container.name))

    def strings_stderr_output(self, error_strings=[]):
        logs_stderr_output = self.container.cli.logs(
            container=self.container.id,
            stderr=True,
            stdout=False
        )
        self.logger.info("{} Stderr : {}".format(self.container.name, logs_stderr_output))

        for error_string in error_strings:
            if error_string in logs_stderr_output:
                self.logger.error("{} String '{}' Exists in stderr, Failing.".format(self.container.name, error_string))
                exit(5)
