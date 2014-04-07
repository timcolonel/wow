from src.build.builder import Builder

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

    def install(self):
        print('install')

    def uninstall(self):
        print('uninstalling')

    def build(self):
        print('Building')
        builder = Builder()
        if self.options['<config_file>'] is not None:
            builder.config_file = self.options['<config_file>']
        builder.build()

