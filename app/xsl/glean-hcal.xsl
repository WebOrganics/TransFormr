<?xml version="1.0"?>
<xsl:stylesheet 
 xmlns:xsl ="http://www.w3.org/1999/XSL/Transform" 
 xmlns:r   ="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
 xmlns:c   ="http://www.w3.org/2002/12/cal/ical#"
 xmlns:h   ="http://www.w3.org/1999/xhtml"
 version="1.0"
>

<xsl:output method="xml" encoding="utf-8" indent="yes"/>

<xsl:strip-space elements="*"/>

<xsl:param name="prodid" select='"-//connolly.w3.org//RDF Calendar $Date: 2007/06/30 19:05:32 $ (BETA)//EN"' />

<xsl:param name="CalNS">http://www.w3.org/2002/12/cal/ical#</xsl:param>
<xsl:param name="XdtNS">http://www.w3.org/2001/XMLSchema#</xsl:param>

<!-- by Dan Connolly -->

<!--

acks...

brian suda
brian@suda.co.uk
http://suda.co.uk/

XHTML-2-vCard
Version 0.5.1
2005-07-08

Copyright 2005 Brian Suda
This work is licensed under the Creative Commons Attribution-ShareAlike License. 
To view a copy of this license, visit 
http://creativecommons.org/licenses/by-sa/1.0/
-->

<!--Best Practices states this should be
    the URL the calendar was transformed from -->
<xsl:param name="Source">
  <xsl:choose>
    <xsl:when test='h:html/h:head/h:link[@rel="base"]'>
      <xsl:value-of select='h:html/h:head/h:link[@rel="base"]/@href' />
    </xsl:when>
    <xsl:when test='h:html/h:head/h:base'>
      <xsl:value-of select='h:html/h:head/h:base/@href'/>
    </xsl:when>
  </xsl:choose>
</xsl:param>

<xsl:param name="Anchor" />

<!-- find a vcard  for my-events idiom -->
<xsl:param name="Me"
	   select="//*[contains(concat(' ', normalize-space(@class), ' '),
		   ' organizer ')]/@id"/>


<xsl:template match="/">
  <r:RDF>
    <!-- The Vcalendar object used to be existentially quantified,
	 but it's convenient to be able to refer to it by URI,
	 so we say the Source document is the Vcalendar.
    -->
    <c:Vcalendar r:about="{$Source}">
      <c:prodid>
	<xsl:value-of select="$prodid" />
      </c:prodid>
      <c:version>2.0</c:version>

      <xsl:apply-templates />
  
    </c:Vcalendar>
  </r:RDF>
</xsl:template>


<!-- Each event is listed in succession -->
<xsl:template
    match="*[contains(concat(' ',normalize-space(@class),' '),' vevent ')]">

  <xsl:if test="not($Anchor) or @id = $Anchor">

    <c:component>
      <c:Vevent>

	<xsl:call-template name="cal-props" />

      </c:Vevent>
    </c:component>
  </xsl:if>
</xsl:template>

<!-- ... and todos. -->
<xsl:template
    match="*[contains(concat(' ', normalize-space(@class), ' '),' vtodo ')]">

  <xsl:if test="not($Anchor) or @id = $Anchor">
    <c:component>
      <c:Vtodo>
	<xsl:call-template name="cal-props" />
      </c:Vtodo>
    </c:component>
  </xsl:if>
</xsl:template>

