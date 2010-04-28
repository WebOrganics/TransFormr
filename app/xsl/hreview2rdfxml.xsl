<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:review="http://dannyayers.com/xmlns/rev/" 
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
	xmlns:mf="http://suda.co.uk/projects/microformats/mf-templates.xsl?template="
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:dcterms="http://purl.org/dc/dcmitype/" 
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
	xmlns:foaf="http://xmlns.com/foaf/0.1/" 
	xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
	xmlns:tag="http://www.holygoat.co.uk/owl/redwood/0.1/tags/"
	version="1.0"
>

<xsl:include href="mf-templates.xsl"/>

<!--
@todo
* language settings
* base URI
* tags
-->
<xsl:param name="Source" />
<xsl:param name="Anchor" />

<xsl:output 
	indent="yes" 
	omit-xml-declaration="yes" 
	method="xml"
/>

<xsl:template match="/xhtml:html/xhtml:body">
	<rdf:RDF>
		<!-- loop through for hReview data -->
		<xsl:for-each select="//*[contains(concat(' ',normalize-space(@class),' '),' hreview ')]">
			<xsl:if test="
			(descendant::*[contains(concat(' ',normalize-space(@class),' '),' summary ')] or descendant::*[contains(concat(' ',normalize-space(@class),' '),' item ')]/descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')])
			and (not($Anchor) or @id = $Anchor)
			">
				<xsl:element name="Description" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
					<xsl:attribute name="about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
						<xsl:choose>
							<!-- this is the about of the @id? or the $Source? -->
							<!-- use permalink -->
							<xsl:when test="descendant::*[contains(concat(' ',normalize-space(@rel),' '),' permalink ')]">
								<xsl:value-of select="descendant::*[contains(concat(' ',normalize-space(@rel),' '),' permalink ')]/@href"/>
							</xsl:when>
							<xsl:when test="$Source">
								<xsl:call-template name="mf:baseURL">
									<xsl:with-param name="Source"><xsl:value-of select="$Source"/></xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							<!-- use local ID -->
							<xsl:when test="@id">
								<xsl:value-of select="@id"/>
							</xsl:when>
							<!-- use URL -->
							<!--
							<xsl:when test="(descendant::*[contains(concat(' ',normalize-space(@class),' '),' summary ')] or descendant::*[contains(concat(' ',normalize-space(@class),' '),' item ')]/descendant::*[contains(concat(' ',normalize-space(@class),' '),' url ')])">
								<xsl:value-of select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' item ')]/descendant::*[contains(concat(' ',normalize-space(@class),' '),' url ')]/@href"/>
							</xsl:when>
							-->
							<!-- use base-param -->
							<!--
							-->
						</xsl:choose>
					</xsl:attribute>
					
					<!-- look for the THING to review -->
					<xsl:call-template name="properties"/>						
					
					<!-- extract Review Data -->
					<xsl:call-template name="hReviewProperties"/>						


				</xsl:element>
			</xsl:if>
  		</xsl:for-each>		
	</rdf:RDF>
</xsl:template>		

<xsl:template name="properties">
	<!-- Item being Reviewed (required) :: 1 instance -->
	  <xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' item ')][1]">

		<xsl:choose>
			<xsl:when test="self::*[contains(concat(' ',normalize-space(@class),' '),' vevent ')]">
				<!-- get vevent data -->


			</xsl:when>
			<!-- beware of vCards nested in vevents -->
			<xsl:when test="self::*[contains(concat(' ',normalize-space(@class),' '),' vcard ')]">
				<!-- get vCard data -->
				<!-- (optional) :: single instance -->
				<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')][1]">					
					<vcard:FN><xsl:call-template name="mf:extractText"/></vcard:FN>
				</xsl:for-each>

				<!-- (optional) :: multiple instances -->
				<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' url ')]">					
					<xsl:variable name="url">
						<xsl:call-template name="mf:extractUrl">
							<xsl:with-param name="Source"><xsl:value-of select="$Source"/></xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<vcard:URL rdf:resource="{$url}"/>
				</xsl:for-each>

				<!-- (optional) :: multiple instances -->
				<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' photo ')]">					
					<vcard:PHOTO>
						<xsl:call-template name="mf:extractUrl">
							<xsl:with-param name="Source"><xsl:value-of select="$Source"/></xsl:with-param>
						</xsl:call-template>	
					</vcard:PHOTO>
				</xsl:for-each>						

				<!-- (optional) :: multiple instances -->
				<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' adr ')]">
					<xsl:call-template name="mf:extractAdr"/>
				</xsl:for-each>

				<!-- (optional) :: single instance -->
				<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', @class, ' '),concat(' ', 'geo', ' '))][1]">
					<xsl:call-template name="mf:extractGeo"/>
				</xsl:for-each>

			</xsl:when>
			<xsl:otherwise>
				<!-- (Required) :: single instances -->
				<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')]">					
					<rdfs:label><xsl:call-template name="mf:extractText"/></rdfs:label>
				</xsl:for-each>

				<!-- (optional) :: multiple instances -->
				<!-- need General Link, seeAlso or seeMore, not RDF at the end just URI -->
				<!--
				<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' url ')]">					
					<dc:identifier>
						<xsl:call-template name="mf:extractUrl">
							<xsl:with-param name="Source"><xsl:value-of select="$Source"/></xsl:with-param>
						</xsl:call-template>
					</dc:identifier>
				</xsl:for-each>
				-->
			
				<!-- (optional) :: multiple instances -->
				<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' photo ')]">					
					<dcterms:Image>
						<xsl:call-template name="mf:extractUrl">
							<xsl:with-param name="Source"><xsl:value-of select="$Source"/></xsl:with-param>
						</xsl:call-template>
					</dcterms:Image>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>				
	  </xsl:for-each>
