<?xml version="1.0"?>
<xsl:stylesheet 
 xmlns:xsl ="http://www.w3.org/1999/XSL/Transform"
 xmlns:mf  ="http://suda.co.uk/projects/microformats/mf-templates.xsl?template="
 xmlns:uri ="http://www.w3.org/2000/07/uri43/uri.xsl?template="
 xmlns:common="http://exslt.org/common" 
 extension-element-prefixes="common"
 version="1.0"
>

<xsl:import href="mf-templates.xsl" />
<xsl:import href="uri.xsl" />

<xsl:output
  encoding="UTF-8"
  indent="no"
  media-type="text/calendar"
  method="text"
/>
<!--
brian suda
brian@suda.co.uk
http://suda.co.uk/

XHTML-2-iCal
Version 0.9.2.1
2007-09-04

Copyright 2005 Brian Suda
This work is relicensed under The W3C Open Source License
http://www.w3.org/Consortium/Legal/copyright-software-19980720


NOTES:
Until the hCal spec has been finalised this is a work in progress.
I'm not an XSLT expert, so there are no guarantees to quality of this code!

-->
<xsl:param name="Prodid">-//suda.co.uk//X2V 0.9.2.1 (BETA)//EN</xsl:param>
<xsl:param name="Source"><xsl:value-of select="$base-uri" /></xsl:param>
<xsl:param name="Anchor" />

<xsl:param name="Encoding" >UTF-8</xsl:param>
<xsl:variable name="nl"><xsl:text>
</xsl:text></xsl:variable>
<xsl:variable name="tb"><xsl:text>	</xsl:text></xsl:variable>


