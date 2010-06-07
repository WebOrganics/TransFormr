<?php
/**
class:    ARC2 Store Template Plugin for Transformr
author:   Martin McEvoy
version:  2010-06-07

homepage: http://arc.semsol.org/
license:  http://arc.semsol.org/license
*/

ARC2::inc('StoreEndpoint');

class ARC2_StoreTemplatePlugin extends ARC2_StoreEndpoint {

  function __construct($a = '', &$caller) {
    parent::__construct($a, $caller);
  }
  
  function ARC2_StoreTemplatePlugin($a = '', &$caller) {
    $this->__construct($a, $caller);
  }
  
  function __init() {
	parent::__init();
  }
  
 /*  */
 
  function go($auto_setup = 0) {
    $this->handleRequest($auto_setup);
    $this->sendHeaders();
    echo $this->getResult();
  }

  function getHTMLFormDoc() {
    return '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
      ' . $this->getHTMLDocHead() . '
      ' . $this->getHTMLDocBody() . '
	</html>
    ';
  }

  function getHTMLDocHead() {
    return '<meta name="keywords" content="hCard Transformer,hAtom Transformer,hCalendar Transformer,Geo Transformer" />
		<meta name="description" content="A Microformats Transformer"/>
		<link type="application/atom+xml" title="TransFormr Updates Feed" href="http://github.com/feeds/WebOrganics/commits/TransFormr/master" rel="alternate" />
		<link type="application/rdf+xml" title="DOAP" href="../doap.rdf" rel="meta" />
		<link rel="icon" href="../favicon.ico" type="image/x-icon"/>
		<link rel="shortcut icon" href="../favicon.ico" type="image/x-icon" />
		<head>
    		<title>' . $this->getHTMLDocTitle() . '</title>
    		<style type="text/css">
        ' . $this->getHTMLDocCSS() . '
    		</style>
    	</head>
    ';
  }
  
  function getHTMLHeader() {
	return $this->v('endpoint_header', '<div class="butt"><small><a rel="nofollow" href="http://wiki.github.com/WebOrganics/TransFormr">Wiki</a> | <a rel="nofollow" href="http://github.com/WebOrganics/TransFormr">Source</a> | <a rel="nofollow" href="http://github.com/WebOrganics/TransFormr/issues">Issues</a> | <a title="Sparql Endpoint" href="?">Endpoint</a> | <a title="Store Dumps" href="../?type=dump">Store Dumps</a> 	</small></div><div class="heading"><h1><a title="Microformat Transformer" href="../"><img alt="Microformat Transformer" src="../images/microformat.png"/></a></h1><q cite="http://www.hp.com/hpinfo/execteam/speeches/fiorina/04openworld.html" class="subtitle">The goal is to transform data into information and information into insight.</q></div>', $this->a);
  }
  
  function getHTMLDocTitle() {
    return $this->v('endpoint_title', 'Microform.at Transformer - ARC SPARQL+ Endpoint (v' . ARC2::getVersion() . ')', $this->a);
  }
  
  function getHTMLDocHeading() {
    return $this->v('endpoint_heading', 'Microform.at ARC SPARQL+ Endpoint (v' . ARC2::getVersion() . ')', $this->a);
  }
  
  function getHTMLDocCSS() {
    $default = '	/*<![CDATA[*/
			@import "../stylesheets/endpoint.css";
		/*]]>*/';
    return $this->v('endpoint_css', $default, $this->a);
  }
  
  function getHTMLDocBody() {
    return '
    	<body>
		
        ' . $this->getHTMLHeader() . '
        <div id="content">
		<div class="intro">
          <p>
            <a href="?">This interface</a> implements 
            <a href="http://www.w3.org/TR/rdf-sparql-query/">SPARQL</a> and
            <a href="http://arc.semsol.org/docs/v2/sparql+">SPARQL+</a> via <a href="http://www.w3.org/TR/rdf-sparql-protocol/#query-bindings-http">HTTP Bindings</a>. 
          </p>
          <p>
            Enabled operations: <span class="upcase">' . join(', ', $this->getFeatures()) . '</span>. 
            Max. number of results : ' . $this->v('endpoint_max_limit', '<em>unrestricted</em>', $this->a) . '
          </p>
        </div>
        ' . $this->getHTMLDocForm() .'
        ' . ($this->p('show_inline') ? $this->query_result : '') . '
    	</div>
		</body>
    ';
  }
  
