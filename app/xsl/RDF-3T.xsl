<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
  	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"  
  	xmlns:tt="http://weborganics.co.uk/Profiles/RDF-3T/"   
	exclude-result-prefixes="xhtml tt"
	version="1.0"
>
<!-- 
 
RDF-3T $version 0.1 *** Stable *** $contact Martin McEvoy <info@weborganics.co.uk>

Published 2009-01-26 with a Creative Commons Public Domain License see: <http://creativecommons.org/licenses/publicdomain/deed.en_GB>

-->
<xsl:output method="xml" 
		   indent="yes" 
		   encoding="UTF-8" 
		   media-type="application/rdf+xml"/>

<!-- base-href of the current HTML doc -->
<xsl:param name="base-href" select="/xhtml:html/xhtml:head/xhtml:base/@href[1]"/>

<!-- base-uri of the current HTML doc set by parser -->
<xsl:param name="base-uri" select='""' />

<!-- chose either $base-href or $base-uri -->
<xsl:param name="this-base">
	<xsl:choose>
		<xsl:when test="string-length($base-href)>0">
			<xsl:value-of select="$base-href"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$base-uri"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:param>

<xsl:template match="/">

<!-- find RDF-3T classes by testing if there is a @name prefix and a (prefix:) -->
<xsl:variable name="ns-prefixes" select="//*[contains(@name,'prefix') and //*[substring-before(@class,':')]]"/>

<xsl:variable name="value" select="//*[contains(@class,':')]"/>
<rdf:RDF xml:base="{$this-base}">
	<xsl:choose>
		<xsl:when test="$ns-prefixes = true()">
				<xsl:for-each select="$value">
					    <xsl:call-template name="tt:triples">
							<xsl:with-param name="thisclass" select="@class"/>
						</xsl:call-template>
			    </xsl:for-each>
				<xsl:apply-templates/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:comment> SORRY CAN'T FIND A SCHEME AND A MATCHING PREFIX </xsl:comment>
		</xsl:otherwise>
	</xsl:choose>
</rdf:RDF>
</xsl:template>

<!-- scheme (prefix) and name (prefix) found  -->
<xsl:template name="tt:triples">
<xsl:param name="thisclass"/>
<xsl:variable name="recurseclass" select="normalize-space(substring-after($thisclass,' '))" />
<xsl:variable name="thisprefix" select="substring-before($thisclass,':')"/>
<xsl:variable name="thisTerm" select="substring-after($thisclass,':')"/>
<xsl:variable name="term" select="substring-before($thisTerm,'=')"/>
<xsl:variable name="namespace" select="/*//*[contains(@name,'prefix') and @scheme = $thisprefix]/@content"/>

<!-- make sure there is a matching namespace -->
<xsl:if test="$namespace = true()">
<xsl:call-template name="tt:rdf">
	<xsl:with-param name="prefix" select="$thisprefix"/>
	<xsl:with-param name="term" select="$term"/>
	<xsl:with-param name="namespace" select="$namespace"/>
	<xsl:with-param name="thisclass" select="$thisclass"/>
</xsl:call-template>
</xsl:if>

<!-- are there more prefixed: references found within the same class?-->
<xsl:if test="substring-after($recurseclass,':')">
	<xsl:call-template name="tt:triples">
		<xsl:with-param name="thisclass" select="$recurseclass"/>
	</xsl:call-template>    	
</xsl:if>

</xsl:template>

