"""
An object used to test web based instances for response after deployment.
"""
import time
import httplib
from HarborMaster import HarborMaster


class HarborMasterWeb(HarborMaster):
    def __init__(self, container):
        super(HarborMasterWeb, self).__init__(container)
        self.retries = 3
        self.sleep = 60
        self.port = 80
        self.host = 'localhost'
        self.url = '/'
        self.healthy_status = [200, 302]
        self.status = None
        self.response = None

    def check_health(self):
        tries_left = self.retries
        while tries_left:
            tries_left -= 1
            if self.healthy():
                self.logger.info("{} Health check Passed! URI:{} Response:{}".format(self.container.name, self.url, self.status))
                return True
            self.logger.warn("{} Health check failed, URI:{} Response:{} Sleeping {}s [{}/{}]".format(self.container.name, self.url, self.status, self.sleep, self.retries-tries_left, self.retries))
            time.sleep(self.sleep)
        self.logger.error("{} Health check retries exhausted, URI:{} Last Response:{}".format(self.container.name, self.url, self.status))
        exit(5)

    def check_string(self, string):
        self.check_health()
        if string not in self.response.read():
            self.logger.error("{} String '{}' Does Not Exist on Page, URI:{} Last Response:{}".format(self.container.name, string, self.url, self.status))
            exit(5)
        self.logger.info("{} String '{}' Exists on Page! URI:{} Response:{}".format(self.container.name, string, self.url, self.status))

    def healthy(self):
        self.set_status()
        if self.status in self.healthy_status:
            return True
        return False

    def set_status(self):
        c = httplib.HTTPConnection(self.host, self.port)
        c.follow_all_redirects = True
        c.request("GET", self.url)
        try:
            self.response = c.getresponse()
            self.status = self.response.status
        except Exception:
            pass
