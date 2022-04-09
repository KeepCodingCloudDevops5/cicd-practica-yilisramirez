import logging, coloredlogs
logger=logging.getLogger(__name__)
coloredlogs.install(level='DEBUG',logger=logger)
logger.debug('Hola Keepcoders')

def add_one(number):
    return number+1

print(add_one(2))