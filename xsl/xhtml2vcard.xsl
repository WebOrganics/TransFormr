<?xml version="1.0"?>
<xsl:transform 
 xmlns:xsl ="http://www.w3.org/1999/XSL/Transform"
 xmlns:mf  ="http://suda.co.uk/projects/microformats/mf-templates.xsl?template="
 xmlns:uri ="http://www.w3.org/2000/07/uri43/uri.xsl?template="
 xmlns:common="http://exslt.org/common"
 extension-element-prefixes="common"
 version="1.0"
>

<xsl:import href="mf-templates.xsl" />

<!--<xsl:strip-space elements="*"/>-->
<xsl:preserve-space elements="pre"/>

<xsl:output
  encoding="UTF-8"
  indent="no"
  media-type="text/x-vcard"
  method="text"
/>

<!--
brian suda
brian@suda.co.uk
http://suda.co.uk/

XHTML-2-vCard
Version 0.12
2008-01-10

Copyright 2005 Brian Suda
This work is relicensed under The W3C Open Source License
http://www.w3.org/Consortium/Legal/copyright-software-19980720

Major optimization created by Dan Connolly [http://www.w3.org/People/Connolly/] have been rolled into this file, along with the URI normalizing template [http://www.w3.org/2000/07/uri43/uri.xsl]
http://dev.w3.org/cvsweb/2001/palmagent/xhtml2vcard.xsl

NOTES:
Until the hCard spec has been finalised this is a work in progress.
I'm not an XSLT expert, so there are no guarantees to quality of this code!

@@ check for profile in head element
@@ decode only the first instance of a singular property
-->



<xsl:param name="Prodid" select='"-//suda.co.uk//X2V 0.12 (BETA)//EN"' />
<xsl:param name="Source" ><xsl:value-of select="$base-uri" /></xsl:param>
<xsl:param name="Encoding" >UTF-8</xsl:param>
<xsl:param name="Anchor" />

<xsl:variable name="nl"><xsl:text>
</xsl:text></xsl:variable>
<xsl:variable name="tb"><xsl:text>	</xsl:text></xsl:variable>

<!-- check for profile in head element -->
<xsl:template match="head[contains(concat(' ',normalize-space(@profile),' '),' http://www.w3.org/2006/03/hcard ')]">
<!-- 
==================== CURRENTLY DISABLED ====================
This will call the vCard template, 
Without the correct profile you cannot assume the class values are intended for the vCard microformat.
-->
<!-- <xsl:call-template name="vcard"/> -->
</xsl:template>

<!-- Each vCard is listed in succession -->
<xsl:template match="*[contains(concat(' ',normalize-space(@class),' '),' vcard ') and descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')]]">
	<xsl:if test="not($Anchor) or ancestor-or-self::*[@id = $Anchor]">		
		<xsl:text>BEGIN:VCARD</xsl:text>
		<!-- <xsl:text>&#x0D;&#x0A;PRODID:</xsl:text><xsl:value-of select="$Prodid"/> -->
		<xsl:text>&#x0D;&#x0A;SOURCE:</xsl:text><xsl:value-of select="$Source"/>
		<xsl:text>&#x0D;&#x0A;NAME:</xsl:text>
		<xsl:apply-templates select="//*[local-name() = 'title']" mode="unFormatText" />
		<xsl:text>&#x0D;&#x0A;VERSION:3.0</xsl:text>
		
		<xsl:call-template name="mf:doIncludes"/>
		<xsl:call-template name="properties"/>

		<xsl:text>&#x0D;&#x0A;END:VCARD&#x0D;&#x0A;&#x0D;&#x0A;</xsl:text>
	</xsl:if>
</xsl:template>

<!-- ============== working templates ================= -->
<xsl:template name="properties">
	<!--  Implied "N" Optimization -->
	<xsl:variable name="n-elt" select="
		.//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ', normalize-space(@class), ' '),' n ')]
		or 
		(
		.//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and not(contains(concat(' ', normalize-space(@class), ' '),' n '))]
		and
		.//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and ancestor::*[contains(concat(' ', normalize-space(@class), ' '),' fn ')] and (contains(concat(' ', normalize-space(@class), ' '),' given-name ') or contains(concat(' ', normalize-space(@class), ' '),' family-name '))]		
		)		
		" />
							
	<xsl:variable name="fn-val">
		<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' fn ')]">
			<xsl:if test="position() = 1">
				<xsl:call-template name="mf:extractText"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>	
	
	<xsl:variable name="org-val">
		<xsl:variable name="orgData">
			<xsl:for-each select=".//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ', normalize-space(@class), ' '),' org ')]">
				<xsl:if test="position() = 1">
					<xsl:call-template name="mf:extractOrg"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:value-of select="common:node-set($orgData)/organization-name"/>
	</xsl:variable>

	<xsl:variable name="is-org" select="$fn-val = $org-val and not($fn-val = '')" />

	<!-- check to see if FN is on the same node as any ADR elements -->
	<xsl:variable name="is-place" select="
			.//*[contains(concat(' ',normalize-space(@class),' '),' fn ') and contains(concat(' ',normalize-space(@class),' '),' adr ')] = true() or 
			.//*[contains(concat(' ',normalize-space(@class),' '),' fn ') and contains(concat(' ',normalize-space(@class),' '),' street-address ')] = true() or 
			.//*[contains(concat(' ',normalize-space(@class),' '),' fn ') and contains(concat(' ',normalize-space(@class),' '),' extended-address ')] = true() or 
			.//*[contains(concat(' ',normalize-space(@class),' '),' fn ') and contains(concat(' ',normalize-space(@class),' '),' locality ')] = true() or 
			.//*[contains(concat(' ',normalize-space(@class),' '),' fn ') and contains(concat(' ',normalize-space(@class),' '),' region ')] = true() or 
			.//*[contains(concat(' ',normalize-space(@class),' '),' fn ') and contains(concat(' ',normalize-space(@class),' '),' country-name ')] = true() or 
			.//*[contains(concat(' ',normalize-space(@class),' '),' fn ') and contains(concat(' ',normalize-space(@class),' '),' post-office-box ')] = true() or 
			.//*[contains(concat(' ',normalize-space(@class),' '),' fn ') and contains(concat(' ',normalize-space(@class),' '),' postal-code ')] = true() or 
			.//*[contains(concat(' ',normalize-space(@class),' '),' fn ') and contains(concat(' ',normalize-space(@class),' '),' label ')] = true()
		"/>

	<xsl:choose>
		<xsl:when test="$n-elt">
			<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' n ')]">
				<xsl:if test="position() = 1">
					<xsl:variable name="nData-RTF">
						<xsl:call-template name="mf:extractN"/>
					</xsl:variable>
					<xsl:variable name="nData" select="common:node-set($nData-RTF)" />
					
					<xsl:text>&#x0D;&#x0A;N</xsl:text>
					<xsl:call-template name="lang" />
					<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
					<xsl:text>:</xsl:text>
					<xsl:for-each select="$nData/family-names/family-name">
						<xsl:if test="position() != 1">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:value-of select="."/>
					</xsl:for-each>
					<xsl:text>;</xsl:text>
					<xsl:for-each select="$nData/given-names/given-name">
						<xsl:if test="position() != 1">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:value-of select="."/>
					</xsl:for-each>
					<xsl:text>;</xsl:text>
					<xsl:for-each select="$nData/additional-names/additional-name">
						<xsl:if test="position() != 1">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:value-of select="."/>
					</xsl:for-each>
					<xsl:text>;</xsl:text>
					<xsl:for-each select="$nData/honorific-prefixs/honorific-prefix">
						<xsl:if test="position() != 1">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:value-of select="."/>
					</xsl:for-each>
					<xsl:text>;</xsl:text>
					<xsl:for-each select="$nData/honorific-suffixs/honorific-suffix">
						<xsl:if test="position() != 1">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:value-of select="."/>
					</xsl:for-each>
					
				</xsl:if>
			</xsl:for-each>
		</xsl:when>
		<xsl:when test="$is-org or $is-place">
			<xsl:text>&#x0D;&#x0A;N:;;;;</xsl:text>
		</xsl:when>
		<xsl:when test="not($n-elt) and not(string-length(normalize-space(.//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' fn ')])) &gt; 1+string-length(translate(normalize-space(.//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' fn ')]),' ','')))">
			<xsl:call-template name="implied-n" />		
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>&#x0D;&#x0A;N:;;;;</xsl:text>
		</xsl:otherwise>
	</xsl:choose>

	<xsl:for-each select=".//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ', normalize-space(@class), ' '),' org ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;ORG</xsl:text>
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
	    	<xsl:text>:</xsl:text>
			<xsl:variable name="orgData-RTF">
				<xsl:call-template name="mf:extractOrg"/>
			</xsl:variable>
			<xsl:variable name="orgData" select="common:node-set($orgData-RTF)" />
			
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:value-of select="$orgData/organization-name"/></xsl:with-param>
			</xsl:call-template>
			<xsl:for-each select="$orgData/organization-units/organization-unit">
				<xsl:text>;</xsl:text>
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string"><xsl:value-of select="."/></xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:if>
	</xsl:for-each>
	
	
	<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' fn ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;FN</xsl:text>
			<xsl:call-template name="lang" />
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
		    <xsl:text>:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>
	
	<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' mailer ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;MAILER</xsl:text>
			<xsl:call-template name="lang" />
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
		    <xsl:text>:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' title ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;TITLE</xsl:text>
			<xsl:call-template name="lang" />
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
		    <xsl:text>:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>
	
	<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' role ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;ROLE</xsl:text>
			<xsl:call-template name="lang" />
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
		    <xsl:text>:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' sort-string ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;SORT-STRING</xsl:text>
			<xsl:call-template name="lang" />
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
		    <xsl:text>:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' class ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;CLASS</xsl:text>
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
		    <xsl:text>:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' tz ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;TZ</xsl:text>
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
		    <xsl:text>:</xsl:text>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>
	
	<xsl:if test=".//*[contains(concat(' ', normalize-space(@class), ' '),' category ')]">
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
	
	<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' rev ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;REV:</xsl:text>
			<!-- maybe convert the ISO template to NOT strip '-'? -->
			<xsl:call-template name="mf:extractText"/>				
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' bday ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;BDAY:</xsl:text>
			<!-- maybe convert the ISO template to NOT strip '-'? -->
			<xsl:call-template name="mf:extractText"/>				
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' uid ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;UID:</xsl:text>
			<xsl:call-template name="mf:extractUrl"/>				
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' url ')]">
			<xsl:text>&#x0D;&#x0A;URL:</xsl:text>
			<xsl:call-template name="mf:extractUrl">
				<xsl:with-param name="Source"><xsl:value-of select="$Source"/></xsl:with-param>
			</xsl:call-template>
	</xsl:for-each>
	
	<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' email ')]">
		<xsl:text>&#x0D;&#x0A;EMAIL</xsl:text>
		<xsl:variable name="emailData-RTF">
			<xsl:call-template name="mf:extractUid">
				<xsl:with-param name="protocol">mailto</xsl:with-param>
				<xsl:with-param name="type-list">internet x400 pref</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="emailData" select="common:node-set($emailData-RTF)" />
		<xsl:if test="$emailData/type != ''">
			<xsl:text>;TYPE=</xsl:text>
			<xsl:value-of select="$emailData/type"/>
		</xsl:if>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="$emailData/value"/>
		
	</xsl:for-each>
	
	<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' adr ')]">
		<xsl:variable name="adrData-RTF">
			<xsl:call-template name="mf:extractAdr">
				<xsl:with-param name="type-list">dom intl postal parcel home work pref</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="adrData" select="common:node-set($adrData-RTF)" />
			<xsl:text>&#x0D;&#x0A;ADR</xsl:text>
			<xsl:call-template name="lang" />
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>

			<xsl:if test="not(normalize-space($adrData/type)) = false()">
				<xsl:text>;TYPE=</xsl:text>
				<xsl:value-of select="normalize-space($adrData/type)"/>
			</xsl:if>
			<xsl:text>:</xsl:text>

			<!-- need to convert these for multiple instances -->
			<xsl:value-of select="$adrData/post-office-box"/>
			<xsl:text>;</xsl:text>
		    <xsl:value-of select="$adrData/extended-address"/>
		    <xsl:text>;</xsl:text>
			<xsl:value-of select="$adrData/street-address"/>
			<xsl:text>;</xsl:text>
		    <xsl:value-of select="$adrData/locality"/>
		    <xsl:text>;</xsl:text>
		    <xsl:value-of select="$adrData/region"/>
		    <xsl:text>;</xsl:text>
		    <xsl:value-of select="$adrData/postal-code"/>
		    <xsl:text>;</xsl:text>
		    <xsl:value-of select="$adrData/country-name"/>
			
	</xsl:for-each>

	<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' tel ')]">
		<xsl:text>&#x0D;&#x0A;TEL</xsl:text>
		<xsl:variable name="telData-RTF">
			<xsl:call-template name="mf:extractUid">
				<xsl:with-param name="protocol">tel fax modem</xsl:with-param>
				<xsl:with-param name="type-list">home work pref voice fax msg cell pager bbs modem car isdn video pcs</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="telData" select="common:node-set($telData-RTF)" />
		
		<xsl:if test="$telData/type != ''">
			<xsl:text>;TYPE=</xsl:text>
			<xsl:value-of select="$telData/type"/>
		</xsl:if>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="$telData/value"/>
		
	</xsl:for-each>

	<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' geo ')][1]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;GEO:</xsl:text>
			<xsl:variable name="geoData">
				<xsl:call-template name="mf:extractGeo"/>
			</xsl:variable>

			<xsl:value-of select="common:node-set($geoData)/latitude"/>
			<xsl:text>;</xsl:text>
			<xsl:value-of select="common:node-set($geoData)/longitude"/>
		</xsl:if>
	</xsl:for-each>
	
	<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' note ')]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;NOTE</xsl:text>
			<xsl:call-template name="lang" />
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
		    <xsl:text>:</xsl:text>
		</xsl:if>
		<!-- pretty output? -->
		<!--
		<xsl:variable name="textFormatted">
		<xsl:apply-templates select="." mode="unFormatText" />
		</xsl:variable>
		<xsl:value-of select="normalize-space($textFormatted)"/>
		-->
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
		</xsl:call-template>
	</xsl:for-each>

	
	<!-- Check to see if this is not a company -->
	<xsl:choose>
		<xsl:when test="not($is-org)">
			<!-- check to see it is only one word long -->
			<xsl:choose>
				<xsl:when test="(false() = not((.//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ',normalize-space(@class),' '),' fn ') and (local-name() = 'img' or local-name() = 'area')]/@alt) and (string-length(normalize-space(.//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ',normalize-space(@class),' '),' fn ') and (local-name() = 'img' or local-name() = 'area')]/@alt)) = string-length(translate(normalize-space(.//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ',normalize-space(@class),' '),' fn ') and (local-name() = 'img' or local-name() = 'area')]/@alt),' ',''))))) or (false() = not((.//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ',normalize-space(@class),' '),' fn ') and (local-name() = 'abbr')]/@title) and (string-length(normalize-space(.//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ',normalize-space(@class),' '),' fn ') and (local-name() = 'abbr')]/@title)) = string-length(translate(normalize-space(.//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ',normalize-space(@class),' '),' fn ') and (local-name() = 'abbr')]/@title),' ',''))))) or (false() = not((.//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ',normalize-space(@class),' '),' fn ') and not(local-name() = 'abbr' or local-name() = 'img')]) and (string-length(normalize-space(.//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ',normalize-space(@class),' '),' fn ') and not(local-name() = 'abbr' or local-name() = 'img' or local-name() = 'area')][1])) = string-length(translate(normalize-space(.//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ',normalize-space(@class),' '),' fn ') and not(local-name() = 'abbr' or local-name() = 'img')][1]),' ','')))))">
