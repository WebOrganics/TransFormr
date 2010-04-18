<?php
class HTMLQuery extends Transformr
{
	public $url = '';
	
	function __construct()
	{
		include_once("ARC2_Transformr.php");
	}
	
	protected function json_dataset($xpath, $url) 
	{
		$data = "//*[contains(concat(' ',normalize-space(@rel), ' '),' dataset ')][1]"; /* only one supported at mo :) */
		if($nodes = $xpath->query($data))
		{
			foreach($nodes as $node)
			{
				$resource = $node->getAttribute('href');
				$json_data = $this->return_url($resource , $url);
            }
			return $json_data;
        }
	}
	
	protected function reverse_strrchr($val, $selector)
	{
		$selector = strrpos($val, $selector);
	
		if (!substr($val, 0, $selector) == '') 
		{
			return substr($val, 0, $selector);
		}
		else return null;
	}

	protected function forward_strrchr($val, $selector)
	{
		if (strrchr($val, $selector))
		{
			return array_pop(explode($selector, $val));
		}
		else return null;
	}

	protected  function get_attr_value($val)
	{
	$selectors = array('class' => '.', 'id' => '#', null => '~=');
	
		foreach ($selectors as $attribute => $selector)
		{
			if(!is_null( $this->reverse_strrchr($val, $selector)) && $selector == '~=' )
			{
				return array( $this->reverse_strrchr($val, $selector) => $this->forward_strrchr($val, $selector) );
			}
			elseif(!is_null( $this->forward_strrchr($val, $selector)) && is_null($this->reverse_strrchr($val, $selector)))
			{
				if (!$attribute == null) 
				{
					return array( $attribute => $this->forward_strrchr($val, $selector) );
				}
			}
		}
	}
	
	protected function return_node_or_attribute($val)
	{
		if (!$this->get_attr_value($val)) return array('node' => $val);
		else return $this->get_attr_value($val);
	}
	
	protected function get_label($value, $item) 
	{
		if (isset($value->label)) $label = $value->label;
		else $label = $item;
		return $label;
	}
	
	protected function return_url($resource, $url)
    {
        if (parse_url($resource, PHP_URL_SCHEME) != '') return $resource;

        if ($resource[0]=='#' || $resource[0]=='?') return $url.$resource;

        extract(parse_url($url));

        $path = preg_replace('#/[^/]*$#', '', $path);

        if ($resource[0] == '/') $path = '';

        $abs = "$host$path/$resource";

        $re = array('#(/\.?/)#', '#/(?!\.\.)[^/]+/\.\./#');
		
        for($n=1; $n>0; $abs=preg_replace($re, '/', $abs, -1, $n)) {}

        return $scheme.'://'.$abs;
    }
	
	protected function rdf_about($url, $documentTag, $value, $class) 
	{
	if( isset($value->about)) $about = $value->about;
	else $about = true;
	
	if ( $documentTag->getAttribute('id') ) {
	
		if (isset($value->about) && !$about == false ) {
			
			foreach ($value->about as $id => $uri ) {
			
				if ($newids = explode('|', $id)) { 
				
					foreach ($newids as $newid) {
					
						if ($documentTag->getAttribute('id') == $newid)  {
							return $class->setAttribute("rdf:about", $uri);
						}
						else {
							return $class->setAttribute("rdf:about", $url."#".$documentTag->getAttribute('id'));
						}
					}
				}
				else {
					if ($documentTag->getAttribute('id') == $id)  {
						return $class->setAttribute("rdf:about", $uri);
					}
					else {
						return $class->setAttribute("rdf:about", $url."#".$documentTag->getAttribute('id'));
					}
				}
			}
		} 
		else 
			if( $about == true ) return $class->setAttribute("rdf:about", $url."#".$documentTag->getAttribute('id'));
	} 
	elseif ($documentTag->getAttribute('href')) return $class->setAttribute("rdf:about", $this->return_url($documentTag->getAttribute('href'), $url));
	elseif ($documentTag->getAttribute('src')) return $class->setAttribute("rdf:about", $this->return_url($documentTag->getAttribute('src'), $url));
	else 
		if( $about == true ) 
			return $class->setAttribute("rdf:about", $url); 
	}
	
