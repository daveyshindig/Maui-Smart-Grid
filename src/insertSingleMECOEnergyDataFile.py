#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Usage:

    time python -u ${PATH}/insertSingleMECOEnergyDataFile.py --filepath \
    ${FILEPATH} [--testing] > ${LOG_FILE}

This script is used by insertMECOEnergyData.py.
"""

__author__ = 'Daniel Zhang (張道博)'
__copyright__ = 'Copyright (c) 2013, University of Hawaii Smart Energy Project'
__license__ = 'https://raw.github' \
              '.com/Hawaii-Smart-Energy-Project/Maui-Smart-Grid/master/BSD' \
              '-LICENSE.txt'

from meco_xml_parser import MECOXMLParser
import re
from msg_configer import MSGConfiger
import gzip
import sys
import argparse
import os
from filelock import FileLock
from msg_logger import MSGLogger


USE_SCRIPT_METHOD = False


class Inserter(object):
    """
    Perform insertion of data contained in a single file to the MECO database
    specified in the configuration file.
    """

    def __init__(self, testing = False):
        """
        Constructor.

        :param testing: Flag indicating if testing mode is on.
        """

        self.logger = MSGLogger(__name__)
        self.parser = MECOXMLParser(testing)
        self.configer = MSGConfiger()

    def insertData(self, filePath, testing = False, jobID = ''):
        """
        Insert data from a single file to the database.

        :param filePath: Full path of a data file.
        :param testing: Boolean flag indicating if the testing database
        should be used.
        :param jobID: An ID used to distinguish multiprocessing jobs.
        :returns: String containing concise log of activity.
        """

        parseMsg = ''
        parseLog = ''

        print "Processing file %s." % filePath
        i = Inserter(testing)
        if i.configer.configOptionValue("Debugging", "debug"):
            print "Debugging is on"

        if testing:
            parseMsg = "\nInserting data to database %s.\n" % i.configer\
                .configOptionValue(
                "Database", "testing_db_name")
            sys.stderr.write(parseMsg)
            parseLog += parseMsg
        else:
            parseMsg += "\nInserting data to database %s.\n" % i.configer\
                .configOptionValue(
                "Database", "db_name")
            sys.stderr.write(parseMsg)
            parseLog += parseMsg

        fileObject = None


        # Open the file and process it.
        if re.search('.*\.xml$', filePath):
            fileObject = open(filePath, "rb")
        elif re.search('.*\.xml\.gz$', filePath):
            fileObject = gzip.open(filePath, "rb")
        else:
            print "Error: %s is not an XML file." % filePath

        try:
            with FileLock(filePath, timeout = 2) as lock:
                self.logger.log("Locking %s " % filePath)
                i.parser.filename = filePath

                # Obtain the log of the parsing.
                parseLog += i.parser.parseXML(fileObject, True, jobID = jobID)

                fileObject.close()
        except TypeError:
            self.logger.log('Type error occurred', 'error')

        return parseLog


def processCommandLineArguments():
    """
    Create command line arguments and parse them.
    """

    global parser, commandLineArgs
    parser = argparse.ArgumentParser(
        description = 'Perform insertion of data contained in a single file to '
                      'the MECO database specified in the configuration file.')
    parser.add_argument('--filepath',
                        help = 'A filepath, including the filename, '
                               'for a file containing data to be inserted.')
    parser.add_argument('--testing', action = 'store_true',
                        help = 'Insert data to the testing database as '
                               'specified in the local configuration file.')
    commandLineArgs = parser.parse_args()

# @DEPRECATED
# @todo Determine if this code is safe to remove.
# @todo Remove this code.

if USE_SCRIPT_METHOD:

    processCommandLineArguments()

    if (commandLineArgs.filepath):
        print "Processing %s." % commandLineArgs.filepath
    else:
        print "Usage: insertData --filepath ${FILEPATH} [--testing]"
        sys.exit(-1)

    filepath = commandLineArgs.filepath

    i = Inserter(commandLineArgs.testing)

    if i.configer.configOptionValue("Debugging", "debug"):
        print "Debugging is on"

    if commandLineArgs.testing:
        sys.stderr.write(
            "\nInserting data to database %s.\n" % i.configer.configOptionValue(
                "Database", "testing_db_name"))
    else:
        sys.stderr.write(
            "\nInserting data to database %s.\n" % i.configer.configOptionValue(
                "Database", "db_name"))

    filename = os.path.basename(filepath)
    fileObject = None

    # Open the file and process it.
    if re.search('.*\.xml$', filepath):
        fileObject = open(filepath, "rb")
    elif re.search('.*\.xml\.gz$', filepath):
        fileObject = gzip.open(filepath, "rb")
    else:
        print "Error: %s is not an XML file." % filepath
    i.parser.filename = commandLineArgs.filepath

    # Obtain the log of the parsing.
    parseLog = i.parser.parseXML(fileObject, True)

    fileObject.close()
