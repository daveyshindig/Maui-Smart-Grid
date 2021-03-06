#!/usr/bin/env python
# -*- coding: utf-8 -*-

__author__ = 'Daniel Zhang (張道博)'
__copyright__ = 'Copyright (c) 2013, University of Hawaii Smart Energy Project'
__license__ = 'https://raw.github' \
              '.com/Hawaii-Smart-Energy-Project/Maui-Smart-Grid/master/BSD' \
              '-LICENSE.txt'

from msg_noaa_weather_data_dupe_checker import MSGWeatherDataDupeChecker
from msg_db_util import MSGDBUtil
from msg_logger import MSGLogger
import sys
import datetime as dt


class MSGNOAAWeatherDataInserter(object):
    """
    Performs weather data insertion to a database.
    """

    def __init__(self, testing = False):
        """
        Constructor.
        :param testing: True if testing mode is being used.
        """

        self.logger = MSGLogger(__name__, 'info')
        self.dbUtil = MSGDBUtil()
        self.dupeChecker = MSGWeatherDataDupeChecker()

    def insertDataDict(self, conn, tableName, listOfDataDicts, commit = False):
        """
        Given a table name and a dictionary of column names and values,
        insert them to the db.

        :param conn: A database connection.
        :param tableName: Name of the DB table to be inserted to.
        :param columnsAndValues: Dictionary of columns and values to be
        inserted to the DB.
        :param (optional) commit: A flag indicated that DB transactions will
        be committed.
        :returns: Set of datetimes processed.
        """

        cur = conn.cursor()
        processedDateTimes = set()

        for row in listOfDataDicts:

            # Add a creation timestamp using the SQL function.
            row['created'] = 'NOW()'

            cols = []
            vals = []

            for col in row.keys():
                # Prepare the columns and values for insertion via SQL.

                cols.append(col)
                if (row[col] != 'NULL'):
                    # Surround each value with single quotes...
                    vals.append("'%s'" % row[col])
                else:
                    # Except for NULL values.
                    vals.append("%s" % row[col])

            #sql = 'INSERT INTO "' + tableName + '" (' + ','.join(cols) + ')'
            # + ' VALUES (' + ','.join(vals) + ')'
            sql = """INSERT INTO "%s" (%s) VALUES (%s)""" % (
            tableName, ','.join(cols), ','.join(vals))

            if self.dupeChecker.duplicateExists(cur, row['wban'],
                                                row['datetime'],
                                                row['record_type']):
                self.logger.log("Dupe found, dropping dupe.", 'info')
            else:
                processedDateTimes.add(
                    dt.datetime.strptime(row['datetime'], "%Y-%m-%d %H:%M"))
                if self.dbUtil.executeSQL(cur, sql,
                                          exitOnFail = False) is False:
                    # An error occurred.
                    for col in sorted(row.keys()):
                        print "%s: %s" % (col, row[col])
                    sys.exit(-1)

        if commit:
            try:
                conn.commit()
            except:
                self.logger.log("ERROR: Commit failed.", 'debug')

        return processedDateTimes