<xsl:template name="cal-props">
    <!-- make a UID out of the Source URI and the ID -->
    <xsl:if test="@id and $Source">
      <xsl:attribute name="r:about">
	<xsl:value-of select='concat($Source, "#", @id)' />
      </xsl:attribute>
    </xsl:if>

    <!-- if parent of vevent has class my-events, then $Me
         is an attendee. -->
    <xsl:if test="contains(concat(' ', normalize-space(../@class), ' '),
                           ' my-events ')">
      <c:organizer r:resource='{concat($Source, "#", $Me)}' />
    </xsl:if>

    <xsl:call-template name="textProp">
      <xsl:with-param name="class">uid</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="dateProp">
      <xsl:with-param name="class">dtstamp</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="textProp">
      <xsl:with-param name="class">summary</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="textProp">
      <xsl:with-param name="class">description</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="dateProp">
      <xsl:with-param name="class">dtstart</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="dateProp">
      <xsl:with-param name="class">dtend</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="durProp">
      <xsl:with-param name="class">duration</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="refProp">
      <xsl:with-param name="class">url</xsl:with-param>
      <xsl:with-param name="default">
	<xsl:choose>
	  <xsl:when test="@id">
	    <xsl:value-of select='concat($Source, "#", @id)' />
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select='$Source' />
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="textProp">
      <xsl:with-param name="class">location</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="textProp">
      <xsl:with-param name="class">status</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="floatPairProp">
      <xsl:with-param name="class">geo</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="recurProp">
      <xsl:with-param name="class">rrule</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="dateProp">
      <xsl:with-param name="class">exdate</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="whoProp">
      <xsl:with-param name="class">attendee</xsl:with-param>
    </xsl:call-template>


</xsl:template>



<xsl:template name="textProp">
  <xsl:param name="class" />

  <xsl:for-each select=".//*[
			contains(concat(' ', @class, ' '),
			concat(' ', $class, ' '))]">

    <!-- @@ "the first descendant element with that class should take
	 effect, any others being ignored." -->
    <xsl:element name="{$class}"
		 namespace="{$CalNS}">
      <xsl:call-template name="lang" />
      
      <xsl:choose>
	<!-- @@this multiple values stuff doesn't seem to be in the spec
	-->
	<xsl:when test='local-name(.) = "ol" or local-name(.) = "ul"'>
	  <xsl:for-each select="*">
	    <xsl:if test="not(position()=1)">
	      <xsl:text>,</xsl:text>
	    </xsl:if>
	    
	    <xsl:value-of select="." />
	  </xsl:for-each>
	</xsl:when>
	
	<xsl:when test='local-name(.) = "abbr" and @title'>
	  <xsl:value-of select="@title" />
	</xsl:when>
	
	<xsl:when test='@content'>
	  <xsl:value-of select="@content" />
	</xsl:when>
	
	<xsl:otherwise>
	  <xsl:value-of select="." /> <!-- normalize space? hmm. -->
	</xsl:otherwise>
      </xsl:choose>
      
    </xsl:element>
  </xsl:for-each>
</xsl:template>


<xsl:template name="lang">
  <xsl:variable name="langElt"
		select='ancestor-or-self::*[@xml:lang or @lang]' />
  <xsl:if test="$langElt">
    <xsl:variable name="lang">
      <xsl:choose>
	<xsl:when test="$langElt/@xml:lang">
	  <xsl:value-of select="normalize-space($langElt/@xml:lang)" />
	</xsl:when>
	<xsl:when test="$langElt/@lang">
	  <xsl:value-of select="normalize-space($langElt/@lang)" />
	</xsl:when>
	<xsl:otherwise>
	  <xsl:message>where id lang and xml:lang go?!?!?
	  </xsl:message>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:attribute name="xml:lang">
      <xsl:value-of select="$lang" />
    </xsl:attribute>
  </xsl:if>
</xsl:template>



<xsl:template name="refProp">
  <xsl:param name="class" />
  <xsl:param name="default" />

  <xsl:choose>
    <xsl:when test=".//*[
		    contains(concat(' ', @class, ' '),
		    concat(' ', $class, ' '))]">

      <xsl:for-each select=".//*[
			    contains(concat(' ', @class, ' '),
			    concat(' ', $class, ' '))]">
	<xsl:variable name="ref">
	  <xsl:choose>
	    <!-- @@make absolute? -->
	    <xsl:when test="@href">
	      <xsl:value-of select="@href" />
	    </xsl:when>
	    
	    <xsl:otherwise>
	      <xsl:value-of select="normalize-space(.)" />
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>
	
	<xsl:element name="{$class}"
		     namespace="{$CalNS}">
	  <xsl:attribute name="r:resource">
	    <xsl:value-of select="$ref" />
	  </xsl:attribute>
	</xsl:element>
	
      </xsl:for-each>
    </xsl:when>

    <xsl:when test="$default">
      <xsl:element name="{$class}"
		   namespace="{$CalNS}">
	<xsl:attribute name="r:resource">
	  <xsl:value-of select="$default" />
	</xsl:attribute>
      </xsl:element>
    </xsl:when>
  </xsl:choose>

