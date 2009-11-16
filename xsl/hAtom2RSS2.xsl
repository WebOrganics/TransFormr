<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:dc="http://purl.org/dc/elements/1.1/"
		xmlns:atom="http://www.w3.org/2005/Atom"
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
 		xmlns:uri ="http://www.w3.org/2000/07/uri43/uri.xsl?template="
		exclude-result-prefixes="xhtml uri"
        version="1.0">
        
<xsl:import href="uri.xsl" />

<xsl:strip-space elements="*"/>

<xsl:output method="xml" 
		   indent="yes" 
		   encoding="UTF-8" 
		   media-type="application/rss+xml"/>

<!-- base of the current HTML doc set by Processor-->
<xsl:param name="base-uri" select="''"/>

<!-- title of the current HTML doc set by Processor ( for fragment parsing ) -->
<xsl:param name="doc-title" select="''"/>

<xsl:param name="generator">
	<xsl:text>TransFormr Version 0.5</xsl:text>
</xsl:param>

<xsl:param name="parser">
	<xsl:text>http://transformr.co.uk/rss2/</xsl:text>
</xsl:param>

<xsl:template match="/">
<xsl:param name="entry" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' hentry ')]"/>

<xsl:param name="meta">
	<xsl:choose>
		<xsl:when test=".//*[contains(concat(' ',normalize-space(@name),' '),' description ')]">
    		<xsl:value-of select=".//*[contains(concat(' ',normalize-space(@name),' '),' description ')]/@content" />
    	</xsl:when>
    	<xsl:otherwise>
            <xsl:text>From: </xsl:text>
    		<xsl:value-of select="$base-uri" />
    	</xsl:otherwise>
	</xsl:choose>
</xsl:param>

<rss version="2.0">
<channel>
<atom:link rel="self" href="{$parser}{$base-uri}" type="application/rss+xml" />
	<title>
    	<xsl:choose>
        	<xsl:when test=".//*[name() = 'title']">
            	<xsl:value-of select=".//*[name() = 'title']"/>
            </xsl:when>
            <xsl:otherwise>
            	<xsl:value-of select="$doc-title"/>
            </xsl:otherwise>
        </xsl:choose>
    </title>
	<link><xsl:value-of select="$base-uri"/></link>
	<generator><xsl:value-of select="$generator"/></generator>
	<description><xsl:value-of select="$meta"/></description>
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
	<xsl:call-template name="entry-content"/>
	<xsl:call-template name="keywords"/>
	<xsl:call-template name="media-enclosure"/>
</xsl:template>

<xsl:template name="title">
<xsl:param name="entry-title" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' entry-title ')]"/>
	<xsl:if test="$entry-title">
		<xsl:element name='title'>
			<xsl:value-of select="normalize-space($entry-title)"/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="pubdate">
<xsl:param name="updated" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' updated ')]"/>
<xsl:param name="published" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' published ')]"/>
	<xsl:if test="$updated or $published">
		<xsl:element name='dc:date'>
		<xsl:for-each select="$updated|$published">
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

<xsl:template name="permalink">
<xsl:param name="bookmark" select="descendant::*[contains(concat(' ',normalize-space(@rel),' '),' bookmark ')]"/>
	<xsl:if test="$bookmark">
		<xsl:choose>
			<xsl:when test="substring-before($bookmark/@href,':') = 'http'" >
				<xsl:element name='guid'>
					<xsl:attribute name="isPermaLink">
						<xsl:text>true</xsl:text>
					</xsl:attribute>
					<xsl:value-of select="$bookmark/@href"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name='guid'>
					<xsl:attribute name="isPermaLink">
						<xsl:text>true</xsl:text>
					</xsl:attribute>
						<xsl:call-template name="uri:expand">
							<xsl:with-param name="base" select="$base-uri"/>
							<xsl:with-param name="there" select="$bookmark/@href"/>
						</xsl:call-template>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<xsl:template name="author-name">
<xsl:param name="name" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' author ')]"/>
	<xsl:if test="$name">
		<xsl:element name='dc:creator'>
			<xsl:value-of select="normalize-space($name)"/>
		</xsl:element>
	</xsl:if>
</xsl:template>


<xsl:template name="entry-summary">
<xsl:param name="summary" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' entry-summary ')]"/>
	<xsl:if test="$summary">
		<xsl:element name='description'>
			<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
          		<xsl:for-each select="$summary">
					<xsl:apply-templates mode="sanitize-html" />
          		</xsl:for-each>
			<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="entry-content">
<xsl:param name="content" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' entry-content ')]"/>
	<xsl:if test="$content">
		<xsl:element name='description'>
			<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
          		<xsl:for-each select="$content">
					<xsl:apply-templates mode="sanitize-html" />
          		</xsl:for-each>
			<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="keywords">
<xsl:variable name="tag" select="descendant::*[contains(concat(' ',normalize-space(@rel),' '),' tag ')]"/>
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


<xsl:template name="media-enclosure">
<xsl:param name="enclosure" select="descendant::*[contains(concat(' ',normalize-space(@rel),' '),' enclosure ')]"/>
	<xsl:if test="$enclosure">
	    <xsl:for-each select="$enclosure">
		<xsl:element name='enclosure'>
			<xsl:attribute name="url"><xsl:value-of select="@href" /></xsl:attribute>
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

<!-- 

 Sanitize HTML output Re-Used from hAtom2Atom.xsl by Luke Arno, Robert Bachmann and Benjamin Carlyle.
 
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
		<xsl:for-each select="@abbr|@accept|@accept-charset|@accesskey|@action|@align|@alt|@axis|@border|
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
