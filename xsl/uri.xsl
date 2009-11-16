<!-- -*- mode: indented-text;-*- -->
<xsl:transform
    xmlns:xsl  ="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:uri  ="http://www.w3.org/2000/07/uri43/uri.xsl?template="
    xmlns:html ="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="uri html"
	>

<div xmlns="http://www.w3.org/1999/xhtml">

<h2>Share and Enjoy</h2>

<p>$Id: uri.xsl,v 1.12 2004/11/05 10:35:03 dom Exp $</p>

<p>Copyright (c) 2000 W3C (MIT, INRIA, Keio), released under the <a
href="http://www.w3.org/Consortium/Legal/copyright-software-19980720">
W3C Open Source License</a> of August 14 1998.  </p>

<h2>Reference</h2>

<p><cite><a href="http://www.ietf.org/rfc/rfc2396.txt">Uniform
    Resource Identifiers (URI): Generic Syntax</a></cite> (RFC 2396)
    T. Berners-Lee, R. Fielding, L. Masinter August 1998 </p>

</div>

<xsl:param name="Debug" select="0"/>

<xsl:variable name="uri:lowalpha"
	      select='"abcdefghijklmnopqrstuvwxyz"'/>
<xsl:variable name="uri:upalpha"
	      select='"ABCDEFGHIJKLMNOPQRSTUVWXYZ"'/>
<xsl:variable name="uri:digit"
	      select='"01234567890"'/>
<xsl:variable name="uri:alpha"
	      select='concat($uri:lowalpha, $uri:upalpha)'/>

