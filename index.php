<?php
/* require Transformr class */
require_once 'app/Transformr.php';

/* Start new Transformr */
$transformer = new Transformr;

/* Application settings please also edit /app/config.php to set MySql user, pass, host and database name */
$settings = array(
	/* pick one. php, online or dom */
	'tidy_option' => 'php',
	/* Admin email address ( used in remote access.log and error.log if transformr behaves badly when geting a url )  */
	'admin' => 'admin@email.com',
	/* 0 to disable ARC2 store */
	'use_store' => 1,
	/* 1 to reset ARC2 database tables ( stores only the last result ) */
	'reset_tables' => 0, 
	/* set store size (in MB) to schedule data dumps */
	'store_size' => '99.00',  
	/* location of store dump folder must be writable by webserver */
	'dump_location' => 'dump/',
	/* backup type for store dumps, pick one turtle, rdf, ntriples or leave empty for sparql result format (xml)*/
	'backup_type' => 'turtle',
	/* ttl (time to live) How long to cache a webpage on the server in seconds 300 = 5mins. */
	'ttl' => 300
);

/*  Transform */
print $transformer->transform($settings);
?>