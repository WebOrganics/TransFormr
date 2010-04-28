<?php
/*
 * TransFormr Version: 0.6.2, Monday, 26th April 2010
 * Contact: Martin McEvoy info@weborganics.co.uk
 */
class Transformr
{
	public $tidy_option = '';
	public $debug = '';
	public $log_errors = '';
	
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
	
	function __construct() 
	{
		$this->path = $this->set_path();
		$this->type = $_GET['type'];
		$this->url = $_GET['url'];
		$this->template = 'template/';
		$this->xsl = 'app/xsl/';
		$this->version = '0.6.2';
		$this->updated = 'Monday, 26th April 2010';
		$this->check_php_version('5.2.0', 'Transformr'); 
		header("X-Application: Transformr ".$this->version );
		ini_set('log_errors', $this->log_errors !='' ? $this->log_errors : 0 );
		ini_set('display_errors', $this->debug !='' ? $this->debug : 0 );
		$this->required = array('Transformr_Types', 'arc/ARC2', 'ARC2_Transformr', 'Dataset_Transformr');
		$this->arc2_parse = '';
	}
	
	public function transform() {	
	
	foreach ( $this->required as $require ) {
		require_once($require.'.php');
	}
	$parse = new ARC2_Transformr();
		
	if ($this->arc2_parse == true) {
	
		$output = isset($_GET['output']) ? $_GET['output'] : 'rdf';
		
		if ($this->type == "rdfa") {
			return $parse->this_semhtml($this->url, $output, $type = 'rdfa');
		}
		elseif ($this->type == "microformats") {
			return $parse->this_semhtml($this->url, $output, $type = 'microformats');
		}
		else {
			$document = $this->transform_xsl($this->url, $xsl_filename);
			return $parse->this_rdf($this->url, $document, $output);
		}
	}	
	elseif ($this->type == "dataset") return $parse->this_query($this->url);
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
		
		!$dom->loadXML($html) ? $dom->loadXML($this->tidy_html($html, $url, $this->tidy_option)) : $dom->loadXML($html);
		
		$title = $dom->getElementsByTagName('title')->item(0)->nodeValue;
		
		if (isset($frag_id)) 
		{
			$dom->relaxNGValidateSource($this->valid_schema());
			$element = $dom->getElementById($frag_id);
			$content = $dom->saveXML($element);
			include( 'Transformr_Fragment.php' );	
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

   protected function valid_schema() {
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
   
   private function check_php_version($version ='', $name ='') 
   {
		$this->php_min_version = $version;
		$this->server_php_version = phpversion();
		$php_self = $this->server_php_version;
		$min_php = $this->php_min_version;
		$php_version = version_compare($this->server_php_version, $this->php_min_version, '>=');
	
		$upgrade_php = '<p>Sorry PHP Upgrade needed, <em>'.$name.'</em> requires PHP '.$min_php.' or newer. Your current PHP version is '.$php_self.'</p>';
		
		if (!$php_version) {
			print("$upgrade_php");
			exit;
		}
	}
	
	private function tidy_html($html, $url, $tidy_option)
	{	
		if ($tidy_option == 'php' && !method_exists('tidy','parseString') ) 
		{
			print("PHP Tidy Method does not exist, try tidy_option = 'online' ");
			exit;
		}
		elseif ( $tidy_option == 'php')
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
			!$tidy ? print("Unable to tidy this document using php tidy") : $result = $tidy;
			return $result;
		} 
		elseif ($tidy_option == 'online') 
		{		
			$tidyURL = 'http://cgi.w3.org/cgi-bin/tidy?forceXML=on&docAddr='.$url;
			$tidy = file_get_contents($tidyURL, FALSE, NULL, 0, 2597152);
			
			!$tidy ? print("online W3C tidy service unavailable") : $result = $tidy;
			return $result;	
		}
		else 
		{
			print("sorry Unable to tidy this document");
			exit;
		}
	}
 }
?>