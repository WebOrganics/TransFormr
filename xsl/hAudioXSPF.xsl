<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns="http://xspf.org/ns/0/"
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
		xmlns:uri ="http://www.w3.org/2000/07/uri43/uri.xsl?template="
		exclude-result-prefixes="xhtml uri"
        version="1.0">
		
<xsl:strip-space elements="*"/>

<xsl:output method="xml" 
		   indent="yes" 
		   encoding="UTF-8" 
		   media-type="application/xml"/>

<xsl:param name='date' select="''"/>

<xsl:param name="base-uri" select="''"/>

<xsl:param name="start" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' haudio ') and descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' item ')]]"/>

<xsl:param name="index" select="$base-uri" />

<xsl:param name="items" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' item ') and descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' fn ')]]"/>

<xsl:param name="audio" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' haudio ') and descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' fn ')]]"/>

<xsl:template match="/xhtml:html">
<playlist version="1">
	<xsl:call-template name="playlist"/>
	<trackList>
	<xsl:choose>
     		<xsl:when test="$items">
			<xsl:call-template name="item"/>
		</xsl:when>
    		<xsl:otherwise>
			<xsl:call-template name="haudio"/>
    		</xsl:otherwise>
	</xsl:choose>
  	</trackList>
</playlist>
</xsl:template>

<!-- ==============================================playlist===============================================-->
<xsl:template name="playlist">
<xsl:param name="published" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' published ')][1]"/>
<title><xsl:value-of select="//xhtml:*[name() = 'title']"/></title>
<link rel="{$index}"><xsl:value-of select="$index"/></link>
<xsl:if test="$published">
<xsl:choose>
	<xsl:when test="$published/@title">
		<date><xsl:value-of select="$published/@title" /></date>
	</xsl:when>
	<xsl:otherwise>
		<date><xsl:value-of select="$published" /></date>
	</xsl:otherwise>
</xsl:choose>
</xsl:if>
</xsl:template>

<!-- ==============================================haudio===============================================-->
<xsl:template name="haudio">
  <xsl:for-each select="$audio">
	<xsl:element name='track'>
		<xsl:call-template name="title"/>
		<xsl:call-template name="creator"/>
		<xsl:call-template name="itemDescription"/>
		<xsl:call-template name="enclosure"/>
		<xsl:call-template name="photo"/>
		<xsl:call-template name="duration"/>
	</xsl:element>
  </xsl:for-each>
</xsl:template>

<!-- ==============================================Item===============================================-->
<xsl:template name="item">
  <xsl:for-each select="$items">
	<xsl:element name='track'>
		<xsl:call-template name="title"/>
		<xsl:call-template name="creator"/>
		<xsl:call-template name="itemDescription"/>
		<xsl:call-template name="enclosure"/>
		<xsl:call-template name="photo"/>
		<xsl:call-template name="duration"/>
	</xsl:element>
   </xsl:for-each>
</xsl:template>

<xsl:template name="title">
<xsl:param name="title" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' fn ') and not(ancestor::*[contains(concat(' ',normalize-space(attribute::class),' '),' vcard ')])]"/>
	<xsl:if test="$title">
		<xsl:element name='title'>
			<xsl:value-of select="$title"/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="creator">
<xsl:param name="name" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' contributor ')]"/>
	<xsl:if test="$name">
		<xsl:element name='creator'>
			<xsl:value-of select="$name"/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="itemDescription">
<xsl:param name="itemDesc" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' description ')]"/>
	<xsl:if test="$itemDesc">
		<xsl:element name='annotation'>
			<xsl:value-of select="$itemDesc"/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="enclosure">
<xsl:param name="enc" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@rel),' '),' enclosure ')]"/>
	<xsl:if test="$enc">
		<xsl:element name='location'>
			<xsl:call-template name="extract-resource">
				<xsl:with-param name="resource" select="$enc/@href" />
			</xsl:call-template>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="photo">
<xsl:param name="photo" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' photo ')]"/>
<xsl:if test="$photo">
	<xsl:element name='image'>
		<xsl:call-template name="extract-resource">
			<xsl:with-param name="resource" select="$photo/@src" />
		</xsl:call-template>
	</xsl:element>
</xsl:if>
</xsl:template>

<xsl:template name="duration">
<xsl:param name="time" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' duration ')]"/>
	<xsl:if test="$time">
		<xsl:element name='duration'>
		<xsl:for-each select="$time">
			<xsl:choose>
            	<xsl:when test="descendant::*[contains(concat(' ', normalize-space(@class), ' '),' value-title ')]">
					<xsl:for-each select="descendant::*[contains(concat(' ', normalize-space(@class), ' '),' value-title ')]">
						<xsl:call-template name="extract-duration">
							<xsl:with-param name="this-duration" select="@title" />
						</xsl:call-template>					
					</xsl:for-each>
				</xsl:when>
            	<xsl:otherwise>
					<xsl:call-template name="extract-duration">
						<xsl:with-param name="this-duration" select="@title" />
					</xsl:call-template>	
            	</xsl:otherwise>
            </xsl:choose>
		</xsl:for-each>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="extract-duration">
	<xsl:param name="this-duration"/>
	<xsl:param name="before" select="substring-before($this-duration,'S')" />
	<xsl:param name="after" select="substring-after($before,'PT')" />
	<xsl:param name="minute" select="substring-before($after,'M')" />
	<xsl:param name="seconds" select="substring-after($after,'M')" />
	
	<xsl:param name="mseconds" select="$seconds * 1000" />
	<xsl:param name="mminute" select="$minute * 60000" />

	<xsl:value-of select="$mminute + $mseconds"/>
</xsl:template>

<xsl:template name="extract-resource">
<xsl:param name="resource"/>
		<xsl:choose>
			<xsl:when test="substring-before($resource,':') = 'http'" >
				<xsl:value-of select="$resource"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="uri:expand">
					<xsl:with-param name="base">
						<xsl:choose>
							<xsl:when test="substring-before($base-uri,'#')">
								<xsl:value-of select="substring-before($base-uri,'#')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$base-uri"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="there" select="$resource"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
</xsl:template>

</xsl:stylesheet>
