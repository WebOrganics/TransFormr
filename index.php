<?php
 //* require Transformr class
require_once 'app/transformr.php';

 //* Start new Transformr
$transformer = new Transformr;

 //* Transform url
$transformer->transform($url, $xsl_filename);
?>