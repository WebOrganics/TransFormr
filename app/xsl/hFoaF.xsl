<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns="http://xmlns.com/foaf/0.1/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:xfn="http://gmpg.org/xfn/11#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	exclude-result-prefixes="xhtml"
    version="1.0">

<!-- 
$Id: hFoaf.xsl,$Version 0.6 *stable* Wednesday June 9th 2010 00:47am  $author: martin McEvoy.
$Description An attempt at enabling Social Network Portability using hCard and XFN a GRDDL profile Inspired by dan connolly's grokXFN.xsl. http://www.w3.org/2003/12/rdf-in-xhtml-xslts/grokXFN.xsl 
-->

<xsl:output method="xml" 
		   indent="yes" 
		   encoding="UTF-8" 
		   media-type="application/rdf+xml"/>

<!-- find first occurrence of a hcard with rel="me" there should only be one-->
<xsl:param name="vcard" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' vcard ') and descendant::*[contains(concat(' ',normalize-space(@rel),' '),' me ')]] | descendant::*[contains(concat(' ',normalize-space(@class),' '),' vcard ') and descendant::*[contains(concat(' ',normalize-space(@class),' '),' uid ')]]"/>

<xsl:param name="rel-me" select="descendant::*[contains(concat(' ',normalize-space(@rel),' '),' me ')]"/>

<xsl:param name="url-rel-me" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' url ') and contains(concat(' ',normalize-space(@rel),' '),' me ')]"/>

<xsl:param name="title" select="descendant::*[name() = 'title']"/>

<xsl:param name="base-uri" select="''"/>

<!-- Get id from hcard else me  -->
<xsl:param name="id">
<xsl:choose>
	<xsl:when test="$vcard/@id" >
	  <xsl:value-of select="$vcard/@id" />
	</xsl:when>
	<xsl:otherwise>
		<xsl:text>me</xsl:text>
	</xsl:otherwise>
</xsl:choose>
</xsl:param>

<!-- Limit output to first vcard  -->
<xsl:param name="pos">1</xsl:param>

<xsl:template match="/">
<xsl:param name="about"/>
<rdf:RDF>
<xsl:choose>
    <xsl:when test="$vcard">
	<xsl:for-each select="$vcard[position() &lt;= $pos]">
		<PersonalProfileDocument rdf:about="{$about}">
			<xsl:if test="$title">
				<dc:title><xsl:value-of select="$title"/></dc:title>
			</xsl:if>
			<maker rdf:nodeID="{$id}"/>
    		<primaryTopic rdf:nodeID="{$id}"/>
		</PersonalProfileDocument>
 	 	<xsl:element name='Person'>
			<xsl:attribute name="rdf:nodeID">
	  			<xsl:value-of select="$id" />
			</xsl:attribute>
			<xsl:call-template name="name"/>
			<xsl:call-template name="firstName"/>
			<xsl:call-template name="familyName"/>
			<xsl:call-template name="nickName"/>
			<xsl:call-template name="homepage"/>
			<xsl:call-template name="mailbox"/>
			<xsl:call-template name="sha1"/>
			<xsl:call-template name="photo"/>
			<xsl:call-template name="interests"/>
			<xsl:call-template name="geo"/>
			<xsl:call-template name="social"/>
			<xsl:call-template name="friends"/>
			<xsl:call-template name="knows"/>
  		</xsl:element>
  	</xsl:for-each>
    </xsl:when>
    <!-- error or no hcard with rel="me" found stop processing -->
    <xsl:otherwise>
		<xsl:text>Oops! something goes wrong :( maybe no single hcard found with rel-me or invalid XHTML/HTML</xsl:text>
    </xsl:otherwise>
</xsl:choose>
</rdf:RDF>
</xsl:template>


<!-- ==============================================Temaplates===============================================-->

<!-- Name =>  class="fn" -->
<xsl:template name="name">
<xsl:param name="fn" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')]"/>
	<xsl:if test="$fn">
		<xsl:element name='name'>
			<xsl:value-of select="$fn"/>
		</xsl:element>
	</xsl:if>
</xsl:template>


<!-- givenname => @class="given-name" -->
<xsl:template name="firstName">
<xsl:param name="firstname" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' given-name ')]"/>
	<xsl:if test="$firstname">
		<xsl:element name='givenname'>
			<xsl:value-of select="$firstname"/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- family_name => @class="family-name" -->
<xsl:template name="familyName">
<xsl:param name="surname" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' family-name ')]"/>
	<xsl:if test="$surname">
		<xsl:element name='family_name'>
			<xsl:value-of select="$surname"/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- nic => @class="nickname" -->
