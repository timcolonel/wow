"""
Wow

Usage:
    wow
    wow install <application>...
    wow uninstall <application>...
    wow unpack <file>...
    wow build [<config_file>]
    wow push
    wow compile
    wow (-h | --help)
    wow --version
Action
Options:
  -h --help     Show this screen.
  --version     Show version.

"""

from src.wow import Wow
from docopt import docopt
from src.exception import WowException
import logging

logging.basicConfig(format='%(message)s', level=logging.DEBUG)

if __name__ == '__main__':
    arguments = docopt(__doc__, version='1.0.0')
    engine = Wow()
    try:
        engine.run(arguments)
    except WowException as e:
        logging.error(str(e))