<xsl:template match="/">
	<xsl:text>BEGIN:VCALENDAR</xsl:text>
	<xsl:text>&#x0D;&#x0A;PRODID:</xsl:text><xsl:value-of select="$Prodid"/>
	<xsl:text>&#x0D;&#x0A;X-ORIGINAL-URL:</xsl:text><xsl:value-of select="normalize-space($Source)"/>
	<xsl:text>&#x0D;&#x0A;X-WR-CALNAME</xsl:text>
	<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/><xsl:text>:</xsl:text>
	<xsl:call-template name="escapeText">
		<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(//*[name() = 'title'])" /></xsl:with-param>
	</xsl:call-template>
	<xsl:text>&#x0D;&#x0A;VERSION:2.0</xsl:text>
	<xsl:text>&#x0D;&#x0A;METHOD:PUBLISH</xsl:text>	
	<xsl:apply-templates select="//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' vevent ')]"/>
	<!-- <xsl:apply-templates select="//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' vtodo ')]"/> -->
	<!-- <xsl:apply-templates select="//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' vfreebusy ')]"/> -->
	<xsl:text>&#x0D;&#x0A;END:VCALENDAR</xsl:text>
</xsl:template>

<!-- Add more templates as they are needed-->
<xsl:template match="*[contains(concat(' ',normalize-space(@class),' '),' vevent ')]">
	<xsl:if test="not($Anchor) or ancestor-or-self::*[@id = $Anchor]">
		<xsl:text>&#x0D;&#x0A;BEGIN:VEVENT</xsl:text>

		<xsl:call-template name="mf:doIncludes"/>
		<xsl:call-template name="properties"/>
		<xsl:text>&#x0D;&#x0A;END:VEVENT&#x0D;&#x0A;</xsl:text>
	</xsl:if>
</xsl:template>

<!-- Add more templates as they are needed-->
<xsl:template match="*[contains(concat(' ',normalize-space(@class),' '),' vtodo ')]">
	<xsl:if test="not($Anchor) or @id = $Anchor">
		<xsl:text>&#x0D;&#x0A;BEGIN:VTODO</xsl:text>
		<xsl:call-template name="mf:doIncludes"/>
		<xsl:call-template name="vtodoProperties"/>
		<xsl:text>&#x0D;&#x0A;END:VTODO&#x0D;&#x0A;</xsl:text>
	</xsl:if>
</xsl:template>

<!-- Add more templates as they are needed-->
<xsl:template match="*[contains(concat(' ',normalize-space(@class),' '),' vfreebusy ')]">
	<xsl:if test="not($Anchor) or @id = $Anchor">
		<xsl:text>&#x0D;&#x0A;BEGIN:VFREEBUSY</xsl:text>
		<xsl:call-template name="mf:doIncludes"/>
		<xsl:call-template name="vfreebusyProperties"/>
		<xsl:text>&#x0D;&#x0A;END:VFREEBUSY&#x0D;&#x0A;</xsl:text>
	</xsl:if>
</xsl:template>

<!--
<xsl:template name="vfreebusyProperties">
	<xsl:call-template name="textPropLang">
		<xsl:with-param name="label">CONTACT</xsl:with-param>
		<xsl:with-param name="class">contact</xsl:with-param>
	</xsl:call-template>
	
	<xsl:variable name="duration-val">
	  <xsl:call-template name="textProp">
	    <xsl:with-param name="class">duration</xsl:with-param>
	  </xsl:call-template>
	</xsl:variable>
	<xsl:if test="not($duration-val = '')">
	    <xsl:text>&#x0D;&#x0A;DURATION;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
	    <xsl:text>:</xsl:text>
		<xsl:value-of select="translate(normalize-space($duration-val),$lcase,$ucase)"/>
	</xsl:if>

	<xsl:call-template name="dateProp">
		<xsl:with-param name="label">DTSTART</xsl:with-param>
		<xsl:with-param name="class">dtstart</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="dateProp">
		<xsl:with-param name="label">DTEND</xsl:with-param>
		<xsl:with-param name="class">dtend</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="dateProp">
		<xsl:with-param name="label">DTSTAMP</xsl:with-param>
		<xsl:with-param name="class">dtstamp</xsl:with-param>
	</xsl:call-template>
	
	<xsl:call-template name="identifierProp">
		<xsl:with-param name="label">UID</xsl:with-param>
  		<xsl:with-param name="class">uid</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="identifierProp">
		<xsl:with-param name="label">URL</xsl:with-param>
  		<xsl:with-param name="class">url</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="personProp">
		<xsl:with-param name="label">ATTENDEE</xsl:with-param>
		<xsl:with-param name="class">attendee</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="personProp">
		<xsl:with-param name="label">ORGANIZER</xsl:with-param>
		<xsl:with-param name="class">organizer</xsl:with-param>
	</xsl:call-template>
	
	<xsl:call-template name="textPropLang">
		<xsl:with-param name="label">COMMENT</xsl:with-param>
		<xsl:with-param name="class">comment</xsl:with-param>
	</xsl:call-template>
	
	freebusy
	rstatus

</xsl:template>
-->

<xsl:template name="properties">	
	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' class ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;CLASS:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>
		
	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' comment ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;COMMENT</xsl:text>
			<xsl:call-template name="lang" />
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
		    <xsl:text>:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>
	
	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' description ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;DESCRIPTION</xsl:text>
			<xsl:call-template name="lang" />
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
		    <xsl:text>:</xsl:text>
		
			<xsl:variable name="textFormatted">
			<xsl:apply-templates select="." mode="unFormatText" />
			</xsl:variable>
			<xsl:value-of select="normalize-space($textFormatted)"/>
			<!--
			<xsl:call-template name="unFormatText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
			</xsl:call-template>
			-->
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' location ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;LOCATION</xsl:text>
			<xsl:call-template name="lang" />
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
		    <xsl:text>:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' summary ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;SUMMARY</xsl:text>
			<xsl:call-template name="lang" />
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
		    <xsl:text>:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' contact ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;CONTACT</xsl:text>
			<xsl:call-template name="lang" />
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
		    <xsl:text>:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' sequence ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;SEQUENCE:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' priority ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;PRIORITY:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>
	
	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' status ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;STATUS:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' transp ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;TRANSP:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>
	
	<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' uid ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;UID:</xsl:text>
			<xsl:call-template name="mf:extractUrl"/>				
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' url ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;URL:</xsl:text>
			<xsl:call-template name="mf:extractUrl">
				<xsl:with-param name="Source"><xsl:value-of select="$Source"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' duration ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;DURATION:</xsl:text>
			<xsl:call-template name="mf:toUpper">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' dtstart ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;DTSTART</xsl:text>
			<!-- TZID needs work! -->
			<!-- check for date-time -->
			<xsl:variable name="dtstart">
				<xsl:call-template name="mf:extractDate"/>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="string-length($dtstart) = 8">
					<xsl:text>;VALUE=DATE</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<!-- default -->
					<xsl:text>;VALUE=DATE-TIME</xsl:text>	
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="ancestor::*[@class='vevent']//*[not (name() = 'del') and contains(concat(' ',@class,' '),' tzid ')]" mode="tzid"/> 
		    <xsl:text>:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:value-of select="$dtstart"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' dtend ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;DTEND</xsl:text>
			<!-- TZID needs work! -->
			<!-- check for date-time -->
			<xsl:variable name="dtend">
				<xsl:call-template name="mf:extractDate"/>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="string-length($dtend) = 8">
					<xsl:text>;VALUE=DATE</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<!-- default -->
					<xsl:text>;VALUE=DATE-TIME</xsl:text>	
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="ancestor::*[@class='vevent']//*[not (name() = 'del') and contains(concat(' ',@class,' '),' tzid ')]" mode="tzid"/> 
		    <xsl:text>:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:value-of select="$dtend"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' dtstamp ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;DTSTAMP</xsl:text>
		    <xsl:text>:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractDate"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' last-modified ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;LAST-MODIFIED</xsl:text>
		    <xsl:text>:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractDate"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' created ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;CREATED</xsl:text>
		    <xsl:text>:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractDate"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' recurrence-id ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;RECURRENCE-ID</xsl:text>
		    <xsl:text>:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractDate"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<xsl:if test=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' category ')]">
		<xsl:text>&#x0D;&#x0A;CATEGORIES</xsl:text>
		<xsl:call-template name="lang" />
		<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
	    <xsl:text>:</xsl:text>
		
		<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' category ')]">
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractKeywords"/></xsl:with-param>
			</xsl:call-template>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:if>

	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' rdate ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;RDATE</xsl:text>
			<!-- TZID needs work! -->
			<xsl:apply-templates select="*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',@class,' '),' tzid ')]" mode="tzid"/>

			<xsl:variable name="rdate">
				<xsl:call-template name="mf:extractMultipleDate"/>
			</xsl:variable>
			<xsl:if test="contains($rdate,'/') = true()">
				<xsl:text>;VALUE=PERIOD</xsl:text>
			</xsl:if>
		    <xsl:text>:</xsl:text>
			<xsl:value-of select="$rdate"/>
		</xsl:if>
	</xsl:for-each>
	
	<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' exdate ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;EXDATE</xsl:text>
			<!-- TZID needs work! -->
			<xsl:apply-templates select="ancestor::*[@class='vevent']//*[not (name() = 'del') and contains(concat(' ',@class,' '),' tzid ')]" mode="tzid"/> 
		    <xsl:text>:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractMultipleDate"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>	

	<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' geo ')]">
		<xsl:text>&#x0D;&#x0D;&#x0A;GEO:</xsl:text>
		<xsl:variable name="geoData">
			<xsl:call-template name="mf:extractGeo"/>
		</xsl:variable>

		<xsl:value-of select="common:node-set($geoData)/latitude"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="common:node-set($geoData)/longitude"/>
	</xsl:for-each>
	
	<xsl:call-template name="personProp">
		<xsl:with-param name="label">ATTENDEE</xsl:with-param>
		<xsl:with-param name="class">attendee</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="personProp">
		<xsl:with-param name="label">ORGANIZER</xsl:with-param>
		<xsl:with-param name="class">organizer</xsl:with-param>
	</xsl:call-template>

	<!-- These are all unique: custom templates -->
	<xsl:apply-templates select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' related-to ')]" mode="related-to"/>
	<xsl:apply-templates select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' attach ')]" mode="attach"/>

	<!-- <xsl:apply-templates select=".//*[contains(concat(' ',normalize-space(@class),' '),' resources ')]" mode="resources"/> -->
	<!-- <xsl:apply-templates select=".//*[contains(concat(' ',normalize-space(@class),' '),' status ')]" mode="status"/> -->
	<!-- <xsl:apply-templates select=".//*[contains(concat(' ',normalize-space(@class),' '),' transp ')]" mode="transp"/> -->

	<!-- UNWRITTEN TEMPLATES -->
	<!--
		
	@@ - all the RRULE stuff!
	
	-->