<xsl:template name="nickName">
<xsl:param name="nickname" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' nickname ')]"/>
	<xsl:if test="$nickname">
		<xsl:element name='nick'>
			<xsl:value-of select="$nickname"/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- homepage => @class="url" and @rel="me" -->
<xsl:template name="homepage">
	<xsl:if test="$url-rel-me">
		<xsl:element name='homepage'>
			<xsl:attribute name='rdf:resource'>
	  			<xsl:value-of select="$url-rel-me/@href"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!-- mbox => class="email"/@href  -->
<xsl:template name="mailbox">
<xsl:param name="email" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' email ')]"/>
	<xsl:if test="$email">
		<xsl:element name='mbox'>
			<xsl:attribute name='rdf:resource'>
				<xsl:value-of select="$email/@href"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:if>
</xsl:template>

<!--  mbox_sha1sum => class="email"/ sha1:email @id -->
<xsl:template name="sha1">
<xsl:param name="uid" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' email ')]"/>
	<xsl:if test="$uid">
	<xsl:for-each select="$uid">
		<xsl:if test="substring-after(normalize-space(@id),'sha1:')">
			<xsl:element name='mbox_sha1sum'>
				<xsl:value-of select="substring-after(normalize-space(@id),'sha1:')"/>
			</xsl:element>
		</xsl:if>
	</xsl:for-each>
	</xsl:if>
</xsl:template>

<!-- depiction =>  @class="photo"  -->
<xsl:template name="photo">
<xsl:param name="image" select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' photo ')]"/>
 <xsl:if test="$image">
		<xsl:choose>
			<xsl:when test="substring-before($image/@src,':') = 'http'" >
			<xsl:element name='img'>
  				<xsl:attribute name='rdf:resource'>
	 	 			<xsl:value-of select="$image/@src" />
				</xsl:attribute>
			</xsl:element>
			</xsl:when>
			<xsl:otherwise>
			<xsl:element name='img'>
  				<xsl:attribute name='rdf:resource'>
	  				<xsl:value-of select="$base-uri"/>
	 	 			<xsl:value-of select="$image/@src" />
				</xsl:attribute>
			</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
  </xsl:if>
</xsl:template>

<!-- interests @rel tag. thank you @Sarven -->
<xsl:template name="interests">
<xsl:param name="tag" select="descendant::*[contains(concat(' ',normalize-space(@rel),' '),' tag ')]"/>
<xsl:if test="$tag">
	<xsl:for-each select="$tag">
		<xsl:element name='interest'>
			<xsl:attribute name='rdf:resource'>
				<xsl:value-of select="@href"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:for-each>
</xsl:if>
</xsl:template>

<!-- geo:Point =>  @class="geo"  geo:lat @class="latitude"/@title  geo:long @class="longitude"/@title -->
<xsl:template name="geo">
<xsl:param name="location" select="//*[contains(concat(' ',normalize-space(@class),' '),' geo ')]"/>
<xsl:param name="long" select="//*[contains(concat(' ',normalize-space(@class),' '),' longitude ')]"/>
<xsl:param name="lat" select="//*[contains(concat(' ',normalize-space(@class),' '),' latitude ')]"/>
	<xsl:if test="$location">
	<xsl:for-each select="$location[position() &lt;= $pos]">
  		<xsl:element name='based_near'>
  		<xsl:element name='geo:Point'>
			<rdf:type rdf:resource="http://www.w3.org/2000/10/swap/pim/contact#ContactLocation"/>
		<xsl:choose>
		<xsl:when test="$location/@title">
			<xsl:element name='geo:lat_long'>
				<xsl:value-of select="$location/@title"/>
			</xsl:element>
		</xsl:when>
		<xsl:otherwise>
			<xsl:element name='geo:lat'>
				<xsl:choose>
					<xsl:when test="$lat/@title" >
						<xsl:value-of select="$lat/@title" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$lat" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		 	<xsl:element name='geo:long'>
				<xsl:choose>
					<xsl:when test="$long/@title" >
						<xsl:value-of select="$long/@title" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$long" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:otherwise>
		</xsl:choose>
		</xsl:element>
		</xsl:element>
	</xsl:for-each>
	</xsl:if>
</xsl:template>

<!-- Build XFN Friend Links see: http://gmpg.org/xfn/11-->
<xsl:template name="friends">
<xsl:call-template name="rel-Links">
	<xsl:with-param name="rel" select='"contact"'/>
