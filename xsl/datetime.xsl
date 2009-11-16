<xsl:transform
    xmlns:xsl      ="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:datetime ="http://suda.co.uk/projects/microformats/datetime.xsl?template="
    xmlns:html     ="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="datetime html"
	>
	
	<!--
		Copyright 2006 Brian Suda
		This work is licensed under The W3C Open Source License
		http://www.w3.org/Consortium/Legal/copyright-software-19980720	
		
		VERSION: 0.1
	-->
	
	<!-- convert all times to UTC Times -->
	<!-- RFC2426 mandates that iCal dates are in UTC without dashes or colons as separators -->
	<xsl:template name="datetime:utc-time-converter">
	<xsl:param name="time-string"/>
	<xsl:choose>
		<xsl:when test="substring-before($time-string,'Z') = true()">
			<xsl:value-of select="translate(translate(substring-before($time-string,'Z'), ':' ,''), '-' ,'')"/>			
			<!-- need to pad with 0000s if needed -->
			<xsl:if test="string-length(translate(translate(substring-before($time-string,'Z'), ':' ,''), '-' ,''))  &lt; 10">
				<xsl:text>0</xsl:text>
			</xsl:if>
			<xsl:if test="string-length(translate(translate(substring-before($time-string,'Z'), ':' ,''), '-' ,''))  &lt; 11">
				<xsl:text>0</xsl:text>
			</xsl:if>
			<xsl:if test="string-length(translate(translate(substring-before($time-string,'Z'), ':' ,''), '-' ,''))  &lt; 12">
				<xsl:text>0</xsl:text>
			</xsl:if>
			<xsl:if test="string-length(translate(translate(substring-before($time-string,'Z'), ':' ,''), '-' ,''))  &lt; 13">
				<xsl:text>0</xsl:text>
			</xsl:if>
			<xsl:if test="string-length(translate(translate(substring-before($time-string,'Z'), ':' ,''), '-' ,''))  &lt; 14">
				<xsl:text>0</xsl:text>
			</xsl:if>
			<xsl:if test="string-length(translate(translate(substring-before($time-string,'Z'), ':' ,''), '-' ,''))  &lt; 15">
				<xsl:text>0</xsl:text>
			</xsl:if>			
			<xsl:text>Z</xsl:text>
		</xsl:when>
		<xsl:when test="substring-before($time-string,'T') = false()">
			<xsl:value-of select="translate(translate($time-string, ':' ,''), '-' ,'')"/>			
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="event-year"> <xsl:value-of select="substring(translate($time-string, '-' ,''),1,4)"/></xsl:variable>
			<xsl:variable name="event-month"><xsl:value-of select="substring(translate($time-string, '-' ,''),5,2)"/></xsl:variable>
			<xsl:variable name="event-day">  <xsl:value-of select="substring(translate($time-string, '-' ,''),7,2)"/></xsl:variable>
			<xsl:variable name="event-date"><xsl:value-of select="substring-before(translate($time-string, '-' ,''),'T')"/></xsl:variable>
			<xsl:choose>
				<xsl:when test="substring-before(substring-after(translate($time-string, ':' ,''),'T'),'+') = true()">
					<xsl:choose>
						<xsl:when test="string-length(substring-before(substring-after(translate($time-string, ':' ,''),'T'),'+')) &lt; 6">
							<xsl:variable name="event-time"><xsl:value-of select="concat(substring-before(substring-after(translate($time-string, ':' ,''),'T'),'+'),'00')"/></xsl:variable>
							<xsl:choose>
								<xsl:when test="string-length(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+')) &lt; 4">
									<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+'),'0000')"/></xsl:variable>											<xsl:call-template name="datetime:build-utc">
										<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
										<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
										<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
										<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time - $event-timezone)" /></xsl:with-param>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="string-length(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+')) &lt; 6">
									<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+'),'00')"/></xsl:variable>											<xsl:call-template name="datetime:build-utc">
										<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
										<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
										<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
										<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time - $event-timezone)" /></xsl:with-param>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="event-timezone"><xsl:value-of select="substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+')"/></xsl:variable>
									<xsl:call-template name="datetime:build-utc">
										<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
										<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
										<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
										<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time - $event-timezone)" /></xsl:with-param>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="event-time"><xsl:value-of select="substring-before(substring-after(translate($time-string, ':' ,''),'T'),'+')"/></xsl:variable>
							<xsl:choose>
								<xsl:when test="string-length(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+')) &lt; 4">
									<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+'),'0000')"/></xsl:variable>
									<xsl:call-template name="datetime:build-utc">
										<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
										<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
										<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
										<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time - $event-timezone)" /></xsl:with-param>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="string-length(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+')) &lt; 6">
									<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+'),'00')"/></xsl:variable>
									<xsl:call-template name="datetime:build-utc">
										<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
										<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
										<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
										<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time - $event-timezone)" /></xsl:with-param>
									</xsl:call-template>
								</xsl:when>

								<xsl:otherwise>
									<xsl:variable name="event-timezone"><xsl:value-of select="substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+')"/></xsl:variable>
									<xsl:call-template name="datetime:build-utc">
										<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
										<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
										<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
										<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time - $event-timezone)" /></xsl:with-param>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="substring-before(substring-after(translate($time-string, ':' ,''),'T'),'-') = true()">
					<xsl:choose>
						<xsl:when test="string-length(substring-before(substring-after(translate($time-string, ':' ,''),'T'),'-')) &lt; 6">
							<xsl:variable name="event-time"><xsl:value-of select="concat(substring-before(substring-after(translate($time-string, ':' ,''),'T'),'-'),'00')"/></xsl:variable>
							<xsl:choose>
								<xsl:when test="string-length(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-')) &lt; 4">
									<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-'),'0000')"/></xsl:variable>
									<xsl:call-template name="datetime:build-utc">
										<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
										<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
										<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
										<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time + $event-timezone)" /></xsl:with-param>
									</xsl:call-template>
								</xsl:when>

								<xsl:when test="string-length(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-')) &lt; 6">
									<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-'),'00')"/></xsl:variable>
									<xsl:call-template name="datetime:build-utc">
										<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
										<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
										<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
										<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time + $event-timezone)" /></xsl:with-param>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="event-timezone"><xsl:value-of select="substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-')"/></xsl:variable>
									<xsl:call-template name="datetime:build-utc">
										<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
										<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
										<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
										<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time + $event-timezone)" /></xsl:with-param>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="event-time"><xsl:value-of select="substring-before(substring-after(translate($time-string, ':' ,''),'T'),'-')"/></xsl:variable>
							<xsl:choose>
								<xsl:when test="string-length(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-')) &lt; 4">
									<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-'),'0000')"/></xsl:variable>
									<xsl:call-template name="datetime:build-utc">
										<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
										<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
										<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
										<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time + $event-timezone)" /></xsl:with-param>
									</xsl:call-template>
								</xsl:when>

								<xsl:when test="string-length(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-')) &lt; 6">
									<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-'),'00')"/></xsl:variable>
									<xsl:call-template name="datetime:build-utc">
										<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
										<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
										<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
										<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time + $event-timezone)" /></xsl:with-param>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="event-timezone"><xsl:value-of select="substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-')"/></xsl:variable>
									<xsl:call-template name="datetime:build-utc">
										<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
										<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
										<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
										<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time + $event-timezone)" /></xsl:with-param>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space($event-year)"/>
					<xsl:value-of select="normalize-space($event-month)"/>
					<xsl:value-of select="normalize-space($event-day)"/>
					<xsl:text>T</xsl:text>
					<!-- hmm, does format-number pad the front or back of the string? -->
					<!--
					<xsl:value-of select="format-number(normalize-space(substring-after(translate($time-string, ':' ,''),'T')),'000000')"/>
					-->
					
					<xsl:if test="string-length(normalize-space(substring-after(translate($time-string, ':' ,''),'T'))) &lt; 6">
						<xsl:text>0</xsl:text>
					</xsl:if>
					<xsl:if test="string-length(normalize-space(substring-after(translate($time-string, ':' ,''),'T'))) &lt; 5">
						<xsl:text>0</xsl:text>
					</xsl:if>
					<xsl:if test="string-length(normalize-space(substring-after(translate($time-string, ':' ,''),'T'))) &lt; 4">
						<xsl:text>0</xsl:text>
					</xsl:if>
					<xsl:if test="string-length(normalize-space(substring-after(translate($time-string, ':' ,''),'T'))) &lt; 3">
						<xsl:text>0</xsl:text>
					</xsl:if>
					<xsl:if test="string-length(normalize-space(substring-after(translate($time-string, ':' ,''),'T'))) &lt; 2">
						<xsl:text>0</xsl:text>
					</xsl:if>
					<xsl:value-of select="normalize-space(substring-after(translate($time-string, ':' ,''),'T'))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
	</xsl:template>

	<!-- create a valid UTC date and increments day/month/year as needed -->
	<xsl:template name="datetime:build-utc">
	<xsl:param name="event-year"></xsl:param>
	<xsl:param name="event-month"></xsl:param>
	<xsl:param name="event-day"></xsl:param>
	<xsl:param name="utc-event-time"></xsl:param>

	<xsl:choose>
		<xsl:when test="$utc-event-time &gt; 235959">
			<xsl:choose>
				<xsl:when test="($event-month = 12) and ($event-day = 31)">
					<xsl:value-of select="$event-year + 1"/>			
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$event-year"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="(($event-month = 12) and ($event-day = 31))">
					<xsl:text>01</xsl:text>	
				</xsl:when>
				<xsl:when test="(($event-month = 11) and ($event-day = 30)) or (($event-month = 10) and ($event-day = 31)) or (($event-month = 9) and ($event-day = 30))">
					<xsl:value-of select="$event-month + 1"/>	
				</xsl:when>
				<xsl:when test="(($event-month = 8) and ($event-day = 31)) or (($event-month = 7) and ($event-day = 31)) or (($event-month = 6) and ($event-day = 30)) or (($event-month = 5) and ($event-day = 31)) or (($event-month = 4) and ($event-day = 30)) or (($event-month = 3) and ($event-day = 31)) or (($event-month = 1) and ($event-day = 31)) or ($event-month = 2) and ($event-day = 29)">
					<xsl:text>0</xsl:text><xsl:value-of select="$event-month + 1"/>	
				</xsl:when>
				<xsl:when test="(($event-month = 2) and ($event-day = 28) and (($event-year mod 4) != 0) or (($event-year mod 400) != 0) and (($event-year mod 100) = 0))">
					<xsl:text>0</xsl:text><xsl:value-of select="$event-month + 1"/>				
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$event-month"/>
				</xsl:otherwise>		
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="(($event-month = 12) and ($event-day = 31)) or (($event-month = 11) and ($event-day = 30)) or (($event-month = 10) and ($event-day = 31)) or (($event-month = 9) and ($event-day = 30)) or (($event-month = 8) and ($event-day = 31)) or (($event-month = 7) and ($event-day = 31)) or (($event-month = 6) and ($event-day = 30)) or (($event-month = 5) and ($event-day = 31)) or (($event-month = 4) and ($event-day = 30)) or (($event-month = 3) and ($event-day = 31)) or (($event-month = 1) and ($event-day = 31)) or ($event-month = 2) and ($event-day = 29)">
					<xsl:text>01</xsl:text>
				</xsl:when>
				<xsl:when test="(($event-month = 2) and ($event-day = 28) and (($event-year mod 4) != 0) or (($event-year mod 400) != 0) and (($event-year mod 100) = 0))">
					<xsl:text>01</xsl:text>
				</xsl:when>
				<xsl:when test="(($event-day = 2) or ($event-day = 3) or ($event-day = 4) or ($event-day = 5) or ($event-day = 6) or ($event-day = 7) or ($event-day = 8))">
					<xsl:text>0</xsl:text><xsl:value-of select="$event-day + 1"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$event-day + 1"/>			
				</xsl:otherwise>
			</xsl:choose>

			<xsl:text>T</xsl:text>
					<xsl:if test="string-length($utc-event-time mod 240000) &lt; 6">
						<xsl:text>0</xsl:text>
					</xsl:if>
					<xsl:if test="string-length($utc-event-time mod 240000) &lt; 5">
						<xsl:text>0</xsl:text>
					</xsl:if>
					<xsl:if test="string-length($utc-event-time mod 240000) &lt; 4">
						<xsl:text>0</xsl:text>
					</xsl:if>
					<xsl:if test="string-length($utc-event-time mod 240000) &lt; 3">
						<xsl:text>0</xsl:text>
					</xsl:if>
					<xsl:if test="string-length($utc-event-time mod 240000) &lt; 2">
						<xsl:text>0</xsl:text>
					</xsl:if>
					<!--
					<xsl:if test="string-length($utc-event-time mod 240000) = 1">
						<xsl:text>0</xsl:text>
					</xsl:if>
					-->
	<!--
			<xsl:if test="string-length($utc-event-time mod 240000) &lt; 6">
			<xsl:text>0</xsl:text>
			</xsl:if>
	-->
			<xsl:value-of select="$utc-event-time mod 240000"/>
			<xsl:text>Z</xsl:text>
		</xsl:when>
		<xsl:when test="$utc-event-time &lt; 0">
			<xsl:choose>
				<xsl:when test="($event-month = 1) and ($event-day = 1)">
					<xsl:value-of select="$event-year - 1"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$event-year"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="(($event-month = 1) and ($event-day = 1))">
					<xsl:text>12</xsl:text>
				</xsl:when>
				<xsl:when test="(($event-month = 11) and ($event-day = 1)) or (($event-month = 12) and ($event-day = 1))">
					<xsl:value-of select="$event-month - 1"/>
				</xsl:when>
				<xsl:when test="(($event-month = 10) and ($event-day = 1)) or (($event-month = 9) and ($event-day = 1)) or (($event-month = 8) and ($event-day = 1)) or (($event-month = 7) and ($event-day = 1)) or (($event-month = 6) and ($event-day = 1)) or (($event-month = 5) and ($event-day = 1)) or (($event-month = 4) and ($event-day = 1)) or (($event-month = 3) and ($event-day = 1)) or ($event-month = 2) and ($event-day = 1)">
					<xsl:text>0</xsl:text><xsl:value-of select="$event-month - 1"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$event-month"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="(($event-month = 11) and ($event-day = 1)) or (($event-month = 9) and ($event-day = 1)) or (($event-month = 6) and ($event-day = 1)) or (($event-month = 4) and ($event-day = 1)) or (($event-month = 2) and ($event-day = 1)) or (($event-month = 1) and ($event-day = 1))">
					<xsl:text>31</xsl:text>
				</xsl:when>
				<xsl:when test="(($event-month = 12) and ($event-day = 1)) or (($event-month = 10) and ($event-day = 1)) or (($event-month = 7) and ($event-day = 1)) or (($event-month = 5) and ($event-day = 1))">
					<xsl:text>30</xsl:text>
				</xsl:when>
				<xsl:when test="(($event-month = 3) and ($event-day = 1) and (($event-year mod 4) != 0) or (($event-year mod 400) != 0) and (($event-year mod 100) = 0))">
					<xsl:text>28</xsl:text>
				</xsl:when>
				<xsl:when test="(($event-month = 3) and ($event-day = 1) and (($event-year mod 4) = 0) or (($event-year mod 400) = 0) and (($event-year mod 100) != 0))">
					<xsl:text>29</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$event-day - 1"/>			
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>T</xsl:text>
			<xsl:if test="string-length(240000 + $utc-event-time) &lt; 0">
			<xsl:text>0</xsl:text>
			</xsl:if>
			<xsl:value-of select="240000 + $utc-event-time"/>
			<xsl:text>Z</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$event-year"/>
			<xsl:value-of select="$event-month"/>
			<xsl:value-of select="$event-day"/>
			<xsl:text>T</xsl:text>

			<xsl:choose>
				<xsl:when test="$utc-event-time = 240000 or $utc-event-time = 0">
					<xsl:text>000000</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="string-length($utc-event-time) &lt; 6">
						<xsl:text>0</xsl:text>
					</xsl:if>
					<xsl:if test="string-length($utc-event-time) &lt; 5">
						<xsl:text>0</xsl:text>
					</xsl:if>
					<xsl:if test="string-length($utc-event-time) &lt; 4">
						<xsl:text>0</xsl:text>
					</xsl:if>
					<xsl:if test="string-length($utc-event-time) &lt; 3">
						<xsl:text>0</xsl:text>
					</xsl:if>
					<xsl:if test="string-length($utc-event-time) &lt; 2">
						<xsl:text>0</xsl:text>
					</xsl:if>
					<xsl:if test="string-length($utc-event-time) = 1">
						<xsl:text>0</xsl:text>
					</xsl:if>
					<xsl:value-of select="$utc-event-time"/>
				</xsl:otherwise>
			</xsl:choose>


			<xsl:text>Z</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
	</xsl:template>

	<!-- recursive function to get all the RDATE times and check them for UTC -->
	<xsl:template name="datetime:rdate-comma-utc">
		<xsl:param name="text-string"/>
		<xsl:choose>
			<xsl:when test="substring-before($text-string,',') = true()">
				<xsl:call-template name="datetime:utc-time-converter">
					<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(substring-before(substring-before($text-string,','),'/'))" /></xsl:with-param>
				</xsl:call-template>
				<xsl:text>/</xsl:text>
				<xsl:call-template name="datetime:utc-time-converter">
					<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(substring-after(substring-before($text-string,','),'/'))" /></xsl:with-param>
				</xsl:call-template>
				<xsl:text>,</xsl:text>
				<xsl:call-template name="datetime:rdate-comma-utc">
					<xsl:with-param name="text-string"><xsl:value-of select="substring-after($text-string,',')"/></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="datetime:utc-time-converter">
					<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(substring-before($text-string,'/'))" /></xsl:with-param>
				</xsl:call-template>
				<xsl:text>/</xsl:text>
				<xsl:call-template name="datetime:utc-time-converter">
					<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(substring-after($text-string,'/'))" /></xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	
</xsl:transform>