<!-- 
	
	
	
	
						       
	-->

					<xsl:if test=".//*[contains(concat(' ', normalize-space(@class), ' '),' nickname ')]">
						<xsl:text>&#x0D;&#x0A;NICKNAME</xsl:text>
						<xsl:call-template name="lang" />
						<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
					    <xsl:text>:</xsl:text>
						<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' nickname ')]">
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
							</xsl:call-template>
						</xsl:for-each>
						<xsl:choose>
							<xsl:when test="false() = not(normalize-space(.//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ',normalize-space(@class),' '),' fn ') and (local-name() = 'img' or local-name() = 'area')]/@alt))">
								<xsl:value-of select=".//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ',normalize-space(@class),' '),' fn ')]/@alt"/>
							</xsl:when>
							<xsl:when test="false() = not(normalize-space(.//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ',normalize-space(@class),' '),' fn ') and local-name() = 'abbr']/@title))">
								<xsl:value-of select="normalize-space(.//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ',normalize-space(@class),' '),' fn ')]/@title)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(.//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ',normalize-space(@class),' '),' fn ')])"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test=".//*[contains(concat(' ', normalize-space(@class), ' '),' nickname ')]">
						<xsl:text>&#x0D;&#x0A;NICKNAME</xsl:text>
						<xsl:call-template name="lang" />
						<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
					    <xsl:text>:</xsl:text>
						<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' nickname ')]">
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
							</xsl:call-template>
							<xsl:if test="not(position()=last())">
								<xsl:text>,</xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>

		</xsl:when>
		<xsl:otherwise>
			<xsl:if test=".//*[contains(concat(' ', normalize-space(@class), ' '),' nickname ')]">
				<xsl:text>&#x0D;&#x0A;NICKNAME</xsl:text>
				<xsl:call-template name="lang" />
				<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
			    <xsl:text>:</xsl:text>
				<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' nickname ')]">
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string"><xsl:call-template name="mf:extractText"/></xsl:with-param>
					</xsl:call-template>
					<xsl:if test="not(position()=last())">
						<xsl:text>,</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
	
	
	<xsl:call-template name="blobProp">
		<xsl:with-param name="label">PHOTO</xsl:with-param>
		<xsl:with-param name="class">photo</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="blobProp">
		<xsl:with-param name="label">LOGO</xsl:with-param>
		<xsl:with-param name="class">logo</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="blobProp">
		<xsl:with-param name="label">SOUND</xsl:with-param>
		<xsl:with-param name="class">sound</xsl:with-param>
	</xsl:call-template>
	

	<!-- Templates that still need work -->
	<!-- <xsl:apply-templates select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' agent ')]" mode="agent"/> 	-->

	<!-- @@TYPE=PGP, TYPE=X509, ENCODING=b -->
	<xsl:variable name="key-elt" select=".//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ', normalize-space(@class), ' '),' key ')]" />
	<xsl:if test="$key-elt">
			<xsl:call-template name="key-prop"/>
	</xsl:if>

	<!-- LABEL needs work!? -->
	<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' label ')]">
		<xsl:text>&#x0D;&#x0A;LABEL:</xsl:text>
		<xsl:variable name="types">
			<xsl:call-template name="find-types">
				<xsl:with-param name="list">dom intl postal parcel home work pref</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="normalize-space($types)">
			<xsl:text>;TYPE=</xsl:text>
			<xsl:value-of select="$types"/>
		</xsl:if>
		<xsl:call-template name="mf:extractText"/>
	</xsl:for-each>
			
