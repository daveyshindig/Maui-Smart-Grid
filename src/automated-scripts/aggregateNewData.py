#!/usr/bin/env python
# -*- coding: utf-8 -*-

__author__ = 'Daniel Zhang (張道博)'
__copyright__ = 'Copyright (c) 2014, University of Hawaii Smart Energy Project'
__license__ = 'https://raw.github' \
              '.com/Hawaii-Smart-Energy-Project/Maui-Smart-Grid/master/BSD' \
              '-LICENSE.txt'

from msg_logger import MSGLogger
from msg_data_aggregator import MSGDataAggregator
from msg_notifier import MSGNotifier
from msg_db_connector import MSGDBConnector
from msg_db_util import MSGDBUtil


NOTIFICATION_HISTORY_TABLE = "NotificationHistory"
NOTIFICATION_HISTORY_TYPE = 'MSG_DATA_AGGREGATOR'


class NewDataAggregator(object):
    """
    Perform aggregation of new data for a set of predefined data types (self
    .rawTypes).
    """

    def __init__(self):
        """
        Constructor.
        """
        self.logger = MSGLogger(__name__, 'DEBUG')
        self.aggregator = MSGDataAggregator()
        self.notifier = MSGNotifier()
        self.rawTypes = ['weather', 'egauge', 'circuit', 'irradiance']
        self.connector = MSGDBConnector()
        self.conn = self.connector.connectDB()
        self.cursor = self.conn.cursor()
        self.dbUtil = MSGDBUtil()


    def lastReportDate(self, notificationType):
        """
        Get the last time a notification was reported.

        :param notificationType: string indicating the type of the
        notification. It is stored in the event history.
        :returns: datetime of last report date.
        """

        cursor = self.cursor
        sql = """SELECT MAX("notificationTime") FROM "{}" WHERE
        "notificationType" = '{}'""".format(NOTIFICATION_HISTORY_TABLE,
                                            notificationType)

        success = self.dbUtil.executeSQL(cursor, sql)
        if success:
            rows = cursor.fetchall()

            if not rows[0][0]:
                return None
            else:
                return rows[0][0]
        else:
            raise Exception('Exception during getting last report date.')


    def sendNewDataNotification(self, result = None, testing = False):
        """
        Sending notification reporting on new data being available since the
        last time new data was reported.

        :param result: list of dicts containing aggregation results as
        provided by MSGDataAggregator::aggregateNewData.
        :param testing: Use testing mode when True.
        """

        self.logger.log('result {}'.format(result), 'debug')

        lastReportDate = self.lastReportDate(NOTIFICATION_HISTORY_TYPE)

        if not lastReportDate:
            lastReportDate = "never"

        if not result:
            msgBody = '\nNew data has NOT been aggregated in {}. No result ' \
                      'was obtained. This is an error that should be ' \
                      'investigated.'.format(self.connector.dbName)
        else:
            msgBody = '\nNew data has been aggregated in {}.'.format(
                self.connector.dbName)
            msgBody += '\n\n'
            for i in range(len(result)):
                msgBody += 'The new data count for type {} is {} readings' \
                           '.\n'.format(result[i].keys()[0],
                                      result[i].values()[0])
            msgBody += '\n\n'
            msgBody += 'The last report date was %s.' % lastReportDate
            msgBody += '\n\n'
        self.notifier.sendNotificationEmail(msgBody, testing = testing)
        self.saveNotificationTime()


    def saveNotificationTime(self):
        """
        Save a notification event to the notification history.
        """

        cursor = self.cursor
        sql = """INSERT INTO "{}" ("notificationType", "notificationTime")
        VALUES ('{}', NOW())""".format(NOTIFICATION_HISTORY_TABLE,
                                       NOTIFICATION_HISTORY_TYPE)
        success = self.dbUtil.executeSQL(cursor, sql)
        self.conn.commit()
        if not success:
            raise Exception('Exception while saving the notification time.')


    def aggregateNewData(self):
        """
        :return: list of dicts obtained from
        MSGDataAggregator::aggregateNewData.
        """

        result = map(self.aggregator.aggregateNewData, self.rawTypes)

        self.logger.log('result {}'.format(result))
        return result


if __name__ == '__main__':
    aggregator = NewDataAggregator()
    logger = MSGLogger(__name__)
    logger.log('Last report date {}'.format(
        aggregator.lastReportDate(NOTIFICATION_HISTORY_TYPE)))
    result = aggregator.aggregateNewData()
    aggregator.sendNewDataNotification(result = result, testing = False)
