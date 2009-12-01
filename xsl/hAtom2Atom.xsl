<!--
                                hAtom2Atom.xsl
   An XSLT stylesheet for transforming hAtom documents into Atom documents.
                          (last updated: 2007-08-09)

                            SUPPORTED XSLT ENGINES

   4xslt    <http://4suite.org/>
   libxslt  <http://xmlsoft.org/XSLT/>
   Saxon    <http://saxon.sourceforge.net/>
   Xalan-C  <http://xml.apache.org/xalan-c/>
   Xalan-J  <http://xml.apache.org/xalan-j/>

                              USAGE INSTRUCTIONS

   It is highly recommended that you set the stylesheet's 
   source-uri parameter to the source URI of your input document.

   Your XHTML document must have the namespace "http://www.w3.org/1999/xhtml".
   If it does not or if your input document is written in HTML, filter it
   through "tidy -asxhtml" <http://tidy.sourceforge.net/> before
   processing it with hAtom2Atom.xsl.

                             STYLESHEET PARAMETERS
   
   $source-uri: 
     Source URI of the input document, e.g: http://example.com/foo.html
     It is highly recommended that you set this parameter.

   $content-type:
     The content type of your input document.
     The default is "text/html".

   $implicit-feed: 
     If no feeds are found, the value of $implicit-feed determines
     wether the whole document should be treated as feed or if the
     first hentry should be extracted as stand-alone atom:entry.
     The default is "1".
     
   $debug-comments:
     If $debug-comments is set to "1", hAtom2Atom.xsl will add 
     comments which can aid with debugging.
     The default is "1".
     
   $sanitize-html:
     If $sanitize-html is set to "1", hAtom2Atom.xsl will remove
     all attributes and elements which are not listed at 
     <http://feedparser.org/docs/html-sanitization.html>
     from atom:summary and atom:content.
     The default is "1".
     
   $tag-schemes:
     If $tag-schemes is set to "1", hAtom2Atom.xsl will add
     the "scheme" attribute to <atom:category> when extracting 
     rel-tags. The value of scheme will be the tag space of 
     the extracted rel-tag.
     The default is "1".

                                     NOTES

   Code sections which are extensions to the current hAtom draft are enclosed
   by "[extension]" and "[/extension]".
   
   For various reasons we need to use the node-set() extension function, see
   <http://www.xml.com/pub/a/2003/07/16/nodeset.html> for an introduction.
   
   This stylesheet and the hAtom specification are still works in progress. 
   Use it at your own risk! 

                                   SEE ALSO

   For the latest version of this stylesheet: 
     <http://rbach.priv.at/Microformats/hAtom2Atom/>
    
   Mercurial repository:
     <http://hg.microformats.org/x2v/>
     
   Information about hAtom:
     <http://microformats.org/wiki/hatom>
    
   Information about Atom:
     <http://www.ietf.org/rfc/rfc4287>

                                    LICENSE

   Copyright 2005    Luke Arno        <http://lukearno.com/>
   Copyright 2005-07 Robert Bachmann  <http://rbach.priv.at/>
   Copyright 2005-06 Benjamin Carlyle <http://soundadvice.id.au/>

   This work is licensed under The W3C Open Source License
   http://www.w3.org/Consortium/Legal/copyright-software-19980720


                               ACKNOWLEDGEMENTS

   Structure of the multi-valued attribute selection trick and
   templates for datetime to UTC conversion taken from
   Brian Suda's X2V: 
     <http://suda.co.uk/projects/X2V/>
     
   The list of acceptable HTML elements and attributes was taken from
   Mark Pilgrim's Universal Feed Parser:
     <http://feedparser.org/>
     
   This work is based on hAtom2Atom.xsl version 0.0.6 from
     <http://lukearno.com/projects/hAtom/>

-->


<xsl:transform version="1.0"
 xmlns="http://www.w3.org/2005/Atom"
 xmlns:xhtml="http://www.w3.org/1999/xhtml"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:extension="http://exslt.org/common"
 xmlns:str="http://exslt.org/strings"
 xmlns:uri="http://www.w3.org/2000/07/uri43/uri.xsl?template="
 xmlns:datetime ="http://suda.co.uk/projects/microformats/datetime.xsl?template="
 xmlns:h2a="http://rbach.priv.at/2007/hatom2atom"
 extension-element-prefixes="extension str"
 exclude-result-prefixes="xhtml uri h2a datetime">

<!-- Downloaded from http://www.w3.org/2000/07/uri43/uri.xsl -->
<xsl:import href="uri.xsl" />
<xsl:import href="datetime.xsl" />
<xsl:param name="base-uri" select="''"/>
<xsl:param name="source-uri" select="$base-uri"/>
<xsl:param name="content-type">text/html</xsl:param>
<xsl:param name="implicit-feed">1</xsl:param>
<xsl:param name="debug-comments">1</xsl:param>
<xsl:param name="sanitize-html">1</xsl:param>
<xsl:param name="tag-schemes">1</xsl:param>

<xsl:variable name="last-updated">2007-08-09</xsl:variable>

<xsl:output method="xml" indent="yes" encoding="UTF-8" />

<xsl:template match="/">
	<xsl:call-template name="h2a:parse">
		<xsl:with-param name="source-uri" select="$source-uri" />
		<xsl:with-param name="content-type" select="$content-type" />
		<xsl:with-param name="implicit-feed" select="$implicit-feed" />
		<xsl:with-param name="debug-comments" select="$debug-comments" />
		<xsl:with-param name="sanitize-html" select="$sanitize-html" />
		<xsl:with-param name="tag-schemes" select="$tag-schemes" />
	</xsl:call-template>
</xsl:template>

