import yaml
import glob
import os.path
from lib.exception import WowException


class Config:
    config = {}
    config_file = 'wow.yml'

    def load(self):
        """
            Load the config file
        """

        if not os.path.isfile(self.config_file):
            raise WowException("Config file does '%s' not exist" % self.config_file)

        stream = open(self.config_file, 'r')
        self.config = yaml.load(stream)

    def all_files(self):
        """
            return all the files matching the patterns provided in the config
        """
        filenames = []

        for pattern in self.config['files']:
            filenames += glob.glob(pattern)
        filenames.append(self.config_file)
        return filenames