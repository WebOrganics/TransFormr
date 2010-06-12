<?xml version="1.0" encoding="UTF-8"?>
<!-- hAtom to SIOC XSLT version: 0.2  -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:sioc="http://rdfs.org/sioc/ns#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:uri ="http://www.w3.org/2000/07/uri43/uri.xsl?template="
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="uri"
    version="1.0">
	
<xsl:import href="uri.xsl" />

<xsl:output method="xml" 
		   indent="yes" 
		   encoding="UTF-8" 
		   media-type="application/rdf+xml"/>

<!-- referring url set by parser  -->
<xsl:param name="base-uri" select="''"/>

<!-- title of the current HTML doc set by Processor ( for fragment parsing ) -->
<xsl:param name="doc-title" select="''"/>

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

<xsl:param name="abs-url">
	<xsl:choose>
		<xsl:when test="substring-before($base-uri,'#')">
			<xsl:value-of select="substring-before($base-uri,'#')"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$base-uri"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:param>

<xsl:template match="/">

<rdf:RDF xml:base="{$abs-url}">
<xsl:if test="$entry">
	<xsl:element name='rdf:Description'>
		<xsl:attribute name="rdf:about"><xsl:value-of select="$abs-url" /></xsl:attribute>
		<xsl:element name="rdf:type">
			<xsl:attribute name="rdf:resource">
				<xsl:value-of select="'http://rdfs.org/sioc/types#Weblog'"/>
			</xsl:attribute>
		</xsl:element>
		<xsl:element name='dc:title'>
			<xsl:value-of select="normalize-space(descendant::*[name() = 'title'])"/>
		</xsl:element>
		<xsl:element name='dc:description'>
			<xsl:value-of select="$meta"/>
		</xsl:element>
		<xsl:for-each select='$entry'>
			<xsl:element name='sioc:container_of'>
				<xsl:choose>
					<xsl:when test="@id">
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="$abs-url" />
							<xsl:text>#</xsl:text>
							<xsl:value-of select="@id" />
						</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="rdf:nodeID">
							<xsl:value-of select="generate-id()"/>
						</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:for-each>
	</xsl:element>
	<xsl:for-each select='$entry'>
		<xsl:call-template name='hentry'/>
	</xsl:for-each>
</xsl:if>
</rdf:RDF>

</xsl:template>

<!-- hentry -->
<xsl:template name="hentry">
<xsl:element name='sioc:Post'>
	<xsl:choose>
		<xsl:when test="@id">
			<xsl:attribute name="rdf:about">
				<xsl:value-of select="$abs-url"/>
				<xsl:text>#</xsl:text>
				<xsl:value-of select="@id" />
			</xsl:attribute>
		</xsl:when>
		<xsl:otherwise>
			<xsl:attribute name="rdf:nodeID">
				<xsl:value-of select="generate-id()"/>
			</xsl:attribute>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:call-template name='title'/>
	<xsl:call-template name='pubdate'/>
	<xsl:call-template name='permalink'/>
	<xsl:call-template name='author-name'/>
	<xsl:call-template name='entry-content'/>
	<xsl:call-template name='keywords'/>
</xsl:element>
</xsl:template>

<!-- entry-title -->
<xsl:template name="title">
<xsl:param name="entry-title" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' entry-title ')]"/>
	<xsl:if test="$entry-title">
		<xsl:element name='dc:title'>
			<xsl:value-of select="normalize-space($entry-title)"/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- updated or published -->
<xsl:template name="pubdate">
<xsl:param name="updated" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' updated ')]"/>
<xsl:param name="published" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' published ')]"/>
	<xsl:if test="$updated">
		<xsl:element name='dcterms:modified'>
		<xsl:for-each select="$updated">
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
	<xsl:if test="$published">
		<xsl:element name='dcterms:created'>
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

<!-- bookmark -->
<xsl:template name="permalink">
<xsl:param name="bookmark" select="descendant::*[contains(concat(' ',normalize-space(@rel),' '),' bookmark ')]"/>
	<xsl:if test="$bookmark">
		<xsl:element name='sioc:link'>
			<xsl:attribute name="rdf:resource">
				<xsl:call-template name="extract-resource">
					<xsl:with-param name="resource" select="$bookmark/@href"/>
				</xsl:call-template>
			</xsl:attribute>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- author -->
<xsl:template name="author-name">
<xsl:param name="name" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' author ') or contains(concat(' ',normalize-space(@class),' '),' fn ')]"/>
<xsl:param name="url" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' url ')]"/>
	<xsl:if test="$name">
		<xsl:element name='sioc:has_creator'>
			<xsl:element name='sioc:UserAccount'>
				<xsl:element name="foaf:name">
					<xsl:value-of select="normalize-space($name)"/>
				</xsl:element>
				<xsl:if test="$url">
					<xsl:element name="foaf:homepage">
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="$url/@href"/>
						</xsl:attribute>
					</xsl:element>
				</xsl:if>
			</xsl:element>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- entry-content or entry-summary -->
<xsl:template name="entry-content">
<xsl:param name="content" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' entry-content ') or contains(concat(' ',normalize-space(@class),' '),' entry-summary ')][1]"/>
	<xsl:if test="$content">
		<xsl:element name='sioc:content'>
				<xsl:value-of select="normalize-space($content)"/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- tag -->
<xsl:template name="keywords">
<xsl:variable name="tag" select="descendant::*[contains(concat(' ',normalize-space(@rel),' '),' tag ')]"/>
		<xsl:if test="$tag">
		<xsl:element name='sioc:topic'>
			<xsl:for-each select="$tag">
        	<xsl:value-of select="."/>
            <xsl:if test="not(position()=last())">
                <xsl:text >, </xsl:text>
            </xsl:if>
      	</xsl:for-each>
		</xsl:element>
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

<!-- strip text -->
<xsl:template match="text()|*"></xsl:template>
</xsl:stylesheet>
