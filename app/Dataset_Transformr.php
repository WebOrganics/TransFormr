<?php
class Dataset_Transformr extends ARC2_Transformr
{
	
	function __construct() {
	
		parent::__construct();
		$this->dataset = '';
		$this->html = file_get_contents($this->url);
		$this->object = json_decode(utf8_encode($this->html));
		$this->rdf_file = $this->rand_filename('rdf');
		$this->xml_file = $this->rand_filename('xml');
	}
	
	public function this_rdf_document($url)
	{
		$json = $this->object->query;
	
		if (isset($json->base)) {
			$this->html = file_get_contents($this->return_url($json->base, $url));
			$this->dataset = "json";
		}
		if (!$this->html) $this->return_error('1');
		
		$dom = new DomDocument();
		@$dom->loadHtml($this->html);
		$xpath = new DomXpath($dom);
		$parse = new ARC2_Transformr();
		
		if ($this->dataset == "json") $this->dataset = file_get_contents($url);
		else $this->dataset = file_get_contents($this->json_dataset($xpath, $url));		
		if (!$this->dataset) return $this->return_error('2');
		
		$this->object = json_decode(utf8_encode($this->dataset));
		if (!$this->object) return $this->return_error('3');
		
		$object = $this->object->query;
		
		$url = isset($object->base) ? $this->return_url($object->base , $url) : $url;
		
		$xml  = new DOMDocument('1.0', 'utf-8');
		$xml->preserveWhiteSpace = true;
		$xml->formatOutput = true;
		
		$root = $xml->createElementNS('http://www.w3.org/1999/02/22-rdf-syntax-ns#', 'rdf:RDF');
		$root->setAttribute("xml:base", $url);
		$this->set_xmlns($object, $root);
		$xml->appendChild($root);
		
		$documentTags = $dom->getElementsByTagName('*');
		
		foreach ( $documentTags as $documentTag ) {
			$this->json_query_rdf_properties($url, $object, $documentTag, $root, $xml, $hasroot = false);
		}
		if (isset($object->output)){ 
			return $parse->this_rdf($this->html, $xml->saveXML(), $object->output);
		}
		else {
			header("Content-type: application/rdf+xml");
			header("Content-Disposition: inline; filename=".$this->rdf_file);
			return $xml->saveXML();
		}
	}
	
	protected function json_query_rdf_properties($url, $object, $documentTag, $root, $xml, $hasroot) 
	{
		foreach ($object->keyword as $item => $value) {
		
		foreach ($this->return_node_or_attribute($item) as $attribute => $item) {
		
		if (preg_match("/\b$item\b/i", $documentTag->getAttribute($attribute)) 
			or
			$documentTag->nodeName == $item && $attribute == "node" ) {
					
			if (isset($value->keyword)) {
	
			$arrvalue = !isset($arrvalue) ? $arrvalue = array() : array_values($arrvalue);
		
			$class = $xml->createElement($this->get_label($value, $item));
			$root->appendChild($class);
					
			$this->rdf_about($url, $documentTag, $value, $class);
					
			$documentTags = $documentTag->getElementsByTagName('*');
					
				foreach ( $documentTags as $documentTag ) {	
												
					foreach ( $value->keyword as $prop => $val ) {
								
						foreach ($this->return_node_or_attribute($prop) as $attribute => $property) {
		
							if (preg_match("/\b$property\b/i", $documentTag->getAttribute($attribute) ) 
								or 
								$documentTag->nodeName == $property && $attribute == "node" ) {
								
									$parse_property = true;
									
									foreach ($arrvalue as $thiskey => $thisval) {
										if ($thisval == $property) $parse_property = false;
									}
									if (isset($val->multiple)) $parse_property = true;
									
									if ($parse_property == true) {									
										$this->return_rdf_properties($url, $property, $val, $documentTag, $class, $xml);
										$arrvalue[] = $property;
										}
									}
								}
							}
						} unset($arrvalue);
					} 
					else 
					{
						if ($hasroot == true ) {
							$this->return_rdf_properties($url, $item, $value, $documentTag, $root, $xml);
						}
						else {
							$class = $xml->createElement('rdf:Description');
							$root->appendChild($class);
							$this->rdf_about($url, $documentTag, $value, $class);
							$this->return_rdf_properties($url, $item, $value, $documentTag, $class, $xml);
						}
					}
				}
			}
		}
	}