</xsl:template>

<!-- blob Property -->
<xsl:template name="blobProp">
	<xsl:param name="label" />
	<xsl:param name="class" />

	<xsl:for-each select=".//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ', @class, ' '),concat(' ', $class, ' '))]">
		<xsl:if test="position() = 1">
		<xsl:text>&#x0D;&#x0A;</xsl:text>
		<xsl:value-of select="$label" />
	
		<xsl:choose>
			<xsl:when test="substring-before(@src,':') = 'data'">
					<xsl:text>;ENCODING=b;TYPE=</xsl:text><xsl:value-of select="substring-after(substring-after(substring-before(@src,';'),':'),'/')"/><xsl:text>:</xsl:text><xsl:value-of select="substring-after(@src,',')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="@src">
						<xsl:text>;VALUE=uri:</xsl:text>
						<xsl:choose>
							<xsl:when test="substring-before(@src,':') = 'http'">
								<xsl:value-of select="normalize-space(@src)" />
							</xsl:when>
							<xsl:otherwise>
								<!-- convert to absolute url -->
								<xsl:call-template name="uri:expand">
									<xsl:with-param name="base">

										<xsl:call-template name="mf:baseURL">
											<xsl:with-param name="Source"><xsl:value-of select="$Source" /></xsl:with-param>
										</xsl:call-template>
										
									</xsl:with-param>
									<xsl:with-param name="there"><xsl:value-of select="@src"/></xsl:with-param>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="@href">
						<xsl:text>;VALUE=uri:</xsl:text>
						<xsl:choose>
							<xsl:when test="substring-before(@href,':') = 'http'">
								<xsl:value-of select="normalize-space(@href)" />
							</xsl:when>
							<xsl:otherwise>
								<!-- convert to absolute url -->
								<xsl:call-template name="uri:expand">
									<xsl:with-param name="base">
										<xsl:call-template name="mf:baseURL">
											<xsl:with-param name="Source"><xsl:value-of select="$Source" /></xsl:with-param>
										</xsl:call-template>
									</xsl:with-param>
									<xsl:with-param name="there"><xsl:value-of select="@href"/></xsl:with-param>
								</xsl:call-template>

							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="@data">
						<xsl:text>;VALUE=uri:</xsl:text>
						<xsl:variable name="textFormatted">
						<xsl:apply-templates select="@data" mode="unFormatText" />
						</xsl:variable>
						<xsl:value-of select="normalize-space($textFormatted)"/>
					</xsl:when>
					<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
						<xsl:text>:</xsl:text>
						<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
							<xsl:variable name="textFormatted">
							<xsl:apply-templates select="." mode="unFormatText" />
							</xsl:variable>
							<xsl:value-of select="normalize-space($textFormatted)"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>:</xsl:text>
						<xsl:variable name="textFormatted">
						<xsl:apply-templates select="." mode="unFormatText" />
						</xsl:variable>
						<xsl:value-of select="normalize-space($textFormatted)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<!-- KEY Property -->
