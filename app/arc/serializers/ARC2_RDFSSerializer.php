<?php
/**
 * ARC2 RDFS Serializer
 *
*/

ARC2::inc('RDFXMLSerializer');

class ARC2_RDFSSerializer extends ARC2_RDFXMLSerializer {

  function __construct($a = '', &$caller) {
    parent::__construct($a, $caller);
  }
  
  function ARC2_RDFSSerializer($a = '', &$caller) {
    $this->__construct($a, $caller);
  }

  function __init() {
    parent::__init();
    $this->content_header = 'application/rdf+xml';
    $this->type_nodes = true;
  }

  /*  */
  
}
