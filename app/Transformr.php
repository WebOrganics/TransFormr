<?php
/*
 * TransFormr Version: 1.2, Wednesday, 12th May 2010
 * Contact: Martin McEvoy info@weborganics.co.uk
 */
class Transformr
{
	public $tidy_option = '';
	public $use_curl = '';
	
 	function set_path()
	{
		$this->script_dir = realpath(dirname($_SERVER['SCRIPT_FILENAME']));
		$this->base_dir = realpath(dirname(__FILE__)); 
		$this->local_path = substr( $this->script_dir, strlen($this->base_dir));
		$this->install_path = $this->local_path
			? substr( dirname($_SERVER['SCRIPT_NAME']), 0, -strlen($this->local_path) )
			: dirname($_SERVER['SCRIPT_NAME']);
		if ($this->install_path == "/" || $this->install_path == "\\") 
			return "http://".$_SERVER['HTTP_HOST']."/";
		else 
			return "http://".$_SERVER['HTTP_HOST'].$this->install_path."/";
	}
	
	private function check_php_version($version ='', $name ='') 
	{
		$this->php_min_version = $version;
		$this->server_php_version = phpversion();
		$php_self = $this->server_php_version;
		$min_php = $this->php_min_version;
		$php_version = version_compare($this->server_php_version, $this->php_min_version, '>=');
		$upgrade_php = '<p>Sorry PHP Upgrade needed, <em>'.$name.'</em> requires PHP '.$min_php.' or newer. Your current PHP version is '.$php_self.'</p>';
		if (!$php_version) die("$upgrade_php");
	}
	
	function __construct() 
	{
		$this->path = $this->set_path();
		$this->url = isset($_GET['url']) ? str_replace('%23','#', trim($_GET['url'])) : '' ;
		$this->type = isset($_GET['type']) ? $_GET['type'] : '';
		$this->output = isset($_GET['output']) ? $_GET['output'] : 'rdf';
		$this->query = isset($_GET['q']) ? stripslashes($_GET["q"]) : '';
		$this->template = 'app/template/';
		$this->xsl = 'app/xsl/';
		$this->version = '1.2';
		$this->updated = array('Wednesday, 12th May 2010', '2010-05-12T21:15:00+01:00');
		$this->check_php_version('5.2.0', 'Transformr'); 
		$this->required = array('arc/ARC2', 'extension/class.hqr', 'extension/class.encoded');
		$this->a = $this->config_ns();
		ini_set('display_errors',  0 );
		header("X-Application: Transformr ".$this->version );
	}
	
	public function transform() 
	{
		foreach ( $this->required as $require ) {
			require_once($require.'.php');
		}
		return ($this->query !='') ? $this->json_query($this->query) : $this->transformr_types();
	}
	
	private function json_query($data) 
	{
		$data = json_decode(utf8_encode($data));
		
		!$data ? die('query not well formed please validate your query at <a href="http://www.jsonlint.com/">http://www.jsonlint.com/</a>') : $data;
		
		$this->url = $data->url;
		
		$this->type = $data->type;
		
		isset($data->output) ? $this->output = $data->output : null;
		
		return $this->transformr_types();
	}
	