<xsl:template name="key-prop">
	<xsl:for-each select=".//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ', @class, ' '),concat(' ', 'key', ' '))]">
	<xsl:if test="position() = 1">
        <xsl:text>&#x0D;&#x0A;KEY:</xsl:text>
		<xsl:variable name="types">
			<xsl:call-template name="find-types">
				<xsl:with-param name="list">pgp x509</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="normalize-space($types)">
			<xsl:text>;TYPE=</xsl:text>
			<xsl:value-of select="$types"/>
		</xsl:if>
		<xsl:text>;ENCODING=b:</xsl:text>
		<xsl:choose>
			<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
				<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
					<xsl:variable name="textFormatted">
					<xsl:apply-templates select="." mode="unFormatText" />
					</xsl:variable>
					<xsl:value-of select="normalize-space($textFormatted)"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="textFormatted">
				<xsl:apply-templates select="." mode="unFormatText" />
				</xsl:variable>
				<xsl:value-of select="normalize-space($textFormatted)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
	</xsl:for-each>
</xsl:template>

<!-- LABEL Property -->
<xsl:template name="label-prop">
	<xsl:for-each select=".//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ', @class, ' '),concat(' ', label, ' '))]">
		<xsl:if test="position() = 1">
	        <xsl:text>&#x0D;&#x0A;LABEL:</xsl:text>
		<xsl:variable name="types">
			<xsl:call-template name="find-types">
				<xsl:with-param name="list">dom intl postal parcel home work pref</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="normalize-space($types)">
			<xsl:text>;TYPE=</xsl:text>
			<xsl:value-of select="$types"/>
		</xsl:if>
		<xsl:value-of select="*/@class"/>
		<xsl:choose>
			<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
				<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
					<xsl:variable name="textFormatted">
					<xsl:apply-templates select="." mode="unFormatText" />
					</xsl:variable>
					<xsl:value-of select="normalize-space($textFormatted)"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="name()"/>
				<xsl:value-of select="."/>
				<xsl:variable name="textFormatted">
					<xsl:apply-templates select="." mode="unFormatText" />
				</xsl:variable>
				<xsl:value-of select="normalize-space($textFormatted)"/>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<!-- IMPLIED N from FN -->
