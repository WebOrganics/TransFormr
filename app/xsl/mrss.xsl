<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
   		xmlns:media="http://search.yahoo.com/mrss/"
		xmlns:dc="http://purl.org/dc/elements/1.1/"
		xmlns:atom="http://www.w3.org/2005/Atom"
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
		exclude-result-prefixes="xhtml"
        version="1.0">

<xsl:strip-space elements="*"/>

<xsl:output method="xml" 
		   indent="yes" 
		   encoding="UTF-8" 
		   media-type="application/rss+xml"/>

<!-- base of the current HTML doc set by Processor-->
<xsl:param name="base-uri" select="''"/>

<xsl:param name="version" select="''"/>

<xsl:param name="generator">
	<xsl:text>TransFormr Version </xsl:text>
	<xsl:value-of select="$version" />
</xsl:param>

<xsl:param name="parser">
	<xsl:text>http://transformr.co.uk/mrss/</xsl:text>
</xsl:param>

<xsl:template match="/">
<xsl:param name="entry" select="//*[contains(concat(' ',normalize-space(attribute::class),' '),' hentry ')]"/>
<xsl:param name="meta" select="//*[contains(concat(' ',normalize-space(attribute::name),' '),' description ')]"/>
<rss version="2.0">
<channel>
<atom:link href="{$parser}{$base-uri}" rel="self" type="application/rss+xml" />
	<title><xsl:value-of select="//*[name() = 'title']"/></title>
	<link><xsl:value-of select="$base-uri"/></link>
	<generator><xsl:value-of select="$generator"/></generator>
	<description><xsl:value-of select="$meta/attribute::content"/></description>
	<xsl:for-each select="$entry">
	 	<xsl:element name='item'>
			<xsl:call-template name="attributes"/>
		</xsl:element>
	</xsl:for-each>
    <xsl:apply-templates/>
</channel>
</rss>
 </xsl:template>

<xsl:template name="attributes">
	<xsl:call-template name="title"/>
	<xsl:call-template name="pubdate"/>
	<xsl:call-template name="permalink"/>
	<xsl:call-template name="author-name"/>
	<xsl:call-template name="entry-summary"/>
	<xsl:call-template name="entry-content"/>
	<xsl:call-template name="media"/>
	<xsl:call-template name="keywords"/>
	<xsl:call-template name="media-enclosure"/>
</xsl:template>

<xsl:template name="title">
<xsl:param name="entry-title" select="descendant::*[contains(concat(' ',normalize-space(attribute::class),' '),' entry-title ')]"/>
	<xsl:if test="$entry-title">
		<xsl:element name='title'>
			<xsl:value-of select="$entry-title"/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="pubdate">
<xsl:param name="updated" select="descendant::*[contains(concat(' ',normalize-space(attribute::class),' '),' updated ')]"/>
<xsl:param name="published" select="descendant::*[contains(concat(' ',normalize-space(attribute::class),' '),' published ')]"/>
	<xsl:if test="$updated or $updated">
		<xsl:element name='dc:date'>
			<xsl:value-of select="$published/attribute::title|$updated/attribute::title"/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="permalink">
<xsl:param name="bookmark" select="descendant::*[contains(concat(' ',normalize-space(attribute::rel),' '),' bookmark ')]"/>
	<xsl:if test="$bookmark">
		<xsl:choose>
			<xsl:when test="substring-before($bookmark/attribute::href,':') = 'http'" >
				<xsl:element name='guid'>
					<xsl:attribute name="isPermaLink">
						<xsl:text>true</xsl:text>
					</xsl:attribute>
					<xsl:value-of select="$bookmark/attribute::href"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name='guid'>
					<xsl:attribute name="isPermaLink">
						<xsl:text>true</xsl:text>
					</xsl:attribute>
					<xsl:value-of select="$base-uri"/>
					<xsl:value-of select="$bookmark/attribute::href"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<xsl:template name="author-name">
<xsl:param name="name" select="descendant::*[contains(concat(' ',normalize-space(attribute::class),' '),' author ')]"/>
	<xsl:if test="$name">
		<xsl:element name='dc:creator'>
			<xsl:value-of select="$name"/>
		</xsl:element>
	</xsl:if>
</xsl:template>


<xsl:template name="entry-summary">
<xsl:param name="summary" select="descendant::*[contains(concat(' ',normalize-space(attribute::class),' '),' entry-summary ')]"/>
	<xsl:if test="$summary">
		<xsl:element name='description'>
			<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
				<xsl:copy-of select="$summary"/>
			<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="entry-content">
