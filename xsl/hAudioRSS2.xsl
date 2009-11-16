<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
   		xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
		exclude-result-prefixes="xhtml"
                version="1.0">

<xsl:strip-space elements="*"/>

<xsl:output method="xml" 
		   indent="yes" 
		   encoding="UTF-8" 
		   media-type="application/xml"/>

<!-- hAudio 2 RSS2 *Stable* by Martin McEvoy $version 4.2 updated Saturday, November 22 2008 16:27 +0100 $contact info@weborganics.co.uk-->

<!-- base of the current HTML doc set by Processor-->
<xsl:param name="base-uri" select="''"/>

<!-- No date found set by Processor-->
<xsl:param name="date" select="''"/>

<xsl:param name="start" select=".//*[contains(concat(' ',normalize-space(@class),' '),' haudio ') and .//*[contains(concat(' ',normalize-space(@class),' '),' item ')]]"/>

<xsl:param name="index">
<xsl:choose>
  <xsl:when test="$start">
		<xsl:value-of select=".//*[contains(concat(' ',normalize-space(@class),' '),' fn ')]/a/@href" />
	</xsl:when>
    	<xsl:otherwise>
		<xsl:value-of select="$base-uri" />
    	</xsl:otherwise>
</xsl:choose>
</xsl:param>

<xsl:template match="/">

<rss xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/" version="2.0">
<channel>
    	<xsl:apply-templates/>
	<xsl:call-template name="item"/>
</channel>
</rss>
 </xsl:template>


<!-- ==============================================Channel===============================================-->
<xsl:template match="html">
<xsl:variable name="description" select=".//*[contains(concat(' ',normalize-space(@class),' '),' description ')]"/>
<xsl:variable name="published" select=".//*[contains(concat(' ',normalize-space(@class),' '),' published ')]"/>
<title><xsl:value-of select="//*[name() = 'title']"/></title>
<link><xsl:value-of select="$index"/></link>
 <xsl:if test="$published">
	<pubDate><xsl:value-of select="$published/@title" /></pubDate>
</xsl:if>
<xsl:choose>
     	<xsl:when test="$description">
			<description>
				<xsl:value-of select="$description" />
			</description>
		</xsl:when>
    	<xsl:otherwise>
			<description>
				<xsl:value-of select="$index" />
			</description>
    	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- ==============================================Item===============================================-->
<xsl:template name="item">
<xsl:variable name="hasItem" select=".//*[contains(concat(' ',normalize-space(@class),' '),' item ') and .//*[contains(concat(' ',normalize-space(@class),' '),' fn ')]]"/>
<xsl:variable name="hasAudio" select=".//*[contains(concat(' ',normalize-space(@class),' '),' haudio ') and .//*[contains(concat(' ',normalize-space(@class),' '),' fn ')]]"/>
<xsl:choose>
     	<xsl:when test="$hasItem">
  		<xsl:for-each select="$hasItem">
			<xsl:call-template name="getValues"/>
   		</xsl:for-each>
	</xsl:when>
    	<xsl:otherwise>
  		<xsl:for-each select="$hasAudio">
			<xsl:call-template name="getValues"/>
   		</xsl:for-each>
    	</xsl:otherwise>
</xsl:choose>
</xsl:template>


<!-- ==============================================Title===============================================-->
<xsl:template name="getValues">
	<xsl:element name='item'>
		<xsl:call-template name="title"/>
		<xsl:call-template name="link"/>
		<xsl:call-template name="pubDate"/>
		<xsl:call-template name="author"/>
		<xsl:call-template name="itemDescription"/>
		<xsl:call-template name="enclosure"/>
		<xsl:call-template name="duration"/>
		<xsl:call-template name="keywords"/>
	</xsl:element>
</xsl:template>

<!-- ==============================================Title===============================================-->
<xsl:template name="title">
<xsl:variable name="title" select=".//*[contains(concat(' ',normalize-space(@class),' '),' fn ') and not(ancestor::*[contains(concat(' ',normalize-space(attribute::class),' '),' vcard ')])]"/>
<xsl:variable name="titleold" select=".//*[contains(concat(' ',normalize-space(@class),' '),' title ')]"/>
<xsl:variable name="artist-name" select=".//*[contains(concat(' ',normalize-space(@class),' '),' contributor ')]"/>
<xsl:choose>
     <xsl:when test="$title">
        <xsl:element name='title'>
		<xsl:if test="$artist-name">
			 <xsl:value-of select="$artist-name"/>
			 <xsl:text>: </xsl:text>
		</xsl:if>
            <xsl:value-of select="$title"/>
        </xsl:element>
    </xsl:when>
     <xsl:when test="$titleold">
	 	<xsl:if test="$artist-name">
			 <xsl:value-of select="$artist-name"/>
			 <xsl:text>: </xsl:text>
		</xsl:if>
        <xsl:element name='title'>
            <xsl:value-of select="$titleold"/>
        </xsl:element>
    </xsl:when>
</xsl:choose>
</xsl:template>

