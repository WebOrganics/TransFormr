<?php
/*
ARC2 RDF Tranformr Plugin

author:   Martin McEvoy
version:  2010-06-13
homepage: http://github.com/WebOrganics/TransFormr
license:  http://arc.semsol.org/license
*/

ARC2::inc('Class');

class ARC2_RDFTranformrPlugin extends ARC2_Class {

	
	function __construct($a = '', &$caller) {
		
		parent::__construct($a, $caller);
		
		$this->use_store = $a['use_store'];
		$this->store_size = $a['store_size'];
		$this->reset_tables = $a['reset_tables']; 
		$this->path = $a['store_root'];
		$this->dump_location = $a['dump_location'];
		$this->type = $a['document_type']; 
		$this->backup_type = $a['backup_type'];
		$this->ext = $a['extension'];
		$this->a['ns'] = $this->loadPrefixes();
	}
  
	function ARC2_RDFTranformrPlugin($a = '', &$caller) {
		$this->__construct($a, $caller);
	}

	function __init() {
		parent::__init();
	}
	
	/*  */
	
	function loadPrefixes()
	{
		$prefixes = dirname(__FILE__).'/namespaces.txt';
		$lines = file($prefixes, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINE);
		$ns = array();
		if ( rand(1, 200) == 1) 
		{
			$nsdoc = "http://prefix.cc/popular/all.file.txt";
			$this->writePrefixes($prefixes, $nsdoc);
		}
		foreach ( $lines as $line ) 
		{
			$prefix = explode("	", $line);
			if( $this->ns_exists($prefix['1'], $ns) == false ) // ignore dupe urls 
			{
				$ns[$prefix['0']] = $prefix['1'];
			}
		}
		return $ns;
	}
	
	function ns_exists($value, $namespace) 
	{
		foreach ($namespace as $prefix => $url) 
		{
			if ($url == $value) return true;
		}
		return false;
	}
	
	function writePrefixes($prefixes='', $nsdoc)
	{
		$nsdoc = implode('', file($nsdoc));
		if(is_null($nsdoc)) {
			error_log('Could not write namespace prefixes to ' . realpath($prefixes), 0);
		} else {
			$doc = trim($nsdoc) . PHP_EOL;
			$doc = preg_replace('/#(.*)\?/', ' ', $doc);
			$document = preg_replace('/\s\s+/', "\r\n", trim($doc));
			if (!$file = @fopen($prefixes, 'w')) 
				error_log('Could not open ' . realpath($prefixes), 0);
			else { 
				fwrite($file, $document);
				@fclose($file);
				return true;
			}
		}
		return false;
	}
	
	function construct_url($url ='', $type='', $output) 
	{
		$store = ARC2::getStore($this->a);
		if ($type =='') $query = $store->query("CONSTRUCT { ?s ?p ?o } WHERE { GRAPH ?g { ?s ?p ?o } FILTER(REGEX(?g, \"". $url ."\")) }");
		else $query = $store->query("DESCRIBE ?s FROM </" . $type ."/". $url ."> WHERE { ?s ?p ?o. }");
		$parser = ARC2::getRDFParser($this->a);
		$document = $parser->toTurtle($query['result']);
		return $this->to_rdf($url, $document, $output, 1);
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
		if ($this->backup_type != '') 
			$this->saveBackup($this->dump_location. substr(md5(uniqid(rand())), 0, 8) .'.'.$this->ext, $this->backup_type, 'CONSTRUCT { ?s ?p ?o . } WHERE { GRAPH ?g { ?s ?p ?o . } } OFFSET '.$offset);
		else 
			$store->createBackup($this->dump_location. substr(md5(uniqid(rand())), 0, 8) .'.xml', 'SELECT * WHERE { GRAPH ?g { ?s ?p ?o . } } OFFSET '.$offset);
		$store->query("DELETE CONSTRUCT { ?s ?p ?o . } WHERE { GRAPH ?g { ?s ?p ?o . } } OFFSET ".$offset);
		$store->optimizeTables();
	}
	
	function saveBackup($path, $type ='', $q = '') 
	{
		$store = ARC2::getStore($this->a);
		$parser = ARC2::getRDFParser($this->a);
		$query = $store->query($q);
		if ($type == 'turtle') $document = $parser->toTurtle($query['result']);
		elseif ($type == 'ntriples') $document = $parser->toNTriples($query['result']);
		elseif ($type == 'rdf') $document = $parser->toRDFXML($query['result']);
		if (!$fp = @fopen($path, 'w')) return $this->addError('Could not create backup file at ' . realpath($path));
		else { 
			fwrite($fp, $document);
			@fclose($fp);
		}
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
	
	function semhtml($url, $output, $type='') 
	{
		$parser = ARC2::getSemHTMLParser($this->a);
		$parser->parse($url);
		$parser->extractRDF($type);
		$triples = $parser->getTriples();
		$document = $parser->toTurtle($triples);
		return $this->to_rdf($url, $document, $output);
	}

	private function toRDFa($triples) 
	{
		ARC2::inc('RDFaSerializer');
		$rdfa = new ARC2_RDFaSerializer($this->a, $this);
		return ( isset($triples[0]) && isset($triples[0]['s']) ) ? $rdfa->getSerializedTriples($triples) : $rdfa->getSerializedIndex($triples);
	}
	
	function to_rdf($url, $document, $output, $store ='') 
	{
		$parser = ARC2::getRDFParser($this->a);
		$parser->parse($url, $document);
		$triples = $parser->getTriples();
		if ( $this->use_store == 1 && $store == '' ) $this->store_rdf($url, $parser->toTurtle($triples));
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