<!-- call RDF Triples -->
<xsl:template name="tt:rdf">
<xsl:param name="prefix"/>
<xsl:param name="term"/>
<xsl:param name="namespace"/>
<xsl:param name="thisclass"/>
<xsl:variable name="value" select="substring-after($thisclass,'=')"/>
<xsl:variable name="nullprefix" select="normalize-space(substring-before($prefix,' '))" />
<xsl:variable name="name" select="$term"/>
	<xsl:variable name="string" select="normalize-space($value)"/>
		<xsl:variable name="thisValue"><!-- strip spaces at the end of a value -->
			<xsl:choose>
				<xsl:when test="substring-after($string,' ')">
					<xsl:value-of select="substring-before($string,' ')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$string"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>	
	<xsl:variable name="thisID" select="@id"/>
	<xsl:variable name="thisAbout" select="@href"/>
	<xsl:variable name="parentType" select="ancestor::*[substring-before(@class,'item')][1]"/>
	<xsl:variable name="lang" select="string(ancestor-or-self::*/attribute::xml:lang[1])" />
	

<!-- reject any prefixes: with spaces -->
<xsl:if test="$nullprefix = false()">
	
	  <!--  for testing <xsl:comment> ============start============== </xsl:comment>
			<xsl:comment><xsl:value-of select="$prefix"/></xsl:comment>
			<xsl:comment><xsl:value-of select="$term"/></xsl:comment>
			<xsl:comment><xsl:value-of select="$namespace"/></xsl:comment>
			<xsl:comment><xsl:value-of select="$thisValue"/></xsl:comment>
			<xsl:comment> ============end============== </xsl:comment> -->
			
<xsl:choose>

<!-- test if there is a string after equals(=) if true triple out!!!!-->
<xsl:when test="string-length($thisValue)>0">
  <xsl:element name='rdf:Description'>
	<xsl:choose>
	
<!-- when test value = item  -->	
		<xsl:when test="$thisValue = 'item'">
			<xsl:call-template name="tt:type">
				<xsl:with-param name="thisID" select="$thisID"/>
				<xsl:with-param name="thisAbout" select="$thisAbout"/>
				<xsl:with-param name="thisIDhref" select="substring-before($thisID,':')"/>
				<xsl:with-param name="thisIDafter" select="substring-after($thisID,':')"/>
			</xsl:call-template>
			<xsl:element name='rdf:type'>
				<xsl:attribute name="rdf:resource">
					<xsl:value-of select="$namespace" />
					<xsl:value-of select="$name" />
				</xsl:attribute>
			</xsl:element>
		</xsl:when>
		
<!-- when test value = resource  -->		
		<xsl:when test="$thisValue = 'resource'">
			<xsl:call-template name="tt:about">
				<xsl:with-param name="parentType" select="$parentType"/>
				<xsl:with-param name="IDhref" select="substring-before($parentType/@id,':')"/>
				<xsl:with-param name="thisIDhref" select="substring-after($parentType/@id,':')"/>
			</xsl:call-template>
			<xsl:element name='{$prefix}:{$name}' namespace="{$namespace}">
				<xsl:attribute name="rdf:resource">
					<xsl:call-template name="tt:resource"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:when>

<!-- when test value = content  -->		
		<xsl:when test="$thisValue = 'content'">
			<xsl:call-template name="tt:about">
				<xsl:with-param name="parentType" select="$parentType"/>
				<xsl:with-param name="IDhref" select="substring-before($parentType/@id,':')"/>
				<xsl:with-param name="thisIDhref" select="substring-after($parentType/@id,':')"/>
			</xsl:call-template>
			<xsl:element name='{$prefix}:{$name}' namespace="{$namespace}">
			<xsl:if test="$lang">
		  		<xsl:attribute name='xml:lang'>
		     		<xsl:value-of select="$lang" />
				</xsl:attribute>				
			</xsl:if>
				<xsl:value-of select="." />
			</xsl:element>
		</xsl:when>
		
<!-- * dev value * when test value = title * dev value * -->		
		<xsl:when test="$thisValue = 'title'">
			<xsl:call-template name="tt:about">
				<xsl:with-param name="parentType" select="$parentType"/>
				<xsl:with-param name="IDhref" select="substring-before($parentType/@id,':')"/>
				<xsl:with-param name="thisIDhref" select="substring-after($parentType/@id,':')"/>
			</xsl:call-template>
			<xsl:element name='{$prefix}:{$name}' namespace="{$namespace}">
			<xsl:if test="$lang">
		  		<xsl:attribute name='xml:lang'>
		     		<xsl:value-of select="$lang" />
				</xsl:attribute>				
			</xsl:if>
				<xsl:value-of select="@title" />
			</xsl:element>
		</xsl:when>
		
		