</xsl:template>


<xsl:template name="whoProp">
  <xsl:param name="class" />

  <xsl:for-each select=".//*[
			contains(concat(' ', @class, ' '),
			concat(' ', $class, ' '))]">
    <xsl:variable name="mbox">
      <xsl:choose>
	<!-- @@make absolute? -->
	<xsl:when test="@href">
	  <xsl:value-of select="@href" />
	</xsl:when>
	    
	<xsl:otherwise>
	  <xsl:value-of select="normalize-space(.)" />
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
	
    <xsl:variable name="cn">
      <xsl:choose>
	<xsl:when test="@href">
	  <xsl:value-of select="normalize-space(.)" />
	</xsl:when>
	    
	<xsl:otherwise>
	  <xsl:value-of select='""'/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
	
    <xsl:element name="{$class}"
		 namespace="{$CalNS}">
      <xsl:attribute name="r:parseType">Resource</xsl:attribute>
      <c:calAddress r:resource="{$mbox}" />
      <xsl:if test="$cn">
	<c:cn><xsl:value-of select="$cn"/></c:cn>
      </xsl:if>
    </xsl:element>
	
  </xsl:for-each>

</xsl:template>


<xsl:template name="dateProp">
  <xsl:param name="class" />

  <xsl:for-each select=".//*[
			contains(concat(' ', @property, ' '),
			concat(' ', $class, ' ')) or contains(concat(' ', @class, ' '),
			concat(' ', $class, ' '))]">
    <xsl:element name="{$class}"
		 namespace="{$CalNS}">
      
  <xsl:variable name="when">
	<xsl:choose>
		<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value-title ')]">
			<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value-title ')]">
				<xsl:value-of select="normalize-space(@title)"/>					
			</xsl:for-each>
		</xsl:when>
	  <xsl:when test="@title">
	    <xsl:value-of select="@title">
	    </xsl:value-of>
	  </xsl:when>
	  <xsl:when test="@content">
	    <xsl:value-of select="@content">
	    </xsl:value-of>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="normalize-space(.)" />
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      
      <xsl:choose>
	<xsl:when test='contains($when, "Z")'>
	  <xsl:attribute name="r:datatype">
	    <xsl:value-of select='concat($XdtNS, "dateTime")' />
	  </xsl:attribute>
	  
	  <xsl:value-of select='$when' />
	</xsl:when>
	
	<xsl:when test='string-length($when) =
			string-length("yyyy-mm-ddThh:mm:ss+hh:mm")'>
	  <xsl:attribute name="r:datatype">
	    <xsl:value-of select='concat($XdtNS, "dateTime")' />
	  </xsl:attribute>
	  <xsl:call-template name="timeDelta">
	    <xsl:with-param name="year"
			    select='number(substring($when, 1, 4))'/>
	    <xsl:with-param name="month"
			    select='number(substring($when, 6, 2))'/>
	    <xsl:with-param name="day"
			    select='number(substring($when, 9, 2))'/>
	    <xsl:with-param name="hour"
			    select='number(substring($when, 12, 2))'/>
	    <xsl:with-param name="minute"
			    select='number(substring($when, 15, 2))'/>
	    
	    <xsl:with-param name="tzOff"
			    select='substring($when, 20, 3)'/>
	  </xsl:call-template>
	</xsl:when>
	
	<xsl:when test='contains($when, "T")'>
	  <xsl:attribute name="r:datatype">
	    <xsl:value-of select='concat($CalNS, "dateTime")' /> <!--??-->
	  </xsl:attribute>
	  <xsl:value-of select='$when' />
	</xsl:when>
	
	<xsl:otherwise>
	  <xsl:attribute name="r:datatype">
	    <xsl:value-of select='concat($XdtNS, "date")' />
	  </xsl:attribute>
	  <xsl:value-of select='$when' />
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:for-each>
</xsl:template>


