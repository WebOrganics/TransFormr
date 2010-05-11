# TransFormr version 1.1

TransFormr is a simple toolkit that uses PHP and XSLT for extracting and transforming microformats http://microformats.org/.

Microformats that are supported by this transformer are:

* hCard http://microformats.org/wiki/hcard.
* hCalendar http://microformats.org/wiki/hcalendar.
* hReview http://microformats.org/wiki/hreview.
* hAtom http://microformats.org/wiki/hatom.
* geo http://microformats.org/wiki/geo.
* hAudio http://microformats.org/wiki/haudio.
* XOXO http://microformats.org/wiki/xoxo.
	
Microformats that are supported by this transformr but are classed as *Experimental* and should not be used in a production environment because they may be removed or updated at any time are:

* hMedia http://microformats.org/wiki/hmedia.
* XFN http://gmpg.org/xfn/
* rel-enclosure http://microformats.org/wiki/rel-enclosure
	
Non microformats supported by this transformer are:
	
* RDFa http://rdfa.info/
* eRDF http://research.talis.com/2005/erdf/wiki/Main/RdfInHtml
* OGP ( Open Graph Protocol ) http://opengraphprotocol.org/
	
## Installation 

You must have PHP version 5.2.0 or higher with XSLT enabled to run TransFormr.

* Download the latest version of Transformr from http://github.com/WebOrganics/TransFormr.
* Unpack the entire contents of the file called WebOrganics-TransFormr-XXXXX to your webserver either into its own directory or the the root of your directory (dedicated transformers only). 
* Surf your way to wherever you unpacked your file eg: http://example.com/transformr/ .
* Enter a url, Have fun transforming some microformats ;)
	
## Conversions

Main conversions are:

* Detect => Detect all.
* hCard => vCard (.vcf), RDF, rdfjson, ntriples, turtle, html ( microdata )  or RDFa.
* hCalendar => iCal (.ics), RDF, rdfjson, ntriples, turtle, html ( microdata )  or RDFa.
* hAtom => Atom.
* hAtom + rel-enclosure => RSS2.
* hReview => RDF, rdfjson, ntriples, turtle, html ( microdata )  or RDFa.
* Geo => KML.
* hAudio => RSS2.
* XOXO => OPML.

Experimental conversions are:

* hAudio => XSPF.
* hAtom + hMedia => MRSS.
* hCard + XFN => FOAF, rdfjson, ntriples, turtle, html ( microdata )  or RDFa.
* All Microformats => RDF, rdfjson, ntriples, turtle, html ( microdata )  or RDFa.
	
Other non microformat conversions

* OGP ( Facebook Open Graph Protocol ) => RDF, rdfjson, ntriples, turtle, html ( microdata )  or RDFa.
* RDFa => RDF, rdfjson, ntriples, turtle, or html ( microdata ).
* eRDF => RDF, rdfjson, ntriples, turtle, html ( microdata )  or RDFa.

## Transformr Conversion urls

### Types are :

detect, hcard, hcard-rdf, hatom, hatom-rss2, geo, hcalendar, hcalendar-rdf, hreview, xoxo-opml, haudio-rss, mo-haudio, haudio-xspf, hfoaf, mrss, ogp-rdf, erdf, rdfa and hcard2qrcode.

#### Non RDF conversions,

* index.php?type=(type)&url=http://(your page)

#### For all RDF conversions

* index.php?type=(type)&output=(ntriples|rdfa|turtle|rdfjson|html)&url=http://(your page)

### Apache Clean URLs

#### Non RDF conversions,

* http://[transformr]/[type]/http://[your page] ( transforms a whole page )
* http://[transformr]/[type]/referer ( transforms from refering url )
* http://[transformr]/[type]/[your fragment] ( transforms from refering html id )

#### For all RDF conversions

* http://[transformr]/[type]/(ntriples|rdfa|turtle|rdfjson|html)/http://[your page]

## Notes

* 1.1 some bugs fixed, new hcard 2 qrcode api
* 1.0 New code, added some configurations, ogp-rdf transformation added, xoxo-opml transformation added, updated version of ARC2 2010-04-26
* 0.6.2 updated ARC2_Transformr, incudes a non-hacked version of ARC2.  
* 0.6.1 Most RDF including RDFa conversions are parsed by ARC2 ( included ) http://arc.semsol.org/
* 0.5.1 Transformr also supports Fragment parsing for individual microformats.

## Credits

### Many thanks to:

* Matthias Pfefferle ( microform.at ) 
* Fabien Gandon ( Facebook Open Graph Protocol, OGPGRDDL.xsl )
* Brian Suda ( X2V, hcard, hcalendar, hreview, geo )
* Benjamin Nowack ( ARC2 rdf parsing and translations )
* Luke Arno, Benjamin Carlyle and Robert Bachmann ( hAtom to Atom )
* Norman Walsh ( hCard 2 RDF conversion )