<?php
###############################
## ResourceSpace
## Local Configuration Script
###############################

# All custom settings should be entered in this file.
# Options may be copied from config.default.php and configured here.

# MySQL database settings
$mysql_server = 'localhost';
$mysql_username = 'mediendatenbank';
$mysql_password = 'MeDi84.Um';
$mysql_db = 'mediendatenbank';

$mysql_bin_path = '/usr/bin';

# Base URL of the installation
$baseurl = 'http://192.168.2.26/mediendatenbank';

# Email settings
$email_from = 'mediendatenbank@dge.de';
$email_notify = 'it@dge.de';

$spider_password = 'YVe6yHAWEgez';
$scramble_key = 'u4A4eTumYju4';

$api_scramble_key = 'uGydALYPYQuR';

# Paths
$imagemagick_path = '/usr/bin';
$ghostscript_path = '/usr/bin';
$ffmpeg_path = '/usr/bin';
$exiftool_path = '/usr/bin';
$antiword_path = '/usr/bin';
$pdftotext_path = '/usr/bin';

$enable_remote_apis = true;
$research_request = true;
$defaultlanguage = 'de';
$applicationname = 'Mediendatenbank';
$ftp_server = 'my.ftp.server';
$ftp_username = 'my_username';
$ftp_password = 'my_password';
$ftp_defaultfolder = 'temp/';
$thumbs_display_fields = array(8,3);
$list_display_fields = array(8,3,12);
$sort_fields = array(12);