</xsl:template>

<xsl:template name="hReviewProperties">
	<review:hasReview>
		
		<!-- this is the about of the @id? or the $Source? -->
		<!-- maybe change this to rdf:seeAlso -->
		<xsl:variable name="reviewAbout">
			<xsl:choose>
				<xsl:when test="descendant::*[contains(concat(' ',normalize-space(@class),' '),' item ')][1]/descendant::*[contains(concat(' ',normalize-space(@class),' '),' url ')][1]">
					<xsl:call-template name="mf:baseURL">
						<xsl:with-param name="Source"><xsl:value-of select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' item ')][1]/descendant::*[contains(concat(' ',normalize-space(@class),' '),' url ')][1]/@href"/></xsl:with-param>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
<!--		<review:Review rdf:about="{$reviewAbout}"> -->
		<review:Review>
		<!-- add rdf:about here with the URL of the item -->
	
	
	<!-- Review Summary (optional) :: 1 instance -->
	<xsl:choose>
		<xsl:when test="descendant::*[contains(concat(' ',normalize-space(@class),' '),' summary ')][1]">
			<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' summary ')][1]">
				<rdfs:label><xsl:call-template name="mf:extractText" /></rdfs:label>
			</xsl:for-each>
		</xsl:when>
		<xsl:when test="false() = descendant::*[contains(concat(' ',normalize-space(@class),' '),' summary ')]">
			<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' item ')][1]/descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')][1]">
				<rdfs:label><xsl:call-template name="mf:extractText" /></rdfs:label>
			</xsl:for-each>
		</xsl:when>
	</xsl:choose>

	<!-- Review Type (optional) :: 1 instance -->
	<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' type ')][1]">
	  <!-- product | business | event | person | place | website | url -->
	  <xsl:variable name="reviewType">
	  	<xsl:call-template name="mf:extractText"/>
	  </xsl:variable>
	  <xsl:choose>
	  	<xsl:when test="
	  		$reviewType = 'product' or
	  		$reviewType = 'business' or
	  		$reviewType = 'event' or
	  		$reviewType = 'person' or
	  		$reviewType = 'place' or
	  		$reviewType = 'website' or
	  		$reviewType = 'url'
	  	">
	  		<dc:type><xsl:value-of select="$reviewType"/></dc:type>
	  	</xsl:when>
	  	<!-- implied types -->
	  	<xsl:when test="//*[
	  		 (contains(concat(' ',normalize-space(@class),' '),' item ') and
	  		  contains(concat(' ',normalize-space(@class),' '),' vcard '))
	  		]/descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ') and contains(concat(' ',normalize-space(@class),' '),' org ')]">
	  		<dc:type>business</dc:type>
	  	</xsl:when>
	  	<xsl:when test="//*[
	  		 (contains(concat(' ',normalize-space(@class),' '),' item ') and
	  		  contains(concat(' ',normalize-space(@class),' '),' vcard '))
	  		]">
	  		<dc:type>person</dc:type>
	  	</xsl:when>
	  	<xsl:when test="//*[
	  		 (contains(concat(' ',normalize-space(@class),' '),' item ') and
	  		  contains(concat(' ',normalize-space(@class),' '),' vevent '))
	  		]">
	  		<dc:type>event</dc:type>
	  	</xsl:when>
	  	<xsl:otherwise>
	  		<!-- default value? -->
	  	</xsl:otherwise>
	  </xsl:choose>
	</xsl:for-each>

  <!-- Review Date (optional) ISO Timestamp :: 1 instance -->
  <xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' dtreviewed ')][1]">
	<review:createdOn><xsl:call-template name="mf:extractDate"/></review:createdOn>
  </xsl:for-each>

  <!-- Rating and Rating scale (optional) :: 1 instance -->
  <xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' rating ')][1]">
	<review:rating rdf:datatype="http://www.w3.org/2001/XMLSchema#float"><xsl:call-template name="mf:extractText"/></review:rating>
  </xsl:for-each>

  <!-- check that these are nested in rating! -->
  <xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' best ')][1]">
  	<review:maxRating rdf:datatype="http://www.w3.org/2001/XMLSchema#float"><xsl:call-template name="mf:extractText"/></review:maxRating>
  </xsl:for-each>
  <xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' worst ')][1]">
  	<review:minRating rdf:datatype="http://www.w3.org/2001/XMLSchema#float"><xsl:call-template name="mf:extractText"/></review:minRating>
  </xsl:for-each>


  <!-- Review Description (optional) :: 1 instance -->
  <xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' description ')][1]">
	<review:text><xsl:call-template name="mf:extractText"/></review:text>
  </xsl:for-each>

  <!-- Review Permalink (optional) :: 1 instance -->
  <!-- this might get moved to rdf:about="" -->
  <!--
  <xsl:for-each select="descendant::*[
	 (contains(concat(' ',normalize-space(@rel),' '),' bookmark ') and
	  contains(concat(' ',normalize-space(@rel),' '),' self '))
	][1]">
	<dc:identifier><xsl:call-template name="mf:extractUrl"/></dc:identifier>
  </xsl:for-each>
  -->

  <!-- Review License (optional) :: multiple instances -->
  <xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@rel),' '),' license ')][1]">
	<dc:license rdf:resource="{@href}" />
  </xsl:for-each>

  <!-- Reviewer (optional) :: 1 instance -->
  <xsl:for-each select="descendant::*[
	 (contains(concat(' ',normalize-space(@class),' '),' reviewer ') and
	  contains(concat(' ',normalize-space(@class),' '),' vcard '))
	][1]">
	<review:reviewer>
		<!-- Range = http://xmlns.com/foaf/0.1/Agent -->
	  <!-- import a hCard2FoaF xslt and call that here? -->
	  <foaf:Person>
		<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')][1]">
			<foaf:name><xsl:call-template name="mf:extractText"/></foaf:name>
		</xsl:for-each>

		<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' url ')]">
			<!-- need absolute URL -->
			<xsl:variable name="reviewerUrl">
				<xsl:call-template name="mf:extractUrl">
					<xsl:with-param name="Source"><xsl:value-of select="$Source"/></xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<foaf:homepage rdf:resource="{$reviewerUrl}"/>
		</xsl:for-each>
	  </foaf:Person>
	</review:reviewer>
  </xsl:for-each>

  <!-- Review Tags (optional) :: multiple instances -->
  <!-- http://www.holygoat.co.uk/owl/redwood/0.1/tags/tags.n3 -->
  <!--
	<xsl:if test="descendant::*[contains(concat(' ', normalize-space(@rel), ' '),' tag ')]">
		<tag:taggedWithTag>
			<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@rel), ' '),' tag ')]">
				<tag:Tag>
					<tag:name><xsl:call-template name="mf:extractKeywords"/></tag:name>
				</tag:Tag>
			</xsl:for-each>
		</tag:taggedWithTag>
	</xsl:if>
  -->
	</review:Review>