<xsl:template name="h2a:parse">
	<xsl:param name="source-uri"     />
	<xsl:param name="content-type"   />
	<xsl:param name="implicit-feed"  />
	<xsl:param name="debug-comments" />
	<xsl:param name="sanitize-html"  />

	<!-- 
	Enable users to use 'h2a:parse' as part of bigger stylesheet, for example:
	
	<xsl:import href="hAtom2Atom.xsl" />
	[...]
	<xsl:for-each select="document('document-a.htm')">
	  <xsl:call-template name="h2a:parse">
	    <xsl:with-param name="source-uri">http://example.com/foo#abc</xsl:with-param>
	    <xsl:with-param name="sanitize-html" select="0" />
	  </xsl:call-template>
	</xsl:for-each>
	[...]
	<xsl:for-each select="document('document-b.htm')">
	  <xsl:call-template name="h2a:parse">
	    <xsl:with-param name="source-uri">http://example.org/bar/foo#abcd</xsl:with-param>
	    <xsl:with-param name="sanitize-html" select="1" />
	  </xsl:call-template>
	</xsl:for-each>
	
	So we can not use the values of the stylesheet's parameters directly, rather we have to pass on all the parameters
	recived by h2a:convert to all the templates.
	
	The usual method to do this would be:
	
	<xsl:template name="h2a:foo">
	  <xsl:param name="source-uri"/>
	  <!- xsl:param for 'content-type' ,'debug-comments', 'sanitize-html', etc. ->
	  [...]
	  <xsl:call-template name="h2a:bar">
	    <xsl:with-param name="source-uri" select="$source-uri" />
	    <!- xsl:with-param for 'content-type' ,'debug-comments', 'sanitize-html', etc. ->
	  </xsl:call-template>
	  
	  <xsl:apply-template name="h2a:bar">
	    <xsl:with-param name="source-uri" select="$source-uri" />
	    <!- xsl:with-param for 'content-type' ,'debug-comments', 'sanitize-html', etc. ->
	  </xsl:apply-template>
	</xsl:template>
	
	As this would make maintance very complicated (for example: if we added a new parameter) ,
	we store all parameters in a single data structure called "params".
	This simplifies the example above to:
	
	<xsl:template name="h2a:foo">
	  <xsl:param name="params"/>
	
	  <xsl:call-template name="h2a:bar">
	    <xsl:with-param name="params" select="$params" />
	  </xsl:call-template>
	  
	  <xsl:apply-template name="h2a:bar">
	    <xsl:with-param name="params" select="$params" />
	  </xsl:apply-template>
	</xsl:template>
	-->
	<xsl:variable name="params-rtf">
		<!--
		 This is the data structure which contains all parameters recived by h2a:convert
		 In XSLT ver. 1.0  the type of this variable is "result tree fragment",
		 we later need to use the node-set() function to convert $params-rtf
		 into a node set.

		 Templates invoked by h2a:convert will recive this node set with
		 '<xsl:parm name="params" />' and can extract values
		 via XPath: '$params/h2a:source-uri'
		-->
		<h2a:source-uri><xsl:value-of select="$source-uri" /></h2a:source-uri>
		<h2a:content-type><xsl:value-of select="$content-type" /></h2a:content-type>
		<h2a:implicit-feed><xsl:value-of select="$implicit-feed" /></h2a:implicit-feed>
		<h2a:debug-comments><xsl:value-of select="$debug-comments" /></h2a:debug-comments>
		<h2a:sanitize-html><xsl:value-of select="$sanitize-html" /></h2a:sanitize-html>
		<h2a:tag-schemes><xsl:value-of select="$tag-schemes" /></h2a:tag-schemes>
		<!-- This isn't a real parameter, but it is derived from one -->
		<h2a:source-uri-sans-fragment>
			<xsl:choose>
				<xsl:when test="contains($source-uri,'#')">
					<xsl:value-of select="substring-before($source-uri,'#')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$source-uri" />
				</xsl:otherwise>
			</xsl:choose>
		</h2a:source-uri-sans-fragment>
	</xsl:variable>

	<!-- Determine the fragement of the $source-uri -->
	<xsl:variable name="fragment">
		<xsl:if test="contains($source-uri,'#')">
			<xsl:value-of select="substring-after($source-uri,'#')" />
		</xsl:if>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="$fragment != ''">
			<!-- we have a fragment, only transform the part identified by the fragment -->
			<xsl:choose>
				<xsl:when test="descendant::*[@id = $fragment]">
					<xsl:for-each select="descendant::*[@id = $fragment][1]">
						<xsl:call-template name="h2a:main">
							<xsl:with-param name="params" select="extension:node-set($params-rtf)" />
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="yes">ERROR: Invalid fragment</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<!-- transform the whole document -->
			<xsl:call-template name="h2a:main">
				<xsl:with-param name="params" select="extension:node-set($params-rtf)" />
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="h2a:main">
	<xsl:param name="params"/>

	<xsl:if test="$params/h2a:debug-comments != 0">
		<xsl:comment>
			<xsl:text> Generated by hAtom2Atom.xsl (</xsl:text>
			<xsl:value-of select="$last-updated"/>
			<xsl:text>) </xsl:text>
		</xsl:comment>
	</xsl:if>
	<!--
	 See if we can find feed elements within this document.
	 Entries that are part of a feed are processed when we
	 reach the feed element.
	 If no feeds are found, the value of $params/h2a:implicit-feed determines
	 wether the whole document should be treated as feed or if the
	 first hentry should be extracted as stand-alone atom:entry.

	 Use modes throughout to determine context. Are we
	 * outside a feed (none),
	 * inside a feed (feed), or
	 * inside an entry (entry)?
	-->
	<xsl:choose>
		<xsl:when test="descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' hfeed ')]">
			<xsl:for-each select="descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' hfeed ')][1]">
				<xsl:apply-templates mode="h2a:conversion" select=".">
					<xsl:with-param name="params" select="$params" />
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:when>
		<xsl:when test="descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' hentry ')]">
			<xsl:choose>
				<xsl:when test="$params/h2a:implicit-feed != 0">
					<xsl:for-each select="/child::*[1]">
						<xsl:call-template name="h2a:feed">
							<xsl:with-param name="params" select="$params"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' hentry ')][1]">
						<xsl:call-template name="h2a:entry">
							<xsl:with-param name="params" select="$params"/>
							<xsl:with-param name="where">stand-alone</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:message terminate="yes">ERROR: No hAtom feeds and hAtom entries were found.</xsl:message>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template mode="h2a:conversion" match="node()|@*">
	<xsl:param name="params"/>
	<xsl:param name="where"/>
	<!-- By default, do nothing -->
	<xsl:apply-templates mode="h2a:conversion" select="node()|@*">
		<xsl:with-param name="params" select="$params"/>
		<xsl:with-param name="where" select="$where"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template mode="h2a:extract-date" match="node()|@*">
	<xsl:param name="params"/>
	<xsl:param name="where"/>
	<!-- By default, do nothing -->
	<xsl:apply-templates mode="h2a:extract-date" select="node()|@*">
		<xsl:with-param name="params" select="$params"/>
		<xsl:with-param name="where" select="$where"/>
	</xsl:apply-templates>
</xsl:template>

<!-- Inhibit <q> and <blockquote -->
<xsl:template mode="h2a:conversion" match="xhtml:q|xhtml:blockquote" />
<xsl:template mode="h2a:extract-date" match="xhtml:q|xhtml:blockquote" />

<xsl:template mode="h2a:conversion" match="xhtml:*[contains(concat(' ',normalize-space(@class),' '),' hfeed ')]">
	<xsl:param name="params"/>
	<xsl:call-template name="h2a:feed">
		<xsl:with-param name="params" select="$params"/>
	</xsl:call-template>
</xsl:template>

<xsl:template name="h2a:feed">
	<xsl:param name="params"/>
	<feed>
		<xsl:variable name="feed-base">
			<xsl:apply-templates mode="h2a:get-base" select=".">
				<xsl:with-param name="params" select="$params"/>
				<xsl:with-param name="fallback" select="/xhtml:html/xhtml:head/xhtml:base[1]/@href" />
			</xsl:apply-templates>
		</xsl:variable>

		<!--[extension]-->
			<xsl:apply-templates mode="h2a:add-lang-attribute" select=".">
				<xsl:with-param name="params" select="$params"/>
			</xsl:apply-templates>
			<xsl:apply-templates mode="h2a:add-base-attribute" select=".">
				<xsl:with-param name="params" select="$params"/>
				<xsl:with-param name="for-feed" select="true()" />
			</xsl:apply-templates>
		<!--[/extension]-->

		<xsl:variable name="feedLevelElements">
			<xsl:call-template name="h2a:feed-level-elements"/>
		</xsl:variable>

		<!-- Extract feed updated -->
		<!--[extension]-->
			<updated>
				<xsl:choose >
					<!-- Try to use the first element with class="updated" at the feed level -->
					<xsl:when test="extension:node-set($feedLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' updated ')]">
						<xsl:for-each select="extension:node-set($feedLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' updated ')][1]">
							<xsl:call-template name="h2a:pad-datetime">
								<xsl:with-param name="date">
									<xsl:call-template name="h2a:text-value-of" />
								</xsl:with-param>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>
					<!-- Try to use the newest datetime from the entry level -->
					<xsl:otherwise>
						<xsl:variable name="datetimes">
							<xsl:apply-templates mode="h2a:extract-date" select="node()|@*">
								<xsl:with-param name="where">feed</xsl:with-param>
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:variable name="sorted-datetimes">
							<xsl:for-each select="extension:node-set($datetimes)/h2a:t">
								<xsl:sort select="@utc" order="descending" />
									<h2a:t orginal="{@orginal}" utc="{@utc}" />
							</xsl:for-each>
						</xsl:variable>
						<xsl:if test="$params/h2a:debug-comments != 0">
							<xsl:comment>
								<xsl:text>&#10;</xsl:text>
								<xsl:text>Using the newest datetime from the entry level.&#10;</xsl:text>
								<xsl:text>&#10;</xsl:text>
								<xsl:text>Here is a sorted list from all the dates at the feed level:&#10;</xsl:text>
								<xsl:text>&#10;</xsl:text>
								<xsl:for-each select="extension:node-set($sorted-datetimes)/h2a:t">
									<xsl:value-of select="concat(@utc,' (',@orginal,')&#10;')" />
								</xsl:for-each>
								<xsl:text>&#10;</xsl:text>
							</xsl:comment>
						</xsl:if>
						<xsl:for-each select="extension:node-set($sorted-datetimes)/h2a:t[1]">
							<xsl:value-of select="@orginal" />
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</updated>
		<!--[/extension]-->

		<!-- Extract feed id and link -->
		<!--[extension]-->
			<xsl:choose>
				<!-- If the feed has an ID attribute use it together with $params/h2a:source-uri -->
				<xsl:when test="@id">
					<xsl:variable name="uri" select="concat($params/h2a:source-uri-sans-fragment,'#',@id)"/>
					<id><xsl:value-of select="$uri"/></id>
					<link rel="alternate" href="{$uri}" type="{$params/h2a:content-type}"/>
				</xsl:when>
				<!-- Use the $params/h2a:source-uri of the feed -->
				<xsl:otherwise>
					<xsl:variable name="uri" select="$params/h2a:source-uri-sans-fragment"/>
					<id><xsl:value-of select="$uri"/></id>
					<link rel="alternate" href="{$uri}" type="{$params/h2a:content-type}"/>
				</xsl:otherwise>
			</xsl:choose>
		<!--[/extension]-->

		<!-- Extract feed title    -->

		<!--[extension]-->
			<!-- Try to find an element with class="feed-title" -->
			<xsl:variable name="classTitles"
				select="extension:node-set($feedLevelElements)/descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' feed-title ')]"
				/>

			<xsl:choose>
				<xsl:when test="$classTitles">
					<xsl:for-each select="$classTitles[1]">
						<title><xsl:call-template name="h2a:text-value-of"/></title>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="/xhtml:html/xhtml:head/xhtml:title">
					<xsl:for-each select="/xhtml:html/xhtml:head/xhtml:title[1]">
						<title><xsl:call-template name="h2a:text-value-of"/></title>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<!--ERROR: A feed must have a title -->
					<title/>
				</xsl:otherwise>
			</xsl:choose>
		<!--[/extension]-->

		<!-- Extract feed's tags -->
		<xsl:for-each select="extension:node-set($feedLevelElements)/descendant::xhtml:a[contains(concat(' ',normalize-space(translate(@rel,'TAG','tag')),' '),' tag ')]">
			<xsl:call-template name="h2a:create-category">
				<xsl:with-param name="params" select="$params"/>
				<xsl:with-param name="base">
					<xsl:apply-templates mode="h2a:get-base" select=".">
						<xsl:with-param name="params" select="$params"/>
						<xsl:with-param name="fallback" select="$feed-base"/>
					</xsl:apply-templates>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<!-- Find the feed's author(s) -->
		<xsl:choose>
			<xsl:when test="extension:node-set($feedLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' author ')]">
				<xsl:for-each select="extension:node-set($feedLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' author ')]">
					<xsl:for-each select="descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' vcard ')]">
						<author>
							<xsl:call-template name="h2a:vcard">
								<xsl:with-param name="params" select="$params"/>
							</xsl:call-template>
						</author>
					</xsl:for-each>
			</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="h2a:find-author" select="parent::*">
					<xsl:with-param name="params" select="$params"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:apply-templates mode="h2a:conversion" select="node()|@*">
			<xsl:with-param name="params" select="$params"/>
			<xsl:with-param name="where">feed</xsl:with-param>
		</xsl:apply-templates>

	</feed>