<!-- when test value = literal  -->		
		<xsl:when test="$thisValue = 'literal'">
			<xsl:call-template name="tt:about">
				<xsl:with-param name="parentType" select="$parentType"/>
				<xsl:with-param name="IDhref" select="substring-before($parentType/@id,':')"/>
				<xsl:with-param name="thisIDhref" select="substring-after($parentType/@id,':')"/>
			</xsl:call-template>
			<xsl:element name='{$prefix}:{$name}' namespace="{$namespace}">
		  		<xsl:attribute name='rdf:datatype'>
		     		<xsl:text>http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral</xsl:text>
				</xsl:attribute>
				<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
					<xsl:copy>
						<xsl:copy-of select="child::*|text()" />
					</xsl:copy>
				<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
			</xsl:element>
		</xsl:when>

<!-- when test value = #id or #_  -->	
		<xsl:when test="substring-after($thisValue,'#')">
		<xsl:variable name="thatNode" select="/*//*[substring-before(@class,'item')][1]"/>
		<xsl:variable name="thisNode" select="substring-after($thisValue,'#')"/>
		<xsl:call-template name="tt:about">
			<xsl:with-param name="parentType" select="$parentType"/>
			<xsl:with-param name="IDhref" select="substring-before($parentType/@id,':')"/>
			<xsl:with-param name="thisIDhref" select="substring-after($parentType/@id,':')"/>
		</xsl:call-template>			
		<xsl:element name='{$prefix}:{$name}' namespace="{$namespace}">				
			<xsl:choose>
				<xsl:when test="$thisNode = $thatNode/@id"><!-- check the id exists in the current html document -->
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="concat($this-base, '#', $thisNode)" />
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="$thisNode = '_'">
				<xsl:variable name="childNode" select="child::*[substring-before(@class,'item')][1]"/>
				<xsl:variable name="thisref" select="substring-before($childNode/@id,':')"/>
					<xsl:choose>
					<xsl:when test="$thisref">
						<xsl:attribute name="rdf:resource">
								<xsl:value-of select="/*//*[contains(@name,'prefix') and @scheme = $thisref]/@content" />
								<xsl:value-of select="substring-after($childNode/@id,':')" />
						</xsl:attribute>					
					</xsl:when>
					<xsl:when test="$childNode/@href">
						<xsl:attribute name="rdf:resource">
							<xsl:for-each select="$childNode">
								<xsl:call-template name="tt:resource"/>
							</xsl:for-each>
						</xsl:attribute>					
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="rdf:nodeID">
							<xsl:value-of select="generate-id($childNode)" />
						</xsl:attribute>
					</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:comment> CAN'T COMPLETE TRIPLE FOR "<xsl:value-of select="$prefix" />:<xsl:value-of select="$name" />", NO MATCHING ID WITHIN THE CURRENT DOCUMENT </xsl:comment>
				</xsl:otherwise>
			</xsl:choose>								
			</xsl:element>
		</xsl:when>	
		
<!-- when test value = [prefix:reference] (curie)  -->		
		<xsl:when test="substring-after($thisValue,'[')">
		<xsl:variable name="curiePrefix" select="substring-before(translate($thisValue,'[]',''),':')"/>
		<xsl:variable name="curieTerm" select="substring-after(translate($thisValue,'[]',''),':')"/>
		<xsl:variable name="curieUrl" select="/*//*[contains(@name,'prefix') and @scheme = $curiePrefix]/@content"/>
		<xsl:call-template name="tt:about">
			<xsl:with-param name="parentType" select="$parentType"/>
				<xsl:with-param name="IDhref" select="substring-before($parentType/@id,':')"/>
				<xsl:with-param name="thisIDhref" select="substring-after($parentType/@id,':')"/>
		</xsl:call-template>
			<xsl:element name='{$prefix}:{$name}' namespace="{$namespace}">
				<xsl:attribute name="rdf:resource">
					<xsl:value-of select="$curieUrl" />
					<xsl:value-of select="$curieTerm" />
				</xsl:attribute>
			</xsl:element>
		</xsl:when>

