<form id="form" action="/" method="get">
<fieldset>
<legend><span style="color:#333333">trans</span><span style="color:#838383">form</span> by <a href="/" title="Transform using a url">url</a> or direct input</legend>
<p id="field">
	<label for="text"><textarea title="Input a Well formed Fragment of HTML" name="text" id="text" tabindex="1"><?php if (!isset($_GET['text'])) echo htmlentities('<div class="vcard" id="BusinessEntity">
   <span class="fn"><a class="url org" href="http://pizza.example.com/">L\'Amourita Pizza</a></span>, 
   <div class="adr">
     <span class="street-address">2040 Any Street</span>
     <span class="locality">Springfield</span>
     <span class="region">WA</span>
     <span class="postal-code">98102</span>, 
	 Tel: <span class="tel">206-555-7242</span>
   </div>
</div>')?></textarea></label>
</p>
<p style="text-align:left; margin-left:10px"><label for="type">Type: <select tabindex="2" id="type" name="type">
<optgroup label="Microformats">
	<option selected="selected" value="hcard">hCard</option>
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
	<option value="hfoaf">hFOAF</option>
	<option value="hatom-sioc">hAtom SIOC</option>
</optgroup>
<optgroup label="Non-Microformats">
	<option value="rdfa">RDFa</option>
	<option value="ogp-rdf">OGP</option>
</optgroup>
</select></label> 
<label for="output">Output: 
<select tabindex="3" id="output" name="output">
<optgroup label="Default">
	<option selected="selected" value="">Default Output</option>
</optgroup>
<optgroup label="If supported">
	<option value="ntriples">NTriples</option>
	<option value="turtle">Turtle</option>
	<option value="rdfjson">RDFJSON</option>
	<option value="rdfa">RDFa</option>
	<option value="html">HTML(Microdata)</option>
</optgroup>
</select></label>
<label for="submit"><button tabindex="4" id="submit" type="submit">Submit</button></label></p>
</fieldset>
</form>
