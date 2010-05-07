<?xml version="1.0" encoding="UTF-8"?>
<stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:h="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:og="http://opengraphprotocol.org/schema/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:vcard="http://www.w3.org/2006/vcard/ns#" xmlns:sioc="http://rdfs.org/sioc/ns#" xmlns:biblio="http://purl.org/ontology/bibo/" xmlns:good="http://purl.org/goodrelations/v1#">


<!-- Open Graph Protocol GRDDL Transformation Version 0.1 by Fabien.Gandon@inria.fr, http://fabien.info -->
<!-- distributed at http://ns.inria.fr/grddl/ogp/ -->
<!-- This software is distributed under either the CeCILL-C license or the GNU Lesser General Public License version 3 license. -->
<!-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License -->
<!-- as published by the Free Software Foundation version 3 of the License or under the terms of the CeCILL-C license. -->
<!-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied -->
<!-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. -->
<!-- See the GNU Lesser General Public License version 3 at http://www.gnu.org/licenses/  -->
<!-- and the CeCILL-C license at http://www.cecill.info/licences/Licence_CeCILL-C_V1-en.html for more details -->


<output indent="yes" method="xml" media-type="application/rdf+xml" encoding="UTF-8" omit-xml-declaration="yes"/>

<!-- base of the current HTML doc -->
<variable name="html_base_no_ns" select="//*/head/base[position()=1]/@href"/>
<variable name="html_base_ns" select="//*/h:head/h:base[position()=1]/@href"/>

<!-- default HTML vocabulary namespace -->
<variable name="default_voc" select="'http://www.w3.org/1999/xhtml/vocab#'"/>

<!-- default Open Graph Protocol vocabulary namespace -->
<variable name="ogpns" select="'http://opengraphprotocol.org/schema/'"/>

<!-- url of the current XHTML page if provided by the XSLT engine -->
<param name="url" select="''"/>

<!-- this contains the URL of the source document whether it was provided by the base or as a parameter e.g. http://example.org/bla/file.html-->
<variable name="this">
	<choose>
		<when test="string-length($html_base_ns)&gt;0"><value-of select="$html_base_ns"/></when>
		<when test="string-length($html_base_no_ns)&gt;0"><value-of select="$html_base_no_ns"/></when>
		<otherwise><value-of select="$url"/></otherwise>
	</choose>
</variable>

<!-- this_location contains the location the source document e.g. http://example.org/bla/ -->
<variable name="this_location">
	<call-template name="get-location"><with-param name="url" select="$this"/></call-template>
</variable>

<!-- this_root contains the root location of the source document e.g. http://example.org/ -->
<variable name="this_root">
	<call-template name="get-root"><with-param name="url" select="$this"/></call-template>
</variable>


<!-- templates for parsing - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

<!--Start the RDF generation-->
<template match="/">
<rdf:RDF xml:base="http://opengraphprotocol.org/schema/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:og="http://opengraphprotocol.org/schema/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:vcard="http://www.w3.org/2006/vcard/ns#" xmlns:sioc="http://rdfs.org/sioc/ns#" xmlns:biblio="http://purl.org/ontology/bibo/" xmlns:good="http://purl.org/goodrelations/v1#">
  <apply-templates mode="ogp2rdfxml"/>  <!-- the mode is used to ease integration with other XSLT templates -->
</rdf:RDF>
</template>