<xsl:template name="implied-n">
	<xsl:for-each select=".//*[not(ancestor-or-self::*[local-name() = 'del']) = true() and contains(concat(' ', @class, ' '),concat(' ', 'fn', ' '))]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0D;&#x0A;N</xsl:text>
			<xsl:call-template name="lang" />
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
			<xsl:text>:</xsl:text>
			
			<xsl:variable name="fn-val">
				<xsl:call-template name="mf:extractText"/>
			</xsl:variable>
			
			<xsl:choose>
				<xsl:when test='
					(string-length(substring-after(normalize-space($fn-val), " ")) = 1) or
					(
					(string-length(substring-after(normalize-space($fn-val), " ")) = 2) and 
					(substring(substring-after(normalize-space($fn-val), " "), 2,1) = ".")
					) or
					(
						substring(
								normalize-space($fn-val),
								string-length(
									(substring-before(
										normalize-space($fn-val), " "
									))
								),
								1
						) = ","
					)
					'>
					<xsl:variable name="given-name">
						<xsl:value-of select='substring-after(normalize-space($fn-val), " ")' />
					</xsl:variable>
					<xsl:choose>
						<xsl:when test='substring(
									normalize-space($fn-val),
									string-length(
										(substring-before(
											normalize-space($fn-val), " "
										))
									),
									1
								) = ","'>
								<xsl:variable name="family-name">
									<xsl:value-of select='substring(
												normalize-space($fn-val),
												1,
												string-length(
													(substring-before(
														normalize-space($fn-val), " "
													))
												)-1
											)' />
								</xsl:variable>
								<xsl:call-template name="escapeText">
									<xsl:with-param name="text-string" select="$family-name" />
								</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="family-name">
								<xsl:value-of select='substring-before(normalize-space($fn-val), " ")' />
							</xsl:variable>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="$family-name" />
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:text>;</xsl:text>
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string" select="$given-name" />
					</xsl:call-template>
					
				</xsl:when>
				<xsl:when test='not(substring-before(normalize-space($fn-val), " "))'>							
					<xsl:variable name="given-name">
						<xsl:text />
					</xsl:variable>
					<xsl:variable name="family-name">
						<xsl:value-of select='substring-before(normalize-space($fn-val), " ")' />
					</xsl:variable>
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string" select="$family-name" />
					</xsl:call-template>
					<xsl:text>;</xsl:text>
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string" select="$given-name" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="string-length(normalize-space($fn-val)) = (1+string-length(translate(normalize-space($fn-val),' ','')))">
					<xsl:variable name="given-name">
						<xsl:value-of select='substring-before(normalize-space($fn-val), " ")' />
					</xsl:variable>
					<xsl:variable name="family-name">
						<xsl:value-of select='substring-after(normalize-space($fn-val), " ")' />
					</xsl:variable>
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string" select="$family-name" />
					</xsl:call-template>
					<xsl:text>;</xsl:text>
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string" select="$given-name" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			
			
			<!--
			<xsl:choose>
				<xsl:when test="local-name(.) = 'abbr' and @title">
					<xsl:choose>
						<xsl:when test='
							(string-length(substring-after(normalize-space(@title), " ")) = 1) or
							(
							(string-length(substring-after(normalize-space(@title), " ")) = 2) and 
							(substring(substring-after(normalize-space(@title), " "), 2,1) = ".")
							) or
							(
								substring(
										normalize-space(@title),
										string-length(
											(substring-before(
												normalize-space(@title), " "
											))
										),
										1
								) = ","
							)
							'>
							<xsl:variable name="given-name">
								<xsl:value-of select='substring-after(normalize-space(@title), " ")' />
							</xsl:variable>
							<xsl:choose>
								<xsl:when test='substring(
											normalize-space(@title),
											string-length(
												(substring-before(
													normalize-space(@title), " "
												))
											),
											1
										) = ","'>
										<xsl:variable name="family-name">
											<xsl:value-of select='substring(
														normalize-space(@title),
														1,
														string-length(
															(substring-before(
																normalize-space(@title), " "
															))
														)-1
													)' />
										</xsl:variable>
										<xsl:call-template name="escapeText">
											<xsl:with-param name="text-string" select="$family-name" />
										</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="family-name">
										<xsl:value-of select='substring-before(normalize-space(@title), " ")' />
									</xsl:variable>
									<xsl:call-template name="escapeText">
										<xsl:with-param name="text-string" select="$family-name" />
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:text>;</xsl:text>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="$given-name" />
							</xsl:call-template>
							
						</xsl:when>
						<xsl:when test='not(substring-before(normalize-space(@title), " "))'>
							<xsl:variable name="given-name">
								<xsl:text />
							</xsl:variable>
							<xsl:variable name="family-name">
								<xsl:value-of select='substring-before(normalize-space(@title), " ")' />
							</xsl:variable>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="$family-name" />
							</xsl:call-template>
							<xsl:text>;</xsl:text>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="$given-name" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="given-name">
								<xsl:value-of select='substring-before(normalize-space(@title), " ")' />
							</xsl:variable>
							<xsl:variable name="family-name">
								<xsl:value-of select='substring-after(normalize-space(@title), " ")' />
							</xsl:variable>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="$family-name" />
							</xsl:call-template>
							<xsl:text>;</xsl:text>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="$given-name" />
							</xsl:call-template>							
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="(local-name(.) = 'img' or local-name(.) = 'area') and @alt">
					<xsl:choose>
						<xsl:when test='
							(string-length(substring-after(normalize-space(@alt), " ")) = 1) or
							(
							(string-length(substring-after(normalize-space(@alt), " ")) = 2) and 
							(substring(substring-after(normalize-space(@alt), " "), 2,1) = ".")
							) or
							(
								substring(
										normalize-space(@alt),
										string-length(
											(substring-before(
												normalize-space(@alt), " "
											))
										),
										1
								) = ","
							)
							'>
							<xsl:variable name="given-name">
								<xsl:value-of select='substring-after(normalize-space(@alt), " ")' />
							</xsl:variable>
							<xsl:choose>
								<xsl:when test='substring(
											normalize-space(@alt),
											string-length(
												(substring-before(
													normalize-space(@alt), " "
												))
											),
											1
										) = ","'>
										<xsl:variable name="family-name">
											<xsl:value-of select='substring(
														normalize-space(@alt),
														1,
														string-length(
															(substring-before(
																normalize-space(@alt), " "
															))
														)-1
													)' />
										</xsl:variable>
										<xsl:call-template name="escapeText">
											<xsl:with-param name="text-string" select="$family-name" />
										</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="family-name">
										<xsl:value-of select='substring-before(normalize-space(@alt), " ")' />
									</xsl:variable>
									<xsl:call-template name="escapeText">
										<xsl:with-param name="text-string" select="$family-name" />
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:text>;</xsl:text>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="$given-name" />
							</xsl:call-template>
							
						</xsl:when>
						<xsl:when test='not(substring-before(normalize-space(@alt), " "))'>
							<xsl:variable name="given-name">
								<xsl:text />
							</xsl:variable>
							<xsl:variable name="family-name">
								<xsl:value-of select='substring-before(normalize-space(@alt), " ")' />
							</xsl:variable>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="$family-name" />
							</xsl:call-template>
							<xsl:text>;</xsl:text>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="$given-name" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="given-name">
								<xsl:value-of select='substring-before(normalize-space(@alt), " ")' />
							</xsl:variable>
							<xsl:variable name="family-name">
								<xsl:value-of select='substring-after(normalize-space(@alt), " ")' />
							</xsl:variable>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="$family-name" />
							</xsl:call-template>
							<xsl:text>;</xsl:text>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="$given-name" />
							</xsl:call-template>							
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test='
							(string-length(substring-after(normalize-space(.), " ")) = 1) or
							(
							(string-length(substring-after(normalize-space(.), " ")) = 2) and 
							(substring(substring-after(normalize-space(.), " "), 2,1) = ".")
							) or
							(
								substring(
										normalize-space(.),
										string-length(
											(substring-before(
												normalize-space(.), " "
											))
										),
										1
								) = ","
							)
							'>
							<xsl:variable name="given-name">
								<xsl:value-of select='substring-after(normalize-space(.), " ")' />
							</xsl:variable>
							<xsl:choose>
								<xsl:when test='substring(
											normalize-space(.),
											string-length(
												(substring-before(
													normalize-space(.), " "
												))
											),
											1
										) = ","'>
										<xsl:variable name="family-name">
											<xsl:value-of select='substring(
														normalize-space(.),
														1,
														string-length(
															(substring-before(
																normalize-space(.), " "
															))
														)-1
													)' />
										</xsl:variable>
										<xsl:call-template name="escapeText">
											<xsl:with-param name="text-string" select="$family-name" />
										</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="family-name">
										<xsl:value-of select='substring-before(normalize-space(.), " ")' />
									</xsl:variable>
									<xsl:call-template name="escapeText">
										<xsl:with-param name="text-string" select="$family-name" />
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>

							<xsl:text>;</xsl:text>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="$given-name" />
							</xsl:call-template>
							
						</xsl:when>
						<xsl:when test='not(substring-before(normalize-space(.), " "))'>							
							<xsl:variable name="given-name">
								<xsl:text />
							</xsl:variable>
							<xsl:variable name="family-name">
								<xsl:value-of select='substring-before(normalize-space(.), " ")' />
							</xsl:variable>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="$family-name" />
							</xsl:call-template>
							<xsl:text>;</xsl:text>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="$given-name" />
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="string-length(normalize-space(.)) = (1+string-length(translate(normalize-space(.),' ','')))">
							<xsl:variable name="given-name">
								<xsl:value-of select='substring-before(normalize-space(.), " ")' />
							</xsl:variable>
							<xsl:variable name="family-name">
								<xsl:value-of select='substring-after(normalize-space(.), " ")' />
							</xsl:variable>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="$family-name" />
							</xsl:call-template>
							<xsl:text>;</xsl:text>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="$given-name" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>;</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		-->
			<xsl:text>;;;</xsl:text>
		</xsl:if>
	</xsl:for-each>
