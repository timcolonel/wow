from src.action.build.builder import Builder
from src.action.push.uploader import Uploader
from src.action.extract.extracter import Extracter


class Wow:
    options = {}

    def run(self, options):
        self.options = options
        if options['install']:
            self.install()
        elif options['uninstall']:
            self.uninstall()
        elif options['build']:
            self.build()
        elif options['push']:
            self.push()

    #Extract a wow file
    def extract(self):
        extracter = Extracter()
        extracter.extract(self.options['<filename>'])

    #Download a
    def install(self):
        print('install')

    def uninstall(self):
        print('uninstalling')

    def build(self):
        print('Building')
        builder = Builder()
        if self.options['<platform>'] is not None:
            builder.platform = self.options['<platform>']
        builder.build()

    def push(self):
        uploader = Uploader()
        uploader.upload(self.options['<file>'][0])