<!-- select a candidate element having meta children -->
<template match="*[child::meta/attribute::property] | *[child::h:meta/attribute::property]" mode="ogp2rdfxml">

   <!-- generate a URI for the object -->
   <variable name="object-uri"><value-of select="concat($this,'#object',generate-id(.))"/></variable>

   <!-- generate a URI for the address -->
   <variable name="address-uri"><value-of select="concat($this,'#address',generate-id(.))"/></variable>

   <!-- iterate on the meta children -->
   <for-each select="child::meta | child::h:meta">

	   <!-- expand predicate -->
	   <variable name="expended-predicate"><call-template name="expand-ns"><with-param name="qname" select="@property"/></call-template></variable>
	   
	   <!-- check we have are in the Open Graph namespace -->
	   <if test="starts-with($expended-predicate,$ogpns)">

		   <!-- predicate name -->
		   <variable name="predicate" select="substring-after($expended-predicate,$ogpns)"/>

		   <!-- content -->
		   <variable name="content" select="@content"/>

           <!-- documenting -->
           <xsl:comment>Processing metadata property="<value-of select="$predicate"/>" content="<value-of select="$content"/>"</xsl:comment>
           
	  		<choose>
	  		    <!-- mapping title -->
	  			<when test="$predicate='title'">
		  			<rdf:Description rdf:about="{$object-uri}">
		  			  <rdfs:label><value-of select="$content"/></rdfs:label>
		  			  <dc:title><value-of select="$content"/></dc:title>
		  			</rdf:Description>
		  			<rdf:Description rdf:about="{$this}">
		  			  <og:title><value-of select="$content"/></og:title>
		  			</rdf:Description>
	  			</when>
	  		    <!-- mapping description  -->
	  			<when test="$predicate='description'">
		  			<rdf:Description rdf:about="{$object-uri}">
		  			  <rdfs:comment><value-of select="$content"/></rdfs:comment>
		  			  <dc:description><value-of select="$content"/></dc:description>
		  			</rdf:Description>
		  			<rdf:Description rdf:about="{$this}">
		  			  <og:description><value-of select="$content"/></og:description>
		  			</rdf:Description>
	  			</when>
	  		    <!-- mapping latitude  -->
	  			<when test="$predicate='latitude'">
		  			<rdf:Description rdf:about="{$object-uri}">
		  			  <geo:lat><value-of select="$content"/></geo:lat>
		  			</rdf:Description>
		  			<rdf:Description rdf:about="{$this}">
		  			  <og:latitude><value-of select="$content"/></og:latitude>
		  			</rdf:Description>
	  			</when>
	  		    <!-- mapping longitude  -->
	  			<when test="$predicate='longitude'">
		  			<rdf:Description rdf:about="{$object-uri}">
		  			  <geo:long><value-of select="$content"/></geo:long>
		  			</rdf:Description>
		  			<rdf:Description rdf:about="{$this}">
		  			  <og:longitude><value-of select="$content"/></og:longitude>
		  			</rdf:Description>
	  			</when>
	  		    <!-- mapping image -->
	  			<when test="$predicate='image'">
		  			<rdf:Description rdf:about="{$object-uri}">
		  			  <foaf:depiction rdf:resource="{$content}"/>
		  			</rdf:Description>
		  			<rdf:Description rdf:about="{$this}">
		  			  <og:image><value-of select="$content"/></og:image>
		  			</rdf:Description>
	  			</when>
	  			<!-- mapping url -->
	  			<when test="$predicate='url'">
		  			<rdf:Description rdf:about="{$object-uri}">
		  			  <foaf:homepage rdf:resource="{$content}"/>
		  			  <rdf:seeAlso rdf:resource="{$content}"/>
		  			</rdf:Description>
					<sioc:Document rdf:about="{$content}">
						<sioc:about rdf:resource="{$object-uri}"/>
					</sioc:Document>
					<rdf:Description rdf:about="{$this}">
		  			  <og:url><value-of select="$content"/></og:url>
		  			</rdf:Description>
	  			</when>
	  			<when test="$predicate='type'">
	  			    <variable name="type-uri" select="concat($ogpns, translate(substring(normalize-space($content),1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), translate(substring(normalize-space($content),2),'ABCDEFGHIJKLMNOPQRSTUVWXYZ ','abcdefghijklmnopqrstuvwxyz_'))"/>
		  			<rdf:Description rdf:about="{$object-uri}">
		  			  <rdf:type rdf:resource="{$type-uri}"/>
		  			</rdf:Description>
		  			<rdf:Description rdf:about="{$this}">
		  			  <og:type><value-of select="$content"/></og:type>
		  			</rdf:Description>
	  			</when>
	  			<when test="$predicate='site_name'">
		  			<sioc:Site rdf:about="{$this_root}">
		  				<rdfs:label><value-of select="$content"/></rdfs:label>
		  			  	<dc:title><value-of select="$content"/></dc:title>
		  			    <sioc:space_of>
		  			      <sioc:Container>
		  			         <sioc:container_of>
		  			           <sioc:Document rdf:about="{$this}">
		  			             <sioc:about rdf:resource="{$object-uri}"/>
		  			           </sioc:Document>
		  			         </sioc:container_of> 
		  			      </sioc:Container>
		  			    </sioc:space_of>		  			  
		  			</sioc:Site>
		  			<rdf:Description rdf:about="{$this}">
		  			  <og:site_name><value-of select="$content"/></og:site_name>
		  			</rdf:Description>
	  			</when>
	  			<!-- mapping street-address -->
	  			<when test="$predicate='street-address'">
		  			<vcard:VCard rdf:about="{$object-uri}">
		  			  <vcard:adr>
		  			    <vcard:Address rdf:about="{$address-uri}">
		  			      <vcard:street-address><value-of select="$content"/></vcard:street-address>
		  			    </vcard:Address>
		  			  </vcard:adr>
		  			</vcard:VCard>
		  			<rdf:Description rdf:about="{$this}">
		  			  <og:street-address><value-of select="$content"/></og:street-address>
		  			</rdf:Description>
	  			</when>
	  			<!-- mapping locality -->
	  			<when test="$predicate='locality'">
		  			<vcard:VCard rdf:about="{$object-uri}">
		  			  <vcard:adr>
		  			    <vcard:Address rdf:about="{$address-uri}">
		  			      <vcard:locality><value-of select="$content"/></vcard:locality>
		  			    </vcard:Address>
		  			  </vcard:adr>
		  			</vcard:VCard>
		  			<rdf:Description rdf:about="{$this}">
		  			  <og:locality><value-of select="$content"/></og:locality>
		  			</rdf:Description>
	  			</when>
	  			<!-- mapping region -->
	  			<when test="$predicate='region'">
		  			<vcard:VCard rdf:about="{$object-uri}">
		  			  <vcard:adr>
		  			    <vcard:Address rdf:about="{$address-uri}">
		  			      <vcard:region><value-of select="$content"/></vcard:region>
		  			    </vcard:Address>
		  			  </vcard:adr>
		  			</vcard:VCard>
		  			<rdf:Description rdf:about="{$this}">
		  			  <og:region><value-of select="$content"/></og:region>
		  			</rdf:Description>
	  			</when>
	  			<!-- mapping postal-code -->
	  			<when test="$predicate='postal-code'">
		  			<vcard:VCard rdf:about="{$object-uri}">
		  			  <vcard:adr>
		  			    <vcard:Address rdf:about="{$address-uri}">
		  			      <vcard:postal-code><value-of select="$content"/></vcard:postal-code>
		  			    </vcard:Address>
		  			  </vcard:adr>
		  			</vcard:VCard>
		  			<rdf:Description rdf:about="{$this}">
		  			  <og:postal-code><value-of select="$content"/></og:postal-code>
		  			</rdf:Description>
	  			</when>	  			
	  			<!-- mapping country-name -->
	  			<when test="$predicate='country-name'">
		  			<vcard:VCard rdf:about="{$object-uri}">
		  			  <vcard:adr>
		  			    <vcard:Address rdf:about="{$address-uri}">
		  			      <vcard:country-name><value-of select="$content"/></vcard:country-name>
		  			    </vcard:Address>
		  			  </vcard:adr>
		  			</vcard:VCard>
		  			<rdf:Description rdf:about="{$this}">
		  			  <og:country-name><value-of select="$content"/></og:country-name>
		  			</rdf:Description>
	  			</when>
	  			<!-- mapping email -->
	  			<when test="$predicate='email'">
		  			<rdf:Description rdf:about="{$object-uri}">
		  			  <foaf:mbox rdf:resource="{concat('mailto:',$content)}"/>
		  			  <vcard:email><value-of select="$content"/></vcard:email>
		  			</rdf:Description>
		  			<rdf:Description rdf:about="{$this}">
		  			  <og:email><value-of select="$content"/></og:email>
		  			</rdf:Description>
	  			</when>
	  			<!-- mapping phone_number -->
	  			<when test="$predicate='phone_number'">
		  			<rdf:Description rdf:about="{$object-uri}">
		  			  	<vcard:tel><value-of select="$content"/></vcard:tel>
		  			  	<foaf:phone><value-of select="$content"/></foaf:phone>
		  			</rdf:Description>
		  			<rdf:Description rdf:about="{$this}">
		  			  <og:phone_number><value-of select="$content"/></og:phone_number>
		  			</rdf:Description>
	  			</when>
	  			<!-- mapping fax_number -->
	  			<when test="$predicate='fax_number'">
		  			<rdf:Description rdf:about="{$object-uri}">
		  			  	<vcard:tel><value-of select="$content"/></vcard:tel>
		  			  	<foaf:phone><value-of select="$content"/></foaf:phone>
		  			</rdf:Description>
		  			<rdf:Description rdf:about="{$this}">
		  			  <og:fax_number><value-of select="$content"/></og:fax_number>
		  			</rdf:Description>
	  			</when>
	  			<!-- mapping Universal Product Code -->
	  			<when test="$predicate='upc'">
		  			<rdf:Description rdf:about="{$object-uri}">
		  			  <good:hasEAN_UCC-13><value-of select="concat('0',$content)"/></good:hasEAN_UCC-13>
		  			</rdf:Description>
		  			<rdf:Description rdf:about="{$this}">
		  			  <og:upc><value-of select="$content"/></og:upc>
		  			</rdf:Description>
	  			</when>
	  			<!-- mapping ISBN  -->
	  			<when test="$predicate='isbn'">
		  			<rdf:Description rdf:about="{$object-uri}">
		  			  <biblio:isbn><value-of select="$content"/></biblio:isbn>
		  			</rdf:Description>
		  			<rdf:Description rdf:about="{$this}">
		  			  <og:isbn><value-of select="$content"/></og:isbn>
		  			</rdf:Description>
	  			</when>
			    <otherwise> <!-- generate a comment for debug -->
			       <xsl:comment>Could not produce the triple predicate: <value-of select="$predicate"/></xsl:comment>
			    </otherwise>
	  		</choose> 
     </if>
   </for-each>
   
   <apply-templates mode="ogp2rdfxml"/> 
   