</xsl:template>

<xsl:template mode="h2a:conversion" match="xhtml:*[contains(concat(' ',normalize-space(@class),' '),' hentry ')]">
	<xsl:param name="params"/>

	<xsl:param name="where"/>
	<xsl:if test="($where = 'feed') and (local-name() != 'q' and local-name() != 'blockquote')">
		<xsl:call-template name="h2a:entry">
			<xsl:with-param name="params" select="$params"/>
			<xsl:with-param name="where">feed</xsl:with-param>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<xsl:template mode="h2a:extract-date" match="xhtml:*[contains(concat(' ',normalize-space(@class),' '),' hentry ')]">
	<xsl:param name="params"/>
	<xsl:variable name="entryLevelElements">
		<xsl:call-template name="h2a:entry-level-elements"/>
	</xsl:variable>
	<xsl:variable name="updated">
				<xsl:choose>
					<xsl:when test="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' updated ')]">
						<!--
						 Use the value of the
						 first element with class="updated"
						 as per hAtom specification
						-->
						<xsl:for-each select="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' updated ')][1]">
							<xsl:call-template name="h2a:pad-datetime">
								<xsl:with-param name="date">
									<xsl:call-template name="h2a:text-value-of" />
								</xsl:with-param>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>
					<!-- If no "updated" is present use the value of the first "published" -->
					<xsl:when test="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' published ')]">
						<xsl:for-each select="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' published ')][1]">
							<xsl:call-template name="h2a:pad-datetime">
								<xsl:with-param name="date">
									<xsl:call-template name="h2a:text-value-of" />
								</xsl:with-param>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<!--ERROR: <updated> is mandatory -->
					</xsl:otherwise>
				</xsl:choose>
	</xsl:variable>
	<xsl:variable name="utc">
	  <xsl:call-template name="datetime:utc-time-converter">
		  <xsl:with-param name="time-string" select="$updated" /> 
		</xsl:call-template>
	</xsl:variable>
	<h2a:t orginal="{$updated}" utc="{substring-before($utc,'Z')}" />
</xsl:template>