</xsl:template>


<!-- get the class value -->
<xsl:template name="class-value">
	<xsl:param name="class" />
	<!--
		<xsl:choose>
			<xsl:when test=".//*[contains(concat(' ', @class, ' '), concat(' ', $class , ' '))]//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
				<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
					<xsl:variable name="textFormatted">
					<xsl:apply-templates select="." mode="unFormatText" />
					</xsl:variable>
					<xsl:value-of select="normalize-space($textFormatted)"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$class = 'additional-name' or $class = 'honorific-prefix' or $class = 'honorific-suffix' or $class='street-address'">
				<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),concat(' ',$class,' '))]">
					<xsl:variable name="textFormatted">
					<xsl:apply-templates select="." mode="unFormatText" />
					</xsl:variable>
					<xsl:value-of select="normalize-space($textFormatted)"/>
					<xsl:if test="not(position()=last())">
						<xsl:text>,</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
			-->
				<xsl:for-each select=".//*[contains(concat(' ', @class, ' '), concat(' ', $class , ' '))]">
					<xsl:if test="(position() = 1 and not($class = 'additional-name' or $class='honorific-prefix' or $class='honorific-suffix' or $class = 'street-address' or $class = 'organization-unit')) or ($class = 'additional-name' or $class='honorific-prefix' or $class='honorific-suffix' or $class = 'street-address' or $class = 'organization-unit')">
					<xsl:choose>
						<xsl:when test='local-name(.) = "abbr" and @title'>
							<xsl:variable name="textFormatted">
							<xsl:apply-templates select="@title" mode="unFormatText" />
							</xsl:variable>
							<xsl:value-of select="normalize-space($textFormatted)"/>
						</xsl:when>
						<xsl:when test='@alt and (local-name(.) = "img" or local-name(.) = "area")'>
							<xsl:variable name="textFormatted">
							<xsl:apply-templates select="@alt" mode="unFormatText" />
							</xsl:variable>
							<xsl:value-of select="normalize-space($textFormatted)"/>
						</xsl:when>
						<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
							<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
								<xsl:variable name="textFormatted">
								<xsl:apply-templates select="." mode="unFormatText" />
								</xsl:variable>
								<xsl:value-of select="normalize-space($textFormatted)"/>						
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="textFormatted">
							<xsl:apply-templates select="." mode="unFormatText" />
							</xsl:variable>
							<xsl:value-of select="normalize-space($textFormatted)"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="not(position()=last()) and ($class = 'additional-name' or $class='honorific-prefix' or $class='honorific-suffix' or $class = 'street-address' or $class = 'organization-unit')">
						<xsl:text>,</xsl:text>
					</xsl:if>
					</xsl:if>
				</xsl:for-each>	
				<!--			
			</xsl:otherwise>
		</xsl:choose>
	-->
