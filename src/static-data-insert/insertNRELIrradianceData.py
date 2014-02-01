#!/usr/bin/env python
# -*- coding: utf-8 -*-

__author__ = 'David Wilkie & Christian Damo'
__copyright__ = 'Copyright (c) 2014, University of Hawaii Smart Energy Project'
__license__ = 'https://raw.github.com/Hawaii-Smart-Energy-Project/ \
			  Maui-Smart-Grid/master/BSD-LICENSE.txt'

"""
Usage:

	python insertNRELIrradianceData.py

	(run from the working directory containing the files you want to insert)
	
This script parses any CSV files in the working directory, which should all be
NREL irradiance data, conditions the data to be inserted into the database, and
finally performs the DB insertion on the cleaned-up files.

Running time is commensurate with the number of files in the working directory.
"""

import csv
import sys
import subprocess
import datetime
import os
from msg_db_connector import MSGDBConnector
from msg_db_util import MSGDBUtil

def get_clean_name(name):
	"""
	A convenience function for naming the output files.

	:param name: A name of the target file.
	:returns: The name suffixed with "_clean" and the file extension.
	"""

	name = name.split(".")
	name = name[0] + "_clean." + name[1]
	return name

def get_timestamp(row):
	"""
	A convenience function to parse a string into a Python datetime object.

	:param datetimeStr: A string containing a date and time, e.g.: Sun Sep 01 2013 24:00:00.000 GMT-1000
	:returns: The corresponding datetime.datetime object
	"""

	#assign the values in the list to the different components needed to
	#create the datetime object
	second = int(row[0])
	year = int(row[1])
	julianDay = int(row[2])
	hour = int(row[3][:-2])
	minute = int(row[3][-2:])
	#if we are dealing with a leap year, use these calculations to find the day
	if is_leap_year(year) == 1:
		if 1 <= julianDay < 32:
			month = 1
			day = julianDay
		if 32 <= julianDay < 61:
			month = 2
			day = julianDay -31
		if 61 <= julianDay < 92:
			month = 3
			day = julianDay - 60
		if 92 <= julianDay < 122:
			month = 4
			day = julianDay - 91
		if 122 <= julianDay < 153:
			month = 5
			day = julianDay - 121
		if 153 <= julianDay < 183:
			month = 6
			day = julianDay - 152
		if 183 <= julianDay < 214:
			month = 7
			day = julianDay - 182
		if 214 <= julianDay < 245:
			month = 8
			day = julianDay - 213
		if 245 <= julianDay < 275:
			month = 9
			day = julianDay - 244
		if 275 <= julianDay < 306:
			month = 10
			day = julianDay - 274
		if 306 <= julianDay < 336:
			month = 11
			day = julianDay - 305
		if 336 <= julianDay <= 366:
			month = 12
			day = julianDay - 335
	else:
		#otherwise we're dealing with a non-leap year, then use these calculations for the day
		if 1 <= julianDay < 32:
			month = 1
			day = julianDay
		if 32 <= julianDay < 60:
			month = 2
			day = julianDay - 31
		if 60 <= julianDay < 91:
			month = 3
			day = julianDay -59
		if 91 <= julianDay < 121:
			month = 4 
			day = julianDay - 90
		if 121 <= julianDay < 152:
			month = 5
			day = julianDay -120
		if 152 <= julianDay < 182:
			month = 6
			day = julianDay - 151
		if 182 <= julianDay < 213:
			month = 7
			day = julianDay - 181
		if 213 <= julianDay < 244:
			month = 8
			day = julianDay - 212
		if 244 <= julianDay < 274:
			month = 9
			day = julianDay - 243
		if 274 <= julianDay < 305:
			month = 10
			day = julianDay - 273
		if 305 <= julianDay < 335:
			month = 11
			day = julianDay - 304
		if 335 <= julianDay <= 365:
			month = 12
			day = julianDay - 334
	#now that we have the necessary componenets, build the object and return it
	timestamp = datetime.datetime(year, month, day, hour, minute, second)
	return timestamp


