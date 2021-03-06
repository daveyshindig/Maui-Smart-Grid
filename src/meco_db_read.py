#!/usr/bin/env python
# -*- coding: utf-8 -*-

__author__ = 'Daniel Zhang (張道博)'
__copyright__ = 'Copyright (c) 2013, University of Hawaii Smart Energy Project'
__license__ = 'https://raw.github' \
              '.com/Hawaii-Smart-Energy-Project/Maui-Smart-Grid/master/BSD' \
              '-LICENSE.txt'

from msg_db_connector import MSGDBConnector
from msg_db_util import MSGDBUtil
import psycopg2
import psycopg2.extras


class MECODBReader(object):
    """
    Read records from a database.
    """

    def __init__(self, testing = False):
        """
        Constructor.

        :param testing: True if in testing mode.
        """

        self.connector = MSGDBConnector()
        self.conn = MSGDBConnector(testing).connectDB()
        self.dbUtil = MSGDBUtil()
        self.dbName = self.dbUtil.getDBName(self.connector.dictCur)

    def selectRecord(self, conn, table, keyName, keyValue):
        """
        Read a record in the database given a table name, primary key name,
        and value for the key.

        :param conn DB connection
        :param table DB table name
        :param keyName DB column name for primary key
        :param keyValue Value to be matched
        :returns: Row containing record data.
        """

        print "selectRecord:"
        sql = """SELECT * FROM "%s" WHERE %s = %s""" % (
        table, keyName, keyValue)
        dcur = conn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        self.dbUtil.executeSQL(dcur, sql)
        row = dcur.fetchone()
        return row

    def readingAndMeterCounts(self):
        """
        Retrieve the reading and meter counts.

        :returns: Multiple lists containing the retrieved data.
        """

        sql = """SELECT "Day", "Reading Count",
        "Meter Count" FROM count_of_readings_and_meters_by_day"""
        dcur = self.conn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        self.dbUtil.executeSQL(dcur, sql)
        rows = dcur.fetchall()

        dates = []
        meterCounts = []
        readingCounts = []

        for row in rows:
            dates.append(row[0])
            readingCounts.append(row[1] / row[2])
            meterCounts.append(row[2])

        return dates, readingCounts, meterCounts
