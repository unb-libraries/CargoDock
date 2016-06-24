"""
An object used to trigger standardized container self-tests (/scripts/runTests.sh) after deployment.
"""
from HarborMaster import HarborMaster


class HarborMasterContainerSelfTest(HarborMaster):
    def __init__(self, container):
        super(HarborMasterContainerSelfTest, self).__init__(container)

    def run_tests(self):
        self.logger.info('Starting in-container tests for {}'.format(self.container.name))
        exec_details = self.container.cli.exec_create(
            container=self.container.id,
            cmd='/scripts/runTests.sh'
        )
        test_output = self.container.cli.exec_start(
            exec_id=exec_details['Id']
        )
        self.logger.info(test_output)

        exec_info = self.container.cli.exec_inspect(exec_details['Id'])
        if not exec_info['ExitCode'] == 0:
            self.logger.error("{} In-Container tests failed. ExitCode:{}".format(self.container.name, not exec_info['ExitCode']))
            exit(5)
        self.logger.info('{} In-Container tests returned a success code'.format(self.container.name))
