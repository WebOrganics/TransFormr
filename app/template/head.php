<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-gb">
<head>
<title>Microform.at Transformer</title>
<meta name="keywords" content="hCard Transformer,hAtom Transformer,hCalendar Transformer,Geo Transformer" />
<meta name="description" content="A Microformats Transformer"/>
<link type="application/atom+xml" title="TransFormr Updates Feed" href="http://github.com/feeds/WebOrganics/commits/TransFormr/master" rel="alternate" />
<link type="application/rdf+xml" title="DOAP" href="<?php echo $this->path; ?>doap.rdf" rel="meta" />
<link rel="icon" href="<?php echo $this->path;?>favicon.ico" type="image/x-icon"/>
<link rel="shortcut icon" href="<?php echo $this->path;?>favicon.ico" type="image/x-icon" />
<link rel="stylesheet"  href="<?php echo $this->path; ?>stylesheets/user.css" media="all" />
</head>
<body>
<div class="butt">
	<small> 
		<a href="http://wiki.github.com/WebOrganics/TransFormr" rel="nofollow">Wiki</a> | 
		<a href="http://github.com/WebOrganics/TransFormr" rel="nofollow">Source</a> | 
		<a href="http://github.com/WebOrganics/TransFormr/issues" rel="nofollow">Issues</a> 
		<?php if ($this->use_store == 1 ) 
			echo ' | <a href="'.$this->path.'sparql/endpoint?" title="Sparql Endpoint">Endpoint</a> | ';
			echo '<a href="'.$this->path.'?type=dump" title="Store Dumps">Store Dumps</a> ';
			
		?>
	</small>
</div>
<div class="heading">
<h1><a href="<?php echo $this->path ; ?>" title="Microformat Transformer"><img src="<?php echo $this->path; ?>images/microformat.png" alt="Microformat Transformer" /></a></h1>
<q class="subtitle" cite="http://www.hp.com/hpinfo/execteam/speeches/fiorina/04openworld.html">The goal is to transform data into information and information into insight.</q>
</div>