</template>


<!-- ignore the rest of the DOM -->
<template match="text()|@*|*" mode="ogp2rdfxml"><apply-templates mode="ogp2rdfxml"/></template>


<!-- named templates to process URIs and token lists - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <!-- get file location from URL -->
  <template name="get-location">
    <param name="url"/>
  	<if test="string-length($url)&gt;0 and contains($url,'/')">
  		<value-of select="concat(substring-before($url,'/'),'/')"/>
  		<call-template name="get-location"><with-param name="url" select="substring-after($url,'/')"/></call-template>
  	</if>
  </template>

  <!-- get root location from URL -->
  <template name="get-root">
    <param name="url"/>
	<choose>
		<when test="contains($url,'//')">
			<value-of select="concat(substring-before($url,'//'),'//',substring-before(substring-after($url,'//'),'/'),'/')"/>
		</when>
		<otherwise>UNKNOWN ROOT</otherwise>
	</choose>    
  </template>

  <!-- return namespace of a qname -->
  <template name="return-ns">
    <param name="qname"/>
    <variable name="ns_prefix" select="substring-before($qname,':')"/>
    <if test="string-length($ns_prefix)&gt;0"> <!-- prefix must be explicit -->
      <variable name="name" select="substring-after($qname,':')"/>
      <value-of select="ancestor-or-self::*/namespace::*[name()=$ns_prefix][position()=1]"/>
    </if>
    <if test="string-length($ns_prefix)=0 and ancestor-or-self::*/namespace::*[name()=''][position()=1]"> <!-- no prefix -->
		<variable name="name" select="substring-after($qname,':')"/>
		<value-of select="ancestor-or-self::*/namespace::*[name()=''][position()=1]"/>
    </if>
  </template>


  <!-- expand namespace of a qname -->
  <template name="expand-ns">
    <param name="qname"/>
    <variable name="ns_prefix" select="substring-before($qname,':')"/>
    <if test="string-length($ns_prefix)&gt;0"> <!-- prefix must be explicit -->
		<variable name="name" select="substring-after($qname,':')"/>
		<variable name="ns_uri" select="ancestor-or-self::*/namespace::*[name()=$ns_prefix][position()=1]"/>
		<value-of select="concat($ns_uri,$name)"/>
    </if>
    <if test="string-length($ns_prefix)=0 and ancestor-or-self::*/namespace::*[name()=''][position()=1]"> <!-- no prefix -->
		<variable name="name" select="substring-after($qname,':')"/>
		<variable name="ns_uri" select="ancestor-or-self::*/namespace::*[name()=''][position()=1]"/>
		<value-of select="concat($ns_uri,$name)"/>
    </if>
  </template>

</stylesheet>