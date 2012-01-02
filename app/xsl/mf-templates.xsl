<xsl:transform
    xmlns:xsl  ="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:mf   ="http://suda.co.uk/projects/microformats/mf-templates.xsl?template="
 	xmlns:datetime ="http://suda.co.uk/projects/microformats/datetime.xsl?template="
 	xmlns:uri ="http://www.w3.org/2000/07/uri43/uri.xsl?template="
    xmlns:common="http://exslt.org/common"
    xmlns:html ="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="mf html"
	>

	<!--
		Copyright 2006 Brian Suda
		This work is licensed under The W3C Open Source License
		http://www.w3.org/Consortium/Legal/copyright-software-19980720
		
		VERSION: 0.2
	-->

	<xsl:import href="datetime.xsl" />
	<!-- i have saved the file locally to conserve bandwidth, always check for updates -->
	<xsl:import href="uri.xsl" />

	<xsl:variable name="ucase" select='"ABCDEFGHIJKLMNOPQRSTUVWXYZ"'/>
	<xsl:variable name="lcase" select='"abcdefghijklmnopqrstuvwxyz"'/>

	<!-- Extract N Property for Microformats -->
	<xsl:template name="mf:extractN">
		<xsl:element name="family-names">
			<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' family-name ')]">
				<xsl:element name="family-name">
					<xsl:call-template name="mf:extractText"/>
				</xsl:element>	
			</xsl:for-each>
		</xsl:element>
		<xsl:element name="given-names">
			<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' given-name ')]">
				<xsl:element name="given-name">
					<xsl:call-template name="mf:extractText"/>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
		
		<xsl:element name="additional-names">
			<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' additional-name ')]">
				<xsl:element name="additional-name">
					<xsl:call-template name="mf:extractText"/>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>

		<xsl:element name="honorific-prefixs">
			<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' honorific-prefix ')]">
				<xsl:element name="honorific-prefix">
					<xsl:call-template name="mf:extractText"/>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>

		<xsl:element name="honorific-suffixs">
			<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' honorific-suffix ')]">
				<xsl:element name="honorific-suffix">
					<xsl:call-template name="mf:extractText"/>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>

	</xsl:template>
	
	<xsl:template name="mf:extractOrg">
		<xsl:choose>
			<xsl:when test=".//*[contains(concat(' ', @class, ' '), concat(' ', 'organization-name', ' '))]" >
				<xsl:element name="organization-name">
					<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' organization-name ')]">
						<xsl:if test="position() = 1">
							<xsl:call-template name="mf:extractText"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:element>

				<xsl:element name="organization-units">
					<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' organization-unit ')]">
						<xsl:if test="position() != 1">
							<xsl:text>;</xsl:text>
						</xsl:if>
						<xsl:element name="organization-unit"><xsl:call-template name="mf:extractText"/></xsl:element>
					</xsl:for-each>
				</xsl:element>
				
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="organization-name"><xsl:call-template name="mf:extractText"/></xsl:element>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	
	<!-- Extract ADR Property for Microformats -->
	<xsl:template name="mf:extractAdr">
		<xsl:param name="type-list"/>
		<xsl:element name="type">
			<xsl:call-template name="mf:find-types">
				<xsl:with-param name="list"><xsl:value-of select="$type-list"/></xsl:with-param>
			</xsl:call-template>
		</xsl:element>
		
		<xsl:variable name="street-address">
			<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' street-address ')]">
				<xsl:if test="position() != 1">
					<xsl:text>,</xsl:text>
				</xsl:if>
				<xsl:call-template name="mf:extractText"/>
			</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="extended-address">
			<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' extended-address ')]">
				<xsl:if test="position() != 1">
					<xsl:text>,</xsl:text>
				</xsl:if>
				<xsl:call-template name="mf:extractText"/>
			</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="post-office-box">
			<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' post-office-box ')]">
				<xsl:if test="position() = 1">
					<xsl:call-template name="mf:extractText"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<xsl:element name="region">
			<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' region ')]">
				<xsl:if test="position() = 1">
					<xsl:call-template name="mf:extractText"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:element>

		<xsl:element name="locality">
			<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' locality ')]">
				<xsl:if test="position() = 1">
					<xsl:call-template name="mf:extractText"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:element>
		
		<xsl:element name="country-name">
			<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' country-name ')]">
				<xsl:if test="position() = 1">
					<xsl:call-template name="mf:extractText"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:element>		

		<xsl:element name="postal-code">
			<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' postal-code ')]">
				<xsl:if test="position() = 1">
					<xsl:call-template name="mf:extractText"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:element>		

		<!-- call display Function -->
		<xsl:element name="street-address"><xsl:value-of select="$street-address"/></xsl:element>
		<xsl:element name="extended-address"><xsl:value-of select="$extended-address"/></xsl:element>
		<xsl:element name="post-office-box"><xsl:value-of select="$post-office-box"/></xsl:element>
	</xsl:template>
	
	<!-- Extract GEO Property for Microformats -->
	<xsl:template name="mf:extractGeo">
		<xsl:choose>
			<xsl:when test="local-name(.) = 'abbr' and @title">
				<xsl:variable name="longitude" select="normalize-space(substring-after(@title,';'))" />
				<xsl:variable name="latitude" select="normalize-space(substring-before(@title,';'))" />
				<xsl:variable name="altitude" select="0" />
				
				<xsl:element name="latitude">
					<xsl:value-of select="$latitude"/>
				</xsl:element>
				<xsl:element name="longitude">
					<xsl:value-of select="$longitude"/>
				</xsl:element>
				<xsl:element name="altitude">
					<xsl:value-of select="$altitude"/>
				</xsl:element>				
			</xsl:when>
			<xsl:when test="local-name(.) = 'img' and @alt">
				<xsl:variable name="longitude" select="normalize-space(substring-after(@alt,';'))" />
				<xsl:variable name="latitude" select="normalize-space(substring-before(@alt,';'))" />
				<xsl:variable name="altitude" select="0" />
				<!-- call display Function -->
				<xsl:element name="latitude">
					<xsl:value-of select="$latitude"/>
				</xsl:element>
				<xsl:element name="longitude">
					<xsl:value-of select="$longitude"/>
				</xsl:element>
				<xsl:element name="altitude">
					<xsl:value-of select="$altitude"/>
				</xsl:element>				
			</xsl:when>
			<!-- look for child elements -->
			<xsl:otherwise>				
				<xsl:variable name="longitude">
					<xsl:choose>
						<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' longitude ')]">
							<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' longitude ')]">
								<xsl:call-template name="mf:extractText"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(substring-after(.,';'))"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="latitude">
					<xsl:choose>
						<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' latitude ')]">
							<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' latitude ')]">
								<xsl:call-template name="mf:extractText"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(substring-before(.,';'))"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>				

				<xsl:variable name="altitude" select="0" />
				
				<!-- call display Function -->
				<xsl:element name="latitude">
					<xsl:value-of select="$latitude"/>
				</xsl:element>
				<xsl:element name="longitude">
					<xsl:value-of select="$longitude"/>
				</xsl:element>
				<xsl:element name="altitude">
					<xsl:value-of select="$altitude"/>
				</xsl:element>				
				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- extract rel-Tags or text -->
	<xsl:template name="mf:extractKeywords">
		<xsl:choose>
			<xsl:when test="@rel and contains(concat(' ', normalize-space(@rel), ' '),' tag ')">
				<xsl:call-template name="mf:tagFromTagspace">
					<xsl:with-param name="text-string" select="@href" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="mf:extractText"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- extract an ISO date from a Microformat property -->
	<xsl:template name="mf:extractDate">
		<xsl:choose>			
			<!-- if the property is on an ABBR element check for @title -->
			<xsl:when test='local-name(.) = "abbr" and @title'>
				<xsl:call-template name="datetime:utc-time-converter">
					<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			
			<xsl:when test='@content'>
				<xsl:call-template name="datetime:utc-time-converter">
					<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@content)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			
			<!-- look on images -->
			<xsl:when test='@longdesc and local-name(.) = "img"'>
				<xsl:call-template name="datetime:utc-time-converter">
					<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test='@alt and (local-name(.) = "img" or local-name(.) = "area")'>
				<xsl:call-template name="datetime:utc-time-converter">
					<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			
			<!-- check for child attributes that might have value-title elements AFTER value -->
			<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value-title ')]">
				<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value-title ')]">
				<xsl:call-template name="datetime:utc-time-converter">
					<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@title)"/></xsl:with-param>
				</xsl:call-template>			
				</xsl:for-each>
			</xsl:when>
			
			<!-- should there be a look in for class="value"? -->
				
			<xsl:otherwise>
				<xsl:call-template name="datetime:utc-time-converter">
					<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	
	
	<!-- @@make this a proper MASKING function -->
	<xsl:template name="mf:extractDateMask">
		<xsl:variable name="unformatedDate">
			<xsl:call-template name="mf:extractDate"/>
		</xsl:variable>
		
		<!-- year -->
		<xsl:value-of select="substring($unformatedDate,1,4)"/>
		<xsl:text>-</xsl:text>
		<!-- month -->
		<xsl:value-of select="substring($unformatedDate,5,2)"/>
		<xsl:text>-</xsl:text>
		<!-- day -->
		<xsl:value-of select="substring($unformatedDate,7,2)"/>
		
		<xsl:choose>
			<xsl:when test="substring($unformatedDate,10,1) = 'T'">
				<xsl:text>T</xsl:text>			
				<!-- hours -->
				<xsl:value-of select="substring($unformatedDate,11,2)"/>
				<xsl:text>:</xsl:text>
				<!-- minutes -->
				<xsl:value-of select="substring($unformatedDate,13,2)"/>
				<xsl:text>:</xsl:text>
				<!-- seconds -->
				<xsl:value-of select="substring($unformatedDate,15,2)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>T00:00:00</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>Z</xsl:text>
				
	</xsl:template>

	<!-- extract an ISO date from a Microformat property -->
	<xsl:template name="mf:extractMultipleDate">
		<xsl:choose>
			<xsl:when test='local-name(.) = "abbr" and @title'>
				<xsl:call-template name="datetime:rdate-comma-utc">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test='@longdesc and local-name(.) = "img"'>
				<xsl:call-template name="datetime:rdate-comma-utc">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test='@alt and (local-name(.) = "img" or local-name(.) = "area")'>
				<xsl:call-template name="datetime:rdate-comma-utc">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			
			<xsl:otherwise>
				<xsl:call-template name="datetime:rdate-comma-utc">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="mf:extractEmail">
		<!-- on hold -->
	</xsl:template>

	<xsl:template name="mf:extractUrl">
		<xsl:param name="Source"/>
		<xsl:choose>
			<xsl:when test="@href and (local-name(.) = 'a' or local-name(.) = 'area')">
				<xsl:choose>
					<xsl:when test="substring-before(@href,':') = 'http'">
						<xsl:value-of select="normalize-space(@href)" />
					</xsl:when>
					<xsl:otherwise>
						<!-- convert to absolute url -->
						<xsl:call-template name="uri:expand">
							<xsl:with-param name="base">
								<xsl:call-template name="mf:baseURL">
									<xsl:with-param name="Source"><xsl:value-of select="$Source" /></xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="there"><xsl:value-of select="@href"/></xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@src and local-name(.) = 'img'">
				<xsl:choose>
					<xsl:when test="substring-before(@src,':') = 'http'">
						<xsl:value-of select="normalize-space(@src)" />
					</xsl:when>
					<xsl:otherwise>
						<!-- convert to absolute url -->
						<xsl:call-template name="uri:expand">
							<xsl:with-param name="base">
								<xsl:call-template name="mf:baseURL">
									<xsl:with-param name="Source"><xsl:value-of select="$Source" /></xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="there"><xsl:value-of select="@src"/></xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@data and local-name(.) = 'object'">
				<xsl:choose>
					<xsl:when test="substring-before(@data,':') = 'http'">
						<xsl:value-of select="normalize-space(@data)" />
					</xsl:when>
					<xsl:otherwise>
						<!-- convert to absolute url -->
						<xsl:call-template name="uri:expand">
							<xsl:with-param name="base">
								<xsl:call-template name="mf:baseURL">
									<xsl:with-param name="Source"><xsl:value-of select="$Source" /></xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="there"><xsl:value-of select="@data"/></xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test='local-name(.) = "abbr" and @title'>
				<xsl:value-of select="normalize-space(@title)"/>
			</xsl:when>			
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="mf:extractBlob">
		<!-- @@ -->
	</xsl:template>

	<!-- this might need some work is a protocol also has a value as a child? -->
	<xsl:template name="mf:extractFromProtocol">
		<xsl:param name="protocolList"/>

		<xsl:choose>
			<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]/@href">
				<xsl:if test="
					contains(
					concat(' ', substring-before(.//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]/@href,':'), ' '),
					concat(' ',
					normalize-space($protocolList),
					' '))
					">
					<xsl:choose>
						<xsl:when test="string-length(normalize-space(substring-before(substring-after(.//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]/@href,':'),'?'))) &lt; 1">
							<xsl:value-of select="normalize-space(substring-after(.//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]/@href,':'))" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(substring-before(substring-after(.//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]/@href,':'),'?'))" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>				
			</xsl:when>
			<xsl:when test="
				contains(
				concat(' ', normalize-space($protocolList),' '),
				concat(' ',
				substring-before(@href,':'), 
				' '))">
				<xsl:choose>
					<xsl:when test="string-length(normalize-space(substring-before(substring-after(@href,':'),'?'))) &lt; 1">
						<xsl:value-of select="normalize-space(substring-after(@href,':'))" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space(substring-before(substring-after(@href,':'),'?'))" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]/@data">
				<xsl:if test="
					contains(
					concat(' ', substring-before(.//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]/@data,':'), ' '),
					concat(' ',
					normalize-space($protocolList),
					' '))
					">
					<xsl:choose>
						<xsl:when test="string-length(normalize-space(substring-before(substring-after(.//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]/@data,':'),'?'))) &lt; 1">
							<xsl:value-of select="normalize-space(substring-after(.//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]/@data,':'))" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(substring-before(substring-after(.//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]/@data,':'),'?'))" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>				
			</xsl:when>
			<xsl:when test="
				contains(
				concat(' ', normalize-space($protocolList),' '),
				concat(' ',
				substring-before(@data,':'), 
				' '))">
				<xsl:choose>
					<xsl:when test="string-length(normalize-space(substring-before(substring-after(@data,':'),'?'))) &lt; 1">
						<xsl:value-of select="normalize-space(substring-after(@data,':'))" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space(substring-before(substring-after(@data,':'),'?'))" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>			
			<xsl:otherwise>
				<xsl:call-template name="mf:extractText"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="mf:extractUid">
		<xsl:param name="type-list"/>
		<xsl:param name="protocol"/>
		<xsl:variable name="type">
			<xsl:call-template name="mf:find-types">
				<xsl:with-param name="list"><xsl:value-of select="$type-list"/></xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="value">
			<xsl:call-template name="mf:extractFromProtocol">
				<xsl:with-param name="protocolList"><xsl:value-of select="$protocol"/></xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:element name="type" ><xsl:value-of select="$type" /></xsl:element>
		<xsl:element name="value"><xsl:value-of select="$value"/></xsl:element>
	</xsl:template>
	
	<!-- extract text from a Microformat property -->
	<xsl:template name="mf:extractText">
		<xsl:choose>
			<!-- when the property is on a list root, comma delineate all the li elements -->
			<xsl:when test='local-name(.) = "ol" or local-name(.) = "ul"'>
				<xsl:for-each select="*">
					<xsl:if test="not(position()=1)">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:choose>
						<!-- check for value in child elements -->
						<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
							<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
								<xsl:choose>
									<xsl:when test="string-length(.) > 0 and string-length(normalize-space(.)) = 0">
										<xsl:text> </xsl:text>
									</xsl:when>
									<!-- if the property is on an ABBR element check for @title -->
									<xsl:when test='local-name(.) = "abbr" and @title'>
										<xsl:value-of select="normalize-space(@title)"/>
									</xsl:when>
									<xsl:when test='@content'>
										<xsl:value-of select="normalize-space(@content)"/>
									</xsl:when>
									<xsl:when test='@datetime'>
										<xsl:value-of select="normalize-space(@datetime)"/>
									</xsl:when>
									<!-- if the property is on an INPUT element check for @type=text -->
									<xsl:when test='local-name(.) = "input" and @type = "text" and @value'>
										<xsl:value-of select="normalize-space(@value)"/>
									</xsl:when>
									<!-- if the property is on an PRE element don't do anything with the white-space -->
									<xsl:when test='local-name(.) = "pre"'>
										<xsl:value-of select="."/>
									</xsl:when>
									<!-- if the property is on an IMG or AREA check the @alt -->
									<xsl:when test='@alt and (local-name(.) = "img" or local-name(.) = "area")'>
										<xsl:value-of select="normalize-space(@alt)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(.)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</xsl:when>
						<!-- check for child attributes that might have value-title elements AFTER value -->
						<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value-title ')]">
							<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value-title ')]">
								<xsl:value-of select="normalize-space(@title)"/>					
							</xsl:for-each>
						</xsl:when>
						<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' type ')]">
							<xsl:variable name="notType">
								<xsl:for-each select="descendant::node()">
									<xsl:if test="not(ancestor-or-self::*[contains(concat(' ', normalize-space(@class), ' '),' type ')]) and (descendant::node() = false())">
										<xsl:value-of select="."/>
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:value-of select="normalize-space($notType)"/>				
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(.)"/>
						</xsl:otherwise>
					</xsl:choose>		
				</xsl:for-each>
			</xsl:when>
			<!-- if the property is on an ABBR element check for @title -->
			<xsl:when test='local-name(.) = "abbr" and @title'>
				<xsl:value-of select="normalize-space(@title)"/>
			</xsl:when>
			<xsl:when test='@content'>
				<xsl:value-of select="normalize-space(@content)"/>
			</xsl:when>
			<!-- if the property is on an INPUT element check for @type=text -->
			<xsl:when test='local-name(.) = "input" and @type = "text" and @value'>
				<xsl:value-of select="normalize-space(@value)"/>
			</xsl:when>
			<!-- if the property is on an PRE element don't do anything with the white-space -->
			<xsl:when test='local-name(.) = "pre"'>
				<xsl:value-of select="."/>
			</xsl:when>
			<!-- if the property is on an IMG or AREA check the @alt -->
			<xsl:when test='@alt and (local-name(.) = "img" or local-name(.) = "area")'>
				<xsl:value-of select="normalize-space(@alt)"/>
			</xsl:when>
			<!-- check for child attributes that might have value elements -->
			<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
				<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
					<xsl:choose>
						<!-- when there are multiple spaces, save one! -->
						<xsl:when test="string-length(.) > 0 and string-length(normalize-space(.)) = 0">
							<xsl:text> </xsl:text>
						</xsl:when>
						<!-- if the property is on an ABBR element check for @title -->
						<xsl:when test='local-name(.) = "abbr" and @title'>
							<xsl:value-of select="normalize-space(@title)"/>
						</xsl:when>
						<!-- if the property is on an INPUT element check for @type=text -->
						<xsl:when test='local-name(.) = "input" and @type = "text" and @value'>
							<xsl:value-of select="normalize-space(@value)"/>
						</xsl:when>
						<!-- if the property is on an PRE element don't do anything with the white-space -->
						<xsl:when test='local-name(.) = "pre"'>
							<xsl:value-of select="."/>
						</xsl:when>
						<!-- if the property is on an IMG or AREA check the @alt -->
						<xsl:when test='@alt and (local-name(.) = "img" or local-name(.) = "area")'>
							<xsl:value-of select="normalize-space(@alt)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(.)"/>
						</xsl:otherwise>
					</xsl:choose>					
				</xsl:for-each>
			</xsl:when>
			<!-- check for child attributes that might have value-title elements AFTER value -->
			<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value-title ')]">
				<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value-title ')]">
					<xsl:value-of select="normalize-space(@title)"/>					
				</xsl:for-each>
			</xsl:when>
			<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' type ')]">
				<xsl:variable name="notType">
					<xsl:for-each select="descendant::node()">
						<xsl:if test="not(ancestor-or-self::*[contains(concat(' ', normalize-space(@class), ' '),' type ')]) and (descendant::node() = false())">
							<xsl:value-of select="."/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:value-of select="normalize-space($notType)"/>				
			</xsl:when>
			<!-- take the value of the child node -->
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(.)"/>						
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="mf:doIncludes">
		<!-- check for header="" and extract that data -->
		<xsl:if test="descendant-or-self::*/@headers">
			<xsl:call-template name="mf:extract-ids">
				<xsl:with-param name="text-string"><xsl:value-of select="descendant-or-self::*/@headers"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		
		<!-- check for object/a elements with data references to IDs -->
		<xsl:if test=".//*[not(ancestor-or-self::*[local-name() = 'del']) = true()] and .//*[not(descendant-or-self::*[local-name() = 'object' or local-name() = 'a']) = false() and (contains(normalize-space(@data),'#') or contains(normalize-space(@href),'#'))]">
			<xsl:for-each select=".//*[not(descendant-or-self::*[local-name() = 'object']) = false() and contains(normalize-space(@data),'#') and contains(concat(' ',normalize-space(@class),' '),' include ')]">
				<xsl:variable name="header-id"><xsl:value-of select="substring-after(@data,'#')"/></xsl:variable>
				<xsl:for-each select="//*[@id=$header-id]">
					<xsl:call-template name="properties"/>
				</xsl:for-each>
			</xsl:for-each>
			<xsl:for-each select=".//*[not(descendant-or-self::*[local-name() = 'a']) = false() and contains(normalize-space(@href),'#') and contains(concat(' ',normalize-space(@class),' '),' include ')]">
				<xsl:variable name="header-id"><xsl:value-of select="substring-after(@href,'#')"/></xsl:variable>
				<xsl:for-each select="//*[@id=$header-id]">
					<xsl:call-template name="properties"/>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	
	<!-- recursive function to extract headers="id id id" -->
	<xsl:template name="mf:extract-ids">
		<xsl:param name="text-string"/>
		<xsl:choose>
			<xsl:when test="not(substring-before($text-string,' ')) = false()">
				<xsl:call-template name="mf:get-header">
					<xsl:with-param name="header-id"><xsl:value-of select="substring-before($text-string,' ')"/></xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="mf:extract-ids">
					<xsl:with-param name="text-string"><xsl:value-of select="substring-after($text-string,' ')"/></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="mf:get-header">
					<xsl:with-param name="header-id"><xsl:value-of select="$text-string"/></xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- include the HTML where the id attribute matches -->
	<xsl:template name="mf:get-header">		
		<!-- problem here!? need to pass the tag WITH the id, not descendants -->
		<xsl:param name="header-id"/>
		<xsl:for-each select="//*[@id=$header-id]">
			<xsl:call-template name="properties"/>
		</xsl:for-each>
	</xsl:template>

	<!-- recursive function to extract Tag from a URL -->
	<xsl:template name="mf:tagFromTagspace">
		<xsl:param name="text-string"></xsl:param>

		<!-- need to strip ? and # -->
		<xsl:choose>
			<xsl:when test="substring-before($text-string,'?')">
				<xsl:call-template name="mf:tagFromTagspace">
					<xsl:with-param name="text-string">
						<xsl:value-of select="substring-before($text-string,'?')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring-before($text-string,'#')">
				<xsl:call-template name="mf:tagFromTagspace">
					<xsl:with-param name="text-string">
						<xsl:value-of select="substring-before($text-string,'#')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($text-string,string-length($text-string),1) = '/'">		
				<xsl:call-template name="mf:tagFromTagspace">
					<xsl:with-param name="text-string">
						<xsl:value-of select="substring($text-string,1,string-length($text-string)-1)"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="not(substring-after($text-string,'/')) = false()">				
				<xsl:call-template name="mf:tagFromTagspace">
					<xsl:with-param name="text-string"><xsl:value-of select="substring-after($text-string,'/')"/></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text-string"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Get the language for an property -->
	<xsl:template name="mf:lang">
		<!-- select the nearest parent language attribute -->
		<xsl:variable name="langElt" select='ancestor-or-self::*[@xml:lang or @lang]' />
		<xsl:if test="$langElt">
			<xsl:variable name="lang">
				<xsl:choose>
					<xsl:when test="$langElt[last()]/@xml:lang">
						<xsl:value-of select="normalize-space($langElt[last()]/@xml:lang)" />
					</xsl:when>
					<xsl:when test="$langElt[last()]/@lang">
						<xsl:value-of select="normalize-space($langElt[last()]/@lang)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:message>where id lang and xml:lang go?!?!?</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="$lang" />
		</xsl:if>
	</xsl:template>

	<!-- Get the language encoding for a page -->
	<xsl:template name="mf:encoding">
		<xsl:param name="Encoding"/>
		<!-- Refer to the W3C TAG-WG for where to look for Encoding -->
		<!-- @@todo: test these XPATHes -->
		<xsl:choose>
			<!-- look to XML processing instruction -->
			<!--
			<xsl:when test="//processing-instruction()[name() = 'xml' and @encoding]">
				<xsl:value-of select="//processing-instruction()[name() = 'xml']/@encoding"/>
			</xsl:when>
		-->
			<!-- use the HTML meta element -->
			<xsl:when test="//html/head/meta[@http-equiv = 'content-type' and contains(normalize-space(@content),';charset=')]">
				<!--
				<xsl:value-of select="normalize-space(substring-after(substring-after(//html/head/meta[@http-equiv = 'content-type' and contains(normalize-space(@content),';charset='),';'),'='))"/>
				-->
			</xsl:when>
			<!-- use the value passed into the XSLT, usually HTTP header content-type -->
			<xsl:otherwise>
				<xsl:value-of select="$Encoding"/>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>

	<!-- Get the base URL for the page if there is one -->
	<xsl:template name="mf:baseURL">
		<xsl:param name="Source" />
		<xsl:choose>
			<!-- if there is an xml:base attribute use that -->
			<xsl:when test="not(//*[@xml:base]) = false()">
				<xsl:value-of select="//*[@xml:base]/@xml:base" />
			</xsl:when>

			<!-- if there is an HTML base element use that -->
			<xsl:when test="not(//*[name() = 'base']) = false()">
				<xsl:value-of select="//*[name() = 'base']/@href" />
			</xsl:when>
			
			<!-- default to the one passed into the XSLT -->
			<xsl:otherwise>
				<xsl:value-of select="$Source" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="mf:toUpper">
		<xsl:param name="text-string" />		
		<xsl:value-of select="translate(normalize-space($text-string),$lcase,$ucase)"/>
	</xsl:template>
	
	<xsl:template name="mf:toLower">
		<xsl:param name="text-string" />
		<xsl:value-of select="translate(normalize-space($text-string),$ucase,$lcase)"/>
	</xsl:template>
	
	<xsl:template name="mf:truncate">
		<xsl:param name="text-string" />
		<xsl:param name="string-length" />
		<xsl:value-of select="substring(normalize-space($text-string),1,$string-length)"/>
	</xsl:template>
	
	<xsl:template name="mf:dateISO2RFC">
		<xsl:param name="iso-date"/>
	
		<xsl:choose>
			<xsl:when test="substring($iso-date,5,2) = '01'">
				<xsl:text>Jan</xsl:text>
			</xsl:when>
			<xsl:when test="substring($iso-date,5,2) = '02'">
				<xsl:text>Feb</xsl:text>
			</xsl:when>
			<xsl:when test="substring($iso-date,5,2) = '03'">
				<xsl:text>Mar</xsl:text>
			</xsl:when>
			<xsl:when test="substring($iso-date,5,2) = '04'">
				<xsl:text>Apr</xsl:text>
			</xsl:when>
			<xsl:when test="substring($iso-date,5,2) = '05'">
				<xsl:text>May</xsl:text>
			</xsl:when>
			<xsl:when test="substring($iso-date,5,2) = '06'">
				<xsl:text>Jun</xsl:text>
			</xsl:when>
			<xsl:when test="substring($iso-date,5,2) = '07'">
				<xsl:text>Jul</xsl:text>
			</xsl:when>
			<xsl:when test="substring($iso-date,5,2) = '08'">
				<xsl:text>Aug</xsl:text>
			</xsl:when>
			<xsl:when test="substring($iso-date,5,2) = '09'">
				<xsl:text>Sep</xsl:text>
			</xsl:when>
			<xsl:when test="substring($iso-date,5,2) = '10'">
				<xsl:text>Oct</xsl:text>
			</xsl:when>
			<xsl:when test="substring($iso-date,5,2) = '11'">
				<xsl:text>Nov</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Dec</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> </xsl:text>
		<xsl:value-of select="substring($iso-date,7,2)"/>	
		<xsl:text> </xsl:text>
		<xsl:value-of select="substring($iso-date,1,4)"/>
		
		<xsl:if test="string-length($iso-date) = 15">
			<xsl:text> </xsl:text>
			<xsl:value-of select="substring($iso-date,10,2)"/>
			<xsl:text>:</xsl:text>
			<xsl:value-of select="substring($iso-date,12,2)"/>		
			<xsl:text>:</xsl:text>
			<xsl:value-of select="substring($iso-date,14,2)"/>
		</xsl:if>
		<xsl:text> GMT</xsl:text>
	</xsl:template>
	
	<!-- get the class value -->
	<xsl:template name="mf:class-attribute-value">
		<xsl:param name="value" />
		<xsl:for-each select=".//*[contains(concat(' ', @class, ' '), concat(' ', 'type', ' '))]">
			<xsl:choose>
				<xsl:when test="translate(normalize-space(.),$ucase,$lcase) = $value">
					<xsl:value-of select="normalize-space($value)"/>
				</xsl:when>
				<xsl:when test="local-name(.) = 'abbr' and @title">
					<xsl:if test="contains(translate(concat(' ', translate(@title,',',' '), ' '),$ucase,$lcase), concat(' ', $value, ' ')) = true()">
						<xsl:value-of select="normalize-space($value)"/>
					</xsl:if>
				</xsl:when>
				<!-- check for child attributes that might have value-title elements -->
				<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value-title ')]">
					<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value-title ')]">
						<xsl:if test="contains(translate(concat(' ', translate(@title,',',' '), ' '),$ucase,$lcase), concat(' ', $value, ' ')) = true()">
							<xsl:value-of select="normalize-space($value)"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>

	</xsl:template>

	<!-- Recursive function to search for property attributes -->
	<xsl:template name="mf:find-types">
	  <xsl:param name="list" /> <!-- e.g. "fax modem voice" -->
	  <xsl:param name="found" />

	  <xsl:variable name="first" select='substring-before(concat($list, " "), " ")' />
	  <xsl:variable name="rest" select='substring-after($list, " ")' />

		<!-- look for first item in list -->

		<xsl:variable name="v">
			<xsl:call-template name="mf:class-attribute-value">
				<xsl:with-param name="value" select='$first' />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="ff">
			<xsl:choose>
				<xsl:when test='normalize-space($v) and normalize-space($found)'>
					<xsl:value-of select='concat($found, ",", $first)' />
				</xsl:when>
				<xsl:when test='normalize-space($v)'>
					<xsl:value-of select='$first' />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$found" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- recur if there are more -->
		<xsl:choose>
			<xsl:when test="$rest">
				<xsl:call-template name="mf:find-types">
					<xsl:with-param name="list" select="$rest" />
					<xsl:with-param name="found" select="$ff" />
				</xsl:call-template>
			</xsl:when>
			<!-- else return what we found -->
			<xsl:otherwise>
				<xsl:value-of select="$ff" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	
</xsl:transform>
