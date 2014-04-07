"""
Wow

Usage:
    wow
    wow install <application>...
    wow uninstall <application>...
    wow build
    wow push
    wow compile
    wow (-h | --help)
    wow --version
Action
Options:
  -h --help     Show this screen.
  --version     Show version.

"""

from lib.wow import Wow
from docopt import docopt


if __name__ == '__main__':
    arguments = docopt(__doc__, version='1.0.0')
    engine = Wow()
    engine.run(arguments)
