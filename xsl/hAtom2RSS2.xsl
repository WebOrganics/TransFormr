<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:dc="http://purl.org/dc/elements/1.1/"
		xmlns:atom="http://www.w3.org/2005/Atom"
		xmlns:media="http://search.yahoo.com/mrss/"
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
 		xmlns:uri ="http://www.w3.org/2000/07/uri43/uri.xsl?template="
		exclude-result-prefixes="xhtml uri"
        version="1.0">
        
<xsl:import href="uri.xsl" />

<xsl:import href="url-encode.xsl" />

<xsl:strip-space elements="*"/>

<xsl:output method="xml" 
		   indent="yes" 
		   encoding="UTF-8" 
		   media-type="application/rss+xml"/>

<!-- base of the current HTML doc set by Processor-->
<xsl:param name="base-uri" select="''"/>

<xsl:param name="version" select="''"/>

<!-- url encoded base of the current HTML doc set by Processor -->
<xsl:param name="base-encoded">
	<xsl:call-template name="url-encode">
		<xsl:with-param name="str" select="$base-uri"/> 
	</xsl:call-template>
</xsl:param>

<!-- title of the current HTML doc set by Processor ( for fragment parsing ) -->
<xsl:param name="doc-title" select="''"/>

<xsl:param name="generator">
	<xsl:text>TransFormr Version </xsl:text>
	<xsl:value-of select="$version" />
</xsl:param>

<xsl:param name="parser">
	<xsl:text>http://transformr.co.uk/?type=rss2&amp;url=</xsl:text>
</xsl:param>

<xsl:template match="/">
<xsl:param name="entry" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' hentry ')]"/>

<xsl:param name="meta">
	<xsl:choose>
		<xsl:when test="descendant::*[contains(concat(' ',normalize-space(@name),' '),' description ')]">
    		<xsl:value-of select="descendant::*[contains(concat(' ',normalize-space(@name),' '),' description ')]/@content" />
    	</xsl:when>
    	<xsl:otherwise>
            <xsl:text>From: </xsl:text>
    		<xsl:value-of select="$base-uri" />
    	</xsl:otherwise>
	</xsl:choose>
</xsl:param>

<rss version="2.0" xml:base="{$base-uri}">
<channel>
<atom:link rel="self" href="{$parser}{$base-encoded}" type="application/rss+xml" />
	<title>
    	<xsl:choose>
        	<xsl:when test="descendant::*[name() = 'title']">
            	<xsl:value-of select="descendant::*[name() = 'title']"/>
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
<xsl:param name="summary" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' entry-summary ')]"/>
<xsl:param name="content" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' entry-content ')]"/>
	<xsl:call-template name="title"/>
	<xsl:call-template name="pubdate"/>
	<xsl:call-template name="permalink"/>
	<xsl:call-template name="author-name"/>
   	<xsl:choose>
    	<xsl:when test="$summary">
        	<xsl:call-template name="entry-summary"/>
        </xsl:when>
        <xsl:otherwise>
        	<xsl:call-template name="entry-content"/>
        </xsl:otherwise>
    </xsl:choose>
	<xsl:call-template name="keywords"/>
	<xsl:call-template name="media"/>
	<xsl:call-template name="media-enclosure"/>
</xsl:template>

<!-- entry-title -->
<xsl:template name="title">
<xsl:param name="entry-title" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' entry-title ')]"/>
	<xsl:if test="$entry-title">
		<xsl:element name='title'>
			<xsl:value-of select="normalize-space($entry-title)"/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- updated or published -->
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

<!-- bookmark -->
<xsl:template name="permalink">
<xsl:param name="bookmark" select="descendant::*[contains(concat(' ',normalize-space(@rel),' '),' bookmark ')]"/>
	<xsl:if test="$bookmark">
		<xsl:element name='guid'>
			<xsl:attribute name="isPermaLink">
				<xsl:text>true</xsl:text>
			</xsl:attribute>
			<xsl:call-template name="extract-resource">
				<xsl:with-param name="resource" select="$bookmark/@href"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- author -->
<xsl:template name="author-name">
<xsl:param name="name" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' author ') or contains(concat(' ',normalize-space(@class),' '),' fn ')]"/>
	<xsl:if test="$name">
		<xsl:element name='dc:creator'>
			<xsl:value-of select="normalize-space($name)"/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- entry-summary -->
<xsl:template name="entry-summary">
<xsl:param name="summary" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' entry-summary ')][1]"/>
	<xsl:if test="$summary">
		<xsl:element name='description'>
			<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
          		<xsl:for-each select="$summary">
					<xsl:apply-templates mode="safe-html" />
          		</xsl:for-each>
			<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- entry-content -->