<xsl:template name="timeDelta">
  <!-- see http://www.microformats.org/wiki/datetime-design-pattern -->
  <!-- returns YYYYMMDDThhmmssZ -->
  <xsl:param name="year" /> <!-- integers -->
  <xsl:param name="month" />
  <xsl:param name="day" />
  <xsl:param name="hour" />
  <xsl:param name="minute" />

  <xsl:param name="tzOff" />
  <xsl:variable name="hourDelta">
    <xsl:choose>
      <xsl:when test='starts-with($tzOff, "-")'>
	<xsl:value-of select='number(substring($tzOff, 2))' />
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select='0 - number(substring($tzOff, 2))' />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="hour2">
    <xsl:choose>
      <xsl:when test="$hour + $hourDelta &gt; 23">
	<xsl:value-of select="$hour + $hourDelta - 24" />
      </xsl:when>
      <xsl:when test="$hour + $hourDelta &lt; 0">
	<xsl:value-of select="$hour + $hourDelta + 24" />
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$hour + $hourDelta" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="dayDelta">
    <xsl:choose>
      <xsl:when test="$hour + $hourDelta &gt; 23">
	<xsl:value-of select="1" />
      </xsl:when>
      <xsl:when test="$hour + $hourDelta &lt; 0">
	<xsl:value-of select="-1" />
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="0" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="maxd">
    <xsl:call-template name="max-days">
      <xsl:with-param name="y" select="$year"/>
      <xsl:with-param name="m" select="$month"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="day2">
    <xsl:choose>
      <xsl:when test="$day + $dayDelta &gt; $maxd">
	<xsl:value-of select="1" />
      </xsl:when>

      <xsl:when test="$day + $dayDelta &lt; 0">
	<xsl:call-template name="max-days">
	  <xsl:with-param name="y" select="$year"/>
	  <!-- @@TODO: handle year crossings -->
	  <xsl:with-param name="m" select="$month - 1"/>
	</xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
	<xsl:value-of select="$day + $dayDelta" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="monthDelta">
    <xsl:choose>
      <xsl:when test="$day + $dayDelta &gt; $maxd">
	<xsl:value-of select="1" />
      </xsl:when>
      <xsl:when test="$day + $dayDelta &lt; 0">
	<xsl:value-of select="-1" />
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="0" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="month2">
    <xsl:choose>
      <xsl:when test="$month + $monthDelta &gt; 12">
	<xsl:value-of select="1" />
      </xsl:when>

      <xsl:when test="$month + $monthDelta &lt; 0">
	<xsl:value-of select="12" />
      </xsl:when>

      <xsl:otherwise>
	<xsl:value-of select="$month + $monthDelta" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="yearDelta">
    <xsl:choose>
      <xsl:when test="$month + $monthDelta &gt; 12">
	<xsl:value-of select="1" />
      </xsl:when>

      <xsl:when test="$month + $monthDelta &lt; 0">
	<xsl:value-of select="-1" />
      </xsl:when>

      <xsl:otherwise>
	<xsl:value-of select="0" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="year2">
    <xsl:value-of select="$year + $yearDelta" />
  </xsl:variable>

  <xsl:value-of select='concat(format-number($year2, "0000"), "-",
			format-number($month2, "00"), "-",
			format-number($day2, "00"), "T",
			format-number($hour2, "00"), ":",
			format-number($minute, "00"), ":00Z")' />

</xsl:template>


