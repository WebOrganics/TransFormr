<?php
class RDFa_Parser extends Transformr
{
	public function get_document($dom)
	{
	$contents = $this->get_json_data($dom);
	
	if (!$contents == null) 
	{
		foreach ($contents as $s => $content)
		{
			$output = utf8_encode(file_get_contents($content));
			$object = json_decode($output); 
			
			if (!$object) return $this->return_error("1"); 
			
			$this->set_xmlns_values($object, $dom);
			
			$doc = $this->replace_keyword_values($object, $dom->saveXML());
			
			return $doc;
			}
		} 
		else return $dom->saveXML();
	}
	
	private static function get_json_data($dom) {
	
	$xpath = new DomXpath($dom);
	
	$data = "//*[contains(concat(' ',normalize-space(@rel), ' '),' prefixMapping ') 
			and contains(concat(' ',normalize-space(@type), ' '),' application/json ')]";
			
		if($nodes = $xpath->query($data))
		{
			$values = array();
			
			foreach($nodes as $node)
			{
				$values[] = $node->getAttribute('href');
            }
			
			return  array_values($values);
        } 
	}

	private function set_xmlns_values($object, $dom)
	{
	$htmlNode = $dom->getElementsByTagName('html');
		
		foreach ( $object->prefix  as $key => $value ) 
		{
			$thisns = "xmlns:".$key;
			$htmlNode->item(0)->setAttributeNS('http://www.w3.org/2000/xmlns/' , $thisns, $value);
		}
	}
	
	private function replace_keyword_values($object, $doc) 
	{
		$attr = "(typeof|property|resource|about|rel|rev|datatype)"; /* match only RDFa attribute names */
	
		foreach ( $object->keyword  as $keyword => $value ) 
		{		
			$uri = $value->uri;
			
			$match1 = $attr.'="'.$keyword.'"'; /* match exact keyword @attr="keyword" */
			$match2 = $attr.'="(.*?)\s'.$keyword.'"'; /* space to left @attr="(.*) keyword" */
			$match3 = $attr.'="'.$keyword.'\s';  /* space to rigt @attr="keyword (.*)" */
			$match4 = $attr.'="\['.$keyword.'\]';  /* a curie @attr="[keyword]" */
			$match5 = $attr.'="(.*?)\s'.$keyword.'\s(.*?)"';  /* space either side @attr="(.*) keyword (.*)" */
			$match6 = "(\s)rel=\"stylesheet\"(\s)?";
			$patterns = array("/$match1/i", "/$match2/i", "/$match3/i", "/$match4/i", "/$match5/i", "/$match6/sU");
			
			$replace1 = '$1="'.$uri.'"';
			$replace2 = '$1="$2 '.$uri.'"';
			$replace3 = '$1="'.$uri.' ';
			$replace4 = '$1="['.$uri.']';
			$replace5 = '$1="$2 '.$uri.' $3"';
			
			$replacements = array($replace1, $replace2, $replace3, $replace4, $replace5, '');
			
			$doc = preg_replace($patterns, $replacements, $doc);
		}
		return $doc;
	}
	protected function return_error($num) 
	{
	switch ($num) {
		case "1":
			return 'Profile not well formed please validate your profile at <a href="http://www.jsonlint.com/">http://www.jsonlint.com/</a>';
		break;       
		}
	}
}
?>