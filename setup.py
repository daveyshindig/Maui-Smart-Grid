#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Test of applying distutils.
"""

__author__ = 'Daniel Zhang (張道博)'
__copyright__ = 'Copyright (c) 2013, University of Hawaii Smart Energy Project'
__license__ = 'https://raw.github' \
              '.com/Hawaii-Smart-Energy-Project/Maui-Smart-Grid/master/BSD' \
              '-LICENSE.txt'

from distutils.core import setup

setup(name = 'MauiSmartGrid',
      version = '1.0',
      description = 'Data Processing and Data Operations for the Maui Smart '
                    'Grid Project.',
      author = 'Daniel Zhang (張道博)',
      author_email= 'Daniel Zhang',
      url = 'https://github.com/Hawaii-Smart-Energy-Project/Maui-Smart-Grid',
      license = 'BSD',
      platforms = 'OS X, Linux',

      package_dir = {'': 'src'},

      py_modules = ['meco_db_delete',
                    'meco_db_insert',
                    'meco_db_read',
                    'meco_dupe_check',
                    'meco_fk',
                    'meco_mapper',
                    'meco_plotting',
                    'meco_pv_readings_in_nonpv_mlh_notifier',
                    'meco_xml_parser',
                    'msg_configer',
                    'msg_db_connector',
                    'msg_db_exporter',
                    'msg_db_util',
                    'msg_logger',
                    'msg_noaa_weather_data_dupe_checker',
                    'msg_noaa_weather_data_inserter',
                    'msg_noaa_weather_data_parser',
                    'msg_noaa_weather_data_util',
                    'msg_notifier',
                    'msg_time_util'
      ],

      scripts = ['insertLocationRecords.py',
                 'insertMECOEnergyData.py',
                 'insertMECOMeterLocationHistoryData.py',
                 'insertMeterRecords.py',
                 'retrieveNOAAWeatherData.py']
)