<xsl:param name="content" select="descendant::*[contains(concat(' ',normalize-space(attribute::class),' '),' entry-content ')]"/>
	<xsl:if test="$content">
		<xsl:element name='description'>
			<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
          <xsl:for-each select="$content">
              	<xsl:copy>
					<xsl:apply-templates mode="sanitize-html" />
				</xsl:copy>
          </xsl:for-each>
			<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="media">
<xsl:param name="hmedia" select="descendant::*[contains(concat(' ',normalize-space(attribute::class),' '),' hmedia ')]"/>
	<xsl:if test="$hmedia">
	    <xsl:for-each select="$hmedia">
        <xsl:call-template name="media-attributes"/>
		</xsl:for-each>
	</xsl:if>
</xsl:template>

<xsl:template name="keywords">
<xsl:variable name="tag" select="descendant::*[contains(concat(' ',normalize-space(attribute::rel),' '),' tag ')]"/>
	<xsl:if test="$tag">
		<xsl:element name='dc:subject'>
      	<xsl:for-each select="$tag">
        			<xsl:value-of select="."/>
                <xsl:if test="not(position()=last())">
                    <xsl:text >, </xsl:text>
              </xsl:if>
      		</xsl:for-each>
     </xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="media-attributes">
<xsl:variable name="url" select="descendant::*[contains(concat(' ',normalize-space(attribute::rel),' '),' enclosure ')]"/>
	<xsl:element name='media:content'>
		<xsl:attribute name="url"><xsl:value-of select="$url/attribute::href" /></xsl:attribute>
		<xsl:attribute name="type">
			<xsl:choose>
				<xsl:when test="substring-before(normalize-space($url/attribute::type),';length=')" >
					<xsl:value-of select="substring-before(normalize-space($url/attribute::type),';length=')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$url/attribute::type" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:if test="substring-after(normalize-space($url/attribute::type),';length=')">
			<xsl:attribute name="fileSize">
				<xsl:value-of select="substring-after(normalize-space($url/attribute::type),';length=')" />
			</xsl:attribute>
		</xsl:if>
		<xsl:call-template name="media-name"/>
		<xsl:call-template name="media-contributor"/>
		<xsl:call-template name="media-img"/>		
		<xsl:call-template name="media-player"/>
	</xsl:element>
</xsl:template>


<xsl:template name="media-name">
<xsl:param name="media-title" select="descendant::*[contains(concat(' ',normalize-space(attribute::class),' '),' fn ')
									  and not(ancestor::*[contains(concat(' ',normalize-space(attribute::class),' '),' contributor ')])
									  and not(ancestor::*[contains(concat(' ',normalize-space(attribute::class),' '),' author ')])]"/>
	<xsl:if test="$media-title">
		<xsl:element name='media:title'>
			<xsl:value-of select="$media-title"/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="media-contributor">
<xsl:param name="contributor" select="descendant::*[contains(concat(' ',normalize-space(attribute::class),' '),' contributor ')]"/>
	<xsl:for-each select="$contributor">
		<xsl:element name='media:credit'>
			<xsl:choose>
				<xsl:when test="descendant::*[contains(concat(' ',normalize-space(attribute::class),' '),' fn ')]" >
					<xsl:value-of select="descendant::*[contains(concat(' ',normalize-space(attribute::class),' '),' fn ')]" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:for-each>
</xsl:template>

<xsl:template name="media-img">
<xsl:param name="photo" select="descendant::*[contains(concat(' ',normalize-space(attribute::class),' '),' photo ')]"/>
	<xsl:if test="$photo">
		<xsl:element name='media:thumbnail'>
			<xsl:attribute name="url"><xsl:value-of select="$photo/attribute::src" /></xsl:attribute>
				<xsl:if test="$photo/attribute::width">
					<xsl:attribute name="width"><xsl:value-of select="$photo/attribute::width" /></xsl:attribute>
				</xsl:if>
				<xsl:if test="$photo/attribute::height">
					<xsl:attribute name="height"><xsl:value-of select="$photo/attribute::height" /></xsl:attribute>
				</xsl:if>
		</xsl:element>
	</xsl:if>
</xsl:template>


<xsl:template name="media-player">
<xsl:param name="video" select="descendant::*[contains(concat(' ',normalize-space(attribute::class),' '),' player ')]"/>
	<xsl:if test="$video">
		<xsl:element name='media:player'>
			<xsl:attribute name="url"><xsl:value-of select="$video/attribute::data" /></xsl:attribute>
				<xsl:if test="$video/attribute::width">
					<xsl:attribute name="width"><xsl:value-of select="$video/attribute::width" /></xsl:attribute>
				</xsl:if>
				<xsl:if test="$video/attribute::height">
					<xsl:attribute name="height"><xsl:value-of select="$video/attribute::height" /></xsl:attribute>
				</xsl:if>
		</xsl:element>
	</xsl:if>