	private function transformr_types() 
	{	
		if ($this->type) 
		{ 
			header("Cache-Control: no-cache, must-revalidate");
			header("Expires: -1");
		}
		switch($this->type)
		{
		case 'hcard':
			$file = $this->rand_filename('vcf');
			header("Content-type: text/x-vcard");
			header('Content-Disposition: attachment; filename="'.$file.'"');
			$xsl_filename = $this->xsl ."xhtml2vcard.xsl";
			return $this->transform_xsl($this->url, $xsl_filename);
		break;

		case 'hcard-rdf':
			$xsl_filename = $this->xsl ."hcard2rdf.xsl";
			$document = $this->transform_xsl($this->url, $xsl_filename);
			return $this->as_rdf($this->url, $document, $this->output);
		break;

		case 'hatom':
			header("Content-type: application/xml");
			$xsl_filename = $this->xsl ."hAtom2Atom.xsl";
			return $this->transform_xsl($this->url, $xsl_filename);
		break;

		case 'hatom-rss2':
			header("Content-type: application/rss+xml");
			$xsl_filename = $this->xsl ."hAtom2RSS2.xsl";
			return $this->transform_xsl($this->url, $xsl_filename);
		break;

		case 'geo':
			$file = $this->rand_filename('kml');
			header("Content-type: application/vnd.google-earth.kml+xml");
			header('Content-Disposition: attachment; filename="'.$file.'"');
			$xsl_filename = $this->xsl ."xhtml2kml.xsl";
			return $this->transform_xsl($this->url, $xsl_filename);
		break;

		case 'hcalendar':
			$file = $this->rand_filename('ics');
			header("Content-type: text/x-vcalendar");
			header('Content-Disposition: attachment; filename="'.$file.'"');
			$xsl_filename = $this->xsl ."xhtml2vcal.xsl";
			return $this->transform_xsl($this->url, $xsl_filename);
		break;

		case 'hcalendar-rdf':
			$xsl_filename = $this->xsl ."glean-hcal.xsl";
			$document = $this->transform_xsl($this->url, $xsl_filename);
			return $this->as_rdf($this->url, $document, $this->output);
		break;

		case 'hreview':
			$xsl_filename = $this->xsl ."hreview2rdfxml.xsl";
			$document = $this->transform_xsl($this->url, $xsl_filename);
			return $this->as_rdf($this->url, $document, $this->output);
		break;
		
		case 'xoxo-opml':
			$file = $this->rand_filename('opml');
			header("Content-type: text/x-opml");
			header('Content-Disposition: attachment; filename="'.$file.'"');
			$xsl_filename = $this->xsl ."xoxo2opml.xsl";
			return $this->transform_xsl($this->url, $xsl_filename);
		break;

		case 'haudio-rss':
			header("Content-type: application/xml");
			$xsl_filename = $this->xsl ."hAudioRSS2.xsl";
			return $this->transform_xsl($this->url, $xsl_filename);
		break;

		case 'mo-haudio':
			$xsl_filename = $this->xsl ."Mo-hAudio.xsl";
			$document = $this->transform_xsl($this->url, $xsl_filename);
			return $this->as_rdf($this->url, $document, $this->output);
		break;

		case 'haudio-xspf':
			$file = $this->rand_filename('xspf');
			header('Content-type: application/xspf+xml');
			header('Content-Disposition: attachment; filename="'.$file.'"');
			$xsl_filename = $this->xsl ."hAudioXSPF.xsl";
			return $this->transform_xsl($this->url, $xsl_filename);
		break;

		case 'hfoaf':
			$xsl_filename = $this->xsl ."hFoaF.xsl";
			$document = $this->transform_xsl($this->url, $xsl_filename);
			return $this->as_rdf($this->url, $document, $this->output);
		break;

		case 'ogp-rdf':
			$xsl_filename = $this->xsl ."OGPGRDDL.xsl";
			$document = $this->transform_xsl($this->url, $xsl_filename);
			return $this->as_rdf($this->url, $document, $this->output);
		break;

		case 'erdf':
			$xsl_filename = $this->xsl ."extract-rdf.xsl";
			$document = $this->transform_xsl($this->url, $xsl_filename);
			return $this->as_rdf($this->url, $document, $this->output);
		break;

		case 'rdfa':
			$xsl_filename = $this->xsl ."RDFa2RDFXML.xsl";
			$document = $this->transform_xsl($this->url, $xsl_filename);
			return $this->as_rdf($this->url, $document, $this->output);
		break;

		case 'detect':
			$xsl_filename = $this->xsl ."detect-uf.xsl";
			return $this->transform_xsl($this->url, $xsl_filename);
		break;
		
		case 'hcard2qrcode':
			return $this->return_qrcode($this->url);
		break;

		default:
			header("Content-Type: text/html; charset=UTF-8");
			include $this->template ."head.php";
			include $this->template ."content.php";
			include $this->template ."foot.php";
		break;
		}
	}
	
	protected function get_file_contents($url)
	{
		if ( $this->use_curl != '' ) {
		
			$cache = curl_init();
			curl_setopt($cache, CURLOPT_RETURNTRANSFER, true );
			curl_setopt($cache, CURLOPT_FOLLOWLOCATION, true );
			curl_setopt($cache, CURLOPT_URL, $url);
			curl_setopt($cache, CURLOPT_USERAGENT, 'Mozilla/5.0');
			$result = curl_exec($cache);
			curl_close($cache);
			return html_convert_entities($result);
		}
		else return html_convert_entities(file_get_contents($url));
	}
	