<xsl:template name="h2a:entry">
	<xsl:param name="params"/>
	<xsl:param name="where"/>

	<xsl:variable name="entry-base">
		<xsl:apply-templates mode="h2a:get-base" select=".">
			<xsl:with-param name="params" select="$params"/>
			<xsl:with-param name="fallback" select="/xhtml:html/xhtml:head/xhtml:base[1]/@href" />
		</xsl:apply-templates>
	</xsl:variable>

		<entry>
			<!--[extension]-->
				<xsl:apply-templates mode="h2a:add-lang-attribute" select=".">
					<xsl:with-param name="params" select="$params"/>
					<xsl:with-param name="end" select="'hfeed'" />
				</xsl:apply-templates>
				<xsl:apply-templates mode="h2a:add-base-attribute" select=".">
					<xsl:with-param name="params" select="$params"/>
					<xsl:with-param name="end" select="'hfeed'" />
				</xsl:apply-templates>
			<!--[/extension]-->

			<!--  Manually deal with the title attribute -->

			<xsl:variable name="entryLevelElements">
				<xsl:call-template name="h2a:entry-level-elements"/>
			</xsl:variable>

			<xsl:variable name="classTitles"
				select="extension:node-set($entryLevelElements)/descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' entry-title ')]"
			/>

			<xsl:variable name="headerTitles"
				select="extension:node-set($entryLevelElements)/descendant-or-self::xhtml:h1|extension:node-set($entryLevelElements)/descendant-or-self::xhtml:h2|extension:node-set($entryLevelElements)/descendant-or-self::xhtml:h3|extension:node-set($entryLevelElements)/descendant-or-self::xhtml:h4|extension:node-set($entryLevelElements)/descendant-or-self::xhtml:h5|extension:node-set($entryLevelElements)/descendant-or-self::xhtml:h6"
			/>

			<xsl:choose>
				<xsl:when test="$classTitles">
					<xsl:for-each select="$classTitles[1]">
						<title><xsl:call-template name="h2a:text-value-of"/></title>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="$headerTitles">
					<xsl:for-each select="$headerTitles[1]">
						<title><xsl:call-template name="h2a:text-value-of"/></title>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise><title/></xsl:otherwise>
			</xsl:choose>

			<!--  Manually deal with the "id" and the "link" element -->
			<xsl:choose>
				<xsl:when test="extension:node-set($entryLevelElements)/descendant::xhtml:a[contains(concat(' ',normalize-space(translate(@rel,'BOKMAR','bokmar')),' '),' bookmark ')]">
					<!-- Convert to absolute URI -->
					<xsl:variable name="uri">
						<xsl:call-template name="uri:expand">
							<xsl:with-param name="base">
								<xsl:apply-templates mode="h2a:get-base"
								                     select="extension:node-set($entryLevelElements)/descendant::xhtml:a[
								                             contains(concat(' ',normalize-space(translate(@rel,'BOKMAR','bokmar')),' '),' bookmark ')][1]" >
									<xsl:with-param name="params" select="$params"/>
									<xsl:with-param name="fallback" select="$entry-base" />
								</xsl:apply-templates>
							</xsl:with-param>
							<xsl:with-param name="there">
								<xsl:value-of select="extension:node-set($entryLevelElements)/descendant::xhtml:a[
									contains(concat(' ',normalize-space(translate(@rel,'BOKMAR','bokmar')),' '),' bookmark ')
									][1]/@href" />
							</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<id><xsl:value-of select="$uri" /></id>
					<link rel="alternate" href="{$uri}">
						<xsl:for-each select="extension:node-set($entryLevelElements)/descendant::xhtml:a[contains(concat(' ',normalize-space(translate(@rel,'BOKMAR','bokmar')),' '),' bookmark ')][1]">
							<xsl:for-each select="@type|@hreflang|@title|@length">
								<xsl:copy />
							</xsl:for-each>
							<xsl:if test="not(@type)">
								<xsl:attribute name="type"><xsl:value-of select="$params/h2a:content-type" /></xsl:attribute>
							</xsl:if>
						</xsl:for-each>
					</link>
				</xsl:when>
				<!-- Try to use the entry's id attribute as ID -->
				<xsl:when test="@id != ''">
					<xsl:variable name="uri" select="concat($params/h2a:source-uri-sans-fragment,'#',@id)" />
					<id><xsl:value-of select="$uri" /></id>
					<link rel="alternate" href="{$uri}" type="{$params/h2a:content-type}" />
				</xsl:when>
				<xsl:otherwise>
					<!--ERROR: <id> is mandatory -->
					<id/>
				</xsl:otherwise>
			</xsl:choose>


			<!--  Manually deal with the "published" element -->
			<xsl:if test="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' published ')]">
				<published>
					<!--
					 Use the value of the
					 first element with class="published"
					 as per hAtom specification
					-->
					<xsl:for-each select="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' published ')][1]">
						<xsl:call-template name="h2a:pad-datetime">
							<xsl:with-param name="date">
								<xsl:call-template name="h2a:text-value-of" />
							</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</published>
			</xsl:if>

			<!--  Manually deal with the "updated" element -->
			<updated>
				<xsl:choose>
					<xsl:when test="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' updated ')]">
						<!--
						 Use the value of the
						 first element with class="updated"
						 as per hAtom specification
						-->
						<xsl:for-each select="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' updated ')][1]">
							<xsl:call-template name="h2a:pad-datetime">
								<xsl:with-param name="date">
									<xsl:call-template name="h2a:text-value-of" />
								</xsl:with-param>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>
					<!-- If no "updated" is present use the value of the first "published" -->
					<xsl:when test="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' published ')]">
						<xsl:for-each select="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' published ')][1]">
							<xsl:if test="$params/h2a:debug-comments != 0">
								<xsl:comment>Using the value of the first "published" element</xsl:comment>
							</xsl:if>
							<xsl:call-template name="h2a:pad-datetime">
								<xsl:with-param name="date">
									<xsl:call-template name="h2a:text-value-of" />
								</xsl:with-param>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<!--ERROR: <updated> is mandatory -->
					</xsl:otherwise>
				</xsl:choose>
			</updated>

			<xsl:if test="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' entry-summary ')]">
				<xsl:variable name="first-summary"
				              select="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' entry-summary ')][1]"
				 />
				<summary type="xhtml">
					<!--[extension]-->
						<!-- 
						 Only xml:lang and xml:base of the first element with class="summary" will be picked up.
						 This may lead to unexpected results!
						-->
						<xsl:apply-templates  mode="h2a:add-lang-attribute" select="$first-summary">
							<xsl:with-param name="params" select="$params"/>
							<xsl:with-param name="end" select="'hentry'" />
						</xsl:apply-templates>
						<xsl:apply-templates mode="h2a:add-base-attribute" select="$first-summary">
							<xsl:with-param name="params" select="$params"/>
							<xsl:with-param name="end" select="'hentry'" />
						</xsl:apply-templates>
					<!--[/extension]-->
					<div xmlns="http://www.w3.org/1999/xhtml">
						<xsl:variable name="entryLevelElements_w_summary">
							<xsl:call-template name="h2a:entry-level-elements">
								<xsl:with-param name="deep-copy">entry-summary</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="summary">
							<xsl:for-each select="extension:node-set($entryLevelElements_w_summary)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' entry-summary ')]">
								<xsl:variable name="inside-q">
									<xsl:apply-templates mode="h2a:is-in-q" select="." />
								</xsl:variable>
								<xsl:if test="$inside-q = 'no'">
									<xsl:copy-of select="child::*|text()" />
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<xsl:call-template name="h2a:output">
							<xsl:with-param name="params" select="$params"/>
							<xsl:with-param name="nodes" select="$summary" />
						</xsl:call-template>
					</div>
				</summary>
			</xsl:if>

			<xsl:if test="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' entry-content ')]">
				<xsl:variable name="first-content"
				              select="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' entry-content ')][1]"
				/>
				<content type="xhtml">
					<!--[extension]-->
						<!--
						 Only xml:lang and xml:base of the first element with class="content" will be picked up.
						 This may lead to unexpected results!
						-->
						<xsl:apply-templates mode="h2a:add-lang-attribute" select="$first-content">
							<xsl:with-param name="params" select="$params"/>
							<xsl:with-param name="end" select="'hentry'" />
						</xsl:apply-templates>
						<xsl:apply-templates mode="h2a:add-base-attribute" select="$first-content">
							<xsl:with-param name="params" select="$params"/>
							<xsl:with-param name="end" select="'hentry'" />
						</xsl:apply-templates>
					<!--[/extension]-->
					<div xmlns="http://www.w3.org/1999/xhtml">
						<xsl:variable name="entryLevelElements_w_content">
							<xsl:call-template name="h2a:entry-level-elements">
								<xsl:with-param name="deep-copy">entry-content</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="content">
							<xsl:for-each select="extension:node-set($entryLevelElements_w_content)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' entry-content ')]">
								<xsl:variable name="inside-q">
									<xsl:apply-templates mode="h2a:is-in-q" select="." />
								</xsl:variable>
								<xsl:if test="$inside-q = 'no'">
									<xsl:copy-of select="child::*|text()" />
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<xsl:call-template name="h2a:output">
							<xsl:with-param name="params" select="$params"/>
							<xsl:with-param name="nodes" select="$content" />
						</xsl:call-template>
					</div>
				</content>
			</xsl:if>

			<!-- Find the entry's author(s) -->
			<xsl:choose>
				<xsl:when test="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' author ')]">
					<xsl:for-each select="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' author ')]">
						<xsl:for-each select="descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' vcard ')]">
							<author>
								<xsl:call-template name="h2a:vcard">
									<xsl:with-param name="params" select="$params"/>
								</xsl:call-template>
							</author>
						</xsl:for-each>
					</xsl:for-each>
				</xsl:when>
				<!-- 
				 If we are extracting a stand-alone entry we need to find
				 the "nearest in parent" <addr> with class="author" 
				-->
				<xsl:when test="$where = 'stand-alone'">
					<xsl:apply-templates mode="h2a:find-author" select="parent::*">
						<xsl:with-param name="params" select="$params"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>

			<!-- Extract entry's tags -->
			<xsl:for-each select="extension:node-set($entryLevelElements)/descendant::xhtml:a[contains(concat(' ',normalize-space(translate(@rel,'TAG','tag')),' '),' tag ')]">
				<xsl:call-template name="h2a:create-category">
					<xsl:with-param name="params" select="$params"/>
					<xsl:with-param name="base">
						<xsl:apply-templates mode="h2a:get-base" select=".">
							<xsl:with-param name="params" select="$params"/>
							<xsl:with-param name="fallback" select="$entry-base"/>
						</xsl:apply-templates>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
		</entry>
</xsl:template>

<!-- 
 Find author outside of "hentry"
-->
<xsl:template mode="h2a:find-author" match="*">
	<xsl:param name="params"/>
	<xsl:variable name="elements">
		<xsl:call-template name="h2a:find-author-filter" />
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="extension:node-set($elements)/descendant::xhtml:address[contains(concat(' ',normalize-space(@class),' '),' author ')]">
			<xsl:for-each select="extension:node-set($elements)/descendant::xhtml:address[contains(concat(' ',normalize-space(@class),' '),' author ')][1]">
				<xsl:for-each select="descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' vcard ')]">
					<author>
						<xsl:call-template name="h2a:vcard">
							<xsl:with-param name="params" select="$params"/>
						</xsl:call-template>
					</author>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates mode="h2a:find-author" select="parent::*">
				<xsl:with-param name="params" select="$params"/>
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Filter for find-author template -->
<xsl:template name="h2a:find-author-filter">
	<xsl:choose>
		<xsl:when test="contains(concat(' ',normalize-space(@class),' '),' hentry ')"/>
		<xsl:when test="contains(concat(' ',normalize-space(@class),' '),' hfeed ')"/>
		<xsl:when test="(local-name() = 'q' or local-name() = 'blockquote')
		                and namespace-uri() = 'http://www.w3.org/1999/xhtml' "/>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:for-each select="@*|node()">
					<xsl:call-template name="h2a:feed-level-elements"/>
				</xsl:for-each>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- 
 Named templates for value extraction
