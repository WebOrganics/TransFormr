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
	/* 1 to reset ARC2 database tables ( stores only the last result ) */
	'reset_tables' => 0, 
	/* set store size (in MB) to schedule data dumps 1mb = 1000 triples (aprox) */
	'store_size' => '99.00',  
	/* location of store dump folder must be writable by webserver */
	'dump_location' => 'dump/',
	/* backup type for store dumps, pick one turtle, rdf, ntriples or leave empty for sparql result format (xml)*/
	'backup_type' => 'turtle'
);

/*  Transform */
print $transformer->transform($settings);
?>