	protected function return_rdf_properties($url, $prop, $val, $documentTag, $class, $xml, $resource = '') 
	{
		$type = isset($val->type) ? $val->type : "text";
		
		if (!isset($val->keyword))
		{
			switch ($type) {
				
			    case "resource":
				$resource = isset($val->content) ? $this->get_resource_from_id($val, $documentTag) : $this->return_resource($documentTag, $url);
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
	
			if (isset($val->rev))
			{
				$root = $xml->createElement($val->rev);
				$class->appendChild($root);
				$newroot = $xml->createElement($this->get_label($val, $prop));
				$root->appendChild($newroot);
				$this->rdf_about($url, $documentTag, $val, $newroot);
			} 
			elseif (isset($val->type) && $val->type == "resource")
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
				$this->json_query_rdf_properties($url, $val, $documentTag, $newroot, $xml, $hasroot = true);
		}
		unset( $class, $text, $resource );
	}
	
	protected function json_dataset($xpath, $url, $json_data ='') 
	{
		$data = "//*[contains(concat(' ',normalize-space(@rel), ' '),' dataset ')][1]";
		
		if($nodes = $xpath->query($data)) {
		
			foreach($nodes as $node) {
				$resource = $node->getAttribute('href');
				$json_data = $this->return_url($resource , $url);
            }
			return $json_data;
        }
	}
	
	protected function set_xmlns($object, $node) 
	{
	foreach ( $object->vocab as $prefix => $urlns ) {	
			if ($prefix == "value") {
				$thisns ="xmlns";
				$node->setAttribute($thisns, $urlns);
			}
			else {
				$thisns = "xmlns:".$prefix;
				$node->setAttributeNS('http://www.w3.org/2000/xmlns/' , $thisns, $urlns);
			}
		}
	}
	
	protected function reverse_strrchr($val, $selector)
	{
		$selector = strrpos($val, $selector);
		return substr($val, 0, $selector) != '' ? substr($val, 0, $selector) : null;
	}

	protected function forward_strrchr($val, $selector)
	{
		return strrchr($val, $selector) ? array_pop(explode($selector, $val)) : null;
	}

	protected  function get_attr_value($val)
	{
		$selectors = array('class' => '.', 'id' => '#', null => '~=');
		
		foreach ($selectors as $attribute => $selector) {
		
			if(!is_null( $this->reverse_strrchr($val, $selector)) && $selector == '~=' ) 
			{
				$result =  array( $this->reverse_strrchr($val, $selector) => $this->forward_strrchr($val, $selector) );
			}
			elseif(!is_null( $this->forward_strrchr($val, $selector)) && is_null($this->reverse_strrchr($val, $selector))) 
			{
				if (!$attribute == null) $result =  array( $attribute => $this->forward_strrchr($val, $selector) );
			}
		}
		return $result;
	}
	
	protected function return_node_or_attribute($val)
	{
		return !$this->get_attr_value($val) ? array('node' => $val) : $this->get_attr_value($val);
	}
	
	protected function get_label($value, $item) 
	{ 
		return isset($value->label) ? $value->label : $item;
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
	$about = isset($value->about) ? $value->about : true;
	
	if ( $documentTag->getAttribute('id') ) {
	
		if ( isset($value->about) && $about != false ) {
			
			foreach ($value->about as $id => $uri ) {
			
				if ($newids = explode('|', $id)) { 
				
					foreach ($newids as $newid) {
					
						return $documentTag->getAttribute('id') == $newid 
						? $class->setAttribute("rdf:about", $uri) 
						: $class->setAttribute("rdf:about", $url."#".$documentTag->getAttribute('id'));
					}
				}
				else {
					return $documentTag->getAttribute('id') == $id 
					? $class->setAttribute("rdf:about", $uri) 
					: $class->setAttribute("rdf:about", $url."#".$documentTag->getAttribute('id'));
				}
			}
		} 
		elseif( $about == true ) return $class->setAttribute("rdf:about", $url."#".$documentTag->getAttribute('id'));
	} 
	elseif ($documentTag->getAttribute('href')) return $class->setAttribute("rdf:about", $this->return_url($documentTag->getAttribute('href'), $url));
	elseif ($documentTag->getAttribute('src')) return $class->setAttribute("rdf:about", $this->return_url($documentTag->getAttribute('src'), $url));
	elseif( $about == true ) return $class->setAttribute("rdf:about", $url); 
	}
	
	protected function get_content_from_id($value, $documentTag, $content_id = null) 
	{	
	foreach ($value->content as $cid => $content) {
		if ($cid == "value") {
			$content_id = 1;
			$text = $content;
		}
		if ($newcids = explode('|', $cid)) {	
		foreach($newcids as $newcid) {		
			if ($documentTag->getAttribute('id') == $newcid) {
				$content_id = 1;
				$text = $content;
				}
			}
		}
		if ($documentTag->getAttribute('id') == $cid) {
			$content_id = 1;
			$text = $content;
		}
		else {
			if (is_null($content_id)) {
				if ($documentTag->getAttribute('datetime')) $text = $documentTag->getAttribute('datetime');
				elseif ($documentTag->getAttribute('content')) $text = $documentTag->getAttribute('content');
				else $text = $documentTag->nodeValue;
				}
			}
		}
		$text = str_replace(array("\r\n", "\r", "\n", "\t"), '', $text);
		return $text;
	}
	
	protected function get_resource_from_id($value, $documentTag, $content_id = '') 
	{
	foreach ($value->content as $cid => $content) {
	if ($cid == "value") {
		$content_id = 1;
		$resource = $content;
	}				
	if ($newcids = explode('|', $cid)) {
		foreach($newcids as $newcid) {		
			if ($documentTag->getAttribute('id') == $newcid) {
				$content_id = 1;
				$resource = $content;
				}
			}
		}
		if ($documentTag->getAttribute('id') == $cid) {
			$content_id = 1;
			$resource = $content;
		}
		else {
			if (is_null($content_id)) $resource = $this->return_resource($documentTag, $this->url);
			}
		}
		return $resource;
	}
	
	protected function return_node_value($doc, $result = '') 
	{	
		$tmpdoc = new DOMDocument();
		$tmpdoc->appendChild($tmpdoc->importNode($doc, TRUE));
		$tmpdoc->formatOutput = true;
		$result .= $tmpdoc->saveXML();
		$result = str_replace(array("\r\n", "\r", "\n", "\t", "&#xD;"), '', $result);
		$result = trim(preg_replace('/<\?xml.*\?>/', '', $result, 1));
		return $result;
	}

	protected function return_text_nodes($val, $documentTag, $prop, $xml) 
	{
		if (isset($val->content)) $text = $this->get_content_from_id($val, $documentTag);
		elseif ($documentTag->getAttribute('datetime')) $text = $documentTag->getAttribute('datetime');
		elseif ($documentTag->getAttribute('content')) $text = $documentTag->getAttribute('content');
		elseif ($documentTag->getAttribute('title')) $text = $documentTag->getAttribute('title');
		else $text = $documentTag->nodeValue;
		$text = str_replace(array("\r\n", "\r", "\n", "\t"), '', $text);
		$result = $xml->createElement($this->get_label($val, $prop), $text );
		return $result;
	}
	
	protected function return_resource($documentTag, $url) 
	{
		if ($documentTag->getAttribute('src')) $resource = $documentTag->getAttribute('src');
		elseif ($documentTag->getAttribute('href')) $resource = $documentTag->getAttribute('href');
		elseif ($documentTag->getAttribute('id')) $resource = $url."#".$documentTag->getAttribute('id');
		return $this->return_url($resource , $url);
	}
	
	protected function return_error($num ='') 
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
	exit;
	}
}
?>