-->

<xsl:template name="h2a:value-of">
	<xsl:param name="context" select="."/>
	<xsl:choose>
		<xsl:when test="name($context)='abbr'">
			<xsl:value-of select="normalize-space($context/@title)"/>
		</xsl:when>
		<xsl:when test="$context/xhtml:*[contains(concat(' ',normalize-space(@class),' '),' value-title ')]">
			<xsl:value-of select="normalize-space($context/xhtml:*[contains(concat(' ',normalize-space(@class),' '),' value-title ')])"/>
		</xsl:when>
		<xsl:when test="name($context)='span' and $context/@title">
			<xsl:value-of select="normalize-space($context/@title)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="normalize-space($context)"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="h2a:text-value-of">
	<xsl:param name="context" select="."/>
	<xsl:choose>
		<xsl:when test="name($context) = 'img' and $context/@alt">
			<xsl:value-of select="normalize-space($context/@alt)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="h2a:value-of">
				<xsl:with-param name="context" select="$context"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="h2a:uri-value-of">
	<xsl:param name="context" select="."/>
	<xsl:choose>
		<xsl:when test="name($context) = 'a' and $context/@href">
			<xsl:value-of select="normalize-space($context/@href)"/>
		</xsl:when>
		<xsl:when test="name($context) = 'img' and $context/@src">
			<xsl:value-of select="normalize-space($context/@src)"/>
		</xsl:when>
		<xsl:when test="name($context) = 'object' and $context/@data">
			<xsl:value-of select="normalize-space($context/@data)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="h2a:value-of">
				<xsl:with-param name="context" select="$context"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="h2a:email-value-of">
	<xsl:param name="context" select="."/>
	<xsl:choose>
		<xsl:when test="name($context) = 'a' and starts-with($context/@href,'mailto:')">
			<xsl:choose>
			<xsl:when test="contains($context/@href,'?')">
				<xsl:value-of select="
					substring-before(substring-after($context/@href,'mailto:'), '?')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring-after($context/@href,'mailto:')"/>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="h2a:text-value-of">
				<xsl:with-param name="context" select="$context"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- 
 "Filter" templates for dealing with hAtom's opacity rules
-->

<xsl:template name="h2a:feed-level-elements">
	<xsl:choose>
		<xsl:when test="contains(concat(' ',normalize-space(@class),' '),' hentry ')"/>
		<xsl:when test="(local-name() = 'q' or local-name() = 'blockquote')
		                and namespace-uri() = 'http://www.w3.org/1999/xhtml' "/>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:for-each select="@*|node()">
					<xsl:call-template name="h2a:feed-level-elements"/>
				</xsl:for-each>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="h2a:entry-level-elements">
	<xsl:param name="deep-copy" />
	<xsl:choose>
		<xsl:when test="$deep-copy != '' and contains(concat(' ',normalize-space(@class),' '), concat(' ',$deep-copy,' '))">
			<xsl:copy-of select="."/>
		</xsl:when>
		<xsl:when test="(local-name() = 'q' or local-name() = 'blockquote')
		                and namespace-uri() = 'http://www.w3.org/1999/xhtml' "/>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:for-each select="@*|node()">
					<xsl:call-template name="h2a:entry-level-elements">
						<xsl:with-param name="deep-copy" select="$deep-copy" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="h2a:vcard">
	<xsl:param name="params"/>
	<xsl:if test="$params = ''"><xsl:message terminate="yes">_</xsl:message></xsl:if>
	<xsl:variable name="vcard-base">
		<xsl:apply-templates mode="h2a:get-base" select=".">
			<xsl:with-param name="params" select="$params"/>
			<xsl:with-param name="fallback" select="/xhtml:html/xhtml:head/xhtml:base[1]/@href" />
		</xsl:apply-templates>
	</xsl:variable>
	<name>
		<xsl:value-of select="normalize-space(descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')])"/>
	</name>
	<xsl:choose>
		<xsl:when test="descendant::xhtml:a[contains(concat(' ',normalize-space(@class),' '),' url ')]">
			<uri>
				<xsl:call-template name="uri:expand">
					<xsl:with-param name="base">
						<xsl:apply-templates mode="h2a:get-base"
						     select="descendant::xhtml:a[
						             contains(concat(' ',normalize-space(@class),' '),' url ')]" >
							<xsl:with-param name="params" select="$params"/>
							<xsl:with-param name="fallback" select="$vcard-base" />
						</xsl:apply-templates>
					</xsl:with-param>
					<xsl:with-param name="there">
						<xsl:value-of select="descendant-or-self::xhtml:a[
						                      contains(concat(' ',normalize-space(@class),' '),' url ')]/@href" />
					</xsl:with-param>
				</xsl:call-template>
			</uri>
		</xsl:when>
		<xsl:when test="descendant::*[contains(concat(' ',normalize-space(@class),' '),' url ')]">
			<uri>
				<xsl:call-template name="uri:expand">
					<xsl:with-param name="base">
						<xsl:apply-templates mode="h2a:get-base"
						                     select="descendant::xhtml:*[
						                             contains(concat(' ',normalize-space(@class),' '),' url ')]" >
							<xsl:with-param name="params" select="$params"/>
							<xsl:with-param name="fallback" select="$vcard-base" />
						</xsl:apply-templates>
					</xsl:with-param>
					<xsl:with-param name="there">
						<xsl:value-of select="descendant::xhtml:*[
						                      contains(concat(' ',normalize-space(@class),' '),' url ')]" />
					</xsl:with-param>
				</xsl:call-template>
			</uri>
		</xsl:when>
	</xsl:choose>
	<xsl:if test="descendant::*[contains(concat(' ',normalize-space(@class),' '),' email ')]">
		<email>
			<xsl:call-template name="h2a:email-value-of">
				<xsl:with-param name="context" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' email ')][1]"/>
			</xsl:call-template>
		</email>
	</xsl:if>
</xsl:template>

<!--
 Templates for handling rel-tag
-->
<!--[extension]-->
<xsl:template name="h2a:create-category">
	<xsl:param name="params" />
	<xsl:param name="base" />

	<category>
		<xsl:variable name="data">
			<xsl:call-template name="h2a:extract-tag">
				<xsl:with-param name="params" select="$params"/>
				<xsl:with-param name="uri" select="@href"/>
				<xsl:with-param name="base" select="$base"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:attribute name="term">
			<xsl:value-of select="extension:node-set($data)/h2a:tag-term" />
		</xsl:attribute>
		<xsl:if test="$params/h2a:tag-schemes != 0">
			<xsl:attribute name="scheme">
				<xsl:value-of select="extension:node-set($data)/h2a:tag-scheme" />
			</xsl:attribute>
		</xsl:if>
		<xsl:attribute name="label"><xsl:value-of select="."/></xsl:attribute>
	</category>
</xsl:template>

<!--
 Extract a tag from an URI
-->
<xsl:template name="h2a:extract-tag">
	<xsl:param name="params" />
	<xsl:param name="uri" />
	<xsl:param name="base" />

	<xsl:variable name="uri-sans-fragment">
		<xsl:choose>
			<xsl:when test="contains($uri,'#')">
				<xsl:value-of select="substring-before($uri,'#')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$uri" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="uri-sans-query">
		<xsl:choose>
			<xsl:when test="contains($uri-sans-fragment,'?')">
				<xsl:value-of select="substring-before($uri-sans-fragment,'?')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$uri-sans-fragment" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="uri-sans-trailing-slashes">
		<xsl:call-template name="h2a:strip-trailing-slashes">
			<xsl:with-param name="str" select="$uri-sans-query" />
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="basename">
		<xsl:call-template name="h2a:basename">
			<xsl:with-param name="uri" select="$uri-sans-trailing-slashes" />
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="term">
		<xsl:call-template name="h2a:decode-uri">
			<xsl:with-param name="uri" select="$basename"/>
		</xsl:call-template>
	</xsl:variable>
	<h2a:tag-term><xsl:value-of select="$term" /></h2a:tag-term>

	<xsl:if test="$params/h2a:tag-schemes != 0">
		<xsl:variable name="uri-expanded">
			<xsl:call-template name="uri:expand">
				<xsl:with-param name="base" select="$base"/>
				<xsl:with-param name="there" select="$uri-sans-trailing-slashes"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="scheme">
			<xsl:value-of select="
			substring( $uri-expanded, 1, string-length($uri-expanded) - string-length($basename) )
			" />
		</xsl:variable>
		<h2a:tag-scheme><xsl:value-of select="$scheme" /></h2a:tag-scheme>
	</xsl:if>
