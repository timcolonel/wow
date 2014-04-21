from src.archive import Archive
from src.wow_config import WowConfig
import os


class Extractor:
    filename = ''

    def destination(self):
        return str(os.path.join(WowConfig.install_folder, os.path.splitext(self.filename)[0]))

    def extract(self, filename):
        self.filename = filename
        print('extracting: ' + str(self.destination()))
        Archive.extract(filename, self.destination())