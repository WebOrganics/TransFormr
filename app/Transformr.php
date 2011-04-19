<?php
/*
TransFormr Version: 2.2
author:   Martin McEvoy
updated:  Saturday, 3rd July 2010
homepage: http://github.com/WebOrganics/TransFormr
web-service: http://microform.at/
licence: see files/gpl-3.0.txt
*/
class Transformr
{
	var $tidy_option = '';
	var $admin = '';
	var $use_store = '';
	var $reset_tables = '';
	var $store_size = '';
	var $dump_location = '';
	var $backup_type = '';
	var $ttl = '';
	
	function __construct() 
	{
		!defined('_Transformr') ? define('_Transformr', true) : '' ;
		ini_set('display_errors',  0 );
		$this->path = $this->set_path();
		$this->version = '2.3';
		$this->updated = array('Saturday, 3rd July 2010', '2010-07-03T12:00:20+01:00');
		$this->check_php_version('5.2.0', 'Transformr'); 
		
		$params = array_merge($_GET, $_POST);
		$this->text = isset($params['text']) ? stripslashes($params['text']) : '';
		$this->url = isset($params['url']) ? str_replace('%23','#', trim($params['url'])) : '' ;
		$this->type = isset($params['type']) ? $params['type'] : '';
		$this->output = isset($params['output']) ? ( $params['output'] == '' ? 'rdf' : $params['output']  ) : 'rdf';
		$this->query = isset($params['q']) ? stripslashes($params["q"]) : '';
		$this->template = dirname(__FILE__).'/template/';
		$this->xsl = dirname(__FILE__).'/xsl/';
		$this->required = array('arc/ARC2', 'include/class.hqr', 'include/function.encoded');
		header("X-Application: Transformr ".$this->version );
	}
	
	public function transform($settings = '') 
	{
		if ($settings !='') foreach ( $settings as $setting => $value ) $this->$setting = $value;
		$this->a = $this->config_ns();
		foreach ( $this->required as $require ) require_once(dirname(__FILE__).DIRECTORY_SEPARATOR.$require.'.php');
		$this->ARC2 = ARC2::getComponent('RDFTranformrPlugin', $this->a);
		return ( $this->query !='' ? $this->json_query($this->query) : $this->transformr_types() );
	}
	