	protected function get_content_from_id($value, $documentTag) 
	{
	$content_id = null;
					
	foreach ($value->content as $cid => $content) 
	{
		if ($cid == "value") 
		{
			$content_id = 1;
			$text = $content;
		}
		
		if ($newcids = explode('|', $cid)) 
		{	
		foreach($newcids as $newcid) 
		{		
			if ($documentTag->getAttribute('id') == $newcid) 
			{
				$content_id = 1;
				$text = $content;
				}
			}
		}
		if ($documentTag->getAttribute('id') == $cid) 
		{
			$content_id = 1;
			$text = $content;
		}
		else 
		{
			if (is_null($content_id)) 
			{
				if ($documentTag->getAttribute('datetime')) 
				{
					$text = $documentTag->getAttribute('datetime');
				}
				elseif ($documentTag->getAttribute('content')) 
				{
					$text = $documentTag->getAttribute('content');
				}
				else {
				
					$text = $documentTag->nodeValue;
					}
				}
			}
		}
		$text = str_replace(array("\r\n", "\r", "\n", "\t"), '', $text);
		return $text;
	}
	
	protected function get_resource_from_id($value, $documentTag) {
	
	global $url;

	$content_id = null;
					
	foreach ($value->content as $cid => $content) 
	{
	if ($cid == "value") 
	{
		$content_id = 1;
		$resource = $content;
	}				
	if ($newcids = explode('|', $cid)) 
	{
		foreach($newcids as $newcid) 
		{		
			if ($documentTag->getAttribute('id') == $newcid) 
			{
				$content_id = 1;
				$resource = $content;
				}
			}
		}
		if ($documentTag->getAttribute('id') == $cid) 
		{
			$content_id = 1;
			$resource = $content;
		}
		else {
		
			if (is_null($content_id)) $resource = $this->return_resource($documentTag, $url);
			}
		}
		return $resource;
	}
	
	protected function return_node_value($child) 
	{	
	$result = '';
	
	$tmpdoc = new DOMDocument();
	$tmpdoc->appendChild($tmpdoc->importNode($child, TRUE));
	$tmpdoc->formatOutput = true;
	$result .= $tmpdoc->saveXML();
	$result = str_replace(array("\r\n", "\r", "\n", "\t", "&#xD;"), '', $result);
	$result = trim(preg_replace('/<\?xml.*\?>/', '', $result, 1));
	
	return $result;
	}

	protected function return_text_nodes($val, $documentTag, $prop, $xml) 
	{
	if (isset($val->content)) 
	{
		$text = $this->get_content_from_id($val, $documentTag);
	}
	elseif ($documentTag->getAttribute('datetime')) $text = $documentTag->getAttribute('datetime');
	elseif ($documentTag->getAttribute('content')) $text = $documentTag->getAttribute('content');
	elseif ($documentTag->getAttribute('title')) $text = $documentTag->getAttribute('title');
	else $text = $documentTag->nodeValue;
	$text = str_replace(array("\r\n", "\r", "\n", "\t"), '', $text);
	$property = $xml->createElement($this->get_label($val, $prop), $text );
	return $property;
	}
	
	protected function return_resource($documentTag, $url) 
	{
	if ($documentTag->getAttribute('src')) $resource = $documentTag->getAttribute('src');
	elseif ($documentTag->getAttribute('href')) $resource = $documentTag->getAttribute('href');
	elseif ($documentTag->getAttribute('id')) $resource = $url."#".$documentTag->getAttribute('id');
	
	return $resource;
	}