</xsl:template>

<!--
<xsl:template name="vtodoProperties">
	<xsl:call-template name="textProp">
		<xsl:with-param name="label">CLASS</xsl:with-param>
		<xsl:with-param name="class">class</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="identifierProp">
		<xsl:with-param name="label">UID</xsl:with-param>
  		<xsl:with-param name="class">uid</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="identifierProp">
		<xsl:with-param name="label">URL</xsl:with-param>
  		<xsl:with-param name="class">url</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="textPropLang">
		<xsl:with-param name="label">DESCRIPTION</xsl:with-param>
		<xsl:with-param name="class">description</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="textPropLang">
		<xsl:with-param name="label">LOCATION</xsl:with-param>
		<xsl:with-param name="class">location</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="textPropLang">
		<xsl:with-param name="label">SUMMARY</xsl:with-param>
		<xsl:with-param name="class">summary</xsl:with-param>
	</xsl:call-template>
	
	<xsl:call-template name="textProp">
		<xsl:with-param name="label">SEQUENCE</xsl:with-param>
		<xsl:with-param name="class">sequence</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="textProp">
		<xsl:with-param name="label">PRIORITY</xsl:with-param>
		<xsl:with-param name="class">priority</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="textProp">
		<xsl:with-param name="label">STATUS</xsl:with-param>
		<xsl:with-param name="class">status</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="dateProp">
		<xsl:with-param name="label">DTSTART</xsl:with-param>
		<xsl:with-param name="class">dtstart</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="dateProp">
		<xsl:with-param name="label">DTSTAMP</xsl:with-param>
		<xsl:with-param name="class">dtstamp</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="dateProp">
		<xsl:with-param name="label">LAST-MODIFIED</xsl:with-param>
		<xsl:with-param name="class">last-modified</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="dateProp">
		<xsl:with-param name="label">CREATED</xsl:with-param>
		<xsl:with-param name="class">created</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="dateProp">
		<xsl:with-param name="label">COMPLETED</xsl:with-param>
		<xsl:with-param name="class">completed</xsl:with-param>
	</xsl:call-template>
	
	<xsl:call-template name="dateProp">
		<xsl:with-param name="label">DUE</xsl:with-param>
		<xsl:with-param name="class">due</xsl:with-param>
	</xsl:call-template>
	
	<xsl:variable name="duration-val">
	  <xsl:call-template name="textProp">
	    <xsl:with-param name="class">duration</xsl:with-param>
	  </xsl:call-template>
	</xsl:variable>
	<xsl:if test="not($duration-val = '')">
	    <xsl:text>&#x0D;&#x0A;DURATION;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
	    <xsl:text>:</xsl:text>
		<xsl:value-of select="translate(normalize-space($duration-val),$lcase,$ucase)"/>
	</xsl:if>
	
	<xsl:call-template name="textProp">
		<xsl:with-param name="label">PERCENT-COMPLETE</xsl:with-param>
		<xsl:with-param name="class">percent-complete</xsl:with-param>
	</xsl:call-template>
	
	<xsl:variable name="geo-elt" select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' geo ')]" />
	<xsl:if test="$geo-elt">
			<xsl:call-template name="geo-prop"/>
	</xsl:if>
	
	<xsl:call-template name="personProp">
		<xsl:with-param name="label">ORGANIZER</xsl:with-param>
		<xsl:with-param name="class">organizer</xsl:with-param>
	</xsl:call-template>
		
	<xsl:call-template name="textPropLang">
		<xsl:with-param name="label">COMMENT</xsl:with-param>
		<xsl:with-param name="class">comment</xsl:with-param>
	</xsl:call-template>
	
	<xsl:call-template name="personProp">
		<xsl:with-param name="label">ATTENDEE</xsl:with-param>
		<xsl:with-param name="class">attendee</xsl:with-param>
	</xsl:call-template>
	
	<xsl:call-template name="multiTextPropLang">
		<xsl:with-param name="label">CATEGORIES</xsl:with-param>
		<xsl:with-param name="class">category</xsl:with-param>
	</xsl:call-template>
	
	<xsl:call-template name="textPropLang">
		<xsl:with-param name="label">CONTACT</xsl:with-param>
		<xsl:with-param name="class">contact</xsl:with-param>
	</xsl:call-template>
	
	<xsl:apply-templates select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' related-to ')]" mode="related-to"/>
	<xsl:apply-templates select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' attach ')]" mode="attach"/>
	<xsl:apply-templates select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' rdate ')]" mode="rdate"/>
	<xsl:apply-templates select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' exdate ')]" mode="exdate"/>
	
	
    exrule / rstatus  / resources / rrule
	
	