</xsl:template>

<!-- get the class value -->
<xsl:template name="class-attribute-value">
	<xsl:param name="value" />
	<xsl:for-each select=".//*[contains(concat(' ', @class, ' '), concat(' ', 'type', ' '))]">
		<xsl:choose>
			<xsl:when test="translate(normalize-space(.),$ucase,$lcase) = $value">
				<xsl:value-of select="normalize-space($value)"/>
			</xsl:when>
			<xsl:when test="local-name(.) = 'abbr' and @title">
				<xsl:if test="contains(translate(concat(' ', translate(@title,',',' '), ' '),$ucase,$lcase), concat(' ', $value, ' ')) = true()">
					<xsl:value-of select="normalize-space($value)"/>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:for-each>

</xsl:template>

<!-- Recursive function to search for property attributes -->
<xsl:template name="find-types">
  <xsl:param name="list" /> <!-- e.g. "fax modem voice" -->
  <xsl:param name="found" />
  
  <xsl:variable name="first" select='substring-before(concat($list, " "), " ")' />
  <xsl:variable name="rest" select='substring-after($list, " ")' />

	<!-- look for first item in list -->

	<xsl:variable name="v">
		<xsl:call-template name="class-attribute-value">
			<xsl:with-param name="value" select='$first' />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="ff">
		<xsl:choose>
			<xsl:when test='normalize-space($v) and normalize-space($found)'>
				<xsl:value-of select='concat($found, ",", $first)' />
			</xsl:when>
			<xsl:when test='normalize-space($v)'>
				<xsl:value-of select='$first' />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$found" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- recur if there are more -->
	<xsl:choose>
		<xsl:when test="$rest">
			<xsl:call-template name="find-types">
				<xsl:with-param name="list" select="$rest" />
				<xsl:with-param name="found" select="$ff" />
			</xsl:call-template>
		</xsl:when>
		<!-- else return what we found -->
		<xsl:otherwise>
			<xsl:value-of select="$ff" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>



