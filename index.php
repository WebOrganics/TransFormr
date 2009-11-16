<?php
 //* require Transformr class
require_once('app/transformr.php');
 
 //* initiate Transformr
Transformr::init();

 //* Include types
include FORMAT."types.php";

 //* Start new Transformr
$transformer = new Transformr();

 //* Transform url
$transformer->transform(URL, $xsl_filename);

 //* Done
?>