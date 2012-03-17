# TransFormr version 2.5

TransFormr is a simple toolkit that uses PHP and XSLT for extracting and transforming microformats <http://microformats.org/>.

Microformats that are supported by this transformer are:

* hCard <http://microformats.org/wiki/hcard>.
* hCalendar <http://microformats.org/wiki/hcalendar>.
* hReview <http://microformats.org/wiki/hreview>.
* hAtom <http://microformats.org/wiki/hatom>.
* geo <http://microformats.org/wiki/geo>.
* hAudio <http://microformats.org/wiki/haudio>.
	
Microformats that are supported by this transformr but are classed as *Experimental* and should not be used in a production environment because they may be removed or updated at any time are:

* hMedia <http://microformats.org/wiki/hmedia>.
* XFN <http://gmpg.org/xfn/>
* rel-enclosure <http://microformats.org/wiki/rel-enclosure>
	
Non microformats supported by this transformer are:
	
* RDFa 1.0 + 1.1 @prefix @vocab <http://rdfa.info/>
* eRDF <http://research.talis.com/2005/erdf/wiki/Main/RdfInHtml>
* OGP ( Open Graph Protocol ) <http://opengraphprotocol.org/>
* Microdata <http://www.whatwg.org/specs/web-apps/current-work/multipage/microdata.html>
	
## Installation 

You must have PHP version 5.2.0 or higher with XSLT enabled to run TransFormr.

* Download the latest version of Transformr from <http://github.com/WebOrganics/TransFormr>.
* Unpack the entire contents of the file called WebOrganics-TransFormr-XXXXX to your webserver either into its own directory or the the root of your directory (dedicated transformers only). 
* Take a look at the settings in index.php and change to suit (everything should work fine without altering anything).
* If you plan to use the ARC2 store, enter your database, user, pass and hosts settings in /app/config.php  and check that the dump folder is writable by the webserver.
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

Experimental conversions are:

* hAudio => XSPF.
* hAudio => MO (Music Ontology).
* hAtom  => SIOC, rdfjson, ntriples, turtle, html ( microdata )  or RDFa. 
* hCard + XFN => FOAF, rdfjson, ntriples, turtle, html ( microdata )  or RDFa.
	
Other non microformat conversions

* OGP ( Facebook Open Graph Protocol ) => RDF, rdfjson, ntriples, turtle, html ( microdata )  or RDFa.
* RDFa => RDF, rdfjson, ntriples, turtle, or html ( microdata ).
* eRDF => RDF, rdfjson, ntriples, turtle, html ( microdata )  or RDFa.
* Microdata => JSON.

## Transformr Conversion urls

### RDF output Options: 

	ntriples, rdfa, turtle, rdfjson, and html (microdata)
	
### Transformation Types are :

detect, hcard, hcard-rdf, hatom, hatom-rss2, geo, hcalendar, hcalendar-rdf, hreview, haudio-rss, mo-haudio, haudio-xspf, hfoaf, mrss, ogp-rdf, erdf, rdfa, hcard2qrcode and hatom-sioc.

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

### By JSON Query.

Queries are formed using three properties, url (url of the webpage ) , type ( conversion type ) and output (output type), example 

* index.php?q={ "url" : "http://somewebsite.com/", "type" : "hcard-rdf", "output" : "ntriples" } 

The output property is optional and may be omitted from a Query, example

* index.php?q={ "url" : "http://somewebsite.com/", "type" : "hcard" }

You can also use describe queries on the ARC2 store ( if enabled ), this will return a document already extracted to the store, example

* index.php?q={"describe": {"url": "http://somewebsite.com/","type": "hatom-sioc","output": "ntriples"}}  

### By SPARQL Query.

When you extract RDF using Transformr and the arc2 store is enabled, you can query the Transformr using the sparql endpoint, example

* sparql/endpoint?query=CONSTRUCT { ?s ?p ?o } WHERE { GRAPH </type/http://someurl.com/> { ?s ?p ?o } }

All graphs are relative to the store, "type" is the type of RDF you extracted e.g hfoaf, rdfa ... etc, and the url of the page you extracted.

### By Direct input.

You can also transform a fragment of html by direct input, this is intended to be used for testing you markup before publishing it live.

## Future releases

Work is in progress supporting the Species Microformat <http://microformats.org/wiki/species-strawman-01>, hProduct <http://microformats.org/wiki/hproduct> + hCard Microformat to Good Relations and Data vocab transformation for Rich Snippets <http://www.google.com/support/webmasters/bin/answer.py?hl=en&answer=99170>. 

## Notes

* 2.5 Added microdata to JSON transformation.
* 2.4 Added value-title parsing for all microformats.
* 2.3 Transformr is now Faster due to new caching action. Added support for Transforming by direct input, Some XSLT bugs fixed.
* 2.2 Transform processes base@href for all xslt transformations, AR2 RDFTransformrPlugin and EndpointTemplatPlugin support around 350 namespaces, 
  list is automaticaly downloaded from <http://prefix.cc/>, improved config.php .
* 2.1 Endpoint has new template using ARC2_EndpointTemplatPlugin, and DELETE FROM <...> functionality. 
* 2.0 adds ARC2 storage and hAtom2SIOC transformation. 
* 1.3 fixes @prefix and @vocab support for RDFa plus one or two minor bugs.
* 1.2.1 Adds @prefix and @vocab support to RDFa2RDFXML.xsl.
* 1.2 Implements JSON Query.
* 1.1 some bugs fixed, new hcard 2 qrcode api
* 1.0 New code, added some configurations, ogp-rdf transformation added, xoxo-opml transformation added, updated version of ARC2 2010-04-26
* 0.6.2 updated ARC2_Transformr, incudes a non-hacked version of ARC2.  
* 0.6.1 Most RDF including RDFa conversions are parsed by ARC2 ( included ) http://arc.semsol.org/
* 0.5.1 Transformr also supports Fragment parsing for individual microformats.

## Credits

### Many thanks to:

* Matthias Pfefferle ( <http://microform.at/> ) 
* Ben Ward ( X2V, <http://github.com/BenWard/x2v> )
* Benjamin Nowack ( ARC2, <http://arc.semsol.org/> )
* Lin Clark (MicrodataPHP, <https://github.com/linclark/MicrodataPHP>)
* Fabien Gandon ( OGPGRDDL.xsl and RDFa2RDFXML.xsl, <http://fabien.info/>)
* Richard Cyganiak ( <http://prefix.cc/>)