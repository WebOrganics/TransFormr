<?php
/**
 * Typed nodes Serializer for ARC2_Transformr
 *
 * @author Benjamin Nowack
 * @license <http://arc.semsol.org/license>
 * @homepage <http://arc.semsol.org/>
 * @package ARC2
 * @version 2009-11-09
*/

ARC2::inc('RDFXMLSerializer');

class ARC2_PrettyRDFSerializer extends ARC2_RDFXMLSerializer {

  function __construct($a = '', &$caller) {
    parent::__construct($a, $caller);
  }
  
  function ARC2_PrettyRDFSerializer($a = '', &$caller) {
    $this->__construct($a, $caller);
  }

  function __init() {
    parent::__init();
    $this->type_nodes = true;
  }

  /*  */
  
}
