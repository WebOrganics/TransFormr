<?php
 //* require Transformr class
require_once('app/transformr.php');

 //* Start new Transformr
$transformer = new Transformr;

 //* initiate Transformr
$transformer->init();

 //* Include types
require_once(FORMAT."types.php");

 //* Transform url
$transformer->transform(URL, $xsl_filename);
?>