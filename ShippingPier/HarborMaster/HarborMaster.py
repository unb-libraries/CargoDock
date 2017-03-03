"""
A generic deployed container testing object.
"""
from ShippingPier.ShippingLogs.ShippingLogs import ShippingLogMixin


class HarborMaster(ShippingLogMixin):
    def __init__(self, container):
        self.container = container
        self.logger.info('Creating Harbor Master for {}'.format(self.container.name))

    #def fail_stderr_logs(self, string):
    def fail_stderr_logs(self):
        logs_stderr_output = self.container.cli.logs(
            container=self.container.id,
            stderr=True,
            stdout=True
        )
        self.logger.info("{} Stderr : {}".format(self.container.name, logs_stderr_output))

        #if string not in self.response.read():
        #    self.logger.error("{} String '{}' Does Not Exist on Page, URI:{} Last Response:{}".format(self.container.name, string, self.url, self.status))
        #    exit(5)
        #self.logger.info("{} String '{}' Exists on Page! URI:{} Response:{}".format(self.container.name, string, self.url, self.status))
