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
<script type="text/javascript">
<!--
function bookmarkUrl() 
{	
  var transformer = "<?php echo $this->path; ?>";	
  var type = document.getElementById('type').value;
  var bookmarklet = "javascript:void(location.href='"+transformer+"?type="+type+"&amp;url='+escape(location.href))";
  document.getElementById('bookmark').innerHTML = '<a href="'+bookmarklet+'">'+type+' bookmarklet</a>';
}

function Validate(form) 
{
  var expression = new RegExp();
  expression.compile("^[A-Za-z]+://[A-Za-z0-9-_]+\\.[A-Za-z0-9-_%&\#\?\/.=]+$");
	
  if (!expression.test(form["url"].value)) 
  {
	form["url"].setAttribute("class", "Invalid");
	return false;
  }
  else
  {
	form["url"].setAttribute("class", "Valid");
	return true;
  }
}

function urlFocus() 
{
  document.getElementById('url').setAttribute("class", "Focus");
}

function urlReset() 
{
  document.getElementById('url').setAttribute("class", "Reset");
}

function hideThis()
{
  document.getElementById('error').setAttribute('class', 'hidden');
}	

function observeEvents() 
{
  var url = document.getElementById('url');
  var type = document.getElementById('type');
  
  url.focus();
  url.onblur = urlReset;
  url.onclick = urlFocus;
  
  type.onblur = bookmarkUrl;
  type.onclick = bookmarkUrl;
  
  this.urlFocus();
  this.bookmarkUrl();
}
window.onload = observeEvents;
// -->
</script>
</head>
<body>
<div id="fork-me">
	<a href="http://wiki.github.com/WebOrganics/TransFormr">
		<img src="./images/github.png" alt="Fork me on github" />	
	</a>
</div>
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