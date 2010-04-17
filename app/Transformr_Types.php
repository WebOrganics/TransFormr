<?php
if (TYPE) 
{ 
	header("Cache-Control: no-cache, must-revalidate");
	header("Expires: -1");
}

$url = URL;
$arc2_parse = false;

switch(TYPE)
{
case 'hcard':
header("Content-type: text/x-vcard");
header('Content-Disposition: attachment; filename="hCard.vcf"');
$xsl_filename = XSL."xhtml2vcard.xsl";
break;

case 'hcard-rdf':
header("Content-type: application/rdf+xml");
header('Content-Disposition: inline; filename="vCard.rdf"');
$xsl_filename = XSL."hcard2rdf.xsl";
$arc2_parse = true;
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
header('Content-Disposition: inline; filename="vCal.rdf"');
$xsl_filename = XSL."glean-hcal.xsl";
$arc2_parse = true;
break;

case 'hreview':
header("Content-type: application/rdf+xml");
header('Content-Disposition: inline; filename="hReview.rdf"');
$xsl_filename = XSL."hreview2rdfxml.xsl";
$arc2_parse = true;
break;

case 'haudio-rss':
header("Content-type: application/xml");
$xsl_filename = XSL."hAudioRSS2.xsl";
break;

case 'mo-haudio':
header('Content-type: application/rdf+xml');
header('Content-Disposition: inline; filename="MoAudio.rdf"');
$xsl_filename = XSL."Mo-hAudio.xsl";
$arc2_parse = true;
break;

case 'haudio-xspf':
header('Content-type: application/xspf+xml');
header('Content-Disposition: attachment; filename="haudio-xspf.xspf"');
$xsl_filename = XSL."hAudioXSPF.xsl";
break;

case 'hfoaf':
header('Content-type: application/rdf+xml');
header('Content-Disposition: inline; filename="hFoaF.rdf"');
$xsl_filename = XSL."hFoaF.xsl";
$arc2_parse = true;
break;

case 'rdfa':
header('Content-type: application/rdf+xml');
header('Content-Disposition: inline; filename="RDFa.rdf"');
$xsl_filename = XSL."RDFa2RDFXML.xsl";
$arc2_parse = true;
break;

case 'mrss':
header("Content-type: application/rss+xml");
$xsl_filename = XSL."mrss.xsl";
break;

case 'RDF-3T':
header("Content-type: application/rdf+xml");
header('Content-Disposition: inline; filename="RDF-3T.rdf"');
$xsl_filename = XSL."RDF-3T.xsl";
$arc2_parse = true;
break;

case 'erdf':
header("Content-type: application/rdf+xml");
header('Content-Disposition: inline; filename="erdf.rdf"');
$xsl_filename = XSL."extract-rdf.xsl";
$arc2_parse = true;
break;

case 'detect':
$xsl_filename = XSL."detect-uf.xsl";
break;

case 'dataset':
$xsl_filename = "dataset";
break;

default:
header("Content-Type: text/html; charset=UTF-8");
include TEMPLATE."head.php";
include TEMPLATE."content.php";
include TEMPLATE."foot.php";
break;
}
?>