</xsl:template>
-->

<!-- Person Property (Attendee / Organizer) -->
<xsl:template name="personProp">
	<xsl:param name="label" />
	<xsl:param name="class" />

	<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', @class, ' '),concat(' ', $class, ' '))]">
    <!-- @@ "the first descendant element with that class should take
         effect, any others being ignored." -->
        <xsl:text>&#x0D;&#x0A;</xsl:text>
		<xsl:value-of select="$label" />
    	<!--<xsl:call-template name="lang" />-->
        <xsl:text>:</xsl:text>
		
		
		<!-- @@ get all the possible parameters -->
		<xsl:text>MAILTO:</xsl:text>
		<xsl:choose>
			<xsl:when test="@href != ''">
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(substring-after(@href,':'))" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="@longdesc != ''">
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="@alt != ''">
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="@title != ''">
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:template>


<!-- working templates -->
<xsl:template match="*[contains(@class,'tzid')]" mode="tzid">
<xsl:text>;TZID=</xsl:text>
<xsl:choose>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- RELATED-TO property -->
<xsl:template match="*[contains(@class,'related-to')]" mode="related-to">
<xsl:text>
RELATED-TO</xsl:text>
<xsl:if test="@rel != ''">
<xsl:text>;</xsl:text><xsl:value-of select="@rel"/>
</xsl:if>
<xsl:text>:</xsl:text>
<xsl:choose>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- ATTACH property -->
<xsl:template match="*[contains(@class,'attach')]" mode="attach">
<xsl:text>
ATTACH</xsl:text>