</xsl:template>

<!--
 Strips trailing slashes from a string
-->
<xsl:template name="h2a:strip-trailing-slashes">
	<xsl:param name="str" />
	<xsl:choose>
		<xsl:when test="substring($str,string-length($str)) = '/'">
			<xsl:call-template name="h2a:strip-trailing-slashes">
				<xsl:with-param name="str"
					 select="substring($str,1,string-length($str)-1)" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$str" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- 
 Basename for URI
-->
<xsl:template name="h2a:basename">
	<xsl:param name="uri" />
	<xsl:choose>
		<xsl:when test="contains($uri,'/')">
			<xsl:call-template name="h2a:basename">
				<xsl:with-param name="uri"
				                select="substring-after($uri,'/')" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$uri" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- 
 Decodes an URI
-->
<xsl:template name="h2a:decode-uri">
	<xsl:param name="uri" />
	<xsl:choose>
		<xsl:when test="function-available('str:decode-uri')">
			<xsl:variable name="s">
				<xsl:call-template name="h2a:plus_to_space">
					<xsl:with-param name="string" select="$uri" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:value-of select="str:decode-uri($s)" />
		</xsl:when>
		<xsl:when test="system-property('xsl:vendor-url') = 'http://xml.apache.org/xalan-j'">
			<xsl:value-of xmlns:xalan="http://xml.apache.org/xalan/java"
			              select="xalan:java.net.URLDecoder.decode($uri,'UTF-8')" />
		</xsl:when>
		<xsl:when test="system-property('xsl:vendor-url') = 'http://www.saxonica.com/'">
			<xsl:value-of xmlns:saxon="java:java.net.URLDecoder"
			              select="saxon:decode($uri,'UTF-8')"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:message terminate="yes">XSLT engine does not support EXSLT's decode-uri().</xsl:message>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--
 Replace "+" with " "
-->
<xsl:template name="h2a:plus_to_space">
	<xsl:param name="string" />
	<xsl:choose>
		<xsl:when test="contains($string,'+')">
			<xsl:variable name="new_string" select="
				concat(
					substring-before($string,'+'),
					' ',
					substring-after($string,'+')
				)
				"/>
			<xsl:call-template name="h2a:plus_to_space">
				<xsl:with-param name="string" select="$new_string" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise><xsl:value-of select="$string" /></xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- 
 Walk the tree upwards to find
 a suitable xml:lang.
 TODO: If no one was found and $for-feed is true try to
 use the $source-lang stylesheet parameter.
-->
<xsl:template mode="h2a:add-lang-attribute" match="xhtml:*">
	<xsl:param name="params"/>
	<xsl:param name="end" />
	<xsl:choose>
		<xsl:when test="@xml:lang">
			<xsl:attribute name="xml:lang"><xsl:value-of select="@xml:lang" /></xsl:attribute>
		</xsl:when>
		<xsl:when test="@lang">
			<xsl:attribute name="xml:lang"><xsl:value-of select="@lang" /></xsl:attribute>
		</xsl:when>
		<xsl:when test="not($end='')">
			<xsl:if test="not(contains(concat(' ',normalize-space(@class),' '), concat(' ',$end,' ')))">
				<xsl:apply-templates mode="h2a:add-lang-attribute" select="parent::*">
					<xsl:with-param name="params" select="$params"/>
					<xsl:with-param name="end" select="$end" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates mode="h2a:add-lang-attribute" select="parent::*">
				<xsl:with-param name="params" select="$params"/>
				<xsl:with-param name="end" select="$end" />
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- 
 Walk the tree upwards to find
 a suitable xml:base.
 If none is found and $for-feed = true()
 try to use HTML's <base>. (If no HTML <base> is present try to use
 use the $params/h2a:source-uri stylesheet parameter.)
-->
<xsl:template mode="h2a:add-base-attribute" match="node()|*">
	<xsl:param name="params"/>
	<xsl:param name="for-feed" />
	<xsl:param name="end" />
	<xsl:choose>
		<xsl:when test="@xml:base">
			<xsl:attribute name="xml:base"><xsl:value-of select="@xml:base" /></xsl:attribute>
		</xsl:when>
		<!--
		 Are we trying to find the xml:base for <feed>
		 and are we already at the root element?
		-->
		<xsl:when test="not(parent::*) and $for-feed">
			<!-- Try to use HTML's <base> -->
			<xsl:choose>
				<xsl:when test="/xhtml:html/xhtml:head/xhtml:base[@href]">
					<xsl:attribute name="xml:base">
						<xsl:value-of select="/xhtml:html/xhtml:head/xhtml:base/@href" />
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="xml:base">
						<xsl:value-of select="$params/h2a:source-uri" />
					</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="not($end='')">
			<xsl:if test="not(contains(concat(' ',normalize-space(@class),' '), concat(' ',$end,' ')))">
				<xsl:apply-templates mode="h2a:add-base-attribute" select="parent::*">
					<xsl:with-param name="params" select="$params"/>
					<xsl:with-param name="end" select="$end" />
					<xsl:with-param name="for-feed" select="$for-feed" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates mode="h2a:add-base-attribute" select="parent::*">
				<xsl:with-param name="params" select="$params"/>
				<xsl:with-param name="end" select="$end" />
				<xsl:with-param name="for-feed" select="$for-feed" />
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- 
 Get the xml:base for the current element
 If no xml:base is present use the value of $fallback.
 If $fallback = "" then use the value of $params/h2a:source-uri
-->
<xsl:template mode="h2a:get-base" match="*">
	<xsl:param name="params"/>
	<xsl:param name="fallback" />

	<xsl:choose>
		<xsl:when test="@xml:base">
			<xsl:value-of select="@xml:base" />
		</xsl:when>
		<!--
		 Are we trying to find the xml:base for <feed>
		 and are we already at the root element?
		-->
		<xsl:when test="not(parent::*)">
			<xsl:choose>
				<xsl:when test="$fallback != ''"><xsl:value-of select="$fallback" /></xsl:when>
				<xsl:otherwise><xsl:value-of select="$params/h2a:source-uri" /></xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates mode="h2a:get-base" select="parent::*">
				<xsl:with-param name="params" select="$params"/>
				<xsl:with-param name="fallback" select="$fallback" />
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- 
 Determine if the element is inside a quotation element.
-->
<xsl:template mode="h2a:is-in-q" match="*">
	<xsl:choose>
		<xsl:when test="(local-name() = 'q' or local-name() = 'blockquote')
		                 and namespace-uri() = 'http://www.w3.org/1999/xhtml' ">
			<xsl:value-of select="'yes'" />
		</xsl:when>
		<xsl:when test="parent::*">
			<xsl:apply-templates mode="h2a:is-in-q" select="parent::*" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="'no'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- 
 Copy HTML output
-->
<xsl:template name="h2a:output">
	<xsl:param name="params"/>
	<xsl:param name="nodes" />
	<xsl:choose>
		<xsl:when test="$params/h2a:sanitize-html != 0">
			<xsl:for-each select="extension:node-set($nodes)">
				<xsl:apply-templates mode="h2a:sanitize-html" />
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="$nodes" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- 
 Sanitize HTML output
-->
<!-- 
 Copy the elements listed bellow.
 The list of acceptable elements was taken from Mark Pilgrim's Universal Feed Parser.
-->
<xsl:template mode="h2a:sanitize-html" 
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
		<xsl:apply-templates mode="h2a:sanitize-html" />
	</xsl:copy>

</xsl:template>

<xsl:template mode="h2a:sanitize-html" match="text()">
	<xsl:copy />
</xsl:template>

<!-- Inhibt all other elements -->
<xsl:template mode="h2a:sanitize-html" match="*" />

