<?php
defined( '_Transformr' ) or die( 'Restricted access' );

/* Database configuration for storing RDF triples: */

$host = 'localhost';
$user = 'username';
$pwd = 'password';
$name = 'database name';

/* try not to edit below here :) */

!method_exists('ARC2','getStoreEndpoint') ? include_once('arc/ARC2.php') : '';

$ns = array(
	'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
	'rdfs' => 'http://www.w3.org/2000/01/rdf-schema#',
	'owl' => 'http://www.w3.org/2002/07/owl#',
	'xsd' => 'http://www.w3.org/2001/XMLSchema#',
	'foaf' => 'http://xmlns.com/foaf/0.1/',
	'dc' => 'http://purl.org/dc/elements/1.1/',
	'dc_terms' => 'http://purl.org/dc/terms/',
	'dc_type' => 'http://purl.org/dc/dcmitype/',
	'rss' => 'http://purl.org/rss/1.0/',
	'taxo' => 'http://purl.org/rss/1.0/modules/taxonomy/',
	'content' => 'http://purl.org/rss/1.0/modules/content/',
	'sy' => 'http://purl.org/rss/1.0/modules/syndication/',
	'cal' => 'http://www.w3.org/2002/12/cal/ical#',
	'sioc' => 'http://rdfs.org/sioc/ns#',
	'sioct' => 'http://rdfs.org/sioc/types#',
	'doap' => 'http://usefulinc.com/ns/doap#',
	'gr' => 'http://purl.org/goodrelations/v1#',
	'geo' => 'http://www.w3.org/2003/01/geo/wgs84_pos#',
	'gv' => 'http://data-vocabulary.org/',
	'wot' => 'http://xmlns.com/wot/0.1/',
	'mo' => 'http://purl.org/ontology/mo/',
	'frbr' => 'http://purl.org/vocab/frbr/core#',
	'vs' => 'http://www.w3.org/2003/06/sw-vocab-status/ns#',
	'tl' => 'http://purl.org/NET/c4dm/timeline.owl#',
	'time' => 'http://www.w3.org/2006/time#',
	'contact' => 'http://www.w3.org/2000/10/swap/pim/contact#',
	'bio' => 'http://purl.org/vocab/bio/0.1/',
	'rel' => 'http://purl.org/vocab/relationship/',
	'rev' => 'http://purl.org/stuff/rev#',
	'voc' => 'http://webns.net/mvcb/',
	'air' => 'http://www.daml.org/2001/10/html/airport-ont#',
	'aff' => 'http://purl.org/vocab/affiliations/0.1/',
	'cc' => 'http://creativecommons.org/ns#',
	'money' => 'http://www.purl.org/net/rdf-money/',
	'media' => 'http://purl.org/microformat/hmedia/',
	'audio' => 'http://purl.org/net/haudio#',
	'xhv' => 'http://www.w3.org/1999/xhtml/vocab#',
	'xfn' => 'http://gmpg.org/xfn/11#',
	'dbp' => ' http://dbpedia.org/property/',
	'dbpr' => 'http://dbpedia.org/resource/',
	'talk' => 'http://www.w3.org/2004/08/Presentations.owl#',
	'doc' => 'http://www.w3.org/2000/10/swap/pim/doc#',
	'act' => 'http://www.w3.org/2001/sw/',
	'org' => 'http://www.w3.org/ns/org#',
	'vc' => 'http://www.w3.org/2001/vcard-rdf/3.0#',
	'vcard' => 'http://www.w3.org/2006/vcard/ns#',
	'bibo' => 'http://purl.org/ontology/bibo/',
	'mf' => 'http://poshrdf.org/ns/mf#',
	'posh' => 'http://poshrdf.org/ns/posh/',
	'label' => 'http://www.w3.org/2004/12/q/contentlabel#',
	'icra' => 'http://www.icra.org/rdfs/vocabularyv03#',
	'uri' => 'http://www.w3.org/2006/uri#',
	'ogp' => 'http://opengraphprotocol.org/schema/',
	'fb' => 'http://developers.facebook.com/schema/',
	'awol' => 'http://purl.org/stuff/Atom#',
	'geoname' => 'http://www.geonames.org/ontology/',
	'rsa' => 'http://www.w3.org/ns/auth/rsa#',
	'cert' => 'http://www.w3.org/ns/auth/cert#',
	'vann' => 'http://purl.org/vocab/vann/' 
);
?>