<xsl:template name="max-days">
  <!-- maximum number of days in the given month of the given year -->
  <!-- @@ skip leap year for now -->
  <xsl:param name="y"/>
  <xsl:param name="m"/>

  <xsl:choose>
    <xsl:when test='$m = 1 or $m = 3 or $m = 5 or $m = 7 or
      $m = 8 or $m = 10 or $m = 12'>
      <xsl:value-of select="31" />
    </xsl:when>

    <xsl:when test='$m = 2'>
      <xsl:value-of select="28" />
    </xsl:when>

    <xsl:otherwise>
      <xsl:value-of select="30" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="durProp">
  <xsl:param name="class" />

  <xsl:for-each select=".//*[
			contains(concat(' ', @property, ' '),
			concat(' ', $class, ' ')) or contains(concat(' ', @class, ' '),
			concat(' ', $class, ' '))]">
    <xsl:element name="{$class}"
		 namespace="{$CalNS}">

      <!-- commas aren't possible, are they? -->
      <xsl:choose>
	<xsl:when test='local-name(.) = "abbr" and @title'>
	  <xsl:value-of select="@title" />
	</xsl:when>
	
	<xsl:when test='@content'>
	  <xsl:value-of select="@content" />
	</xsl:when>

	<xsl:otherwise>
	  <xsl:value-of select='normalize-space(.)' />
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:for-each>
</xsl:template>

<xsl:template name="floatPairProp">
  <xsl:param name="class" />

  <xsl:for-each select=".//*[
			contains(concat(' ', @property, ' '),
			concat(' ', $class, ' ')) or contains(concat(' ', @class, ' '),
			concat(' ', $class, ' '))]">

    <xsl:variable name="xy">
      <xsl:choose>
	<xsl:when test='local-name(.) = "abbr" and @title'>
	  <xsl:value-of select="@title" />
	</xsl:when>

	<xsl:when test='@content'>
	  <xsl:value-of select="@content" />
	</xsl:when>
	
	<xsl:otherwise>
	  <xsl:value-of select="." />
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="x" select='substring-before($xy, ";")' />
    <xsl:variable name="y" select='substring-after($xy, ";")' />

    <xsl:element name="{$class}"
		 namespace="{$CalNS}">
      <xsl:attribute name="r:parseType">Resource</xsl:attribute>

      <r:first r:datatype="http://www.w3.org/2001/XMLSchema#double">
	<xsl:value-of select="$x" />
      </r:first>

      <r:rest r:parseType="Resource">
	<r:first r:datatype="http://www.w3.org/2001/XMLSchema#double">
	  <xsl:value-of select="$y" />
	</r:first>
	<r:rest r:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#nil" />
      </r:rest>
    </xsl:element>
  </xsl:for-each>
</xsl:template>


<xsl:template name="recurProp">
  <xsl:param name="class" />

  <xsl:for-each select=".//*[
			contains(concat(' ', @class, ' '),
			concat(' ', $class, ' '))]">
    <xsl:element name="{$class}"
		 namespace="{$CalNS}">
      <xsl:attribute name="r:parseType">Resource</xsl:attribute>
      <xsl:call-template name="sub-prop">
	<xsl:with-param name="ln" select='"freq"' />
      </xsl:call-template>

      <xsl:call-template name="sub-prop">
	<xsl:with-param name="ln" select='"interval"' />
      </xsl:call-template>

      <xsl:call-template name="sub-prop">
	<xsl:with-param name="ln" select='"byday"' />
      </xsl:call-template>

      <xsl:call-template name="sub-prop">
	<xsl:with-param name="ln" select='"bymonthday"' />
      </xsl:call-template>

      <xsl:call-template name="sub-prop">
	<xsl:with-param name="ln" select='"until"' />
      </xsl:call-template>

    </xsl:element>
  </xsl:for-each>
</xsl:template>

<xsl:template name="sub-prop">
  <xsl:param name="ln" />
  <xsl:variable name="v">
    <xsl:call-template name="class-value">
      <xsl:with-param name="class" select="$ln" />
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="string-length($v) &gt; 0">
    <xsl:element name="{$ln}" namespace="{$CalNS}">
      <xsl:value-of select="$v" />
    </xsl:element>
  </xsl:if>
</xsl:template>

<xsl:template name="class-value">
  <xsl:param name="class" />

  <xsl:value-of	select="descendant-or-self::*[
			contains(concat(' ', @class, ' '),
			concat(' ', $class, ' '))]" />
</xsl:template>

<!-- don't pass text thru -->
<xsl:template match="text()" />
</xsl:stylesheet>
