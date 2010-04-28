<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
		xmlns:atom="http://www.w3.org/2005/Atom"
		xmlns:dc="http://purl.org/dc/elements/1.1/"
		xmlns:uri ="http://www.w3.org/2000/07/uri43/uri.xsl?template="
		exclude-result-prefixes="xhtml uri"
        version="1.0">
		
<xsl:import href="uri.xsl" />

<xsl:import href="url-encode.xsl" />

<xsl:strip-space elements="*"/>

<xsl:output method="xml" 
		   indent="yes" 
		   encoding="UTF-8" 
		   media-type="application/xml"/>

<!-- hAudio 2 RSS2 *Stable* by Martin McEvoy $version 5.5 updated Wednesday, March 31 2010 $contact info@weborganics.co.uk-->

<!-- base of the current HTML doc set by Processor-->
<xsl:param name="base-uri" select="''"/>

<xsl:param name="version" select="''"/>

<xsl:param name="generator">
	<xsl:text>TransFormr Version </xsl:text>
	<xsl:value-of select="$version" />
</xsl:param>

<!-- url encoded base of the current HTML doc set by Processor -->
<xsl:param name="base-encoded">
	<xsl:call-template name="url-encode">
		<xsl:with-param name="str" select="$base-uri"/> 
	</xsl:call-template>
</xsl:param>

<!-- No date found set by Processor-->
<xsl:param name="date" select="''"/>

<xsl:param name="parser">
	<xsl:text>http://transformr.co.uk/haudio-rss/</xsl:text>
</xsl:param>

<xsl:param name="start" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' haudio ') and descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' item ')]]"/>

<xsl:param name="index" select="$base-uri" />

<xsl:template match="/">

<rss version="2.0" xml:base="{$base-uri}">
<channel>
<atom:link rel="self" href="{$parser}{$index}" type="application/rss+xml" />
    <xsl:apply-templates/>
	<xsl:call-template name="item"/>
</channel>
</rss>
 </xsl:template>


<!-- ==============================================Channel===============================================-->
<xsl:template match="xhtml:html">
<xsl:variable name="description" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' description ')]"/>
<xsl:variable name="published" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' published ')][1]"/>
<title><xsl:value-of select="//xhtml:*[name() = 'title']"/></title>
<link><xsl:value-of select="$index"/></link>
<xsl:choose>
     <xsl:when test="$published">
		<dc:date><xsl:value-of select="$published/@title" /></dc:date>
	</xsl:when>
    <xsl:otherwise>
		<dc:date><xsl:value-of select="$date" /></dc:date>
    </xsl:otherwise>
</xsl:choose>
<xsl:choose>
     <xsl:when test="$description">
		<description>
			<xsl:value-of select="$description" />
		</description>
	</xsl:when>
    <xsl:otherwise>
		<description><xsl:value-of select="$index" /></description>
    </xsl:otherwise>
</xsl:choose>
<generator><xsl:value-of select="$generator"/></generator>
</xsl:template>

<!-- ==============================================Item===============================================-->
<xsl:template name="item">
<xsl:variable name="hasItem" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' item ') and descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' fn ')]]"/>
<xsl:variable name="hasAudio" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' haudio ') and descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' fn ')]]"/>
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
		<xsl:call-template name="keywords"/>
	</xsl:element>
</xsl:template>

<!-- ==============================================Title===============================================-->
<xsl:template name="title">
<xsl:variable name="title" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' fn ')]"/>
<xsl:variable name="titleold" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' title ')]"/>
<xsl:choose>
     <xsl:when test="$title">
        <xsl:element name='title'>
            <xsl:value-of select="$title"/>
        </xsl:element>
    </xsl:when>
     <xsl:when test="$titleold">
        <xsl:element name='title'>
            <xsl:value-of select="$titleold"/>
        </xsl:element>
    </xsl:when>
</xsl:choose>
</xsl:template>

<!-- ==============================================Title@href===============================================-->
<xsl:template name="link">
<xsl:variable name="href" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' fn ')]/xhtml:*[name() = 'a']"/>
     <xsl:if test="$href">
		<xsl:element name='link'>
			<xsl:call-template name="extract-resource">
				<xsl:with-param name="resource" select="$href/@href" />
			</xsl:call-template>
		</xsl:element>
		<xsl:element name='guid'>
  			<xsl:attribute name='isPermaLink'>
				<xsl:text>true</xsl:text>
			</xsl:attribute>
			<xsl:call-template name="extract-resource">
				<xsl:with-param name="resource" select="$href/@href" />
			</xsl:call-template>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- ==============================================Published===============================================-->
<xsl:template name="pubDate">
<xsl:variable name="published" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' published ')]"/>
	<xsl:if test="$published">
		<xsl:element name='dc:date'>
			<xsl:for-each select="$published">
			<xsl:choose>
            	<xsl:when test="descendant::*[contains(concat(' ', normalize-space(@class), ' '),' value-title ')]">
					<xsl:for-each select="descendant::*[contains(concat(' ', normalize-space(@class), ' '),' value-title ')]">
						<xsl:value-of select="normalize-space(@title)"/>					
					</xsl:for-each>
				</xsl:when>
            	<xsl:otherwise>
					<xsl:value-of select="@title"/>
            	</xsl:otherwise>
            </xsl:choose>
		</xsl:for-each>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- ==============================================Contributor===============================================-->
<xsl:template name="author">
<xsl:variable name="name" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' contributor ')]"/>
    <xsl:if test="$name">
		<xsl:for-each select="$name">
			<xsl:element name='dc:contributor'>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:for-each>
	</xsl:if>
</xsl:template>