<xsl:template name="uri:expand">
  <!-- 5.2. Resolving Relative References to Absolute Form -->
  <xsl:param name="base"/> <!-- an absolute URI -->
  <xsl:param name="there"/> <!-- a URI reference -->

  <!-- @@assert that $there contains only URI characters -->
  <!-- @@implement the unicode->ascii thingy from HTML 4.0 -->

  <xsl:variable name="fragment" select='substring-after($there, "#")'/>
		<!-- hmm... I'd like to split after the *last* #,
		     but substring-after splits after the first occurence.
		     Anyway... more than one # is illegal -->

  <xsl:variable name="hashFragment">
    <xsl:choose>
      <xsl:when test="string-length($fragment) > 0">
        <xsl:value-of select='concat("#", $fragment)'/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select='""'/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="rest"
		select='substring($there, 1,
			          string-length($there)
				  - string-length($hashFragment))'/>

  <xsl:if test="$Debug"><xsl:message>
    there: [<xsl:value-of select="$there"/>]
    fragment: [<xsl:value-of select="$fragment"/>]
    hashFragment: [<xsl:value-of select="$hashFragment"/>]
    rest: [<xsl:value-of select="$rest"/>]
  </xsl:message></xsl:if>

  <xsl:choose>
    <!-- step 2) -->
    <xsl:when test="string-length($rest) = 0">
      <xsl:if test="0">
      <xsl:message>ur:expand called with reference to self-same document.
			     should this be prohibited? i.e.
			     should the caller handle references
			     to the self-same document?</xsl:message>
      </xsl:if>
      <xsl:value-of select="concat($base, $hashFragment)"/>
    </xsl:when>

    <xsl:otherwise>
      <xsl:variable name="scheme">
        <xsl:call-template name="uri:split-scheme">
	  <xsl:with-param name="ref" select="$rest"/>
	</xsl:call-template>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test='string-length($scheme) > 0'>
	  <!-- step 3) ref is absolute. we're done -->
	  <xsl:value-of select="$there"/>
	</xsl:when>
        <xsl:when test="string-length($base) = 0">
          <!-- if base is not an absoute uri, no point to continue processing -->
          <xsl:message>base uri empty, defaulting to return there</xsl:message>
          <xsl:value-of select="$there"/>
        </xsl:when>
        <xsl:otherwise>
	  <xsl:variable name="rest2"
			select='substring($rest, string-length($scheme) + 1)'/>

	  <xsl:variable name="baseScheme">
	    <xsl:call-template name="uri:split-scheme">
	    <xsl:with-param name="ref" select="$base"/>
	    </xsl:call-template>
	  </xsl:variable>

	  <xsl:choose>
	    <xsl:when test='starts-with($rest2, "//")'>
	      <!-- step 4) network-path; we're done -->

	      <xsl:value-of select='concat($baseScheme, ":",
					   $rest2, $hashFragment)'/>
            </xsl:when>

	    <xsl:otherwise>

	      <xsl:variable name="baseRest"
			    select='substring($base,
				 string-length($baseScheme) + 2)'/>

	      <xsl:variable name="baseAuthority">
		<xsl:call-template name="uri:split-authority">
		  <xsl:with-param name="ref" select="$baseRest"/>
		</xsl:call-template>
	      </xsl:variable>

	      <xsl:choose>
	        <xsl:when test='starts-with($rest2, "/")'>
		  <!-- step 5) absolute-path; we're done -->

		  <xsl:value-of select='concat($baseScheme, ":",
					       $baseAuthority,
					       $rest2, $hashFragment)'/>
		</xsl:when>

		<xsl:otherwise>
		  <!-- step 6) relative-path -->
		  <!-- @@ this part of the implementation is *NOT*
		       per the spec, because I want combine(wrt(x,y))=y
		       even in the case of y = foo/../bar
		       -->

		  <xsl:variable name="baseRest2"
			    select='substring($baseRest,
				 string-length($baseAuthority) + 1)'/>

		  <xsl:variable name="baseParent">
		    <xsl:call-template name="uri:path-parent">
		      <xsl:with-param name="path" select="$baseRest2"/>
		    </xsl:call-template>
		  </xsl:variable>

		  <xsl:variable name="path">
		    <xsl:call-template name="uri:follow-path">
		      <xsl:with-param name="start" select="$baseParent"/>
		      <xsl:with-param name="path" select="$rest2"/>
		    </xsl:call-template>
		  </xsl:variable>

		  <xsl:if test="$Debug"><xsl:message>
		    step 6 rel
		    rest2: [<xsl:value-of select="$rest2"/>]
		    baseRest2: [<xsl:value-of select="$baseRest2"/>]
		    baseParent: [<xsl:value-of select="$baseParent"/>]
		    path: [<xsl:value-of select="$path"/>]
		  </xsl:message></xsl:if>

		  <xsl:value-of select='concat($baseScheme, ":",
					       $baseAuthority,
					       $path,
					       $hashFragment)'/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:otherwise>
	  </xsl:choose>

        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="uri:split-scheme">
  <!-- from a URI reference -->
  <xsl:param name="ref"/>

  <xsl:variable name="scheme_"
		    select='substring-before($ref, ":")'/>
  <xsl:choose>
    <!-- test whether $scheme_ is a legal scheme name,
	 i.e. whether it starts with an alpha
	 and contains only alpha, digit, +, -, .
	 -->
    <xsl:when
      test='string-length($scheme_) > 0
            and contains($uri:alpha, substring($scheme_, 1, 1))
	    and string-length(translate(substring($scheme_, 2),
			                concat($uri:alpha, $uri:digit,
					       "+-."),
				        "")) = 0'>
	  <xsl:value-of select="$scheme_"/>
    </xsl:when>

    <xsl:otherwise>
      <xsl:value-of select='""'/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="uri:split-authority">
  <!-- from a URI reference that has had the fragment identifier
       and scheme removed -->
       <!-- cf 3.2. Authority Component -->

  <xsl:param name="ref"/>

  <xsl:choose>
    <xsl:when test='starts-with($ref, "//")'>
      <xsl:variable name="auth1" select='substring($ref, 3)'/>
      <xsl:variable name="auth2">
        <xsl:choose>
          <xsl:when test='contains($auth1, "?")'>
	    <xsl:value-of select='substring-before($auth1, "?")'/>
	  </xsl:when>
	  <xsl:otherwise><xsl:value-of select="$auth1"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>

      <xsl:variable name="auth3">
        <xsl:choose>
          <xsl:when test='contains($auth2, "/")'>
	    <xsl:value-of select='substring-before($auth1, "/")'/>
	  </xsl:when>
	  <xsl:otherwise><xsl:value-of select="$auth2"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>

      <xsl:value-of select='concat("//", $auth3)'/>
    </xsl:when>

    <xsl:otherwise>
      <xsl:value-of select='""'/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="uri:follow-path">
  <xsl:param name="start"/> <!-- doesn't end with / ; may be empty -->
  <xsl:param name="path"/> <!-- doesn't start with / -->

  <xsl:if test="$Debug"><xsl:message>
    follow-path
    start: [<xsl:value-of select="$start"/>]
    path: [<xsl:value-of select="$path"/>]
  </xsl:message></xsl:if>

  <xsl:choose>
    <xsl:when test='starts-with($path, "./")'>
      <xsl:call-template name="uri:follow-path">
        <xsl:with-param name="start" select="$start"/>
	<xsl:with-param name="path" select='substring($path, 3)'/>
      </xsl:call-template>
    </xsl:when>

    <xsl:when test='starts-with($path, "../")'>
      <xsl:call-template name="uri:follow-path">
        <xsl:with-param name="start">
	  <xsl:call-template name="uri:path-parent">
	    <xsl:with-param name="path" select="$start"/>
	  </xsl:call-template>
	</xsl:with-param>
	<xsl:with-param name="path" select='substring($path, 4)'/>
      </xsl:call-template>
    </xsl:when>

    <xsl:otherwise>
      <xsl:value-of select='concat($start, "/", $path)'/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="uri:path-parent">
  <xsl:param name="path"/>

  <xsl:if test="$Debug"><xsl:message>
    path parent
    path: [<xsl:value-of select="$path"/>]
  </xsl:message></xsl:if>

  <xsl:choose>
	      <!-- foo/bar/    => foo/bar    , return -->
    <xsl:when test='substring($path, string-length($path)) = "/"'>
      <xsl:value-of select='substring($path, 1, string-length($path)-1)'/>
    </xsl:when>

	      <!-- foo/bar/baz => foo/bar/ba , recur -->
	      <!-- foo/bar/ba  => foo/bar/b  , recur -->
	      <!-- foo/bar/b   => foo/bar/   , recur -->
    <xsl:when test='contains($path, "/")'>
      <xsl:call-template name="uri:path-parent">
        <xsl:with-param name="path"
		   select='substring($path, 1, string-length($path)-1)'/>
      </xsl:call-template>
    </xsl:when>

	      <!-- '' => '' -->
	      <!-- foo => '' -->
    <xsl:otherwise>
      <xsl:value-of select='""'/>
    </xsl:otherwise>

  </xsl:choose>

</xsl:template>


</xsl:transform>

