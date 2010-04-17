<?php
/*
homepage: http://arc.semsol.org/
license:  http://arc.semsol.org/license

class:    ARC2_RDFaSerializerPlugin
author:   Keith Alexander
version:  2008-03-05
*/

ARC2::inc('RDFSerializer');

class ARC2_RDFaSerializer extends ARC2_RDFSerializer {

  function __construct($a = '', &$caller) {
    parent::__construct($a, $caller);
  }
  
  function ARC2_RDFaSerializerPlugin($a = '', &$caller) {
    $this->__construct($a, $caller);
  }

  function __init() {
    parent::__init();
  }

  /*  */
  function getTerm($v, $type) {
    if (!is_array($v)) {/* iri or bnode */
      if (preg_match('/^\_\:(.*)$/', $v, $m)) {
        return ' about="[' . $v . ']"';
      }
      if ($type == 's') {
        return ' about="' . htmlspecialchars($v) . '"';
      }
      if ($type == 'p') {
        if ($pn = $this->getPName($v)) {
          return $pn;
        }
        return 0;
      }
  	}
  }
  
  function getHead() {
	$nl = "\n";
	$r =  '<div';
	$first_ns = 1;
	foreach ($this->used_ns as $v) {
      $r .= $first_ns ? ' ' : $nl . '  ';
      $r .= 'xmlns:' . $this->nsp[$v] . '="' .$v. '"';
      $first_ns = 0;
    }
    $r .= '>';
    return $r;
  }

  function getLabel($index, $uri){
	if(!isset($index[$uri])){
		return $uri;
	}
	else{
		$candidates = array('label','name','nick','mbox','title', 'fn');
		foreach ($index[$uri] as $p => $obs) {
			foreach($candidates as $c) if(preg_match('@'.$c.'$@', $p)){
				return is_array($obs[0])? isset($obs[0]['value'])? $obs[0]['value'] : $obs[0]['val'] : $obs[0];
			}
		}

	}
	return $uri;
  }
  
  function getFooter() {
    return '</div>';
  }
  
  function URItoLabel($uri){
	return array_pop(preg_split('/#|\//', $uri));
  }

  function getObjectType($o){
	
	if(preg_match('@[a-zA-Z]:.+@', $o)){
		return 'uri';
	}
	if(substr( $o, 0,2)=='_:'){
		return 'bnode';
	}
	else return 'literal';
	
	
  }

  function getSerializedIndex($index) {
    $r = '';
    $nl = "\n";
    foreach ($index as $s => $ps) {
	$r.= '<div><h2>'.$this->getLabel($index, $s).'</h2>';
      $r .= $r ? $nl . $nl : '';
      $s = $this->getTerm($s, 's');
      $r .= '  <dl' .$s . '>';
      $first_p = 1;
      foreach ($ps as $p => $os) {
        $r .= $nl . str_pad('', 4);
        $qname = $this->getTerm($p, 'p');
		$r.='<dt>'.$this->URItoLabel($p).'</dt>';
		foreach($os as $obj){
				
			if(!is_array($obj)){
				$obj = array(
					'value' => $obj,
					'type' => $this->getObjectType($obj),
					);
			}
			else{
						/* For backward/forward compatibility with rdf/json style */
						if(isset($obj['val'])) $obj['value'] = $obj['val'];
						if(isset($obj['dt'])) $obj['datatype'] = $obj['dt'];
				
			}
			$r.= '<dd';
			switch($obj['type']){
				case 'uri':
				case 'iri':
				 if(preg_match('@(jpg)|(gif)|(png)|(bmp)@', $obj['value'])){
					$r.=' rel="'.$qname.'"';
					
					$r.= '><img alt="'.$this->URItoLabel($p).'" src="'.$obj['value'].'" width="60"/>';
				}
				else{
					$r.= '><a rel="'.$qname.'" href="'.$obj['value'].'">'.$obj['value'].'</a>';
				}
				break;
				case 'bnode':
					$r.='><span rel="'.$qname.'" resource="['.$obj['value'].']">'.$obj['value'].'</span>';
				break;
				case 'literal':
					$r.=' property="'.$qname.'"';
					if(isset($obj['lang'])){
					 $r.=' xml:lang="' . htmlspecialchars($obj['lang'] ). '">'.htmlspecialchars($obj['value']);
					}
					elseif(!isset($obj['datatype'])){
						$r.='>'.htmlspecialchars($obj['value']);						
					}
			    	elseif(isset($obj['datatype']) AND $obj['datatype']== 'http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral'){
					 $r.='>'.$obj['value'];						
					}
					else{
					 $r.=' datatype="' . htmlspecialchars($obj['datatype'] ). '">'.htmlspecialchars($obj['value']);												
					}
				break; 
			}
			$r.= '</dd>';			
		}
      }
      $r .= $r ? $nl . '  </dl></div>' : '';


    }
    $r = $this->getHead() . $nl . $nl . $r . $this->getFooter();
    return  $r;
  }

  /*  */

}
?>