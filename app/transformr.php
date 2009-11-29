<?php
// TransFormr Version: 0.5.2, Updated: Sunday, 29th November 2009
// Contact: Martin McEvoy info@weborganics.co.uk

class Transformr
 {
 	private static function set_path()
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
	
	public static function init()
	{
	define('MIN_PHP_VERSION', '5.2.0');
	define('THIS_PHP_VERSION', phpversion());
	$php_self = THIS_PHP_VERSION;
	$min_php = MIN_PHP_VERSION;
	$php_version = version_compare(THIS_PHP_VERSION, MIN_PHP_VERSION, '>=');
	$upgrade_php = '<p>Sorry PHP Upgrade needed, <em>Transformr</em> requires PHP '.$min_php.' or newer. Your current PHP version is '.$php_self.'</p>';
	
	if (!$php_version) {
		echo $upgrade_php;
	exit;
	}
	define('PATH',  self::set_path());
	define('TYPE',  $_GET['type']);
	define('URL',  $_GET['url']);
	define('FORMAT',  'format/');
	define('TEMPLATE',  'template/');
	define('XSL',  'xsl/');
	define('VERSION',  '0.5.2');
	define('UPDATED',  'Sunday, 29th November 2009');
	header("X-Application: Transformr ".VERSION );
	ini_set('display_errors', 0); // set this to 1 to debug errors
	}
	
	public static function transform($url, $xsl_filename)
	{
	if( strrchr($url, 'http://') ) {
		
		// disable same host requests
		if ($url == PATH) {
			header("Location: ".PATH);
			exit;
		}
		
		$html = file_get_contents($url, FALSE, NULL, 0, 2097152);
		
		if (strrchr($url, '#')) $frag_id = array_pop(explode('#', $url));
		
		if (strrchr($url, 'docAddr=')) $url = array_pop(explode('docAddr=', $url));
		
		$dom = new DOMDocument('1.0');
		
		$dom->preserveWhiteSpace = true;
		
		if (!@$dom->loadXML($html)) {
			
			$htmlDoctype = '/<!DOCTYPE(.*)>/sU';
			
			$withStrict = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">';
			
			$xmlNs = 'http://www.w3.org/1999/xhtml';
			
			$html = preg_replace ($htmlDoctype, $withStrict, $html);
			
			@$dom->loadHTML($html);
			
			if (!$dom->getElementsByTagName('html')->item(0)->getAttribute('xmlns'))
				$dom->getElementsByTagName('html')->item(0)->setAttribute('xmlns', $xmlNs);
		}
		else {
			@$dom->loadXML($html);
		}
		
		$title = $dom->getElementsByTagName('title')->item(0)->nodeValue;
		
		if (isset($frag_id)) 
		{
			$dom->relaxNGValidateSource(self::schema());
			
			$element = $dom->getElementById($frag_id);

			$doc = $dom->saveXML($element); 	
		} 
		else {
			$doc = $dom->saveXML();
		}
		
		if (!DomDocument::loadXML($doc)) {
			
			if (isset($tidyPhase)) $tidyPhase++;
			else $tidyPhase = 1;
			
			if ($tidyPhase == 2) {
				echo "Sorry Cant parse this document";
					unset($tidyPhase);
				exit;
			}
			else {
				$tidyURL = 'http://cgi.w3.org/cgi-bin/tidy?forceXML=on&docAddr=';
					self::transform($tidyURL.$url, $xsl_filename);
			}
		}
		
		$xslt = new xsltProcessor;
		$xslt->setParameter('','transformr', PATH);
		$xslt->setParameter('','url', $url);
		$xslt->setParameter('','base-uri', $url);
		$xslt->setParameter('','doc-title', $title);
		$xslt->importStyleSheet(DomDocument::load($xsl_filename));
		
		print $xslt->transformToXML(DomDocument::loadXML($doc));
	}

	elseif ($url == 'referer' && getenv("HTTP_REFERER") != '') {
	
	$referer = getenv("HTTP_REFERER");
		self::transform($referer, $xsl_filename);	
	}
	
	elseif (getenv("HTTP_REFERER") != '' && $url !='') {
	
	$referer = getenv("HTTP_REFERER");
	
		self::transform($referer.'#'.$url, $xsl_filename);	
	}
	
	else {
		header("Location: ".PATH."?error=noURL");
		exit;
	}
   }

   private static function schema()
   {
    // a  generic RelaxNG schema to validate the presence of @id on any element in XHTML documents 
	// (its faster than $dom->validateOnParse = true function) .
	
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