<!-- 
  Pad a datetime to the RFC 3339 format.
  
  The following format is accepted as input:
  
   date-fullyear   = 4DIGIT
   date-month      = 2DIGIT  ; 01-12
   date-mday       = 2DIGIT  ; 01-28, 01-29, 01-30, 01-31 based on
                             ; month/year
   time-hour       = 2DIGIT  ; 00-23
   time-minute     = 2DIGIT  ; 00-59
   time-second     = 2DIGIT  ; 00-58, 00-59, 00-60 based on leap second
                             ; rules
   time-secfrac    = "." 1*DIGIT
   time-numoffset  = ("+" / "-") time-hour [[":"] time-minute]
   time-offset     = "Z" / time-numoffset

   partial-time    = time-hour [":"] time-minute 
                     [ [":"] time-second [time-secfrac] ]
   full-date       = date-fullyear ["-"] date-month ["-"] date-mday
   full-time       = partial-time time-offset

   whitespace      = CR / LF / HTAB / SPC
   
   seperator       = "T" / (1*whitespace)
   
   input       = *whitespace full-date [seperator full-time] *whitespace
   
  
  If no <full-time> is present it will be assumed "00:00:00+00:00".
  If no <time-second> is present it will be assumed "00".
  If no <time-minute> is present in <time-offset> it will be assumed "00".
  
  A <time-offset> of "Z" will be translated to "+00:00".
  
  Upon invalid input the string "invalid" will be returned.
  
