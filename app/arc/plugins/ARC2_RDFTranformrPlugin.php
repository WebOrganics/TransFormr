<?php
/*
ARC2 RDF Tranformr Plugin

author:   Martin McEvoy
version:  2010-06-04
homepage: http://github.com/WebOrganics/TransFormr
license:  http://arc.semsol.org/license

*/

ARC2::inc('Class');

class ARC2_RDFTranformrPlugin extends ARC2_Class {

	
	function __construct($a = '', &$caller) {
		
		parent::__construct($a, $caller);
		
		$this->use_store = $a['use_store']; // 0 = false|1 = true 
		$this->store_size = $a['store_size']; // in mb eg: 99.00
		$this->reset_tables = $a['reset_tables']; // 0 = false|1 = true 
		$this->dump_location = $a['dump_location']; // folder to dump data to
		$this->path = $a['store_path']; // host url eg http://somehost.com/
		$this->type = $a['document_type']; // hfoaf, hcard-rdf ... etc
	}
  
	function ARC2_RDFTranformrPlugin($a = '', &$caller) {
		$this->__construct($a, $caller);
	}

	function __init() {
		parent::__init();
	}
	
	/*  */
	
	function construct_url($url ='', $type='', $output) 
	{
		$store = ARC2::getStore($this->a);
		if ($type =='') $query = $store->query("CONSTRUCT { ?s ?p ?o } WHERE { GRAPH ?g { ?s ?p ?o } FILTER(REGEX(?g, \"". $url ."\")) }");
		else $query = $store->query("DESCRIBE ?s FROM </" . $type ."/". $url ."> WHERE { ?s ?p ?o. }");
		$parser = ARC2::getRDFParser($this->a);
		$document = $parser->toTurtle($query['result']);
		return $this->to_rdf($url, $document, $output, $this->use_store = 0);
	}
	
	function count_triples() 
	{
		$store = ARC2::getStore($this->a);
		$query = $store->query("SELECT count(*) AS ?count WHERE { GRAPH ?g { ?s ?p ?o .} }");
		$rows = $query["result"]["rows"];
		foreach ($rows as $row) {
			$count = $row["count"];
		}
		return $count;
	}
	

	function store_dump() 
	{
		$store = ARC2::getStore($this->a);
		$count = $this->count_triples();
		$offset = round($count/4*3);
		$store->createBackup($this->dump_location. substr(md5(uniqid(rand())), 0, 8) .'.xml', 'SELECT * WHERE { GRAPH ?g { ?s ?p ?o . } } OFFSET '.$offset);
		$store->query("DELETE CONSTRUCT { ?s ?p ?o . } WHERE { GRAPH ?g { ?s ?p ?o . } } OFFSET ".$offset);
		$store->optimizeTables();
	}

	function get_store_size() 
	{
		$store = ARC2::getStore($this->a);
		$result = mysql_query('SHOW TABLE STATUS', $store->getDBCon());
		while($row = mysql_fetch_array($result)) {
			$total = $row['Data_length']+$row['Index_length'];
		}
		$store->closeDBCon();
		
		return round($total/1048576, 2);
	}
	
	function store_rdf($url, $triples) 
	{
		$store = ARC2::getStore($this->a);
		if (!$store->isSetUp()) $store->setUp();
		if ($this->reset_tables == 1) $store->reset();
		if (rand(1, 50) == 1 && $this->store_size != '' ) {
			if ( $this->store_size < $this->get_store_size() ) $this->store_dump();
		}
		$store->delete('', $this->path .$this->type .'/' .$url); 
		$store->insert($triples, '/' .$this->type .'/' .$url, $keep_bnode_ids = 1);
	}

	private function toRDFa($triples) {
		ARC2::inc('RDFaSerializer');
		$rdfa = new ARC2_RDFaSerializer($this->a, $this);
		return ( isset($triples[0]) && isset($triples[0]['s']) ) ? $rdfa->getSerializedTriples($triples) : $rdfa->getSerializedIndex($triples);
	}
	
	function to_rdf($url, $document, $output) 
	{
		$parser = ARC2::getRDFParser($this->a);
		$parser->parse($url, $document);
		$triples = $parser->getTriples();
		if ( $this->use_store == 1 ) $this->store_rdf($url, $parser->toTurtle($triples));
		
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
			
			case 'rdf':	
				$file = $this->rand_filename('rdf');
				header("Content-type: application/rdf+xml");
				header("Content-Disposition: inline; filename=".$file);
				$result = $parser->toRDFXML($triples);
			break;
			
			case 'html':	
				$file = $this->rand_filename('html');
				header("Content-type: text/html");
				header("Content-Disposition: inline; filename=".$file);
				$result = $parser->toHTML($triples);
			break;
			
			case 'rdfa':	
				$file = $this->rand_filename('html');
				header("Content-type: text/html");
				header("Content-Disposition: inline; filename=".$file);
				$result = $this->toRDFa($triples);
			break;
		}
		return $result;
	}
	
	private function rand_filename($ext = '') 
	{
		return substr(md5(uniqid(rand())), 0, 8).'.'.$ext;
	}
	
	/* */
}
?>