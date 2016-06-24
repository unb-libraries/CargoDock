"""
A generic deployed container testing object.
"""
from ShippingPier.ShippingLogs.ShippingLogs import ShippingLogMixin


class HarborMaster(ShippingLogMixin):
    def __init__(self, container):
        self.container = container
        self.logger.info('Creating Harbor Master for {}'.format(self.container.name))