-->
<xsl:template name="h2a:pad-datetime">
	<xsl:param name="date" />
	<xsl:param name="s" select="translate(normalize-space($date),'tz','TZ')" />

	<xsl:param name="phase">year</xsl:param>

	<xsl:param name="year" />
	<xsl:param name="month" />
	<xsl:param name="day" />
	<xsl:param name="hour">00</xsl:param>
	<xsl:param name="minute">00</xsl:param>
	<xsl:param name="second">00</xsl:param>

	<xsl:param name="secfrac" />
	<xsl:param name="offset-sign">+</xsl:param>
	<xsl:param name="offset-h">00</xsl:param>
	<xsl:param name="offset-m">00</xsl:param>

	<xsl:variable name="s2" select="substring($s,1,2)" />

	<xsl:choose>
		<xsl:when test="$s = '' and $phase = 'year'">
			<xsl:text>invalid</xsl:text>
	  <xsl:comment>Blank string, expected datetime(Error code: 01)</xsl:comment>
		</xsl:when>
		<xsl:when test="$phase = 'year'">
			<xsl:variable name="s4" select="substring($s,1,4)" />
			<xsl:choose>
				<xsl:when test="
				                string-length($s4) = 4
				                and
				                translate($s4,'0123456789','') = ''
				">
					<xsl:call-template name="h2a:pad-datetime">
						<xsl:with-param name="phase">month</xsl:with-param>
						<xsl:with-param name="year" select="number($s4)" />
						<xsl:with-param name="date" select="$date" />
						<xsl:with-param name="s">
							<xsl:choose>
								<xsl:when test="substring($s,5,1) = '-'">
									<xsl:value-of select="substring($s,6)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="substring($s,5)" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>invalid</xsl:text>
					<xsl:comment>Invalid input: Year part is not 4 digits long and/or contains invalid characters(Error code: 02)</xsl:comment>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$phase = 'month'">
			<xsl:choose>
				<xsl:when test="
				                string-length($s2) = 2
				                and
				                translate($s2,'0123456789','') = ''
				">
					<xsl:call-template name="h2a:pad-datetime">
						<xsl:with-param name="phase">day</xsl:with-param>
						<xsl:with-param name="date" select="$date" />
						<xsl:with-param name="year" select="$year" />
						<xsl:with-param name="month" select="$s2" />
						<xsl:with-param name="s">
							<xsl:choose>
								<xsl:when test="substring($s,3,1) = '-'">
									<xsl:value-of select="substring($s,4)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="substring($s,3)" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>invalid</xsl:text>
					<xsl:comment>Invalid input: Month part is not 2 digits long and/or contains invalid characters(Error code: 03)</xsl:comment>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$phase = 'day'">
			<xsl:choose>
				<xsl:when test="
				                string-length($s2) = 2
				                and
				                translate($s2,'0123456789','') = ''
				">
						<xsl:choose>
							<xsl:when test="string-length($s) = 2">
								<xsl:call-template name="h2a:pad-datetime">
									<xsl:with-param name="phase">return</xsl:with-param>
									<xsl:with-param name="date" select="$date" />
									<xsl:with-param name="year" select="$year" />
									<xsl:with-param name="month" select="$month" />
									<xsl:with-param name="day" select="$s2" />
								</xsl:call-template>
							</xsl:when>
							<xsl:when test="
							               (substring($s,3,1) = 'T' or substring($s,3,1) = ' ')
							               and
							               string-length($s) != 3
							               and
							               translate(substring($s,4,1),'0123456789','') = ''
							">
								<xsl:call-template name="h2a:pad-datetime">
									<xsl:with-param name="phase">hour</xsl:with-param>
									<xsl:with-param name="date" select="$date" />
									<xsl:with-param name="year" select="$year" />
									<xsl:with-param name="month" select="$month" />
									<xsl:with-param name="day" select="$s2" />
									<xsl:with-param name="s" select="substring($s,4)" />
								</xsl:call-template>
							</xsl:when>
							<xsl:when test="substring($s,3,1) != 'T' and substring($s,3,1) != ' '">
								<xsl:text>invalid</xsl:text>
								<xsl:comment>Invalid input: Expected "T" or whitespace after YYYYMMDD(Error code: 04)</xsl:comment>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>invalid</xsl:text>
								<xsl:comment>Invalid input: Expected numeric characters after "T" or whitespace(Error code: 05)</xsl:comment>
							</xsl:otherwise>
						</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>invalid</xsl:text>
					<xsl:comment>Invalid input: Day part is not 2 digits long and/or contains invalid characters(Error code: 06)</xsl:comment>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$phase = 'hour'">
			<xsl:choose>
				<xsl:when test="
				                string-length($s2) = 2
				                and
				                translate($s2,'0123456789','') = ''
				">
					<xsl:call-template name="h2a:pad-datetime">
						<xsl:with-param name="phase">minute</xsl:with-param>
						<xsl:with-param name="date" select="$date" />
						<xsl:with-param name="year" select="$year" />
						<xsl:with-param name="month" select="$month" />
						<xsl:with-param name="day" select="$day" />
						<xsl:with-param name="hour" select="$s2" />
						<xsl:with-param name="s">
							<xsl:choose>
								<xsl:when test="substring($s,3,1) = ':'">
									<xsl:value-of select="substring($s,4)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="substring($s,3)" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>invalid</xsl:text>
					<xsl:comment>Invalid input: Hour part is not 2 digits long and/or contains invalid characters(Error code: 07)</xsl:comment>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$phase = 'minute'">
			<xsl:choose>
				<xsl:when test="
				                string-length($s2) = 2
				                and
				                translate($s2,'0123456789','') = ''
				">
					<xsl:choose>
						<xsl:when test="substring($s,3,1) = '+' or substring($s,3,1) = '-' or substring($s,3,1) = 'Z'">
							<xsl:call-template name="h2a:pad-datetime">
								<xsl:with-param name="phase">offset-h</xsl:with-param>
								<xsl:with-param name="date" select="$date" />
								<xsl:with-param name="year" select="$year" />
								<xsl:with-param name="month" select="$month" />
								<xsl:with-param name="day" select="$day" />
								<xsl:with-param name="hour" select="$hour" />
								<xsl:with-param name="minute" select="$s2" />
								<xsl:with-param name="offset-sign" select="substring($s,3,1)" />
								<xsl:with-param name="s" select="substring($s,4)" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="h2a:pad-datetime">
								<xsl:with-param name="phase">second</xsl:with-param>
								<xsl:with-param name="date" select="$date" />
								<xsl:with-param name="year" select="$year" />
								<xsl:with-param name="month" select="$month" />
								<xsl:with-param name="day" select="$day" />
								<xsl:with-param name="hour" select="$hour" />
								<xsl:with-param name="minute" select="$s2" />
								<xsl:with-param name="s">
									<xsl:choose>
										<xsl:when test="substring($s,3,1) = ':'">
											<xsl:value-of select="substring($s,4)" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring($s,3)" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>invalid</xsl:text>
					<xsl:comment>Invalid input: Minute part is not 2 digits long and/or contains invalid characters(Error code: 08)</xsl:comment>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$phase = 'second'">
			<xsl:choose>
				<xsl:when test="
				               string-length($s2) = 2
				               and
				               translate($s2,'0123456789','') = ''
				">
					<xsl:choose>
						<xsl:when test="substring($s,3,1) = '.'">
							<xsl:call-template name="h2a:pad-datetime">
								<xsl:with-param name="phase">secfrac</xsl:with-param>
								<xsl:with-param name="date" select="$date" />
								<xsl:with-param name="year" select="$year" />
								<xsl:with-param name="month" select="$month" />
								<xsl:with-param name="day" select="$day" />
								<xsl:with-param name="hour" select="$hour" />
								<xsl:with-param name="minute" select="$minute" />
								<xsl:with-param name="second" select="$s2" />
								<xsl:with-param name="s" select="substring($s,4)" />
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="string-length($s) != 2">
							<xsl:call-template name="h2a:pad-datetime">
								<xsl:with-param name="phase">offset-h</xsl:with-param>
								<xsl:with-param name="date" select="$date" />
								<xsl:with-param name="year" select="$year" />
								<xsl:with-param name="month" select="$month" />
								<xsl:with-param name="day" select="$day" />
								<xsl:with-param name="hour" select="$hour" />
								<xsl:with-param name="minute" select="$minute" />
								<xsl:with-param name="second" select="$s2" />
								<xsl:with-param name="offset-sign" select="substring($s,3,1)" />
								<xsl:with-param name="s" select="substring($s,4)" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>invalid</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>invalid</xsl:text>
					<xsl:comment>Invalid input: Second part is not 2 digits long and/or contains invalid characters(Error code: 09)</xsl:comment>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$phase = 'secfrac'">
		<xsl:choose>
			<xsl:when test="$s != ''">
				<xsl:variable name="sf">
					<xsl:choose>
					<xsl:when test="contains($s,'+')">
						<xsl:value-of select="substring-before($s,'+')" />
					</xsl:when>
					<xsl:when test="contains($s,'-')">
						<xsl:value-of select="substring-before($s,'-')" />
					</xsl:when>
					<xsl:when test="contains($s,'Z')">
						<xsl:value-of select="substring-before($s,'Z')" />
					</xsl:when>
					<xsl:otherwise/>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="sf-len" select="string-length($sf)" />
				<xsl:choose>
				<xsl:when test="($sf-len &gt; 0) and (translate($sf,'0123456789','') = '')">
					<xsl:call-template name="h2a:pad-datetime">
						<xsl:with-param name="phase">offset-h</xsl:with-param>
						<xsl:with-param name="date" select="$date" />
						<xsl:with-param name="year" select="$year" />
						<xsl:with-param name="month" select="$month" />
						<xsl:with-param name="day" select="$day" />
						<xsl:with-param name="hour" select="$hour" />
						<xsl:with-param name="minute" select="$minute" />
						<xsl:with-param name="second" select="$second" />
						<xsl:with-param name="secfrac" select="$sf" />
						<xsl:with-param name="offset-sign" select="substring($s,$sf-len + 1,1)" />
						<xsl:with-param name="s" select="substring($s,$sf-len + 2)" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>invalid</xsl:text>
					<xsl:comment>Invalid input: Secfrac part contains invalid characters(Error code: 10)</xsl:comment>
				</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>invalid</xsl:text>
				<xsl:comment>Invalid input: Expected timezone offset(Error code: 11)</xsl:comment>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$phase = 'offset-h'">
			<xsl:choose>
			<xsl:when test="$offset-sign = 'Z'">
				<xsl:choose>
					<xsl:when test="$s != ''">
						<xsl:text>invalid</xsl:text>
						<xsl:comment>Invalid input: Extra characters after "Z"(Error code: 12)</xsl:comment>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="h2a:pad-datetime">
							<xsl:with-param name="phase">return</xsl:with-param>
							<xsl:with-param name="date" select="$date" />
							<xsl:with-param name="year" select="$year" />
							<xsl:with-param name="month" select="$month" />
							<xsl:with-param name="day" select="$day" />
							<xsl:with-param name="hour" select="$hour" />
							<xsl:with-param name="minute" select="$minute" />
							<xsl:with-param name="second" select="$second" />
							<xsl:with-param name="secfrac" select="$secfrac" />
							<xsl:with-param name="offset-sign">+</xsl:with-param>
							<xsl:with-param name="offset-h">00</xsl:with-param>
							<xsl:with-param name="offset-m">00</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="
			                string-length($s2) = 2
			                and
			                translate($s2,'0123456789','') = ''
			">
				<xsl:choose>
					<xsl:when test="string-length($s) = 2">
						<xsl:call-template name="h2a:pad-datetime">
							<xsl:with-param name="phase">return</xsl:with-param>
							<xsl:with-param name="date" select="$date" />
							<xsl:with-param name="year" select="$year" />
							<xsl:with-param name="month" select="$month" />
							<xsl:with-param name="day" select="$day" />
							<xsl:with-param name="hour" select="$hour" />
							<xsl:with-param name="minute" select="$minute" />
							<xsl:with-param name="second" select="$second" />
							<xsl:with-param name="secfrac" select="$secfrac" />
							<xsl:with-param name="offset-sign" select="$offset-sign" />
							<xsl:with-param name="offset-h" select="$s2" />
						</xsl:call-template>
					</xsl:when>
						<xsl:when test="string-length($s) &gt;= 2">
							<xsl:call-template name="h2a:pad-datetime">
								<xsl:with-param name="phase">offset-m</xsl:with-param>
								<xsl:with-param name="date" select="$date" />
								<xsl:with-param name="year" select="$year" />
								<xsl:with-param name="month" select="$month" />
								<xsl:with-param name="day" select="$day" />
								<xsl:with-param name="hour" select="$hour" />
								<xsl:with-param name="minute" select="$minute" />
								<xsl:with-param name="second" select="$second" />
								<xsl:with-param name="secfrac" select="$secfrac" />
								<xsl:with-param name="offset-sign" select="$offset-sign" />
								<xsl:with-param name="offset-h" select="$s2" />
								<xsl:with-param name="s">
									<xsl:choose>
										<xsl:when test="substring($s,3,1) = ':'">
											<xsl:value-of select="substring($s,4)" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring($s,3)" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>invalid</xsl:text>
							<xsl:comment>Invalid input: Extra character after offset hour(Error code: 13)</xsl:comment>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>invalid</xsl:text>
					<xsl:comment>Invalid input: Offset hour part is not 2 digits long and/or contains invalid characters(Error code: 14)</xsl:comment>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$phase = 'offset-m'">
			<xsl:choose>
				<xsl:when test="
				                string-length($s2) = 2
				                and
				                translate($s2,'0123456789','') = ''
				">
					<xsl:choose>
						<xsl:when test="string-length($s) = 2">
							<xsl:call-template name="h2a:pad-datetime">
								<xsl:with-param name="phase">return</xsl:with-param>
								<xsl:with-param name="date" select="$date" />
								<xsl:with-param name="year" select="$year" />
								<xsl:with-param name="month" select="$month" />
								<xsl:with-param name="day" select="$day" />
								<xsl:with-param name="hour" select="$hour" />
								<xsl:with-param name="minute" select="$minute" />
								<xsl:with-param name="second" select="$second" />
								<xsl:with-param name="secfrac" select="$secfrac" />
								<xsl:with-param name="offset-sign" select="$offset-sign" />
								<xsl:with-param name="offset-h" select="$offset-h" />
								<xsl:with-param name="offset-m" select="$s2" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>invalid</xsl:text>
							<xsl:comment>Invalid input: characters after offset minute(Error code: 15)</xsl:comment>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>invalid</xsl:text>
					<xsl:comment>Invalid input: Offset minute part is not 2 digits long and/or contains invalid characters(Error code: 16)</xsl:comment>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$phase = 'return'">
			<xsl:value-of select="concat($year,'-',$month,'-',$day,'T',$hour,':',$minute,':',$second)" />
			<xsl:if test="$secfrac != ''">
				<xsl:value-of select="concat('.',$secfrac)" />
			</xsl:if>
			<xsl:value-of select="concat($offset-sign,$offset-h,':',$offset-m)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>invalid</xsl:text>
			<xsl:comment>Internal error in stylesheet(Error code: 17)</xsl:comment>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- strip text -->
<xsl:template match="text()"></xsl:template>
</xsl:transform>