</xsl:call-template>
<xsl:call-template name="rel-Links">
	<xsl:with-param name="rel" select='"acquaintance"'/>
</xsl:call-template>
<xsl:call-template name="rel-Links">
	<xsl:with-param name="rel" select='"friend"'/>
</xsl:call-template>
<xsl:call-template name="rel-Links">
	<xsl:with-param name="rel" select='"met"'/>
</xsl:call-template>
<xsl:call-template name="rel-Links">
	<xsl:with-param name="rel" select='"colleague"'/>
</xsl:call-template>
<xsl:call-template name="rel-Links">
	<xsl:with-param name="rel" select='"co-worker"'/>
</xsl:call-template>
<xsl:call-template name="rel-Links">
	<xsl:with-param name="rel" select='"co-resident"'/>
</xsl:call-template>
<xsl:call-template name="rel-Links">
	<xsl:with-param name="rel" select='"neighbor"'/>
</xsl:call-template>
<xsl:call-template name="rel-Links">
	<xsl:with-param name="rel" select='"child"'/>
</xsl:call-template>
<xsl:call-template name="rel-Links">
	<xsl:with-param name="rel" select='"parent"'/>
</xsl:call-template>
<xsl:call-template name="rel-Links">
	<xsl:with-param name="rel" select='"sibling"'/>
</xsl:call-template>
<xsl:call-template name="rel-Links">
	<xsl:with-param name="rel" select='"spouse"'/>
</xsl:call-template>
<xsl:call-template name="rel-Links">
	<xsl:with-param name="rel" select='"kin"'/>
</xsl:call-template>
<xsl:call-template name="rel-Links">
	<xsl:with-param name="rel" select='"muse"'/>
</xsl:call-template>
<xsl:call-template name="rel-Links">
	<xsl:with-param name="rel" select='"crush"'/>
</xsl:call-template>
<xsl:call-template name="rel-Links">
	<xsl:with-param name="rel" select='"date"'/>
</xsl:call-template>
<xsl:call-template name="rel-Links">
	<xsl:with-param name="rel" select='"sweetheart"'/>
</xsl:call-template>
</xsl:template>


<xsl:template name="rel-Links">
<xsl:param name="rel"/>
  <xsl:for-each select="/*//*[contains(concat(' ', @rel, ' '), concat(' ', $rel, ' '))]">
  	<xsl:element name='xfn:{$rel}'>
		<xsl:attribute name="rdf:nodeID"><xsl:value-of select="generate-id()"/></xsl:attribute>
  	</xsl:element>
  </xsl:for-each>
</xsl:template>


<!-- build social network links -->

<xsl:template name="social">
<xsl:param name="rel-me"/>
  <xsl:for-each select="/*//*[contains(concat(' ', @rel, ' '), concat(' ', 'me', ' '))][position() &lt;= $pos]">
  	<xsl:choose>
		<xsl:when test="substring-after(@href,'twitter.com')">
			<xsl:call-template name="has-account">
				<xsl:with-param name="accountpage" select='@href'/>
				<xsl:with-param name="servicepage">
					<xsl:text>twitter.com/</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="serviceurl">
					<xsl:text>http://twitter.com/</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="substring-after(@href,'flickr.com')">
			<xsl:call-template name="has-account">
				<xsl:with-param name="accountpage" select='@href'/>
				<xsl:with-param name="servicepage">
				<xsl:choose>
					<xsl:when test="substring-after(@href,'flickr.com/people/')">
						<xsl:text>flickr.com/people/</xsl:text>
					</xsl:when>
					<xsl:when test="substring-after(@href,'flickr.com/photos/')">
						<xsl:text>flickr.com/photos/</xsl:text>
					</xsl:when>
					<xsl:when test="substring-after(@href,'flickr.com/')">
						<xsl:text>flickr.com/</xsl:text>
					</xsl:when>
				</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="serviceurl">
					<xsl:text>http://flickr.com/</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="substring-after(@href,'digg.com')">
			<xsl:call-template name="has-account">
				<xsl:with-param name="accountpage" select='@href'/>
				<xsl:with-param name="servicepage">
					<xsl:text>digg.com/users/</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="serviceurl">
					<xsl:text>http://digg.com/</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="substring-after(@href,'www.last.fm')">
			<xsl:call-template name="has-account">
				<xsl:with-param name="accountpage" select='@href'/>
				<xsl:with-param name="servicepage">
					<xsl:text>last.fm/user/</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="serviceurl">
					<xsl:text>http://www.last.fm/</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="substring-after(@href,'delicious.com')">
			<xsl:call-template name="has-account">
				<xsl:with-param name="accountpage" select='@href'/>
				<xsl:with-param name="servicepage">
					<xsl:text>delicious.com/</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="serviceurl">
					<xsl:text>http://delicious.com/</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="substring-after(@href,'youtube.com')">
			<xsl:call-template name="has-account">
				<xsl:with-param name="accountpage" select='@href'/>
				<xsl:with-param name="servicepage">
					<xsl:text>youtube.com/user/</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="serviceurl">
					<xsl:text>http://youtube.com/</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="substring-after(@href,'twine.com')">
			<xsl:call-template name="has-account">
				<xsl:with-param name="accountpage" select='@href'/>
				<xsl:with-param name="servicepage">
					<xsl:text>twine.com/user/</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="serviceurl">
					<xsl:text>http://www.twine.com/</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="substring-after(@href,'identi.ca')">
			<xsl:call-template name="has-account">
				<xsl:with-param name="accountpage" select='@href'/>
				<xsl:with-param name="servicepage">
					<xsl:text>identi.ca/</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="serviceurl">
					<xsl:text>http://identi.ca/</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		
		<xsl:when test="substring-after(@href,'foursquare.com')">
			<xsl:call-template name="has-account">
				<xsl:with-param name="accountpage" select='@href'/>
				<xsl:with-param name="servicepage">
					<xsl:text>foursquare.com/user/</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="serviceurl">
					<xsl:text>http://foursquare.com/</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		
		<xsl:when test="substring-after(@href,'google.com/profiles')">
			<xsl:call-template name="has-account">
				<xsl:with-param name="accountpage" select='@href'/>
				<xsl:with-param name="servicepage">
					<xsl:text>google.com/profiles/</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="serviceurl">
					<xsl:text>http://www.google.com/profiles</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		
	</xsl:choose> 
  </xsl:for-each>
