<div class="butt">
	<small><a href="http://wiki.github.com/WebOrganics/TransFormr" rel="nofollow">Wiki</a> | <a href="http://github.com/WebOrganics/TransFormr" rel="nofollow">Source</a> | <a href="http://github.com/WebOrganics/TransFormr/issues" rel="nofollow">Issues</a> | Updates feed:</small> <a rel="alternate" href="http://github.com/feeds/WebOrganics/commits/TransFormr/master" title="TransFormr Updates Feed">
		<img alt="Atom Feed" src="images/Feeds_16x16.png"/>
	</a>
</div>
<div class="heading" style="clear:both;">
<h1><a href="<?php echo PATH; ?>" title="Microformats Transformer"><img src="images/transformr.png" alt="Microformats Transformer"/></a></h1>
<q class="subtitle" cite="http://www.hp.com/hpinfo/execteam/speeches/fiorina/04openworld.html">The goal is to transform data into information and information into insight.</q>
</div>

<form enctype="multipart/form-data" action="" method="get">
<fieldset>
<legend>Transform a url</legend>
<p><label for="type">Microformat type: <select tabindex="1" id="type" name="type">
<optgroup label="Default">
	<option selected="selected" value="detect">Detect all</option>
</optgroup>
<optgroup label="Type">
	<option value="hcard">hCard</option>
	<option value="hcard-rdf">hCard-RDF</option>
	<option value="hatom">hAtom2Atom</option>
	<option value="geo">Geo KML</option>
	<option value="hcalendar">hCalendar</option>
	<option value="hcalendar-rdf">hCalendar RDF</option>
	<option value="hreview">hReview RDF</option>
</optgroup>
<optgroup label="Experimental">
	<option value="rss2">hAtom2RSS2</option>
	<option value="rdfa2rdfxml">RDFa2RDF</option>
	<option value="haudio-rss2">hAudio2RSS2</option>
	<option value="hfoaf">hFOAF</option>	
    <option value="mrss">hAtom+hMedia2MRSS</option>
</optgroup>
</select></label> 
<span id="urlfield">
	<label for="url">Url: <input tabindex="2" id="url" type="text" name="url" /></label>
</span>
<label for="submit"><button tabindex="3" id="submit" type="submit">Submit</button></label></p>
</fieldset>
</form>