<!-- ==============================================Description===============================================-->
<xsl:template name="itemDescription">
<xsl:variable name="itemDesc" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' description ')]"/>
	<xsl:if test="$itemDesc">
		<xsl:element name='description'>
		     <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
				<xsl:for-each select="$itemDesc">
					<xsl:apply-templates mode="safe-html" />
          		</xsl:for-each>
		     <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- ==============================================Enclosure===============================================-->
<xsl:template name="enclosure">
<xsl:param name="enclosure" select="descendant::*[contains(concat(' ',normalize-space(@rel),' '),' enclosure ')]"/>
	<xsl:if test="$enclosure">
	    <xsl:for-each select="$enclosure">
		<xsl:element name='enclosure'>
			<xsl:attribute name="url">
				<xsl:call-template name="extract-resource">
					<xsl:with-param name="resource" select="@href" />
				</xsl:call-template>
			</xsl:attribute>
			<xsl:attribute name="type">
			<xsl:choose>
				<xsl:when test="substring-before(normalize-space(@type),';length=')" >
					<xsl:value-of select="substring-before(normalize-space(@type),';length=')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@type" />
				</xsl:otherwise>
			</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="length">
			<xsl:choose>
				<xsl:when test="substring-after(normalize-space(@type),';length=')" >
					<xsl:value-of select="substring-after(normalize-space(@type),';length=')" />
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

<!-- ==============================================Duration===============================================-->
<!-- <xsl:template name="duration">
<xsl:variable name="time" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' duration ')]"/>
	<xsl:for-each select="$time">
		<xsl:element name='itunes:duration'>
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
		</xsl:element>
	</xsl:for-each>
</xsl:template> -->

<!-- ==============================================Tag===============================================-->
<xsl:template name="keywords">
<xsl:variable name="tag" select="descendant::xhtml:*[contains(concat(' ',normalize-space(@rel),' '),' tag ')]"/>
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

<!-- <xsl:template name="extract-duration">
<xsl:param name="this-duration"/>
<xsl:param name="before" select="substring-before($this-duration,'S')" />
<xsl:param name="after" select="substring-after($before,'PT')" />
<xsl:param name="minute" select="substring-before($after,'M')" />
<xsl:param name="seconds" select="substring-after($after,'M')" />
<xsl:value-of select="$minute"/>
<xsl:text>:</xsl:text>
<xsl:value-of select="$seconds"/>
</xsl:template> -->

<!-- extract @href, @src and @data  -->
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

<xsl:template mode="safe-html" 
              match="xhtml:a|xhtml:abbr|xhtml:acronym|xhtml:address|xhtml:area|xhtml:b|xhtml:big|xhtml:blockquote|xhtml:br|xhtml:button|
					 xhtml:caption|xhtml:center|xhtml:cite|xhtml:code|xhtml:col|xhtml:colgroup|xhtml:dd|xhtml:del|xhtml:dfn|xhtml:dir|
                     xhtml:div|xhtml:dl|xhtml:dt|xhtml:em|xhtml:fieldset|xhtml:font|xhtml:form|xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|
                     xhtml:h6|xhtml:hr|xhtml:i|xhtml:img|xhtml:input|xhtml:ins|xhtml:kbd|xhtml:label|xhtml:legend|xhtml:li|xhtml:map|xhtml:menu|
                     xhtml:ol|xhtml:optgroup|xhtml:option|xhtml:p|xhtml:pre|xhtml:q|xhtml:s|xhtml:samp|xhtml:select|xhtml:small|xhtml:span|
                     xhtml:strike|xhtml:strong|xhtml:sub|xhtml:sup|xhtml:table|xhtml:tbody|xhtml:td|xhtml:textarea|xhtml:tfoot|xhtml:th|
                     xhtml:thead|xhtml:tr|xhtml:tt|xhtml:u|xhtml:ul|xhtml:var|a|abbr|acronym|address|area|b|big|blockquote|br|button|caption|
                     center|cite|code|col|colgroup|dd|del|dfn|dir|div|dl|dt|em|fieldset|font|form|h1|h2|h3|h4|h5|h6|hr|i|img|input|ins|kbd|
                     label|legend|li|map|menu|ol|optgroup|option|p|pre|q|s|samp|select|small|span|strike|strong|sub|sup|table|tbody|td|
                     textarea|tfoot|th|thead|tr|tt|u|ul|var|@*">  

	<xsl:copy>
	<!--
	 Copy the attributes listed bellow.
	 The list of acceptable attributes was taken from Mark Pilgrim's Universal Feed Parser.
	 (xml:lang and xml:base were added)
	-->
		<xsl:for-each select="@abbr|@accept|@accept-charset|@accesskey|@action|@align|@alt|@axis|@border|@cellpadding|@cellspacing|
       						  @char|@charoff|@charset|@checked|@cite|@class|@clear|@cols|@colspan|@color|@compact|@coords|@datetime|
                              @dir|@disabled|@enctype|@for|@frame|@headers|@height|@href|@hreflang|@hspace|@id|@ismap|@label|@lang|
                              @longdesc|@maxlength|@media|@method|@multiple|@name|@nohref|@noshade|@nowrap|@prompt|@readonly|@rel|@rev|
							  @rows|@rowspan|@rules|@scope|@selected|@shape|@size|@span|@src|@start|@summary|@tabindex|@target|@title|@type|
                              @usemap|@valign|@value|@vspace|@width|@xml:lang|@xml:base">
			<xsl:copy />
		</xsl:for-each>
		<xsl:apply-templates mode="safe-html" />
	</xsl:copy>

</xsl:template>

<xsl:template mode="safe-html" match="text()">
	<xsl:copy />
</xsl:template>

<!-- Inhibt all other elements -->
<xsl:template mode="safe-html" match="*" />

<!-- strip text -->
<xsl:template match="text()"></xsl:template>
</xsl:stylesheet>