</xsl:template>

<xsl:template name="has-account">
  <xsl:param name="accountpage"/>
  <xsl:param name="servicepage"/>
  <xsl:param name="serviceurl"/>
  	<xsl:variable name="this" select="substring-after(@href, $servicepage)"/>
	<xsl:variable name="strip" select="substring-before($this,'/')"/>
  	<xsl:element name='holdsAccount'>
	<xsl:element name='OnlineAccount'>
			<xsl:element name='accountName'>
				 <xsl:choose>
					<xsl:when test="$strip">
						<xsl:value-of select="$strip"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$this"/>
					</xsl:otherwise>
				</xsl:choose> 
			</xsl:element>
			<xsl:element name='accountProfilePage'>
					<xsl:attribute name="rdf:resource"><xsl:value-of select='$accountpage'/></xsl:attribute>
		  	</xsl:element>
			<xsl:element name='accountServiceHomepage'>
					<xsl:attribute name="rdf:resource"><xsl:value-of select='$serviceurl'/></xsl:attribute>
		  	</xsl:element>
  	</xsl:element>
	</xsl:element>
</xsl:template>

<!-- XFN person template -->

<xsl:template name="knows">
  <xsl:for-each select="/*//*[contains(concat(' ', @rel, ' '), concat(' ', 'friend', ' '))]|/*//*[contains(concat(' ', @rel, ' '), concat(' ', 'colleague', ' '))]|/*//*[contains(concat(' ', @rel, ' '), concat(' ', 'acquaintance', ' '))]|/*//*[contains(concat(' ', @rel, ' '), concat(' ', 'co-worker', ' '))]|/*//*[contains(concat(' ', @rel, ' '), concat(' ', 'met', ' '))]|/*//*[contains(concat(' ', @rel, ' '), concat(' ', 'muse', ' '))]|/*//*[contains(concat(' ', @rel, ' '), concat(' ', 'contact', ' '))]">
  <xsl:element name='knows'>
	<xsl:element name='Person'>
    		<xsl:attribute name="rdf:nodeID"><xsl:value-of select="generate-id()"/></xsl:attribute>				
			<xsl:element name='name'>
	 	 		<xsl:choose>
					<xsl:when test="//img">
	  					<xsl:value-of select="//img/@alt" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name='weblog'>
				<xsl:attribute name="rdf:resource"><xsl:value-of select="@href"/></xsl:attribute>
			</xsl:element>
  	</xsl:element>
  </xsl:element>
  </xsl:for-each>
</xsl:template>

<!-- strip text -->
<xsl:template match="*|text()"></xsl:template>
</xsl:stylesheet>