<xsl:choose>
	<xsl:when test="@href != ''">
		<xsl:if test="@type">
			<xsl:text>;FMTTYPE=</xsl:text><xsl:value-of select="@type"/>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="substring-before(@href,':') = 'http'">
				<xsl:text>:</xsl:text><xsl:value-of select="@href" />
			</xsl:when>
			<xsl:when test="substring-before(@href,':') = 'data'">
				<xsl:text>;ENCODING=BASE64;VALUE=BINARY:</xsl:text><xsl:value-of select="substring-after(@src,',')"/>
			</xsl:when>
			<xsl:when test="@href != ''">
				<!-- probably need to make this absolute ONLY if no other protocol -->
				<xsl:text>:</xsl:text>
				<xsl:value-of select="@href"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>:</xsl:text><xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:when test="@src != ''">
		<xsl:choose>
			<xsl:when test="substring-before(@src,':') = 'http'">
				<xsl:text>:</xsl:text><xsl:value-of select="@src" />
			</xsl:when>
			<xsl:when test="substring-before(@src,':') = 'data'">
				<xsl:text>ENCODING=BASE64;VALUE=BINARY:</xsl:text><xsl:value-of select="substring-after(@src,',')"/>
			</xsl:when>
			<xsl:when test="@src != ''">
				<xsl:text>;VALUE=</xsl:text>
				<!-- convert to absolute url -->
				<xsl:call-template name="uri:expand">
					<xsl:with-param name="base" ><xsl:value-of select="$Source"/></xsl:with-param>
					<xsl:with-param name="there" ><xsl:value-of select="@src"/></xsl:with-param>
				</xsl:call-template>
				</xsl:when>
			<xsl:otherwise>
				<xsl:text>:</xsl:text><xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise>
		<xsl:text>:</xsl:text><xsl:value-of select="normalize-space(.)" />
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- recursive function to escape text -->
<xsl:template name="escapeText">
	<xsl:param name="text-string"></xsl:param>

	<xsl:call-template name="replaceText"> <!-- , -->
		<xsl:with-param name="search">,</xsl:with-param>
		<xsl:with-param name="replace">\,</xsl:with-param>
		<xsl:with-param name="subject">
			<xsl:call-template name="replaceText"> <!-- ; -->
				<xsl:with-param name="search">;</xsl:with-param>
				<xsl:with-param name="replace">\;</xsl:with-param>
				<xsl:with-param name="subject">
					<xsl:call-template name="replaceText"> <!-- \ -->
						<xsl:with-param name="search">\</xsl:with-param>
						<xsl:with-param name="replace">\\</xsl:with-param>
						<xsl:with-param name="subject" select="$text-string" />
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template name="replaceText">
	<xsl:param name="subject" />
	<xsl:param name="search" />
	<xsl:param name="replace" />

	<xsl:choose>
		<xsl:when test="contains($subject, $search)">
			<xsl:value-of select="substring-before($subject, $search)" />
			<xsl:value-of select="$replace" />
			<xsl:call-template name="replaceText">
				<xsl:with-param name="subject" select="substring-after($subject, $search)"/>
				<xsl:with-param name="search" select="$search"/>
				<xsl:with-param name="replace" select="$replace"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$subject" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- recursive function to give plain text some equivalent HTML formatting -->