<!-- otherwise the value is a string  -->		
		<xsl:otherwise>
			<xsl:call-template name="tt:about">
				<xsl:with-param name="parentType" select="$parentType"/>
				<xsl:with-param name="IDhref" select="substring-before($parentType/@id,':')"/>
				<xsl:with-param name="thisIDhref" select="substring-after($parentType/@id,':')"/>
			</xsl:call-template>
			<xsl:element name='{$prefix}:{$name}' namespace="{$namespace}">
				<xsl:choose>
				<xsl:when test="$thisValue = '#'">
					<xsl:comment> CAN'T COMPLETE TRIPLE FOR "<xsl:value-of select="$prefix" />:<xsl:value-of select="$name" />", VALUE AFTER # EMPTY </xsl:comment>
				</xsl:when>
					<xsl:otherwise><xsl:value-of select="$thisValue" /></xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:otherwise>
		
	</xsl:choose>	
 </xsl:element>
</xsl:when>

<!-- discard triple  -->
	<xsl:otherwise><xsl:comment> CAN'T COMPLETE TRIPLE, VALUE (=) CAN'T BE AN EMPTY STRING </xsl:comment></xsl:otherwise>
	
</xsl:choose>
</xsl:if>
</xsl:template>





<!-- ============================ basic templates for parsing  below here ======================= -->

<xsl:template name="tt:about">
<xsl:param name="parentType"/>
<xsl:param name="IDhref"/>
<xsl:param name="thisIDhref"/>
	<xsl:choose>
		<xsl:when test="$parentType/@href">
			<xsl:attribute name="rdf:about">
				<xsl:value-of select="$parentType/@href" />
			</xsl:attribute>
		</xsl:when>
		<xsl:when test="$IDhref">
			<xsl:attribute name="rdf:about">
				<xsl:value-of select="/*//*[contains(@name,'prefix') and @scheme = $IDhref]/@content" />
				<xsl:value-of select="$thisIDhref" />
			</xsl:attribute>
		</xsl:when>
		<xsl:when test="$parentType/@id">
			<xsl:attribute name="rdf:about">
				<xsl:value-of select="concat($this-base, '#', $parentType/@id)" />
			</xsl:attribute>
		</xsl:when>
		<xsl:when test="$parentType">
			<xsl:attribute name="rdf:nodeID">
				<xsl:value-of select="generate-id($parentType)" />
			</xsl:attribute>
		</xsl:when>
		<xsl:otherwise>
			<xsl:attribute name="rdf:about">
				<xsl:value-of select="$this-base" />
			</xsl:attribute>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="tt:type">
<xsl:param name="thisID"/>
<xsl:param name="thisAbout"/>
<xsl:param name="thisIDhref"/>
<xsl:param name="thisIDafter"/>
<xsl:choose>
	<xsl:when test="$thisAbout">
		<xsl:attribute name="rdf:about">
			<xsl:call-template name="tt:resource"/>
		</xsl:attribute>
	</xsl:when>
	<xsl:when test="$thisIDhref">
		<xsl:attribute name="rdf:about">
			<xsl:value-of select="/*//*[contains(@name,'prefix') and @scheme = $thisIDhref]/@content" />
			<xsl:value-of select="$thisIDafter" />
		</xsl:attribute>
	</xsl:when>
	<xsl:when test="$thisID">
		<xsl:attribute name="rdf:about">
			<xsl:value-of select="concat($this-base, '#', $thisID)" />
		</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
		<xsl:attribute name="rdf:nodeID">
			<xsl:value-of select="generate-id()" />
		</xsl:attribute>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="tt:resource">