</review:hasReview>

</xsl:template>

<!-- output Address information -->
<xsl:template name="adrCallBack">
	<xsl:param name="type"/>
	<xsl:param name="post-office-box"/>
	<xsl:param name="street-address"/>
	<xsl:param name="extended-address"/>
	<xsl:param name="locality"/>
	<xsl:param name="region"/>
	<xsl:param name="country-name"/>
	<xsl:param name="postal-code"/>

	<vcard:ADR rdf:parseType="Resource">
		<xsl:if test="$street-address != ''"><vcard:Street><xsl:value-of select="$street-address"/></vcard:Street></xsl:if>
		<xsl:if test="$region != ''"><vcard:Region><xsl:value-of select="$region"/></vcard:Region></xsl:if>
		<xsl:if test="$locality != ''"><vcard:Locality><xsl:value-of select="$locality"/></vcard:Locality></xsl:if>
		<xsl:if test="$extended-address != ''"><vcard:Ext><xsl:value-of select="$extended-address"/></vcard:Ext></xsl:if>
		<xsl:if test="$country-name != ''"><vcard:Country><xsl:value-of select="$country-name"/></vcard:Country></xsl:if>
		<xsl:if test="$postal-code != ''"><vcard:Pcode><xsl:value-of select="$postal-code"/></vcard:Pcode></xsl:if>
	</vcard:ADR>		
</xsl:template>

<!-- output geo data -->
<xsl:template name="geoCallBack">
	<xsl:param name="latitude"/>
	<xsl:param name="longitude"/>
	
	<geo:long><xsl:value-of select="$longitude"/></geo:long>
	<geo:lat><xsl:value-of select="$latitude"/></geo:lat>
</xsl:template>

<!-- unused templates, but without these XSLT 2.0 throws errors -->
<xsl:template name="nCallBack">
	<xsl:param name="family-name"/>
	<xsl:param name="given-name"/>
	<xsl:param name="additional-name"/>
	<xsl:param name="honorific-prefix"/>
	<xsl:param name="honorific-suffix"/>

</xsl:template>

<xsl:template name="orgCallBack">
	<xsl:param name="organization-name"/>
	<xsl:param name="organization-unit"/>
	
</xsl:template>

<xsl:template name="uidCallBack">
	<xsl:param name="type"/>
	<xsl:param name="value"/>
	
</xsl:template>

<!-- don't pass text thru -->
<xsl:template match="text()"></xsl:template>

</xsl:stylesheet>