	protected function transform_xsl($url, $xsl_filename) 
	{
	if( strrchr($url, 'http://') ) {
		
		if (strrchr($url, '#')) $fragment = array_pop(explode('#', $url));
		
		$html = $this->get_file_contents($url);
		
		$dom = new DOMDocument('1.0');
		$dom->preserveWhiteSpace = true;
		$dom->formatOutput = true;
		
		$dom->loadXML($this->tidy_html($html, $url, $this->tidy_option));
		
		$title = $dom->getElementsByTagName('title')->item(0)->nodeValue;
		
		if (isset($fragment)) 
		{
			$dom->relaxNGValidateSource($this->valid_schema());
			$element = $dom->getElementById($fragment);
			$content = $dom->saveXML($element);
			$doc = $this->return_html_frag($content, $title);	
		} 
		else {
			$doc = $dom->saveXML();
		}
		
		if (!method_exists('xsltProcessor','transformToXML')) {
			die( "Sorry PHP xslt functions unavailable" );
		}
		else {
			$xslt = new xsltProcessor;
			$xslt->setParameter('','transformr', $this->path);
			$xslt->setParameter('','url', $url);
			$xslt->setParameter('','base-uri', $url);
			$xslt->setParameter('','doc-title', $title);
			$xslt->setParameter('','version', $this->version);
			$xslt->importStyleSheet(DomDocument::load($xsl_filename));
			
			if(!DomDocument::loadXML($doc)) return $this->error_location('invalidDoc');
			else return $xslt->transformToXML(DomDocument::loadXML($doc));
		}
	}
	elseif ($url == 'referer' && getenv("HTTP_REFERER") != '') {
		$referer = getenv("HTTP_REFERER");
		return $this->transform_xsl($referer, $xsl_filename);	
	}
	elseif (getenv("HTTP_REFERER") != '' && $url !='') {
		$referer = getenv("HTTP_REFERER");
		return $this->transform_xsl($referer.'#'.$url, $xsl_filename);	
	}
	else {
		return $this->error_location('noURL');
		exit;
	  }
	}
	
	private function return_qrcode($url)
	{
		$hqr = new hQR;
		include $this->template ."head.php";
		include $this->template ."content-qr.php";
	}

	private function toRDFa($triples) {
		ARC2::inc('RDFaSerializer');
		$rdfa = new ARC2_RDFaSerializer($this->a, $this);
		return ( isset($triples[0]) && isset($triples[0]['s']) ) ? $rdfa->getSerializedTriples($triples) : $rdfa->getSerializedIndex($triples);
	}
	
	protected function as_rdf($url, $document, $output) 
	{
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
	
	protected function tidy_html($html, $url, $tidy_option)
	{	
		if ($tidy_option == 'php' && !method_exists('tidy','cleanRepair') ) {
			die("Sorry PHP Tidy function does not exist, try tidy_option = 'online' ");
		}
		elseif ( $tidy_option == 'php') {
			$config = array(
				'doctype'                     => 'strict',
				'logical-emphasis'            => true,
				'output-xml'                  => true,
				'wrap'                        => 200
			);
			$tidy = new tidy;
			$tidy->parseString($html, $config, 'utf8');
			$tidy->cleanRepair();
			$result = !$tidy ? die("Sorry unable to tidy this document using php tidy") : $tidy;
		} 
		elseif ($tidy_option == 'online') {		
			$tidyURL = 'http://cgi.w3.org/cgi-bin/tidy?forceXML=on&docAddr='.$url;
			$tidy = $this->get_file_contents($tidyURL);
			$result = !$tidy ? die("Sorry online W3C tidy service unavailable") : $tidy;
		}
		else {
			die("sorry Unable to tidy this document");
		}
		return $result;	
	}
	
	protected function rand_filename($ext = '') 
	{
		return substr(md5(uniqid(rand())), 0, 8).'.'.$ext;
	}
	
	protected function config_ns() 
	{
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
		'ogp' => 'http://opengraphprotocol.org/schema/'
	);
	return array(
		'ns' => $ns, 
		'auto_extract' => 0, 
		'serializer_type_nodes' => 1, 
		'bnode_prefix' => 'gen'.substr(md5(uniqid(rand())), 0, 4) 
	  );
    }
	
	protected function valid_schema() 
	{	
		$valid = '<grammar xmlns="http://relaxng.org/ns/structure/1.0" datatypeLibrary="http://www.w3.org/2001/XMLSchema-datatypes">
		<start>
			<element>
				<anyName/>
				<ref name="xhtmlID"/>
			</element>
		</start>
		<define name="xhtmlID">
			<zeroOrMore>
				<choice>
					<element>
						<anyName/>
						<ref name="xhtmlID"/>
					</element>
					<attribute name="id">
						<data type="ID"/>
					</attribute>
					<zeroOrMore>
						<attribute><anyName/></attribute>
					</zeroOrMore>
					<text/>
				</choice>
			</zeroOrMore>
		</define>
		</grammar>';
		
		return $valid;
	}
	
	private function return_html_frag($content, $title) 
	{
	
		$result = <<<HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
	<title>$title</title>
</head>
	<body>
		$content
	</body>
</html>
HTML;
	
		return $result;
	}
	
	private function error_location($error = '') 
	{
	
		$exit = $this->path;
	
		$result = <<<ERR
<script language="text/javascript">
	<!-- 
		location.replace("$exit?error=$error");
	-->
</script>
ERR;

		return $result;
	}
 }
?>