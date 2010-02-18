<?php
class DatasetParse extends Transformr
{
	public $url = '';
	
	public function html_query($url)
	{
		$contents = '';
	
		$html = file_get_contents($url);
		
		$object = json_decode(utf8_encode($html));
		
		if (isset($object->query->base)) 
		{
			$html = file_get_contents($object->query->base);
			$contents = "json";
		}
		
		if (!$html) 
		{ 
			return self::return_error('1'); 
			exit;
		}
		
		$dom = new DomDocument();

		@$dom->loadHtml($html);
		$xpath = new DomXpath($dom);
		
		if ($contents == "json") $contents = file_get_contents($url);
		else $contents = file_get_contents(self::json_dataset($xpath));
		
		if (!$contents) 
		{ 
			return self::return_error('2');  
			exit;
		}
		
		$object = json_decode(utf8_encode($contents));  # decode dataset 
		
		if (!$object) 
		{ 
			return self::return_error('3'); 
			exit;
		}
		
		$object = $object->query;
		
		$xml  = new DOMDocument('1.0', 'utf-8');
		$xml->preserveWhiteSpace = true;
		$xml->formatOutput = true;
		$root = $xml->createElementNS('http://www.w3.org/1999/02/22-rdf-syntax-ns#', 'rdf:RDF');
		
		if ( isset($object->base) ) $url = $object->base;
		
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
			self::json_query_properties($url, $object, $documentTag, $root, $xml, $hasroot = false);
		}
		return $xml->saveXML();
	}
	
	private static function json_query_properties($url, $object, $documentTag, $root, $xml, $hasroot) 
	{
		foreach ($object->item as $item => $value) {
		
		foreach (self::return_node_or_attribute($item) as $attr => $i)
		{
			$attribute = $attr;
			$item = $i;
		}
			// Exact word match 
			if (preg_match("/\b$item\b/i", $documentTag->getAttribute($attribute)) 
				or
				$documentTag->nodeName == $item && $attribute == "node" ) {
					
					if (isset($value->item)) {
					
					$class = $xml->createElement(self::get_label($value, $item));
					$root->appendChild($class);
					
					self::rdf_about($url, $documentTag, $value, $class);
					
					$documentTags = $documentTag->getElementsByTagName('*');
					
					if (!isset($arrvalue) ) $arrvalue = array();
					else $arrvalue = array_values($arrvalue);
					
						foreach ( $documentTags as $documentTag ) 
						{						
						$parse_property = true;
							
							foreach ( $value->item as $prop => $val ) {
								
								foreach (self::return_node_or_attribute($prop) as $attr => $i)
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
										self::return_properties($url, $prop, $val, $documentTag, $class, $xml);
										$arrvalue[] = $prop;
									}
								}
							}
						}
						unset( $arrvalue, $thiskey, $thisval, $parse_property );
					}
					else {
					
						if ($hasroot == true ) 
						{
							self::return_properties($url, $item, $value, $documentTag, $root, $xml);
						}
						else 
						{
						if (!isset($arrvalue) ) $arrvalue = array();
						else $arrvalue = array_values($arrvalue);
							
						$parse_property = true;
							
						foreach ($arrvalue as $thiskey => $thisval)
						{
							if ($thisval == $prop) $parse_property = false;
						}
						if (isset($value->multiple)) $parse_property = true;
						
						if ($parse_property == true) {
							$class = $xml->createElement('rdf:Description');
							$root->appendChild($class);
							self::rdf_about($url, $documentTag, $value, $class);
							self::return_properties($url, $item, $value, $documentTag, $class, $xml);
							$arrvalue[] = $item;
						}
						unset( $arrvalue, $thiskey, $thisval, $parse_property );
					}
				}
			}
		}
	}
	
	
	private static function json_dataset($xpath) 
	{
		$json_data ='';
		
		$data = "//link[contains(concat(' ',normalize-space(@rel), ' '),' dataset ')]";
		if($nodes = $xpath->query($data)){
			foreach($nodes as $node){
				$json_data = $node->getAttribute('href');
            }
			return $json_data;
        }
	}
	
	private function reverse_strrchr($val, $selector)
	{
		$selector = strrpos($val, $selector);
	
		if (!substr($val, 0, $selector) == '') 
		{
			return substr($val, 0, $selector);
		}
		return null;
	}

	private function forward_strrchr($val, $selector)
	{
		if (strrchr($val, $selector))
		{
			return array_pop(explode($selector, $val));
		}
		return null;
	}

	private function get_attr_value($val)
	{
	$selectors = array('class' => '.', 'id' => '#', null => '~=');
	
		foreach ($selectors as $attribute => $selector)
		{
			if(!is_null( self::reverse_strrchr($val, $selector)) && $selector == '~=' )
			{
				return array( self::reverse_strrchr($val, $selector) => self::forward_strrchr($val, $selector) );
			}
			elseif(!is_null( self::forward_strrchr($val, $selector)) && is_null(self::reverse_strrchr($val, $selector)))
			{
				if (!$attribute == null) 
				{
					return array( $attribute => self::forward_strrchr($val, $selector) );
				}
			}
		}
	}
	
	private function return_node_or_attribute($val)
	{
		if (!self::get_attr_value($val)) return array('node' => $val);
		else return self::get_attr_value($val);
	}
	
	private function get_label($value, $item) 
	{
	
		if (isset($value->label)) $label = $value->label;
		else $label = $item;
		
		return $label;
	
	}
	
	private function return_url($resource, $url)
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
	
	private function rdf_about($url, $documentTag, $value, $class) 
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
	elseif ($documentTag->getAttribute('href')) return $class->setAttribute("rdf:about", self::return_url($documentTag->getAttribute('href'), $url));
	elseif ($documentTag->getAttribute('src')) return $class->setAttribute("rdf:about", self::return_url($documentTag->getAttribute('src'), $url));
	else 
		if( $about == true ) return $class->setAttribute("rdf:about", $url); 
	}

	private static function return_properties($url, $prop, $val, $documentTag, $class, $xml) 
	{
		$resource = '';
		
		if (isset($val->type)) $type = strtolower($val->type);
		else $type = "text";
	
		if (!isset($val->item))
		{
			switch ($type) {
				
			    case "resource":
			    if (isset($val->content)) {
					$resource =	self::get_resource_from_id($val, $documentTag);
				}  
				else $resource = self::return_resource($documentTag, $url);
				$property = $xml->createElement(self::get_label($val, $prop));
				$property->setAttribute("rdf:resource", self::return_url($resource, $url));
			    break;
				
				case 'resourceplain': 
				$resource = self::return_resource($documentTag, $url);
				$property = $xml->createElement(self::get_label($val, $prop), self::return_url($resource, $url));
				break;
				
				case 'literal':
				$children = $documentTag->childNodes;
				$property = $xml->createElement(self::get_label($val, $prop));
				$property->setAttribute('rdf:datatype', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral');
				foreach ($children as $child) {
					if ($child != new DOMText) $child->setAttribute('xmlns', 'http://www.w3.org/1999/xhtml');
					$property->appendChild($xml->importNode($child, TRUE));
				}
				break;
						
				case 'cdata':
				$result = '';
				$children = $documentTag->childNodes;
				$property = $xml->createElement(self::get_label($val, $prop));
				foreach ($children as $child) {
					$result .= self::return_node_value($child);
				}
				$cdata = $property->ownerDocument->createCDATASection($result);
				$property->appendChild($cdata);
				break;
				
			    case "string":
				$property = self::return_text_nodes($val, $documentTag, $prop, $xml);
				$property->setAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#string');
			    break;
				
			    case "int":
				$property = self::return_text_nodes($val, $documentTag, $prop, $xml);
				$property->setAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#int');
			    break;
				
			    case "integer":
				$property = self::return_text_nodes($val, $documentTag, $prop, $xml);
				$property->setAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#integer');
			    break;
				
			    case "decimal":
				$property = self::return_text_nodes($val, $documentTag, $prop, $xml);
				$property->setAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#decimal');
			    break;
				
			    case "duration":
				$property = self::return_text_nodes($val, $documentTag, $prop, $xml);
				$property->setAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#duration');
			    break;
				
				case "datetime":
				$property = self::return_text_nodes($val, $documentTag, $prop, $xml);
				$property->setAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#dateTime');
			    break;
				
			    case "date":
				$property = self::return_text_nodes($val, $documentTag, $prop, $xml);
				$property->setAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#date');
			    break;
				
			    case "time":
				$property = self::return_text_nodes($val, $documentTag, $prop, $xml);
				$property->setAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#time');
			    break;
				
			    case "text":
				$property = self::return_text_nodes($val, $documentTag, $prop, $xml);
			    break;  
			}
			$class->appendChild($property);
		} 
		else
		{ 
		$documentTags = $documentTag->getElementsByTagName('*');
		
		if (isset($val->item))
		{	
			if (isset($val->rev))
			{
				$root = $xml->createElement($val->rev);
				$class->appendChild($root);
				$newroot = $xml->createElement(self::get_label($val, $prop));
				$root->appendChild($newroot);
				self::rdf_about($url, $documentTag, $val, $newroot);
			} 
				else 
			{
				$newroot = $xml->createElement(self::get_label($val, $prop));
				$class->appendChild($newroot);
				if (!isset($val->about) ) $newroot->setAttribute("rdf:parseType", "Resource");	
			}
			foreach ( $documentTags as $documentTag ) 
				self::json_query_properties($url, $val, $documentTag, $newroot, $xml, $hasroot = true);
			}
		}
		unset( $class, $text, $resource );
	}
	
	private function get_content_from_id($value, $documentTag) 
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
				if ($documentTag->getAttribute('title')) 
				{
					$text = $documentTag->getAttribute('title');
				}
				elseif ($documentTag->getAttribute('datetime')) 
				{
					$text = $documentTag->getAttribute('datetime');
				}
				elseif ($documentTag->getAttribute('content')) 
				{
					$text = $documentTag->getAttribute('content');
				}
				else 
				{
					$text = $documentTag->nodeValue;
					}
				}
			}
		}
		$text = str_replace(array("\r\n", "\r", "\n", "\t"), '', $text);
		return $text;
	}
	
	private function get_resource_from_id($value, $documentTag) {
	
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
			if (is_null($content_id)) $resource = self::return_resource($documentTag, $url);
			}
		}
		return $resource;
	}
	
	private function return_node_value($child) 
	{	
	$result = '';
	
	$tmpdoc = new DOMDocument();
	$tmpdoc->appendChild($tmpdoc->importNode($child, TRUE));
	$tmpdoc->formatOutput = true;
	$result .= $tmpdoc->saveXML();
	$result = str_replace(array("\r\n", "\r", "\n", "\t"), '', $result);
	$result = trim(preg_replace('/<\?xml.*\?>/', '', $result, 1));
	
	return $result;
	}

	private function return_text_nodes($val, $documentTag, $prop, $xml) 
	{
	if (isset($val->content)) 
	{
		$text = self::get_content_from_id($val, $documentTag);
	}
	elseif ($documentTag->getAttribute('title')) $text = $documentTag->getAttribute('title');
	elseif ($documentTag->getAttribute('datetime')) $text = $documentTag->getAttribute('datetime');
	elseif ($documentTag->getAttribute('content')) $text = $documentTag->getAttribute('content');
	else $text = $documentTag->nodeValue;
	$text = str_replace(array("\r\n", "\r", "\n", "\t"), '', $text);
	$property = $xml->createElement(self::get_label($val, $prop), $text );
	return $property;
	}
	
	private function return_resource($documentTag, $url) 
	{
	if ($documentTag->getAttribute('src')) $resource = $documentTag->getAttribute('src');
	elseif ($documentTag->getAttribute('href')) $resource = $documentTag->getAttribute('href');
	elseif ($documentTag->getAttribute('id')) $resource = $url."#".$documentTag->getAttribute('id');
	
	return $resource;
	}
	
	private function return_error($num) 
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