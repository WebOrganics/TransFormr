<form id="form" onsubmit="return Validate(this);" action="" method="get">
<fieldset>
<legend><span style="color:#333333">trans</span><span style="color:#838383">form</span> by url or <a href="direct/" title="Transform a Fragment of HTML">direct input</a></legend>
<p>
<span id="urlfield">
	<label for="url" title="Enter a URL"><input tabindex="2" id="url" type="text" name="url" /></label>
</span>
</p><p style="text-align: left; padding-left: 5px;">
<label for="type">Type: <select tabindex="1" id="type" name="type" style="width: 240px;">
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
<label for="output">Output: 
<select tabindex="3" id="output" name="output" style="width: 240px;">
<optgroup label="Default">
	<option selected="selected" value="">Default Output</option>
</optgroup>
<optgroup label="RDF Types only">
	<option value="ntriples">NTriples</option>
	<option value="turtle">Turtle</option>
	<option value="rdfjson">RDFJSON</option>
	<option value="rdfa">RDFa</option>
	<option value="html">HTML(Microdata)</option>
</optgroup>
</select></label> 
<label for="submit"><button tabindex="3" id="submit" type="submit" style="width: 125px;">Submit</button></label></p>
<p class="pad">Drag this <span id="bookmark"></span>&nbsp;to your favorites.</p>
<?php include( 'errors.php' ); ?>
</fieldset>
</form>