<!-- ==============================================Title@href===============================================-->
<xsl:template name="link">
<xsl:variable name="href" select=".//*[name() = 'a']/attribute::href"/>
<xsl:variable name="titlehref" select=".//*[contains(concat(' ',normalize-space(@class),' '),' fn ') and not(ancestor::*[contains(concat(' ',normalize-space(attribute::class),' '),' vcard ')])]/@href"/>
<xsl:choose>
	<xsl:when test="$titlehref">
		<xsl:element name='link'>
			<xsl:value-of select="$titlehref"/>
		</xsl:element>
		<xsl:element name='guid'>
  			<xsl:attribute name='isPermaLink'>
				<xsl:text>true</xsl:text>
			</xsl:attribute>
			<xsl:value-of select="$titlehref"/>
		</xsl:element>
	</xsl:when>
	<xsl:otherwise>
	<xsl:if test="$href">
		<xsl:element name='link'>
			<xsl:value-of select="$href"/>
		</xsl:element>
		<xsl:element name='guid'>
  			<xsl:attribute name='isPermaLink'>
				<xsl:text>true</xsl:text>
			</xsl:attribute>
			<xsl:value-of select="$href"/>
		</xsl:element>
	</xsl:if>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- ==============================================Published===============================================-->
<xsl:template name="pubDate">
<xsl:variable name="published" select=".//*[contains(concat(' ',normalize-space(@class),' '),' published ')]"/>
<xsl:variable name="xsdDate" select=".//*[contains(concat(' ',normalize-space(@datatype),' '),' xsd:dateTime ')]"/>
	<xsl:if test="$published|$xsdDate">
		<xsl:element name='pubDate'>
			<xsl:value-of select="$published/@title|$xsdDate/@content"/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- ==============================================Contributor===============================================-->
<xsl:template name="author">
<xsl:variable name="name" select=".//*[contains(concat(' ',normalize-space(@class),' '),' contributor ')]"/>
<xsl:variable name="fallback" select="/*//*[contains(concat(' ',normalize-space(@class),' '),' contributor ')][1]"/>
<xsl:choose>
     <xsl:when test="$name">
		<xsl:element name='itunes:author'>
			<xsl:value-of select="$name"/>
		</xsl:element>
	</xsl:when>
    	<xsl:otherwise>
	<xsl:if test="$fallback">
		<xsl:element name='itunes:author'>
			<xsl:value-of select="$fallback"/>
		</xsl:element>
	</xsl:if>
    	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- ==============================================Description===============================================-->
<xsl:template name="itemDescription">
<xsl:variable name="itemDesc" select=".//*[contains(concat(' ',normalize-space(@class),' '),' description ')]"/>
<xsl:variable name="img" select=".//*[contains(concat(' ',normalize-space(attribute::class),' '),' photo ') and not(ancestor::*[contains(concat(' ',normalize-space(attribute::class),' '),' description ')])]"/>
	<xsl:if test="$itemDesc|$img">
		<xsl:element name='description'>
		     <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
				<xsl:copy-of select="$img"/>
				<xsl:copy-of select="$itemDesc"/>
		     <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- ==============================================Enclosure===============================================-->
<xsl:template name="enclosure">
<xsl:variable name="enc" select=".//*[contains(concat(' ',normalize-space(@rel),' '),' enclosure ')]"/>
<xsl:variable name="length" select=".//*[contains(concat(' ',normalize-space(@class),' '),' length ')]"/>
	<xsl:if test="$enc">
		<xsl:element name='enclosure'>
  			<xsl:attribute name='url'>
				<xsl:value-of select="$enc/@href"/>
			</xsl:attribute>
  			<xsl:attribute name='type'>
				<xsl:value-of select="$enc/@type"/>
			</xsl:attribute>
			<xsl:if test="$length">
  				<xsl:attribute name='length'>
					<xsl:value-of select="$length/@title"/>
				</xsl:attribute>
			</xsl:if>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- ==============================================Duration===============================================-->
<xsl:template name="duration">
<xsl:variable name="time" select=".//*[contains(concat(' ',normalize-space(@class),' '),' duration ')]"/>
<xsl:variable name="h" select=".//*[contains(concat(' ',normalize-space(@class),' '),' h ')]"/>
<xsl:variable name="min" select=".//*[contains(concat(' ',normalize-space(@class),' '),' min ')]"/>
<xsl:variable name="s" select=".//*[contains(concat(' ',normalize-space(@class),' '),' s ')]"/>
	<xsl:for-each select="$time">
		<xsl:element name='itunes:duration'>
		<xsl:choose>
        <xsl:when test="$h|$min|$s">
        	<xsl:if test="$h">
        	    <xsl:value-of select="$h"/>
        	</xsl:if>
        	<xsl:if test="$h and $min">
        	    <xsl:text>:</xsl:text>
        	</xsl:if>
        	<xsl:if test="$min">
        	    <xsl:value-of select="$min"/>
        	</xsl:if>
        	<xsl:if test="$min and $s">
        	    <xsl:text>:</xsl:text>
        	</xsl:if>
        	<xsl:if test="$s">
        	    <xsl:value-of select="$s"/>
        	</xsl:if>
        </xsl:when>
        <xsl:otherwise>
    	      <xsl:value-of select="$time"/>
        </xsl:otherwise>
    </xsl:choose>
		</xsl:element>
	</xsl:for-each>
</xsl:template>

<!-- ==============================================Tag===============================================-->
<xsl:template name="keywords">
<xsl:variable name="tag" select=".//*[contains(concat(' ',normalize-space(@rel),' '),' tag ')]"/>
	<xsl:if test="$tag">
		<xsl:element name='itunes:keywords'>
      			<xsl:for-each select="$tag">
        			<xsl:value-of select="$tag"/>
				<xsl:text disable-output-escaping="yes">,</xsl:text>
      			</xsl:for-each>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- strip text -->
<xsl:template match="text()"></xsl:template>
</xsl:stylesheet>