	public function this_document($url)
	{
		$this->__construct();
		
		$this->contents = '';
	
		$this->html = file_get_contents($url);
		
		$this->object = json_decode(utf8_encode($this->html));
		
		$this->file = $this->rand_filename().".rdf";
		
		if (isset($this->object->query->base)) 
		{
			$this->html = file_get_contents($this->return_url($this->object->query->base, $url));
			$this->contents = "json";
		}
		if (!$this->html) 
		{ 
			return $this->return_error('1'); 
			exit;
		}
		
		$dom = new DomDocument();
		@$dom->loadHtml($this->html);
		$xpath = new DomXpath($dom);
		
		if ($this->contents == "json") $this->contents = file_get_contents($url);
		else $this->contents = file_get_contents($this->json_dataset($xpath, $url));
		
		if (!$this->contents) 
		{ 
			return $this->return_error('2');  
			exit;
		}
		
		$this->object = json_decode(utf8_encode($this->contents));
		
		if (!$this->object) 
		{ 
			return $this->return_error('3'); 
			exit;
		}
		$object = $this->object->query;
		
		$xml  = new DOMDocument('1.0', 'utf-8');
		$xml->preserveWhiteSpace = true;
		$xml->formatOutput = true;
		$root = $xml->createElementNS('http://www.w3.org/1999/02/22-rdf-syntax-ns#', 'rdf:RDF');
		
		header("Content-type: application/rdf+xml");
		header("Content-Disposition: inline; filename=".$this->file);
		
		if ( isset($object->base) ) $url = $this->return_url($object->base , $url);
		$root->setAttribute("xml:base", $url);
		
		$xml->appendChild($root);
		
		$documentTags = $dom->getElementsByTagName('*');

		foreach ( $object->vocab as $prefix => $urlns ) 
		{	
			if ($prefix == "value") {
				$thisns ="xmlns";
				$root->setAttribute($thisns, $urlns);
			}
			else {
				$xmlns = "xmlns:";
				$thisns = $xmlns.$prefix;
				$root->setAttributeNS('http://www.w3.org/2000/xmlns/' , $thisns, $urlns);
			}
		}
		
		foreach ( $documentTags as $documentTag ) 
		{
			$this->json_query_properties($url, $object, $documentTag, $root, $xml, $hasroot = false);
		}
		
		if (isset($object->output)) 
		{ 
			$RDFparser = new ARC2_Transformr;
			
			return $RDFparser->Parse($this->html, $xml->saveXML(), $object->output);
		}
		else {
			return $xml->saveXML();
		}
	}
	
	protected function json_query_properties($url, $object, $documentTag, $root, $xml, $hasroot) 
	{
	/* this function is messy sorry */
	
		foreach ($object->keyword as $item => $value) {
		
		$parse_property = true;
	
		if (!isset($arrvalue) ) $arrvalue = array();
		else $arrvalue = array_values($arrvalue);
		
		foreach ($this->return_node_or_attribute($item) as $attr => $i)
		{
			$attribute = $attr;
			$item = $i;
		}
			if (preg_match("/\b$item\b/i", $documentTag->getAttribute($attribute)) 
				or
				$documentTag->nodeName == $item && $attribute == "node" ) {
					
					if (isset($value->keyword)) {
					
					$class = $xml->createElement($this->get_label($value, $item));
					$root->appendChild($class);
					
					$this->rdf_about($url, $documentTag, $value, $class);
					
					$documentTags = $documentTag->getElementsByTagName('*');
					
						foreach ( $documentTags as $documentTag ) 
						{													
							foreach ( $value->keyword as $prop => $val ) {
								
								foreach ($this->return_node_or_attribute($prop) as $attr => $i)
								{
									$attribute = $attr;
									$prop = $i;
								}
								if (preg_match("/\b$prop\b/i", $documentTag->getAttribute($attribute) ) 
									or 
									$documentTag->nodeName == $prop && $attribute == "node" ) 
								{
									foreach ($arrvalue as $thiskey => $thisval)
									{
										if ($thisval == $prop) $parse_property = false;
									}
									if (isset($val->multiple)) $parse_property = true;
									
									if ($parse_property == true) 
									{									
										$this->return_properties($url, $prop, $val, $documentTag, $class, $xml);
										$arrvalue[] = $prop;
									}
								}
							}
						}
					}
					else 
					{
						if ($hasroot == true ) 
						{
							$this->return_properties($url, $item, $value, $documentTag, $root, $xml);
							$arrvalue[] = $item;
						}
						else {
							
						foreach ($arrvalue as $thiskey => $thisval)
						{
							if ($thisval == $item) $parse_property = false;
						}
						if (isset($value->multiple)) $parse_property = true;
						
						if ($parse_property == true) {
							$class = $xml->createElement('rdf:Description');
							$root->appendChild($class);
							$this->rdf_about($url, $documentTag, $value, $class);
							$this->return_properties($url, $item, $value, $documentTag, $class, $xml);
							$arrvalue[] = $item;
						}
					}
				}
			}
		}
		unset( $arrvalue, $thiskey, $thisval, $parse_property );
		/* end messy function */
	}

