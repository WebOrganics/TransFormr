<?php
/* require Transformr class */
require_once 'app/Transformr.php';

/* Start new Transformr */
$transformer = new Transformr;

/* settings please also edit /app/config.php to set MySql user, pass, host and database name */
$settings = array(
	/* pick one. php, online or dom */
	'tidy_option' => 'php',
	/* 0 to use file_get_contents */
	'use_curl' => 1,
	/* 0 to disable ARC2 store */
	'use_store' => 1,
	/* 1 to reset (delete) ARC2 database tables ( stores only the last result ) */
	'reset_tables' => 0, 
	/* set store size (in MB) to schedule data dumps */
	'store_size' => '99.00',  
	/* location of store dump folder must be writable by webserver */
	'dump_location' => 'dump/' 
);

/*  Transform */
print $transformer->transform($settings);
?>