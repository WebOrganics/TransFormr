<?php
/*
 * TransFormr Version: 0.6.0, Saturday, 17th April 2010
 * Contact: Martin McEvoy info@weborganics.co.uk
 */

class Transformr
{
 	public function set_path()
	{
	$_SCRIPT_DIR = realpath(dirname($_SERVER['SCRIPT_FILENAME']));
	$_BASE_DIR = realpath(dirname(__FILE__)); 
	$_PATH = substr( $_SCRIPT_DIR, strlen($_BASE_DIR));
	$INSTALLATION_PATH = $_PATH
		? substr( dirname($_SERVER['SCRIPT_NAME']), 0, -strlen($_PATH) )
		: dirname($_SERVER['SCRIPT_NAME']);
	if ($INSTALLATION_PATH == "/" || $INSTALLATION_PATH == "\\") 
		return "http://".$_SERVER['HTTP_HOST']."/";
	else 
		return "http://".$_SERVER['HTTP_HOST'].$INSTALLATION_PATH."/";
	}
	
	protected function init()
	{
	define('MIN_PHP_VERSION', '5.2.0');
	define('THIS_PHP_VERSION', phpversion());
	$php_self = THIS_PHP_VERSION;
	$min_php = MIN_PHP_VERSION;
	$php_version = version_compare(THIS_PHP_VERSION, MIN_PHP_VERSION, '>=');
	$upgrade_php = '<p>Sorry PHP Upgrade needed, <em>Transformr</em> requires PHP '.$min_php.' or newer. Your current PHP version is '.$php_self.'</p>';
	
	if (!$php_version) 
	{
		echo $upgrade_php;
		exit;
	}
	
	define('PATH',  $this->set_path());
	define('TYPE',  $_GET['type']);
	define('URL',  $_GET['url']);
	define('TEMPLATE',  'template/');
	define('XSL',  'xsl/');
	define('VERSION',  '0.6.0');
	define('UPDATED',  'Saturday, 17th April 2010');
	header("X-Application: Transformr ".VERSION );
	ini_set('display_errors', 0); // set this to 1 to debug errors
	}
	
	public function transform()
	{
	$this->init();	
	
	$required = array("Transformr_Types", "RDFa_Parser", "ARC2_Transformr", "Entity_Decode", "Dataset_Transformr");
	
	foreach ($required as $require)
	{
		require_once($require.'.php');
	}
	
	$RDFparser = new ARC2_Transformr;
	
	$HTMLQuery = new HTMLQuery;
		
	if ($arc2_parse == true) 
	{
		$output = 'rdf';
		$document = $this->transform_xsl($url, $xsl_filename);
		if (isset($_GET['output'])) $output = $_GET['output'];
		return $RDFparser->Parse($url, $document, $output);
	}	
	if ($xsl_filename == "dataset") return $HTMLQuery->this_document($url);
	else return $this->transform_xsl($url, $xsl_filename);
	}
	
	protected function transform_xsl($url, $xsl_filename)
	{
	if( strrchr($url, 'http://') ) {
		
		// disable same host requests
		if ($url == PATH) {
			header("Location: ".PATH);
			exit;
		}
		
		$html = html_entity_safe_decode(file_get_contents($url, FALSE, NULL, 0, 2597152));
		
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
				$tidyURL = 'http://cgi.w3.org/cgi-bin/tidy?forceXML=on&docAddr=';
				$tidy = file_get_contents($tidyURL.$url, FALSE, NULL, 0, 2597152);
			}
		}
		
		if (isset($tidy)) $html = $tidy;
		$dom->loadXML($html);
		
		if (TYPE == "rdfa")
		{
			$RDFaparser = new RDFa_Parser;
			$dom->loadXML($RDFaparser->get_document($dom)); 
		}
		
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
		$xslt->setParameter('','transformr', PATH);
		$xslt->setParameter('','url', $url);
		$xslt->setParameter('','base-uri', $url);
		$xslt->setParameter('','doc-title', $title);
		$xslt->setParameter('','version', VERSION);
		$xslt->importStyleSheet(DomDocument::load($xsl_filename));
		return $xslt->transformToXML(DomDocument::loadXML($doc));
	}
	elseif ($url == 'referer' && getenv("HTTP_REFERER") != '') {
		$referer = getenv("HTTP_REFERER");
		$this->transform($referer, $xsl_filename);	
	}
	elseif (getenv("HTTP_REFERER") != '' && $url !='') {
		$referer = getenv("HTTP_REFERER");
		$this->transform($referer.'#'.$url, $xsl_filename);	
	}
	else {
		header("Location: ".PATH."?error=noURL");
		exit;
	  }
   }

   protected function schema()
   {
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