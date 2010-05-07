<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
 xmlns:xsl ="http://www.w3.org/1999/XSL/Transform"
 xmlns:mf  ="http://suda.co.uk/projects/microformats/mf-templates.xsl?template="
 xmlns     ="http://www.opml.org/spec"
 exclude-result-prefixes="mf"
 version="1.0"
>

<!-- i have saved the file locally to conserve bandwidth, always check for updateds -->
<xsl:import href="mf-templates.xsl" />

<xsl:output
  encoding="UTF-8"
  indent="yes"
  media-type="application/opml+xml"
  method="xml"
/>

<!--
brian suda
brian@suda.co.uk
http://suda.co.uk/

XOXO-2-OPML
Version 0.2.1
2007-07-01

Copyright 2006 Brian Suda
This work is relicensed under The W3C Open Source License
http://www.w3.org/Consortium/Legal/copyright-software-19980720

@@ check for profile in head element
-->

<xsl:param name="url" select="''"/>

<xsl:param name="Source" select="$url"/>

<xsl:param name="Anchor" />

<xsl:template match="/">	
<opml version="1.0">
	<head>
		<title><xsl:value-of select="normalize-space(//*[name() = 'title'])" /></title>
	</head>
	<body>
	<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and descendant-or-self::*[name() = 'ul' or name() = 'ol'] = true() and contains(concat(' ',normalize-space(@class),' '),' xoxo ')]">
		<xsl:if test="not($Anchor) or ancestor-or-self::*[@id = $Anchor]">
			<xsl:element name="outline" namespace="http://www.opml.org/spec">
		
			<xsl:if test="@title">
				<xsl:attribute name="text">
					<xsl:value-of select="normalize-space(@title)"/>
				</xsl:attribute>
				<xsl:attribute name="title">
					<xsl:value-of select="normalize-space(@title)"/>
				</xsl:attribute>
			</xsl:if>
				
			<xsl:for-each select="*[local-name() = 'li']">			
				<xsl:call-template name="outline-item"/>
			</xsl:for-each>
			</xsl:element>
		</xsl:if>
	</xsl:for-each>
	</body>
</opml>
</xsl:template>

<xsl:template name="outline-item">	

	<xsl:for-each select="*">
		<xsl:if test="local-name() = 'a'">
		<xsl:element name="outline" namespace="http://www.opml.org/spec">
			<xsl:attribute name="xmlURL">
				<xsl:call-template name="mf:extractUrl">
					<xsl:with-param name="Source"><xsl:value-of select="$Source"/></xsl:with-param>
				</xsl:call-template>
			</xsl:attribute>
		
			<xsl:attribute name="text">
				<xsl:value-of select="normalize-space(text())"/>
			</xsl:attribute>

			<xsl:if test="@type">
				<xsl:attribute name="type">
					<xsl:value-of select="normalize-space(@type)"/>
				</xsl:attribute>
			</xsl:if>

			<xsl:if test="@title">
				<xsl:attribute name="title">
					<xsl:value-of select="normalize-space(@title)"/>
				</xsl:attribute>
			</xsl:if>
			
			<xsl:for-each select="following-sibling::*[name() = 'dl']/dt">
				<xsl:attribute name="{text()}"><xsl:value-of select="following-sibling::dd/text()"/></xsl:attribute>
			</xsl:for-each>
		</xsl:element>
		</xsl:if>
		<xsl:if test="local-name() = 'ul' or local-name() = 'ol'">
			<xsl:for-each select="*[local-name() = 'li']">			
				<xsl:call-template name="outline-item"/>
			</xsl:for-each>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<xsl:template match="comment()"></xsl:template>

<!-- don't pass text thru -->
<xsl:template match="text()"></xsl:template>
</xsl:stylesheet>