</xsl:template>


<xsl:template name="media-enclosure">
<xsl:param name="enclosure" select="descendant::*[contains(concat(' ',normalize-space(attribute::rel),' '),' enclosure ')]"/>
	<xsl:if test="$enclosure">
	    <xsl:for-each select="$enclosure">
		<xsl:element name='enclosure'>
			<xsl:attribute name="url"><xsl:value-of select="attribute::href" /></xsl:attribute>
			<xsl:attribute name="type">
			<xsl:choose>
				<xsl:when test="substring-before(normalize-space(attribute::type),';length=')" >
					<xsl:value-of select="substring-before(normalize-space(attribute::type),';length=')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="attribute::type" />
				</xsl:otherwise>
			</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="length">
			<xsl:choose>
				<xsl:when test="substring-after(normalize-space(attribute::type),';length=')" >
					<xsl:value-of select="substring-after(normalize-space(attribute::type),';length=')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>0</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			</xsl:attribute>
		</xsl:element>
		</xsl:for-each>
	</xsl:if>
</xsl:template>

<!-- 
 Sanitize HTML output
-->
<!-- 
 Copy the elements listed bellow.
 
 The list of acceptable elements was taken from Mark Pilgrim's Universal Feed Parser.
-->

<xsl:template mode="sanitize-html" 
              match="xhtml:a|xhtml:abbr|xhtml:acronym|xhtml:address|xhtml:area|
xhtml:b|xhtml:big|xhtml:blockquote|xhtml:br|xhtml:button|
xhtml:caption|xhtml:center|xhtml:cite|xhtml:code|xhtml:col|xhtml:colgroup|
xhtml:dd|xhtml:del|xhtml:dfn|xhtml:dir|xhtml:div|xhtml:dl|xhtml:dt|
xhtml:em|
xhtml:fieldset|xhtml:font|xhtml:form|
xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|xhtml:h6|xhtml:hr|
xhtml:i|xhtml:img|xhtml:input|xhtml:ins|
xhtml:kbd|
xhtml:label|xhtml:legend|xhtml:li|
xhtml:map|xhtml:menu|
xhtml:ol|xhtml:optgroup|xhtml:option|
xhtml:p|xhtml:pre|xhtml:q|xhtml:s|
xhtml:samp|xhtml:select|xhtml:small|xhtml:span|xhtml:strike|xhtml:strong|xhtml:sub|xhtml:sup|
xhtml:table|xhtml:tbody|xhtml:td|xhtml:textarea|xhtml:tfoot|xhtml:th|xhtml:thead|xhtml:tr|xhtml:tt|
xhtml:u|xhtml:ul|
xhtml:var|@*">  

	<xsl:copy>
	<!--
	 Copy the attributes listed bellow.
	 The list of acceptable attributes was taken from Mark Pilgrim's Universal Feed Parser.
	 (xml:lang and xml:base were added)
	-->
		<xsl:for-each select="@abbr|@accept|@accept-charset|@accesskey|@action|@align|@alt|@axis|
@border|
@cellpadding|@cellspacing|@char|@charoff|@charset|@checked|@cite|@class|@clear|
@cols|@colspan|@color|@compact|@coords|
@datetime|@dir|@disabled|@enctype|
@for|@frame|
@headers|@height|@href|@hreflang|@hspace|
@id|@ismap|
@label|@lang|@longdesc|
@maxlength|@media|@method|@multiple|
@name|
@nohref|@noshade|@nowrap|
@prompt|
@readonly|@rel|@rev|
@rows|@rowspan|@rules|
@scope|@selected|@shape|@size|
@span|@src|@start|@summary|
@tabindex|@target|@title|@type|
@usemap|
@valign|@value|@vspace|
@width|
@xml:lang|@xml:base">
			<xsl:copy />
		</xsl:for-each>
		<xsl:apply-templates mode="sanitize-html" />
	</xsl:copy>

</xsl:template>

<xsl:template mode="sanitize-html" match="text()">
	<xsl:copy />
</xsl:template>

<!-- Inhibt all other elements -->
<xsl:template mode="sanitize-html" match="*" />

<!-- strip text -->
<xsl:template match="text()|*"></xsl:template>
</xsl:stylesheet>
