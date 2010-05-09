<?php
/* require Transformr class */
require_once 'app/Transformr.php';

/* Start new Transformr */
$transformer = new Transformr;

/* tidy is used to convert html documents to xhtml, the choices are 'php' to use the servers php tidy function ( if installed ) or 'online' for the w3c online tidy service. */
   
$transformer->tidy_option = 'php';

/* comment out the line below '#' to use file get contents instead of curl */

$transformer->use_curl = 1;

/* uncomment line below to print transformr errors ( including html errors ) to screen default 0 */

# $transformer->debug = 1;

/*  Transform */
print $transformer->transform();
?>