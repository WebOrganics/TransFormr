<form id="form" action="index.php" method="post">
<fieldset>
<legend><span style="color:#333333">trans</span><span style="color:#838383">form</span> by <a href="index.php" title="Transform using a url">url</a> or direct input</legend>
<p id="field">
	<label for="text"><textarea title="Enter Some X/HTML Here" name="text" id="text" tabindex="1"><?php if (!isset($_GET['text'])) echo htmlentities('<div itemscope itemtype="http://data-vocabulary.org/Organization"> 
    <span itemprop="name">L\'Amourita Pizza</span>
    Located at 
    <span itemprop="address" itemscope 
      itemtype="http://data-vocabulary.org/Address">
      <span itemprop="street-address">123 Main St</span>, 
      <span itemprop="locality">Albuquerque</span>, 
      <span itemprop="region">NM</span>.
    </span>
    Phone: <span itemprop="tel">206-555-1234</span>.
    <a href="http://www.example.com" itemprop="url">http://pizza.example.com</a>.
</div>')?></textarea></label>
</p>
<p style="text-align: left; margin-left: 50px;">
Change HTTP method: 
	<a onclick="javascript:document.getElementById('form').method='get'" href="javascript:;">GET</a> 
	<a onclick="javascript:document.getElementById('form').method='post'" href="javascript:;">POST</a>
</p>
<p><label for="type">Type: <select tabindex="2" id="type" name="type">
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
	<option value="hfoaf">hFOAF</option>
	<option value="hatom-sioc">hAtom SIOC</option>
</optgroup>
<optgroup label="Non-Microformats">
	<option value="rdfa">RDFa</option>
	<option value="ogp-rdf">OGP</option>
	<option value="microdata"  selected="selected">Microdata</option>
</optgroup>
</select></label> 
<label for="output">Output: 
<select tabindex="3" id="output" name="output">
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
<label for="submit"><button tabindex="4" id="submit" type="submit">Submit</button></label></p>
</fieldset>
</form>