<xsl:template match="*" mode="unFormatText">
	<xsl:for-each select="node()">
		<xsl:choose>

			<xsl:when test="name() = 'p'">
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>\n\n</xsl:text>
			</xsl:when>
			<xsl:when test="name() = 'del'"></xsl:when>
			
			<xsl:when test="name() = 'div'">
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>\n</xsl:text>
			</xsl:when>
			<xsl:when test="name() = 'dl' or name() = 'dt' or name() = 'dd'">
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>\n</xsl:text>
			</xsl:when>
			<xsl:when test="name() = 'q'">
				<xsl:text>“</xsl:text>
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>”</xsl:text>
				<xsl:text>\n</xsl:text>
			</xsl:when>
			<xsl:when test="name() = 'sup'">
				<xsl:text>[</xsl:text>
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:when test="name() = 'sub'">
				<xsl:text>(</xsl:text>
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:when test="name() = 'ul' or name() = 'ol'">
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>\n</xsl:text>
			</xsl:when>
			<xsl:when test="name() = 'li'">
				<xsl:choose>
					<xsl:when test="name(..) = 'ol'">
						<xsl:number format="1. " />
						<xsl:apply-templates select="." mode="unFormatText"/>
						<xsl:text>\n</xsl:text>
					</xsl:when> 
					<xsl:otherwise> 
						<xsl:text>* </xsl:text>
						<xsl:apply-templates select="." mode="unFormatText"/>
						<xsl:text>\n</xsl:text>
					</xsl:otherwise> 
				</xsl:choose>
			</xsl:when>
			<xsl:when test="name() = 'pre'">
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string">
						<xsl:value-of select="."/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="name() = 'br'">
				<xsl:text>\n</xsl:text>
			</xsl:when>
			<xsl:when test="name() = 'h1' or name() = 'h2' or name() = 'h3' or name() = 'h4' or name() = 'h5' or name() = 'h6'">
				<xsl:apply-templates select="." mode="unFormatText"/>				
				<xsl:text>\n</xsl:text>
			</xsl:when>
			<xsl:when test="descendant::*">
				<xsl:apply-templates select="." mode="unFormatText"/>
			</xsl:when>
			<xsl:when test="text()">
				<xsl:call-template name="normalize-spacing">
					<xsl:with-param name="text-string">
						<xsl:call-template name="escapeText">
							<xsl:with-param name="text-string">
								<xsl:value-of select="."/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				
				<xsl:choose>
					<!--
					<xsl:when test="normalize-space(.) = '' and not(contains(.,' '))"><xsl:text>^</xsl:text></xsl:when>-->
					<xsl:when test="contains(translate(.,$nl,''),' ') and normalize-space(translate(.,$nl,'')) = ''">
						<xsl:text> </xsl:text>
					</xsl:when>
					<xsl:when test="substring(translate(.,$nl,''),1,1) = $tb or substring(translate(.,$nl,''),1,1) = ' '">						
						<xsl:if test="substring(translate(.,$nl,''),1,1) = $tb or substring(translate(.,$nl,''),1,1) = ' '">
								<xsl:text> </xsl:text>
						</xsl:if>					
						<xsl:choose>
							<xsl:when test="substring(translate(.,$nl,''),string-length(translate(.,$nl,'')),1) = $tb or substring(translate(.,$nl,''),string-length(translate(.,$nl,'')),1) = ' '">
								<xsl:call-template name="escapeText">
									<xsl:with-param name="text-string">
										<xsl:value-of select="normalize-space(translate(.,$nl,''))"/>
									</xsl:with-param>
								</xsl:call-template>
								<xsl:text> </xsl:text>
							</xsl:when>	
							<xsl:otherwise>
								<xsl:call-template name="escapeText">
									<xsl:with-param name="text-string">
										<xsl:value-of select="normalize-space(translate(.,$nl,''))"/>
									</xsl:with-param>
								</xsl:call-template>
								
							</xsl:otherwise>						
						</xsl:choose>
					</xsl:when>
					<xsl:when test="substring(.,string-length(translate(.,$nl,'')),1) = $tb or substring(.,string-length(translate(.,$nl,'')),1) = ' '">
						<xsl:call-template name="escapeText">
							<xsl:with-param name="text-string">
								<xsl:value-of select="normalize-space(translate(.,$nl,''))"/>
							</xsl:with-param>
						</xsl:call-template>
						
						<xsl:text> </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						
						<!--
						<xsl:call-template name="normalize-spacing">
							<xsl:with-param name="text-string">
						-->
								<xsl:call-template name="escapeText">
									<xsl:with-param name="text-string">
										<xsl:value-of select="translate(translate(.,$tb,' '),$nl,'')"/>
									</xsl:with-param>
								</xsl:call-template>
						<!--
							</xsl:with-param>
						</xsl:call-template>
					-->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>

</xsl:template>

<!-- recursive function to normalize-spacing in text -->
<xsl:template name="normalize-spacing">
	<xsl:param name="text-string"></xsl:param>
	<xsl:param name="colapse-spacing">1</xsl:param>
	<xsl:choose>
		<xsl:when test="substring($text-string,2) = true()">
			<xsl:choose>
				<xsl:when test="$colapse-spacing = '1'">
					<xsl:choose>
						<xsl:when test="substring($text-string,1,1) = ' ' or substring($text-string,1,1) = '$tb' or substring($text-string,1,1) = '$cr' or substring($text-string,1,1) = '$nl'">
							<xsl:text> </xsl:text>
							<xsl:call-template name="normalize-spacing">
								<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
								<xsl:with-param name="colapse-spacing">1</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(substring($text-string,1,1))"/>
							<xsl:call-template name="normalize-spacing">
								<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
								<xsl:with-param name="colapse-spacing">0</xsl:with-param>
							</xsl:call-template>							
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="substring($text-string,1,1) = ' ' or substring($text-string,1,1) = '$tb' or substring($text-string,1,1) = '$cr' or substring($text-string,1,1) = '$nl'">
							<xsl:text> </xsl:text>
							<xsl:call-template name="normalize-spacing">
								<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
								<xsl:with-param name="colapse-spacing">1</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(substring($text-string,1,1))"/>
							<xsl:call-template name="normalize-spacing">
								<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
								<xsl:with-param name="colapse-spacing">0</xsl:with-param>
							</xsl:call-template>							
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>		
			
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="$colapse-spacing = '1'">
					<xsl:value-of select="normalize-space($text-string)"/>			
				</xsl:when>
				<xsl:when test="substring($text-string,1,1) = ' '">
					<xsl:text> </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space($text-string)"/>			
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>		
	</xsl:choose>
</xsl:template>

<!-- Get the language for an property -->
<xsl:template name="lang">
	<xsl:variable name="lang">
		<xsl:call-template name="mf:lang"/>
	</xsl:variable>
	<xsl:if test="$lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text>
		<xsl:value-of select="$lang" />
	</xsl:if>
</xsl:template>

<!-- don't pass text thru -->
<xsl:template match="text()"></xsl:template>

<!-- Empty templates required by Saxon -->
<xsl:template name="vtodoProperties" />
<xsl:template name="vfreebusyProperties" />

</xsl:stylesheet>
