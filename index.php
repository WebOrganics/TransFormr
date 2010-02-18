<?php
 //* require Transformr class
require_once('app/transformr.php');

 //* Start new Transformr
$transformer = new Transformr;

 //* initiate Transformr
$transformer->init();

 //* Include types
require_once(FORMAT."types.php");

if (TYPE == 'dataset') 
{
	//* require datasetParser class
	include( 'app/datasetParser.php' );
	echo HTMLQuery::this_document($url);
}
 //* Transform url
else $transformer->transform($url, $xsl_filename);
?>