	protected function return_properties($url, $prop, $val, $documentTag, $class, $xml) 
	{
		$resource = '';
		
		if (isset($val->type)) $type = $val->type;
		else $type = "text";
	
		if (!isset($val->keyword))
		{
			switch ($type) {
				
			    case "resource":
			    if (isset($val->content)) {
					$resource =	$this->get_resource_from_id($val, $documentTag);
				}  
				else $resource = $this->return_resource($documentTag, $url);
				$property = $xml->createElement($this->get_label($val, $prop));
				$property->setAttribute("rdf:resource", $this->return_url($resource, $url));
			    break;
				
				case 'resourceplain': 
				$resource = $this->return_resource($documentTag, $url);
				$property = $xml->createElement($this->get_label($val, $prop), $this->return_url($resource, $url));
				break;
				
				case 'literal':
				$children = $documentTag->childNodes;
				$property = $xml->createElement($this->get_label($val, $prop));
				$property->setAttribute('rdf:datatype', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral');
				foreach ($children as $child) {
					if ($child != new DOMText) $child->setAttribute('xmlns', 'http://www.w3.org/1999/xhtml');
					$property->appendChild($xml->importNode($child, TRUE));
				}
				break;
						
				case 'cdata':
				$result = '';
				$children = $documentTag->childNodes;
				$property = $xml->createElement($this->get_label($val, $prop));
				foreach ($children as $child) {
					$result .= $this->return_node_value($child);
				}
				$cdata = $property->ownerDocument->createCDATASection($result);
				$property->appendChild($cdata);
				break;
				
			    case "text":
				$property = $this->return_text_nodes($val, $documentTag, $prop, $xml);
			    break;
				
				default:
				$property = $this->return_text_nodes($val, $documentTag, $prop, $xml);
				$property->setAttribute('rdf:datatype', $type);
				break;
			}
			$class->appendChild($property);
		} 
		else { 
		if (isset($val->keyword))
		{	
			if (isset($val->rev))
			{
				$root = $xml->createElement($val->rev);
				$class->appendChild($root);
				$newroot = $xml->createElement($this->get_label($val, $prop));
				$root->appendChild($newroot);
				$this->rdf_about($url, $documentTag, $val, $newroot);
			} 
			elseif (isset($val->type) && $val->type == "rdfresource")
			{
				$newroot = $xml->createElement($this->get_label($val, $prop));
				$class->appendChild($newroot);
				$newroot->setAttribute("rdf:parseType", "Resource");	
			}
			
			elseif (isset($val->type) && $val->type == "collection")
			{
				$newroot = $xml->createElement($this->get_label($val, $prop));
				$class->appendChild($newroot);
				$newroot->setAttribute("rdf:parseType", "Collection");	
			}
			elseif (isset($val->type) && $val->type == "literal")
			{
				$newroot = $xml->createElement($this->get_label($val, $prop));
				$class->appendChild($newroot);
				$newroot->setAttribute("rdf:parseType", "Literal");	
			}
			
			elseif (!isset($val->type) && !isset($val->rev))
			{
				$this->root = $xml->createElement($this->get_label($val, $prop));
				$class->appendChild($this->root);
				$newroot = $xml->createElement("rdf:Description");
				$this->root->appendChild($newroot);
			}
			
			$documentTags = $documentTag->getElementsByTagName('*');
			
			foreach ( $documentTags as $documentTag ) 
				$this->json_query_properties($url, $val, $documentTag, $newroot, $xml, $hasroot = true);
			}
		}
		unset( $class, $text, $resource );
	}
	
	protected function rand_filename($ext)
	{
		return preg_replace("/([0-9])/e","chr((\\1+112))",mt_rand(100000,999999)).'.'.$ext;
	}
	
	protected function return_error($num) 
	{
	switch ($num) {
		case "1":
			return 'Could not get the URL';
		break;
		case "2":
			return 'Could not get the Dataset';
		break;
		case "3":
			return 'Dataset not well formed please validate your dataset at <a href="http://www.jsonlint.com/">http://www.jsonlint.com/</a>';
		break;       
		}
	}
}
?>