	protected function json_query($data) 
	{
		$data = json_decode(utf8_encode($data));
		!$data ? die('query not well formed please validate your query at <a href="http://www.jsonlint.com/">http://www.jsonlint.com/</a>') : $data;
		if ( isset($data->describe)) {
			$this->url = $data->describe->url;
			$this->type = $data->describe->type;
			isset($data->describe->output) ? $this->output = $data->describe->output : '';
			return $this->ARC2->construct_url($this->url, $this->type, $this->output);
		}
		else {
			$this->url = $data->url;
			$this->type = $data->type;
			isset($data->output) ? $this->output = $data->output : '';
			return $this->transformr_types();
		}
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
			return $this->ARC2->to_rdf($this->url, $document, $this->output);
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
		
		case 'hatom-sioc':
			$xsl_filename = $this->xsl ."hAtom2SIOC.xsl";
			$document = $this->transform_xsl($this->url, $xsl_filename);
			return $this->ARC2->to_rdf($this->url, $document, $this->output);
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
			return $this->ARC2->to_rdf($this->url, $document, $this->output);
		break;

		case 'hreview':
			$xsl_filename = $this->xsl ."hreview2rdfxml.xsl";
			$document = $this->transform_xsl($this->url, $xsl_filename);
			return $this->ARC2->to_rdf($this->url, $document, $this->output);
		break;

		case 'haudio-rss':
			header("Content-type: application/xml");
			$xsl_filename = $this->xsl ."hAudioRSS2.xsl";
			return $this->transform_xsl($this->url, $xsl_filename);
		break;

		case 'mo-haudio':
			$xsl_filename = $this->xsl ."Mo-hAudio.xsl";
			$document = $this->transform_xsl($this->url, $xsl_filename);
			return $this->ARC2->to_rdf($this->url, $document, $this->output);
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
			return $this->ARC2->to_rdf($this->url, $document, $this->output);
		break;

		case 'ogp-rdf':
			$xsl_filename = $this->xsl ."OGPGRDDL.xsl";
			$document = $this->transform_xsl($this->url, $xsl_filename);
			return $this->ARC2->to_rdf($this->url, $document, $this->output);
		break;

		case 'erdf':
			$xsl_filename = $this->xsl ."extract-rdf.xsl";
			$document = $this->transform_xsl($this->url, $xsl_filename);
			return $this->ARC2->to_rdf($this->url, $document, $this->output);
		break;

		case 'rdfa':
			$xsl_filename = $this->xsl ."RDFa2RDFXML.xsl";
			$document = $this->transform_xsl($this->url, $xsl_filename);
			return $this->ARC2->to_rdf($this->url, $document, $this->output);
		break;

		case 'detect':
			$xsl_filename = $this->xsl ."detect-uf.xsl";
			return $this->transform_xsl($this->url, $xsl_filename);
		break;
		
		case 'hcard2qrcode':
			return $this->return_qrcode($this->url);
		break;
		
		case 'dump':
			header("Content-Type: text/html; charset=UTF-8");
			include $this->template ."head.php";
			include $this->template ."dump.php";
			include $this->template ."foot.php";
		break;

		case 'direct':
			header("Content-Type: text/html; charset=UTF-8");
			include $this->template ."head.php";
			include $this->template ."direct.php";
			include $this->template ."foot.php";
		break;
		
		default:
			header("Content-Type: text/html; charset=UTF-8");
			include $this->template ."head.php";
			include $this->template ."content.php";
			include $this->template ."foot.php";
		break;
		}
	}
	
	function get_file_contents($url) 
	{	
		$cache_path = dirname(__FILE__).DIRECTORY_SEPARATOR.'cache';
		
		foreach( glob($cache_path.DIRECTORY_SEPARATOR."*.dat") as $file_name ) {
			if ( (time() - $this->ttl ) > filemtime($file_name) ) 
			unlink($file_name);
		}
		
		if( $cache_file = sprintf('%s/%08X.dat', $cache_path, crc32($url))) 
		{
			$cache_exists = file_exists($cache_file);
			
			if ($this->ttl !='' && $cache_exists && (filemtime($cache_file) > (time() - $this->ttl)) ) 
			{
				$cached = implode('', file($cache_file));
				$cached = rtrim($cached, "\r\n") . PHP_EOL;	
				return $cached;
			}
			clearstatcache();
			touch($cache_file);
			
			$cache = curl_init();
			curl_setopt($cache, CURLOPT_URL, $url);
			curl_setopt($cache, CURLOPT_TIMEOUT, 15);
			curl_setopt($cache, CURLOPT_RETURNTRANSFER, true);
			curl_setopt($cache, CURLOPT_USERAGENT, 'Transformr/'.$this->version.'  ('.$this->path.'; '.$this->admin.')');
			
			if ($cache_exists) 
			{	
				curl_setopt($cache, CURLOPT_TIMECONDITION, CURL_TIMECOND_IFMODSINCE);
				curl_setopt($cache, CURLOPT_TIMEVALUE, filemtime($cache_file));
			}
			$content = curl_exec($cache);
			
			/* insert non breaking space so tidy does not clean empty span or span with just a space, 
				XSL however is set to strip-space elements="*" so it should not appear in results */
				
			$content = trim(preg_replace('/<\s*span(.*?)>\s<\/\s*?span[^>\w]*?>/', 
				'<span$1>&nbsp;$2</span>', $content));
			$content = trim(preg_replace('/<\s*span(.*?)><\/\s*?span[^>\w]*?>/', 
				'<span$1>&nbsp;</span>', $content));
				
			$status = curl_getinfo($cache, CURLINFO_HTTP_CODE);
			curl_close($cache);
			
			if ($cache_exists && ($status == 304)) 
			{ 
				$cached = implode('', file($cache_file));
				$cached = rtrim($cached, "\r\n") . PHP_EOL;	
				return $cached;
			}
			else if (!$file_name = @fopen($cache_file, 'w')) {
				die('Could not open ' . $cache_file);
			}
			else { 
				fwrite($file_name, html_convert_entities($content));
				@fclose($file_name);
			}
			chmod($cache_file, 0644);
			return $content;
		}
	}
	
	protected function transform_xsl($url, $xsl_filename, $isstring = 0) 
	{
	if( strrchr($url, 'http://') || $this->text != '' ) {
		
		if (strrchr($url, '#')) $fragment = array_pop(explode('#', $url));
		
		if( $this->text != '' ) 
		{ 
			$this->use_store = 0;
			$title = 'Using direct Input';
			$url = $this->path.'direct/';
			$html = method_exists('tidy','cleanRepair') ? 
			  $this->tidy_html( urldecode($this->text), '', 'php' ) : 
			  urldecode($this->text);
			
		}
		else $html = $this->get_file_contents($url);
		
		if ( strlen(trim($html)) === 0 ) return $this->error('noURL');
		
		$dom = new DOMDocument('1.0');
		$dom->preserveWhiteSpace = true;
		if( $this->text != '' ) @$dom->loadXML($html);
		else @$dom->loadXML($this->tidy_html($html, $url, $this->tidy_option));
		$dom->formatOutput = true;
		$dom->normalizeDocument();
		
		$title = !isset($title) ? $dom->getElementsByTagName('title')->item(0)->nodeValue : $title;
		
		if ($this->type == 'rdfa' && !$dom->getElementsByTagName('html')->item(0)->getAttribute('xmlns'))
			$dom->getElementsByTagName('html')->item(0)->setAttribute('xmlns', 'http://www.w3.org/1999/xhtml');
		
		if (isset($fragment)) 
		{
			$dom->relaxNGValidateSource($this->valid_schema());
			$element = $dom->getElementById($fragment);
			$content = $dom->saveXML($element);
			$dom = $this->return_html_frag($content, $title);	
		} 
		
		if (!method_exists('xsltProcessor','transformToXML')) {
			die( "Sorry PHP xslt functions unavailable" );
		}
		
		$xslt = new xsltProcessor;
		$xslt->setParameter('','transformr', $this->path);
		$xslt->setParameter('','url', $url);
		$xslt->setParameter('','request-uri', $_SERVER['REQUEST_URI']);
		$xslt->setParameter('','base-uri', $url);
		$xslt->setParameter('','doc-title', $title);
		$xslt->setParameter('','version', $this->version);
		if ( $this->use_store == 1 ) $xslt->setParameter('','endpoint-link', $this->path. 'sparql/endpoint?');
		$xslt->importStyleSheet(DomDocument::load($xsl_filename));
		
		if (!@DomDocument::loadXML($dom->saveXML()))	
		{
			$dom = @DomDocument::loadXML($this->tidy_html($html, $url, $this->tidy_option, 'output-xml')); // reload as plain vanilla xml
			if (!$dom) return $this->error('invalidDoc');
		}
		return $xslt->transformToXML(@DomDocument::loadXML($dom->saveXML()));
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
		return $this->error('noURL');
	  }
	}
	
	private function return_qrcode($url)
	{
		$hqr = new hQR;
		include $this->template ."head.php";
		include $this->template ."qrcode.php";
	}
	
	private function tidy_html($html, $url='', $tidy_option='', $output ='')
	{	
		$output = $output == '' ? 'output-xhtml' : $output ;
		
		if ( $tidy_option == 'php') 
		{
			if ( !method_exists('tidy','cleanRepair') ) 
			{
				return $this->error('noPHPTidy');
			} 
			else {
				$config = array(
					'doctype'                     => 'strict',
					'logical-emphasis'            => true,
					"$output"                     => true,
					'wrap'                        => 200,
					'clean'						  =>true
				);
				$tidy = new tidy;
				$tidy->parseString($html, $config, 'utf8');
				$tidy->cleanRepair();
				return !$tidy ? $this->error('tidyFail') : $tidy;
			}
		} 
		elseif ($tidy_option == 'dom') 
		{
			$newdoc = new DOMDocument();
			$newdoc->preserveWhiteSpace = true;
			!$newdoc->loadXML($html) ? @$newdoc->loadHTML($html) : @$newdoc->loadXML($html) ;
			$newdoc->formatOutput = true;
			$newdoc->normalizeDocument();
			$html = $newdoc->saveXML();
			return str_replace(array("\r\n", "\r", "\n", "\t", "&#xD;"), '', $html);
		}
		elseif ($tidy_option == 'online') 
		{		
			$tidyURL = 'http://cgi.w3.org/cgi-bin/tidy?forceXML=on&docAddr='.$url;
			$tidy = $this->get_file_contents($tidyURL);
			return !$tidy ? $this->error('noW3CTidy') : $tidy;
		}
		return $html;	
	}
	
	function rand_filename($ext = '') 
	{
		return substr(md5(uniqid(rand())), 0, 8).'.'.$ext;
	}
	
	protected function config_ns() 
	{
	require_once(dirname(__FILE__).DIRECTORY_SEPARATOR.'config.php' );
	
	if ($this->backup_type !='') 
	{
		if ($this->backup_type == 'rdf') $ext = 'rdf';
		elseif ($this->backup_type == 'ntriples') $ext = 'nt';
		else $ext = 'ttl';
	} 
	else $ext = 'xml';
	
	return array(
		'use_store' => $this->use_store,
		'store_size' => $this->store_size,
		'reset_tables' => $this->reset_tables,
		'dump_location' => $this->dump_location,
		'store_root' => $this->path,
		'document_type' => $this->type,
		'backup_type' => $this->backup_type,
		'extension' => $ext,
		
		'auto_extract' => 0, 
		'serializer_type_nodes' => 1, 
		'bnode_prefix' => 'id'.substr(md5(uniqid(rand())), 0, 6),
		
		/* MySQL database settings */
		'db_host' => $host,
		'db_user' => $user,
		'db_pwd' => $passwd,
		'db_name' => $dbname,

		/* ARC2 store settings */
		'store_name' => $storename
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
		$result = '
			<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
			<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
			<head>
				<title>'.$title.'</title>
			</head>
				<body>' . $content. '</body>
			</html> ';
		
		$result = DomDocument::loadXML($result);
		$result->formatOutput = true;
		
		return $result;
	}
	
 	private function set_path()
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
	
	private function error($error = '', $result ='') 
	{
	// headers already sent, use javascript hack to replace location
	?>
	<script language="javascript">
	<!-- 
		location.replace("?error=<?php echo $error ?>&url=<?php echo $this->url ?>");
	-->
	</script>
	<?php
		include $this->template ."head.php";
		include $this->template ."content.php";
		include $this->template ."foot.php";
	}
 }
?>