<?php
if ($this->type) 
{ 
	header("Cache-Control: no-cache, must-revalidate");
	header("Expires: -1");
}
switch($this->type)
{
case 'hcard':
header("Content-type: text/x-vcard");
header('Content-Disposition: attachment; filename="hCard.vcf"');
$xsl_filename = $this->xsl ."xhtml2vcard.xsl";
break;

case 'hcard-rdf':
header("Content-type: application/rdf+xml");
header('Content-Disposition: inline; filename="vCard.rdf"');
$xsl_filename = $this->xsl ."hcard2rdf.xsl";
$this->arc2_parse = true;
break;

case 'hatom':
header("Content-type: application/xml");
$xsl_filename = $this->xsl ."hAtom2Atom.xsl";
break;

case 'rss2':
header("Content-type: application/rss+xml");
$xsl_filename = $this->xsl ."hAtom2RSS2.xsl";
break;

case 'geo':
header("Content-type: application/vnd.google-earth.kml+xml");
header('Content-Disposition: attachment; filename="Geo.kml"');
$xsl_filename = $this->xsl ."xhtml2kml.xsl";
break;

case 'hcalendar':
header("Content-type: text/x-vcalendar");
header('Content-Disposition: attachment; filename="hCal.ics"');
$xsl_filename = $this->xsl ."xhtml2vcal.xsl";
break;

case 'hcalendar-rdf':
header("Content-type: application/rdf+xml");
header('Content-Disposition: inline; filename="vCal.rdf"');
$xsl_filename = $this->xsl ."glean-hcal.xsl";
$this->arc2_parse = true;
break;

case 'hreview':
header("Content-type: application/rdf+xml");
header('Content-Disposition: inline; filename="hReview.rdf"');
$xsl_filename = $this->xsl ."hreview2rdfxml.xsl";
$this->arc2_parse = true;
break;

case 'haudio-rss':
header("Content-type: application/xml");
$xsl_filename = $this->xsl ."hAudioRSS2.xsl";
break;

case 'mo-haudio':
header('Content-type: application/rdf+xml');
header('Content-Disposition: inline; filename="MoAudio.rdf"');
$xsl_filename = $this->xsl ."Mo-hAudio.xsl";
$this->arc2_parse = true;
break;

case 'haudio-xspf':
header('Content-type: application/xspf+xml');
header('Content-Disposition: attachment; filename="haudio-xspf.xspf"');
$xsl_filename = $this->xsl ."hAudioXSPF.xsl";
break;

case 'hfoaf':
header('Content-type: application/rdf+xml');
header('Content-Disposition: inline; filename="hFoaF.rdf"');
$xsl_filename = $this->xsl ."hFoaF.xsl";
$this->arc2_parse = true;
break;

case 'mrss':
header("Content-type: application/rss+xml");
$xsl_filename = $this->xsl ."mrss.xsl";
break;

case 'RDF-3T':
header("Content-type: application/rdf+xml");
header('Content-Disposition: inline; filename="RDF-3T.rdf"');
$xsl_filename = $this->xsl ."RDF-3T.xsl";
$this->arc2_parse = true;
break;

case 'erdf':
header("Content-type: application/rdf+xml");
header('Content-Disposition: inline; filename="erdf.rdf"');
$xsl_filename = $this->xsl ."extract-rdf.xsl";
$this->arc2_parse = true;
break;

case 'rdfa':
header('Content-type: application/rdf+xml');
$this->arc2_parse = true;
break;

case 'microformats':
header('Content-type: application/rdf+xml');
$this->arc2_parse = true;
break;

case 'dataset':

break;

case 'detect':
$xsl_filename = $this->xsl ."detect-uf.xsl";
break;

default:
header("Content-Type: text/html; charset=UTF-8");
include $this->template ."head.php";
include $this->template ."content.php";
include $this->template ."foot.php";
break;
}
?>