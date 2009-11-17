<?php
if (TYPE) { 
	header("Cache-Control: no-cache, must-revalidate");
	header("Expires: -1");
}
switch(TYPE)
{
case 'hcard':
header("Content-type: text/x-vcard");
header('Content-Disposition: attachment; filename="hCard.vcf"');
$xsl_filename = XSL."xhtml2vcard.xsl";
break;

case 'hcard-rdf':
header("Content-type: application/rdf+xml");
header('Content-Disposition: attachment; filename="vCard.rdf"');
$xsl_filename = XSL."hcard2rdf.xsl";
break;

case 'hatom':
header("Content-type: application/xml");
$xsl_filename = XSL."hAtom2Atom.xsl";
break;

case 'rss2':
header("Content-type: application/rss+xml");
$xsl_filename = XSL."hAtom2RSS2.xsl";
break;

case 'geo':
header("Content-type: application/vnd.google-earth.kml+xml");
header('Content-Disposition: attachment; filename="Geo.kml"');
$xsl_filename = XSL."xhtml2kml.xsl";
break;

case 'hcalendar':
header("Content-type: text/x-vcalendar");
header('Content-Disposition: attachment; filename="hCal.ics"');
$xsl_filename = XSL."xhtml2vcal.xsl";
break;

case 'hcalendar-rdf':
header("Content-type: application/rdf+xml");
header('Content-Disposition: attachment; filename="vCal.rdf"');
$xsl_filename = XSL."glean-hcal.xsl";
break;

case 'hreview':
header("Content-type: application/rdf+xml");
header('Content-Disposition: attachment; filename="hReview.rdf"');
$xsl_filename = XSL."hreview2rdfxml.xsl";
break;

case 'haudio-rss2':
header("Content-type: application/xml");
$xsl_filename = XSL."hAudioRSS2.xsl";
break;

case 'mo-haudio':
header('Content-type: application/rdf+xml');
header('Content-Disposition: attachment; filename="MoAudio.rdf"');
$xsl_filename = XSL."Mo-hAudio.xsl";
break;

case 'hfoaf':
header('Content-type: application/rdf+xml');
header('Content-Disposition: attachment; filename="hFoaF.rdf"');
$xsl_filename = XSL."hFoaF.xsl";
break;

case 'rdfa2rdfxml':
header('Content-type: application/rdf+xml');
header('Content-Disposition: attachment; filename="RDFa.rdf"');
$xsl_filename = XSL."RDFa2RDFXML.xsl";
break;

case 'mrss':
header("Content-type: application/rss+xml");
$xsl_filename = XSL."mrss.xsl";
break;

case 'RDF-3T':
header("Content-type: application/rdf+xml");
header('Content-Disposition: attachment; filename="RDF-3T.rdf"');
$xsl_filename = XSL."RDF-3T.xsl";
break;

case 'detect':
$xsl_filename = XSL."detect-uf.xsl";
break;

default:
header("Content-Type: text/html; charset=UTF-8");
include TEMPLATE."head.php";
include TEMPLATE."content.php";
include TEMPLATE."foot.php";
break;
}
?>