def is_leap_year(year):
	"""
	Helper methed for get_timestamp.

	:param year: The year.
	:returns True if the year is a leap year.
	"""

	year = int(year)
	if(year%400) ==0:
		leap=1
	elif (year%100) == 0:
		leap = 0
	elif (year%4) == 0:
		leap = 1
	else:
		leap = 0
	return leap


def insertData(files, table, cols):
	"""
	Insert aggregated data generated by this script into a database table.

	:param files: A list of the filenames to be processed.
	:param table: The name of the table in the DB.
	:param cols: A list of the columns (as strings) in the table.
	:param testing: Specify whether to use test 
	"""

	connector = MSGDBConnector()
	conn = connector.connectDB()
	dbUtil = MSGDBUtil()
	cursor = conn.cursor()

	cnt = 0

	for file in files:

		with open(file, 'rb') as csvfile:
			myReader = csv.reader(csvfile, delimiter = ',')
			# Skip the header line.
			myReader.next()
			for row in myReader:
				print row
				sql = """INSERT INTO "%s" (%s) VALUES (%s)""" % (
					table, ','.join(cols),
					','.join("'" + item.strip() + "'" for item in row))

				sql = sql.replace("'NULL'", 'NULL')
				dbUtil.executeSQL(cursor, sql)
				cnt += 1
				if cnt % 10000 == 0:
					conn.commit()

		conn.commit()
		cnt = 0

def getFileNames(ext):
	"""
	Return a list of filenames having a given extension from the current 
	working directory. Skips files that have a tilde in the name.

	:param ext: The extension (or whatever string contained) in the filename.
	:returns: A list of the filenames.
	"""
	# Capture a system call "ls" to see what files are in the folder.
	output = subprocess.Popen(["ls"],stdout = subprocess.PIPE, \
			 stderr = subprocess.STDOUT, shell = True).communicate()[0]
	# Split the string by lines.
	output = output.split("\n")
	fileNames = []

	# For each line split it by the empty spaces
	for line in output:
		line = line.split(" ")

		# For each element find the file name of the files in that folder with
		# the extension *.txt
		for element in line:
			if ext in element and "~" not in element:
				#if you found a valid filename, put it in a list
				fileNames.append(element)

	return fileNames

def cleanFiles(files, targetDir):
	"""
	Process the files given and output into the target directory.

	:param files: A list of filenames.
	:param targetDir: The directory in which to write the output.
	"""
	for file_ in fileNames:
		print "Cleaning " + file_
		# Setup the csv reader and writer.
		inputFile = 	open(file_,"r")
		reader = 		csv.reader(inputFile)
		newName = 		get_clean_name(file_)
		outputFile = 	open(targetDir + newName, "wb")
		writer = 		csv.writer(outputFile)
		# Make the csv header row and write it to the file.
		newRow = ["timestamp", "sensor_id", "irradiance_w_per_m2"]

		writer.writerow(newRow)

		for row in reader:
			# Get the temporal data and compress into a datetime object.
			timestamp = get_timestamp(row)
			# Build the new row with the datetime object and the 2 rows of data.
			if int(file_[:6]) <= 201206:
				newRow = [str(timestamp),1,row[4]]
				writer.writerow(newRow)
				newRow = [str(timestamp),2,row[5]]
				writer.writerow(newRow)
				newRow = [str(timestamp),3,row[6]]
				writer.writerow(newRow)
			else:
				newRow = [str(timestamp),2,row[4]]
				writer.writerow(newRow)
				newRow = [str(timestamp),3,row[5]]
				writer.writerow(newRow)

		print "Successfully created " + outputFile.name


#----------------#
# Body of script #
#----------------#

fileNames = getFileNames(".txt")
targetDir = "/usr/local/smb-share/1.Projects/1.6.Maui Smart Grid/NREL_irradiance_clean_data/"
cleanFiles(fileNames, targetDir)

os.chdir(targetDir)
cols = ['timestamp', 'sensor_id', 'irradiance_w_per_m2']
fileNames = getFileNames(".txt")
insertData(fileNames, "IrradianceData", cols)