  function getHTMLDocForm() {
    $q = $this->p('query') ? htmlspecialchars($this->p('query')) : "SELECT * WHERE {\n  GRAPH ?g { ?s ?p ?o . }\n}\nLIMIT 10";
    return '
      <form id="sparql-form" action="?" enctype="application/x-www-form-urlencoded" method="' . ($_SERVER['REQUEST_METHOD'] == 'GET' ? 'get' : 'post' ) . '">
       <fieldset>
	   <legend>Query</legend>
	   <label for="query"><textarea id="query" name="query" rows="20" cols="80">' . $q . '</textarea></label>
        ' . $this->getHTMLDocOptions() . '
        <div class="form-buttons">
          <label for="submit"><input name="submit" type="submit" value="Send Query" /></label>
          <label for="reset"><input name="reset" type="reset" value="Reset" /></label>
        </div>
		</fieldset>
      </form>
    ';
  }
  
  function getHTMLDocOptions() {
    $sel = $this->p('output');
    $sel_code = ' selected="selected"';
    return '
      <div class="options">
        <h3>Options</h3>
        <dl>
          <dt class="first">Output format (if supported by type):</dt>
          <dd>
            <label for="output"><select id="output" name="output">
			<optgroup label="Options">
			  <option value="htmltab" ' . (!$sel ?  $sel_code : '') . '>HTML Table</option>
              <option value="xml" ' . ($sel == 'xml' ? $sel_code : '') . '>Sparql Results</option>
              <option value="json" ' . ($sel == 'json' ? $sel_code : '') . '>JSON</option>
              <option value="plain" ' . ($sel == 'plain' ? $sel_code : '') . '>Plain</option>
              <option value="php_ser" ' . ($sel == 'php_ser' ? $sel_code : '') . '>Serialized PHP</option>
              <option value="turtle" ' . ($sel == 'turtle' ? $sel_code : '') . '>Turtle</option>
              <option value="rdfxml" ' . ($sel == 'rdfxml' ? $sel_code : '') . '>RDF/XML</option>
              <option value="infos" ' . ($sel == 'infos' ? $sel_code : '') . '>Query Structure</option>
              ' . ($this->allow_sql ? '<option value="sql" ' . ($sel == 'sql' ? $sel_code : '') . '>SQL</option>' : '') . '
              <option value="tsv" ' . ($sel == 'tsv' ? $sel_code : '') . '>TSV</option>
			</optgroup>
            </select></label>
          </dd>
          
          <dt>jsonp/callback (for <span class="upcase">json</span> results)</dt>
          <dd>
            <label for="jsonp"><input type="text" id="jsonp" name="jsonp" value="' . htmlspecialchars($this->p('jsonp')) . '" /></label>
          </dd>
          
          <dt>API key (for <span class="upcase">delete</span> requests)</dt>
          <dd>
            <label for="key"><input type="text" id="key" name="key" value="' . htmlspecialchars($this->p('key')) . '" /></label>
          </dd>
          
          <dt>Show results inline: </dt>
          <dd>
            <label for="show_inline"><input type="checkbox" name="show_inline" value="1" ' . ($this->p('show_inline') ? ' checked="checked"' : '') . ' /></label>
          </dd>
          
        </dl>
      </div>
      <div class="options-2">
        Change HTTP method: 
            <a href="javascript:;" onclick="javascript:document.getElementById(\'sparql-form\').method=\'get\'">GET</a> 
            <a href="javascript:;" onclick="javascript:document.getElementById(\'sparql-form\').method=\'post\'">POST</a> 
       </div>
    ';
  }
  
  /*  */
  
 }