<xsl:template name="entry-content">
<xsl:param name="content" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' entry-content ')][1]"/>
	<xsl:if test="$content">
		<xsl:element name='description'>
			<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
          		<xsl:for-each select="$content">
					<xsl:apply-templates mode="safe-html" />
          		</xsl:for-each>
			<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- tag -->
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


<!-- Start hMedia to MRSS extensions for RSS2 -->

<!-- match hmedia and enclosure -->
<xsl:template name="media">
<xsl:param name="hmedia" select="descendant-or-self::*[contains(concat(' ',normalize-space(@class),' '),' hmedia ')]"/>
<xsl:param name="enc" select="descendant::*[contains(concat(' ',normalize-space(@rel),' '),' enclosure ')]"/>
	<xsl:if test="$hmedia and $enc">
	    <xsl:for-each select="$hmedia">
			<xsl:call-template name="media-attributes">
				<xsl:with-param name="url" select="$enc"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:if>
</xsl:template>

<!-- hmedia enclosure -->
<xsl:template name="media-attributes">
<xsl:param name="url"/>
	<xsl:element name='media:content'>
		<xsl:attribute name="url">
			<xsl:call-template name="extract-resource">
				<xsl:with-param name="resource" select="$url/@href" />
			</xsl:call-template>
		</xsl:attribute>
		<xsl:attribute name="type">
			<xsl:choose>
				<xsl:when test="substring-before(normalize-space($url/@type),';length=')" >
					<xsl:value-of select="substring-before(normalize-space($url/@type),';length=')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$url/@type" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:if test="substring-after(normalize-space($url/@type),';length=')">
			<xsl:attribute name="fileSize">
				<xsl:value-of select="substring-after(normalize-space($url/@type),';length=')" />
			</xsl:attribute>
		</xsl:if>
		<xsl:call-template name="media-name"/>
		<xsl:call-template name="media-contributor"/>
		<xsl:call-template name="media-img"/>		
		<xsl:call-template name="media-player"/>
	</xsl:element>
</xsl:template>

<!-- hmedia fn -->
<xsl:template name="media-name">
<xsl:param name="media-title" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')
									  and not(ancestor::*[contains(concat(' ',normalize-space(@class),' '),' contributor ')])
									  and not(ancestor::*[contains(concat(' ',normalize-space(@class),' '),' author ')])]"/>
	<xsl:if test="$media-title">
		<xsl:element name='media:title'>
			<xsl:value-of select="$media-title"/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- hmedia contributor -->
<xsl:template name="media-contributor">
<xsl:param name="contributor" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' contributor ')]"/>
	<xsl:for-each select="$contributor">
		<xsl:element name='media:credit'>
			<xsl:choose>
				<xsl:when test="descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')]" >
					<xsl:value-of select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')]" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:for-each>
</xsl:template>

<!-- hmedia photo -->
<xsl:template name="media-img">
<xsl:param name="photo" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' photo ')]"/>
	<xsl:if test="$photo">
		<xsl:element name='media:thumbnail'>
			<xsl:attribute name="url">
				<xsl:call-template name="extract-resource">
					<xsl:with-param name="resource" select="$photo/@src" />
				</xsl:call-template>
			</xsl:attribute>
				<xsl:if test="$photo/@width">
					<xsl:attribute name="width"><xsl:value-of select="$photo/@width" /></xsl:attribute>
				</xsl:if>
				<xsl:if test="$photo/@height">
					<xsl:attribute name="height"><xsl:value-of select="$photo/@height" /></xsl:attribute>
				</xsl:if>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- hmedia player -->
<xsl:template name="media-player">
<xsl:param name="video" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' player ')]"/>
	<xsl:if test="$video">
		<xsl:element name='media:player'>
			<xsl:attribute name="url">
				<xsl:call-template name="extract-resource">
					<xsl:with-param name="resource" select="$video/@data|$video/@src|$video/@value" />
				</xsl:call-template>
			</xsl:attribute>
				<xsl:if test="$video/@width">
					<xsl:attribute name="width"><xsl:value-of select="$video/@width" /></xsl:attribute>
				</xsl:if>
				<xsl:if test="$video/@height">
					<xsl:attribute name="height"><xsl:value-of select="$video/@height" /></xsl:attribute>
				</xsl:if>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- /End hMedia to MRSS extensions -->


<!-- rel-enclosure extension -->
<xsl:template name="media-enclosure">
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

<!-- 

 Safe HTML output Re-Used from hAtom2Atom.xsl by Luke Arno, Robert Bachmann and Benjamin Carlyle. 
 
 Updated by Martin McEvoy to match both XHTML and HTML elements. 
 
 The list of acceptable elements was taken from Mark Pilgrim's Universal Feed Parser.
 
-->

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
<xsl:template match="text()|*"></xsl:template>
</xsl:stylesheet>
