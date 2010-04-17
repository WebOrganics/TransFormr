<?php
class ARC2_Transformr extends Transformr
{
	function __construct()
	{
		include_once("arc/ARC2.php");
	}
	
	public function Parse($url, $document, $output)
	{
	$this->__construct();
	
	$conf = ARC2::return_ns();
	$parser = ARC2::getRDFParser($conf);
	$parser->parse($url, $document);
	$triples = $parser->getTriples();
		
		switch ($output) 
		{
			case 'ntriples':
				$file = $this->rand_filename($ext = 'nt');
				header("Content-type: text/plain");
				header("Content-Disposition: inline; filename=".$file);
				$result = $parser->toNTriples($triples); 
			break;
			
			case 'turtle':
				$file = $this->rand_filename($ext = 'ttl');
				header("Content-type: text/turtle");
				header("Content-Disposition: inline; filename=".$file);
				$result = $parser->toTurtle($triples);
			break;
			
			case 'rdfjson':	
				$file = $this->rand_filename($ext = 'json');
				header("Content-type: application/json");
				header("Content-Disposition: inline; filename=".$file);
				$result = $parser->toRDFJSON($triples);
			break;
			
			case 'rdfa':	
				$file = $this->rand_filename($ext = 'html');
				header("Content-type: text/html");
				header("Content-Disposition: inline; filename=".$file);
				$result = $parser->toRDFa($triples);
			break;
			
			case 'rdf':	
				$file = $this->rand_filename($ext = 'rdf');
				header("Content-type: application/rdf+xml");
				header("Content-Disposition: inline; filename=".$file);
				$result = $parser->toRDFSS($triples);
			break;
		}
		return $result;
	}
	
	protected function rand_filename($ext)
	{
		return preg_replace("/([0-9])/e","chr((\\1+112))",mt_rand(100000,999999)).".".$ext;
	}

}
?>
