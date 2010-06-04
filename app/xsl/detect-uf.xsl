<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:dc="http://purl.org/dc/elements/1.1/"
        version="1.0"
		exclude-result-prefixes="xhtml xs dc">

<xsl:import href="url-encode.xsl" />

<xsl:strip-space elements="*"/>

<xsl:param name="base-uri" select="''"/>

<xsl:param name="doc-title" select="''"/>

<xsl:param name="endpoint-link" select="''"/>

<xsl:param name="base-encoded">
	<xsl:call-template name="url-encode">
		<xsl:with-param name="str" select="$base-uri"/> 
	</xsl:call-template>
</xsl:param>

<xsl:param name="transformr" select="''"/>

<xsl:param name="title">
<xsl:choose>
	<xsl:when test=".//*[local-name() = 'title']">
		<xsl:value-of select=".//*[local-name() = 'title']" />
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="$doc-title" />
	</xsl:otherwise>
</xsl:choose>
</xsl:param>

<xsl:param name="hatom" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' hentry ')]"/>
<xsl:param name="hcard" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' vcard ')]"/>
<xsl:param name="hfoaf" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' vcard ') and descendant::*[contains(concat(' ',normalize-space(@rel),' '),' me ')]]"/>
<xsl:param name="geo" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' geo ')]"/>
<xsl:param name="haudio" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' haudio ')]"/>
<xsl:param name="hreview" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' hreview ')]"/>
<xsl:param name="vevent" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' vevent ')]"/>
<xsl:param name="rdfa" select="descendant::*/attribute::about|descendant::*/attribute::property"/>
<xsl:param name="xfn" select="descendant::*[contains(concat(' ',normalize-space(@profile),' '),' http://gmpg.org/xfn/11 ') or contains(concat(' ',normalize-space(@profile),' '),' http://gmpg.org/xfn/1 ')]"/>
<xsl:param name="erdf" select="descendant::*[contains(concat(' ',normalize-space(@profile),' '),' http://purl.org/NET/erdf/profile ')]"/>
<xsl:output 
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" encoding="utf-8"  media-type="text/html;charset=utf-8" method="xml" indent="yes"/>

<!-- ============================================================ -->

<xsl:template match="/">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
	<head profile="http://gmpg.org/xfn/11">
	<title>Microform.at Transformer - <xsl:value-of select="$title"/></title>
	<meta name="description" content="Microformats Transformer"/>
	<link rel="stylesheet" type="text/css" media="screen" href="{$transformr}stylesheets/user.css" />
<xsl:if test="$hfoaf">
  	<link type="application/rdf+xml" title="FOAF" href="{$transformr}hfoaf/{$base-uri}" rel="meta" />
</xsl:if>
<xsl:if test="$hatom">
	<link type="application/atom+xml" title="Atom" href="{$transformr}hatom/{$base-uri}" rel="alternate"/>
	<link type="application/rss+xml" title="RSS2" href="{$transformr}hatom-rss2/{$base-uri}" rel="alternate"/>
	<link type="application/rdf+xml" title="SIOC" href="{$transformr}hatom-sioc/{$base-uri}" rel="alternate"/>
</xsl:if>
<link rel="default-slice" type="application/x-hatom" href="{$transformr}detect/#content"/>
	</head>
<body>
<div class="butt">
	<small> 
		<a href="http://wiki.github.com/WebOrganics/TransFormr" rel="nofollow">Wiki</a> | 
		<a href="http://github.com/WebOrganics/TransFormr" rel="nofollow">Source</a> | 
		<a href="http://github.com/WebOrganics/TransFormr/issues" rel="nofollow">Issues</a> 
		<xsl:if test="$endpoint-link !=''">
			| <a href="{$endpoint-link}" title="Sparql Endpoint">Endpoint</a> |  
			<a href="{$transformr}?type=dump" title="Store Dumps">Store Dumps</a>    
		</xsl:if>
	</small> 
</div>
<div class="heading">
<h1>
	<a href="{$transformr}">
		<img style="border:0;" src="{$transformr}images/microformat.png" alt="Microformat TransFormer"/>
	</a>
</h1>
<q class="subtitle" cite="http://www.hp.com/hpinfo/execteam/speeches/fiorina/04openworld.html">The goal is to transform data into information and information into insight.</q>
</div>
<div class="hslice" id="content">
 <h2 class="entry-title">
   <xsl:value-of select="$title"/>
 </h2>
<div class="entry-content" style="margin-left:0px;text-align:left;">
<p>Source:
  <a rel="canonical" href="{$base-uri}">
    <xsl:value-of select="$base-uri"/>
  </a>
</p>

<p>Detected formats:</p>
	<xsl:call-template name="classes"/>
</div>
</div>

<div style="clear:both;margin-top:40px;">
<p>
	<strong>
		<a href="javascript:history.go(-1);">Go Back</a>
	</strong>
</p>
</div>
</body>
</html>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="classes">
<ul>
<xsl:if test="$hcard">
	<li><p>hCard <a href="{$transformr}?type=hcard&amp;url={$base-encoded}">vCard</a> | <a href="{$transformr}?type=hcard-rdf&amp;url={$base-encoded}">RDF</a> | <a href="{$transformr}?type=hcard2qrcode&amp;url={$base-encoded}">QRCode</a></p></li>
</xsl:if>
<xsl:if test="$hatom">
	<li><p>hAtom <a href="{$transformr}?type=hatom&amp;url={$base-encoded}">Atom</a> | <a href="{$transformr}?type=hatom-rss2&amp;url={$base-encoded}">RSS2</a> | <a href="{$transformr}?type=hatom-sioc&amp;url={$base-encoded}">RDF</a></p></li>
</xsl:if>
<xsl:if test="$hfoaf">
	<li><p>hFoaF <a href="{$transformr}?type=hfoaf&amp;url={$base-encoded}">RDF</a></p></li>
</xsl:if>
<xsl:if test="$geo">
	<li><p>Geo <a href="{$transformr}?type=geo&amp;url={$base-encoded}">KML</a></p></li>
</xsl:if>
<xsl:if test="$haudio">
	<li><p>hAudio <a href="{$transformr}?type=haudio-rss&amp;url={$base-encoded}">RSS2</a> | <a href="{$transformr}?type=haudio-xspf&amp;url={$base-encoded}">XSPF</a></p></li>
</xsl:if>
<xsl:if test="$hreview">
	<li><p>hReview <a href="{$transformr}?type=hreview&amp;url={$base-encoded}">RDF</a></p></li>
</xsl:if>
<xsl:if test="$vevent">
	<li><p>hCalendar <a href="{$transformr}?type=hcalendar&amp;url={$base-encoded}">vCal</a> | <a href="{$transformr}?type=hcalendar-rdf&amp;url={$base-encoded}">RDF</a></p></li>
</xsl:if>

<xsl:if test="$rdfa">
	<li><p>RDFa <a href="{$transformr}?type=rdfa&amp;url={$base-encoded}">RDF</a></p></li>
</xsl:if>
<xsl:if test="$erdf">
	<li><p>eRDF <a href="{$transformr}?type=erdf&amp;url={$base-encoded}">RDF</a></p></li>
</xsl:if>
</ul>
</xsl:template>

</xsl:stylesheet>