<!-- ================ HELPER TEMPLATE =================== -->

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

<!-- recursive function to give plain text some equivalent HTML formatting -->
<xsl:template match="*" mode="unFormatText">
	<xsl:for-each select="node()">
		<xsl:choose>
			<xsl:when test="local-name() = 'p'">
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>\n\n</xsl:text>
			</xsl:when>
			<xsl:when test="local-name() = 'del'"></xsl:when>
			
			<xsl:when test="local-name() = 'div'">
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>\n</xsl:text>
			</xsl:when>
			<xsl:when test="local-name() = 'dl' or local-name() = 'dt' or local-name() = 'dd'">
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>\n</xsl:text>
			</xsl:when>
			<xsl:when test="local-name() = 'q'">
				<xsl:text>“</xsl:text>
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>”</xsl:text>
				<xsl:text>\n</xsl:text>
			</xsl:when>
			<xsl:when test="local-name() = 'sup'">
				<xsl:text>[</xsl:text>
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:when test="local-name() = 'sub'">
				<xsl:text>(</xsl:text>
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:when test="local-name() = 'ul' or local-name() = 'ol'">
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>\n</xsl:text>
			</xsl:when>
			<xsl:when test="local-name() = 'li'">
				<xsl:choose>
					<xsl:when test="local-name(..) = 'ol'">
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
			<xsl:when test="local-name() = 'pre'">
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string">
						<xsl:value-of select="."/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="local-name() = 'br'">
				<xsl:text>\n</xsl:text>
			</xsl:when>
			<xsl:when test="local-name() = 'h1' or local-name() = 'h2' or local-name() = 'h3' or local-name() = 'h4' or local-name() = 'h5' or local-name() = 'h6'">
				<xsl:apply-templates select="." mode="unFormatText"/>				
				<xsl:text>\n</xsl:text>
			</xsl:when>
			<xsl:when test="descendant::*">
				<xsl:apply-templates select="." mode="unFormatText"/>
			</xsl:when>
			<xsl:when test="self::comment()">
				<!-- do nothing -->
			</xsl:when>
			<!--
			<xsl:when test="self::text()">
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
			-->
			<xsl:otherwise>
				<xsl:choose>
					<!--
					<xsl:when test="normalize-space(.) = '' and not(contains(.,' '))"><xsl:text>^</xsl:text></xsl:when>-->
					<xsl:when test="contains(.,' ') and normalize-space(.) = ''">
						<xsl:text> </xsl:text>
					</xsl:when>					
					<xsl:when test="substring(.,1,1) = $tb or substring(.,1,1) = ' '">
						<xsl:text> </xsl:text>
						<xsl:choose>
							<xsl:when test="substring(.,string-length(.),1) = $tb or substring(.,string-length(.),1) = ' '">
								<xsl:call-template name="escapeText">
									<xsl:with-param name="text-string">
										<xsl:value-of select="normalize-space(.)"/>
									</xsl:with-param>
								</xsl:call-template>	
								<xsl:text> </xsl:text>	
							</xsl:when>	
							<xsl:otherwise>
								<xsl:call-template name="escapeText">
									<xsl:with-param name="text-string">
										<xsl:value-of select="normalize-space(.)"/>
									</xsl:with-param>
								</xsl:call-template>	
							</xsl:otherwise>						
						</xsl:choose>
					</xsl:when>
					<xsl:when test="substring(.,string-length(.),1) = $tb or substring(.,string-length(.),1) = ' '">
						<xsl:call-template name="escapeText">
							<xsl:with-param name="text-string">
								<xsl:value-of select="normalize-space(.)"/>
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
										<xsl:value-of select="translate(translate(.,$tb,' '),$nl,' ')"/>
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
		<xsl:when test="not(substring($text-string,2)) = false()">
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

<!-- recursive function to escape text -->
<xsl:template name="escapeText">
	<xsl:param name="text-string"></xsl:param>
	<xsl:choose>
		<xsl:when test="not(substring($text-string,2)) = false()">
			<xsl:choose>
				<xsl:when test="substring($text-string,1,1) = '\'">
					<xsl:text>\\</xsl:text>
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="substring($text-string,1,1) = ','">
					<xsl:text>\,</xsl:text>
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="substring($text-string,1,1) = ';'">
					<xsl:text>\;</xsl:text>
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<!-- New Line -->
				<xsl:when test="substring($text-string,1,1) = $nl">
					<xsl:text>\n</xsl:text>
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring($text-string,1,1)"/>
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>				
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="$text-string = '\'">
					<xsl:text>\\</xsl:text>
				</xsl:when>
				<xsl:when test="$text-string = ','">
					<xsl:text>\,</xsl:text>
				</xsl:when>
				<xsl:when test="$text-string = ';'">
					<xsl:text>\;</xsl:text>
				</xsl:when>
				<!-- New Line -->
				<xsl:when test="$text-string = $nl">
					<xsl:text>\n</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$text-string"/>
				</xsl:otherwise>
			</xsl:choose>		
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="comment()"></xsl:template>

<!-- don't pass text thru -->
<xsl:template match="text()"></xsl:template>
</xsl:transform>
