<?php
class ARC2_Transformr extends Transformr
{
	function __construct() {
	
		parent::__construct();
		$this->a = $this->config_ns();
	}
	
	function __init() {
		parent::__init();
	}

	public function get_semhtml($url, $output, $type) {
	
		$parser = ARC2::getSemHTMLParser($this->a);
		$parser->parse($url);
		$parser->extractRDF($type);
		$triples = $parser->getTriples();
		$document = $parser->toRDFXML($triples);
		return $this->parse_rdf($url, $document, $output);
	}
	
	function parse_rdf($url, $document, $output) {
	
	$parser = ARC2::getRDFParser($this->a);
	$parser->parse($url, $document);
	$triples = $parser->getTriples();
		
		switch ($output) 
		{
			case 'ntriples':
				$file = $this->rand_filename('nt');
				header("Content-type: text/plain");
				header("Content-Disposition: inline; filename=".$file);
				$result = $parser->toNTriples($triples); 
			break;
			
			case 'turtle':
				$file = $this->rand_filename('ttl');
				header("Content-type: text/turtle");
				header("Content-Disposition: inline; filename=".$file);
				$result = $parser->toTurtle($triples);
			break;
			
			case 'rdfjson':	
				$file = $this->rand_filename('json');
				header("Content-type: application/json");
				header("Content-Disposition: inline; filename=".$file);
				$result = $parser->toRDFJSON($triples);
			break;
			
			case 'rdfa':	
				$file = $this->rand_filename('html');
				header("Content-type: text/html");
				header("Content-Disposition: inline; filename=".$file);
				$result = $this->toRDFa($triples);
			break;
			
			case 'rdf':	
				$file = $this->rand_filename('rdf');
				header("Content-type: application/rdf+xml");
				header("Content-Disposition: inline; filename=".$file);
				$result = $parser->toRDFXML($triples);
			break;
		}
		return $result;
	}
	
	function config_ns() {
	
	$ns = array(
		'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
		'rdfs' => 'http://www.w3.org/2000/01/rdf-schema#',
		'owl' => 'http://www.w3.org/2002/07/owl#',
		'xsd' => 'http://www.w3.org/2001/XMLSchema#',
		'foaf' => 'http://xmlns.com/foaf/0.1/',
		'dc' => 'http://purl.org/dc/elements/1.1/',
		'dc_terms' => 'http://purl.org/dc/terms/',
		'dc_type' => 'http://purl.org/dc/dcmitype/',
		'rss' => 'http://purl.org/rss/1.0/',
		'taxo' => 'http://purl.org/rss/1.0/modules/taxonomy/',
		'content' => 'http://purl.org/rss/1.0/modules/content/',
		'sy' => 'http://purl.org/rss/1.0/modules/syndication/',
		'cal' => 'http://www.w3.org/2002/12/cal/ical#',
		'sioc' => 'http://rdfs.org/sioc/ns#',
		'sioct' => 'http://rdfs.org/sioc/types#',
		'doap' => 'http://usefulinc.com/ns/doap#',
		'gr' => 'http://purl.org/goodrelations/v1#',
		'geo' => 'http://www.w3.org/2003/01/geo/wgs84_pos#',
		'gv' => 'http://data-vocabulary.org/',
		'wot' => 'http://xmlns.com/wot/0.1/',
		'mo' => 'http://purl.org/ontology/mo/',
		'frbr' => 'http://purl.org/vocab/frbr/core#',
		'vs' => 'http://www.w3.org/2003/06/sw-vocab-status/ns#',
		'tl' => 'http://purl.org/NET/c4dm/timeline.owl#',
		'time' => 'http://www.w3.org/2006/time#',
		'contact' => 'http://www.w3.org/2000/10/swap/pim/contact#',
		'bio' => 'http://vocab.org/bio/0.1/',
		'rel' => 'http://purl.org/vocab/relationship/',
		'rev' => 'http://purl.org/stuff/rev#',
		'voc' => 'http://webns.net/mvcb/',
		'air' => 'http://www.daml.org/2001/10/html/airport-ont#',
		'aff' => 'http://purl.org/vocab/affiliations/0.1/',
		'cc' => 'http://creativecommons.org/ns#',
		'money' => 'http://www.purl.org/net/rdf-money/',
		'media' => 'http://purl.org/microformat/hmedia/',
		'audio' => 'http://purl.org/net/haudio#',
		'xhv' => 'http://www.w3.org/1999/xhtml/vocab#',
		'xfn' => 'http://gmpg.org/xfn/11#',
		'dbp' => ' http://dbpedia.org/property/',
		'dbpr' => 'http://dbpedia.org/resource/',
		'talk' => 'http://www.w3.org/2004/08/Presentations.owl#',
		'doc' => 'http://www.w3.org/2000/10/swap/pim/doc#',
		'act' => 'http://www.w3.org/2001/sw/',
		'org' => 'http://www.w3.org/2001/04/roadmap/org#',
		'vc' => 'http://www.w3.org/2001/vcard-rdf/3.0#',
		'vcard' => 'http://www.w3.org/2006/vcard/ns#',
		'bibo' => 'http://purl.org/ontology/bibo/',
		'mf' => 'http://poshrdf.org/ns/mf#',
		'posh' => 'http://poshrdf.org/ns/posh/',
		'label' => 'http://www.w3.org/2004/12/q/contentlabel#',
		'icra' => 'http://www.icra.org/rdfs/vocabularyv03#',
		'uri' => 'http://www.w3.org/2006/uri#',
	);
		return array(
			'ns' => $ns, 
			'auto_extract' => 0, 
			'serializer_type_nodes' => 1, 
			'bnode_prefix' => 'genid'.substr(md5(uniqid(rand())), 0, 4) 
		);
    }
	
 	function rand_filename($ext = '') {
		return preg_replace("/([0-9])/e","chr((\\1+112))",mt_rand(100000,999999)).".".$ext;
	}
	
	function toRDFa($triples) {
		ARC2::inc('RDFaSerializer');
		$rdfa = new ARC2_RDFaSerializer($this->a, $this);
		return (isset($triples[0]) && isset($triples[0]['s'])) ? $rdfa->getSerializedTriples($triples) : $rdfa->getSerializedIndex($triples);
	}
	
    function this_document_query($url = '') {
		$htmlquery = new HTMLQuery;
		return $htmlquery->this_document($url);
	}
}
?>
