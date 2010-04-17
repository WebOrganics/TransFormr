<?php
 # require Transformr class
require_once 'app/Transformr.php';

 # Start new Transformr
$transformer = new Transformr;

 # Transform url
print $transformer->transform();
?>