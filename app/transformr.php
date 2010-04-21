<?php
/*
 * TransFormr Version: 0.6.1, Wednesday, 21st April 2010
 * Contact: Martin McEvoy info@weborganics.co.uk
 */

class Transformr
{
 	public function set_path()
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
	
	function __construct() {
	
	$this->php_min_version = '5.2.0';
	$this->server_php_version = phpversion();
	
	$php_self = $this->server_php_version;
	$min_php = $this->php_min_version;
	$php_version = version_compare($this->server_php_version, $this->php_min_version, '>=');
	$upgrade_php = '<p>Sorry PHP Upgrade needed, <em>Transformr</em> requires PHP '.$min_php.' or newer. Your current PHP version is '.$php_self.'</p>';
	
	if (!$php_version) {
		echo $upgrade_php;
		break;
	}
	$this->path = $this->set_path();
	$this->type = $_GET['type'];
	$this->url = $_GET['url'];
	$this->template = 'template/';
	$this->xsl = 'xsl/';
	$this->version = '0.6.1';
	$this->updated = 'Wednesday, 21st April 2010';
	$this->required = array('ARC2_Transformr', 'Dataset_Transformr', 'Transformr_Types');
	
	header("X-Application: Transformr ".$this->version );
	ini_set('html_errors', 0); 
	ini_set('display_errors', 0); // set this to 1 to debug errors
	}
	
	function __init() {
		$this->__construct();
	}
	
	public function transform() {	
	
	foreach ( $this->required as $require ) {
		require_once($require.'.php');
	}
	$rdfparser = new ARC2_Transformr;
	$htmlquery = new HTMLQuery;
		
	if ($arc2_parse == true) {
	
		if (isset($_GET['output'])) $output = $_GET['output'];
		else $output = 'rdf';
		if ($this->type == "rdfa") return $rdfparser->get_semhtml($this->url, $output, $type = 'rdfa');
		elseif ($this->type == "microformats") return $rdfparser->get_semhtml($this->url, $output, $type = 'microformats');
		else $document = $this->transform_xsl($this->url, $xsl_filename);
		if (isset($document)) return $rdfparser->Parse($this->url, $document, $output);
	}	
	elseif ($this->type == "dataset") return $htmlquery->this_document($this->url);
	else return $this->transform_xsl($this->url, $xsl_filename);
	}
	
	protected function transform_xsl($url, $xsl_filename) {
	
	if( strrchr($url, 'http://') ) {
		
		$html = file_get_contents($url, FALSE, NULL, 0, 2597152);

		if (strrchr($url, 'docAddr=')) $url = array_pop(explode('docAddr=', $url));
		if (strrchr($url, '#')) $frag_id = array_pop(explode('#', $url));
		
		$dom = new DOMDocument('1.0');
		$dom->preserveWhiteSpace = true;
		$dom->formatOutput = true;
		
		if (!$dom->loadXML($html)) {
		
			# try local tidy function first
			if (method_exists(new tidy,'parseString'))
			{
				$config = array(
					'doctype'                     => 'strict',
					'logical-emphasis'            => true,
					'output-xhtml'                => true,
					'wrap'                        => 200
				);		
				$tidy = new tidy;
				$tidy->parseString($html, $config, 'utf8');
				$tidy->cleanRepair();
			} 
			# or use w3c online tidy service
			else {
				$tidyURL = 'http://cgi.w3.org/cgi-bin/tidy?forceXML=on&docAddr='.$url;
				$tidy = file_get_contents($tidyURL, FALSE, NULL, 0, 2597152);
			}
		}
		
		if (isset($tidy)) $dom->loadXML($tidy);
		else $dom->loadXML($html);
		
		$title = $dom->getElementsByTagName('title')->item(0)->nodeValue;
		
		if (isset($frag_id)) 
		{
			$dom->relaxNGValidateSource($this->schema());
			$element = $dom->getElementById($frag_id);
			$content = $dom->saveXML($element);
			include( 'HTML_Fragment.php' );	
		} 
		else {
			$doc = $dom->saveXML();
		}
		
		$xslt = new xsltProcessor;
		$xslt->setParameter('','transformr', $this->path);
		$xslt->setParameter('','url', $url);
		$xslt->setParameter('','base-uri', $url);
		$xslt->setParameter('','doc-title', $title);
		$xslt->setParameter('','version', $this->version);
		$xslt->importStyleSheet(DomDocument::load($xsl_filename));
		return $xslt->transformToXML(DomDocument::loadXML($doc));
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
		header("Location: ".$this->path."?error=noURL");
		exit;
	  }
   }

   protected function schema() {
    /* 
	 *	a  generic RelaxNG schema to validate the presence of @id on any element in XHTML documents 
	 *	its faster than $dom->validateOnParse = true option
	 *
	 */
	
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
 }
?>