<xsl:choose>
<xsl:when test="@src">
<!-- attempt to resolve relative urls for images -->
	<xsl:choose>
		<xsl:when test="starts-with(@src,'./')" >
			<xsl:call-template name="tt:location">
				<xsl:with-param name="url" select="$this-base"/>
			</xsl:call-template>
			<xsl:value-of select="substring-after(@src,'./')"/>
		</xsl:when>
		<xsl:when test="starts-with(@src,'../') or starts-with(@src,'/')" >
			<xsl:call-template name="tt:root">
				<xsl:with-param name="url" select="$this-base"/>
			</xsl:call-template>
			<xsl:choose>
				<xsl:when test="substring-after(@src,'../')" >
					<xsl:value-of select="substring-after(@src,'../')"/>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="substring-after(@src,'/')"/></xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="starts-with(@src,'http')" >
					<xsl:value-of select="@src" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="tt:location">
						<xsl:with-param name="url" select="$this-base"/>
					</xsl:call-template>
						<xsl:value-of select="@src"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
	</xsl:choose>
</xsl:when>
<xsl:otherwise>
<!-- attempt to resolve relative url's for links -->
	<xsl:choose>
		<xsl:when test="starts-with(@href,'#')">
			<xsl:value-of select="$this-base" />
			<xsl:value-of select="@href"/>
		</xsl:when>
		<xsl:when test="starts-with(@href,'./')">
			<xsl:call-template name="tt:location">
				<xsl:with-param name="url" select="$this-base"/>
			</xsl:call-template>
				<xsl:value-of select="substring-after(@href,'./')"/>
			</xsl:when>
			<xsl:when test="starts-with(@href,'../') or starts-with(@href,'/')" >
			<xsl:call-template name="tt:root">
			<xsl:with-param name="url" select="$this-base"/>
			</xsl:call-template>
			<xsl:choose>
				<xsl:when test="substring-after(@href,'../')">
					<xsl:value-of select="substring-after(@href,'../')"/>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="substring-after(@href,'/')"/></xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
		<xsl:variable name="true" select="substring-before(@href,':')"/>
			<xsl:choose>
				<xsl:when test="starts-with(@href,'http:') or starts-with(@href,'mailto:') or starts-with(@href,'ftp:')" >
					<xsl:value-of select="@href" />
				</xsl:when>
				<!-- href is not http:, mailto: or ftp: try to extract curie -->
				<xsl:when test="substring-before(@href,':')" >
					<xsl:value-of select="/*//*[contains(@name,'prefix') and @scheme = $true]/@content" />
					<xsl:value-of select="substring-after(@href,':')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="tt:location">
						<xsl:with-param name="url" select="$this-base"/>
					</xsl:call-template>
					<xsl:value-of select="@href"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- @@@ below here re-used from Fabien Gandon's RDFa2RDF.xsl thank you :) @@@ -->
  <xsl:template name="tt:root">
    <xsl:param name="url" />
	<xsl:choose>
		<xsl:when test="contains($url,'//')">
			<xsl:value-of select="concat(substring-before($url,'//'),'//',substring-before(substring-after($url,'//'),'/'),'/')"/>
		</xsl:when>
		<xsl:otherwise><xsl:comment> CAN'T FIND ROOT </xsl:comment></xsl:otherwise>
	</xsl:choose>    
  </xsl:template>
  
  <xsl:template name="tt:location">
    <xsl:param name="url" />
  	<xsl:if test="string-length($url)>0 and contains($url,'/')">
  		<xsl:value-of select="concat(substring-before($url,'/'),'/')"/>
  		<xsl:call-template name="tt:location"><xsl:with-param name="url" select="substring-after($url,'/')"/></xsl:call-template>
  	</xsl:if>
  </xsl:template>
<!-- exit  -->		
<!-- discard text -->
<xsl:template match="text()|*"></xsl:template>
</xsl:stylesheet>