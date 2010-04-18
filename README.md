= TransFormr version 0.6.0 =  

TransFormr is a simple toolkit that uses PHP and XSLT for extracting and transforming microformats http://microformats.org/.

Microformats that are supported by this transformer are:

	* hCard http://microformats.org/wiki/hcard.
	* hCalendar http://microformats.org/wiki/hcalendar.
	* hReview http://microformats.org/wiki/hreview.
	* hAtom http://microformats.org/wiki/hatom.
	* geo http://microformats.org/wiki/geo.
	* hAudio http://microformats.org/wiki/haudio.
	
Microformats that are supported by this transformr but are classed as *Experimental* and should not be used in a production environment because they may be removed or updated at any time are:

	* hMedia http://microformats.org/wiki/hmedia.
	* XFN http://gmpg.org/xfn/
	* rel-enclosure http://microformats.org/wiki/rel-enclosure
	
Non microformats supported by this transformer are:
	
	* RDFa http://rdfa.info/
	* eRDF http://research.talis.com/2005/erdf/wiki/Main/RdfInHtml
	* JSON Dataset http://weborganics.co.uk/dataset/
	
== Installation ==

You must have PHP version 5.2.0 or higher with XSLT enabled to run TransFormr.

	* Download the latest version of Transformr from http://github.com/WebOrganics/TransFormr.
	* Unpack the entire contents of the file called WebOrganics-TransFormr-XXXXX to your webserver either into its own directory or the the root of your directory (dedicated transformers only). 
	* Surf your way to wherever you unpacked your file eg: http://example.com/transformr/ it works ( and looks ) exactly the same as the webservice available at http://transformr.co.uk/.
	* Enter a url, Have fun transforming some microformats ;)
	
== Conversions ==

Main conversions are:

	* Detect => Detect all.
	* hCard => vCard (.vcf), RDF, rdfjson, ntriples, turtle or RDFa.
	* hCalendar => iCal (.ics), RDF, rdfjson, ntriples, turtle or RDFa.
	* hAtom => Atom.
	* hAtom => RSS2 + rel-enclosure.
	* hReview => RDF, rdfjson, ntriples, turtle or RDFa.
	* Geo => KML.
	* hAudio => RSS2.

Experimental conversions are:

	* hAudio => XSPF.
	* hAtom + hMedia => MRSS.
	* hCard + XFN => FOAF, rdfjson, ntriples, turtle or RDFa.
	
Other non microformat conversions

	* RDFa => RDF, rdfjson, ntriples or turtle
	* eRDF => RDF, rdfjson, ntriples, turtle or RDFa.
	* JSON Dataset => RDF, rdfjson, ntriples, turtle or RDFa.
	
== Notes ==

This Version of transformr also supports Fragment parsing for individual microformats.

= Credits =

Many thanks to:

	* Brian Suda (X2V)
	* Fabien Gandon (RDFa 2 RDF)
	* Luke Arno, Benjamin Carlyle and Robert Bachmann ( hAtom to Atom)
	* Dan Connoly, inspiration for FOAF conversion.