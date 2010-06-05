<div class="butt">
	<small> 
		<a href="http://wiki.github.com/WebOrganics/TransFormr" rel="nofollow">Wiki</a> | 
		<a href="http://github.com/WebOrganics/TransFormr" rel="nofollow">Source</a> | 
		<a href="http://github.com/WebOrganics/TransFormr/issues" rel="nofollow">Issues</a> 
		<?php if ($this->use_store == 1 ) 
			echo ' | <a href="'.$this->path.'endpoint/?" title="Sparql Endpoint">Endpoint</a> | ';
			echo '<a href="'.$this->path.'?type=dump" title="Store Dumps">Store Dumps</a> ';
		?>
	</small> 
</div>
<div class="heading">
<h1><a href="<?php echo $this->path ; ?>" title="Microformat Transformer"><img src="<?php echo $this->path; ?>images/microformat.png" alt="Microformat Transformer"/></a></h1>
<q class="subtitle" cite="http://www.hp.com/hpinfo/execteam/speeches/fiorina/04openworld.html">The goal is to transform data into information and information into insight.</q>
</div>
<form id="form" onsubmit="return Validate(this);" action="" method="get">
<fieldset>
<legend><span style="color:#333333">trans</span><span style="color:#838383">form</span> a url</legend>
<p><label for="type">Select type: <select tabindex="1" id="type" name="type">
<optgroup label="Default">
	<option selected="selected" value="detect">Detect all</option>
</optgroup>
<optgroup label="Microformats">
	<option value="hcard">hCard</option>
	<option value="hcard-rdf">hCard RDF</option>
	<option value="hatom">hAtom2Atom</option>
	<option value="hatom-rss2">hAtom RSS2</option>
	<option value="geo">Geo KML</option>
	<option value="hcalendar">hCalendar</option>
	<option value="hcalendar-rdf">hCalendar RDF</option>
	<option value="hreview">hReview RDF</option>
	<option value="haudio-rss">hAudio RSS2</option>
</optgroup>
<optgroup label="Experimental">
	<option value="mo-haudio">hAudio MO</option>
	<option value="haudio-xspf">hAudio XSPF</option>
	<option value="hfoaf">hFOAF</option>
	<option value="hcard2qrcode">hCard2QRCode</option>
	<option value="hatom-sioc">hAtom SIOC</option>
</optgroup>
<optgroup label="Non-Microformats">
	<option value="rdfa">RDFa</option>
	<option value="erdf">eRDF</option>
	<option value="ogp-rdf">OGP</option>
</optgroup>
</select></label> 
<span id="urlfield">
	<label for="url">Url: <input tabindex="2" id="url" type="text" name="url" /></label>
</span>
<label for="submit"><button tabindex="3" id="submit" type="submit">Submit</button></label></p>
<p class="pad">Drag this <span id="bookmark"></span>&nbsp;to your favorites.</p>
<?php 
if (isset($error) != '')
{
?>
	<p id="error" class="errors"><?php echo $error; ?> <a class="hide-button" href="#" onclick="return hideThis();" title="Continue">[continue]</a></p>
<?php
}
?>
</fieldset>
</form>
