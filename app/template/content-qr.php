<div class="heading" style="clear:both;">
	<h1><a href="<?php echo $this->path ; ?>" title="Microformats Transformer">
		<img src="images/transformr.png" alt="Microformats Transformer">
	</a></h1>
	<q class="subtitle" cite="http://www.hp.com/hpinfo/execteam/speeches/fiorina/04openworld.html">
		The goal is to transform data into information and information into insight.
	</q>
</div>
<div id="content" class="hslice">
<?php
	print ('<h2>hCard to QRCode Result</h2>'."\n");
	print ('<p>Source: <a href="'. $this->url .'">'. $this->url .'</a></p>'."\n");		
	print ('<p>Save hCard as <a href="'.$hqr->getUrlVCard().'">vCard</a> (Tiny Url: <a href="'.$hqr->getTinyUrl().'">'.$hqr->getTinyUrl().'</a>)</p>'."\n");
	print ('<h3>QR-Codes</h3>'."\n");
	
	// to load faster
	if(isset($_GET['full']) && $_GET['full'] == true) 
	{
		print ('<p>QR-Code of the vCard, Or get the <a href="'. $this->path. '?type=hcard2qrcode&amp;url='. urlencode($this->url) .'">small size version </a>.</p>'."\n");
		print ('<p><img src="'.$hqr->getVcardQR().'" alt="for your mobile phone" /></p>'."\n");
		print ('<p>Source of the vCard</p>'."\n");
		print ('<pre>'.$hqr->getVCard().'</pre>'."\n");
		
	} else {
		
		print ('<p>QR-Code of the Tiny URL, Or get the <a href="'. $this->path. '?type=hcard2qrcode&amp;full=true&amp;url='. urlencode($this->url) .'">full size version </a>.</p>'."\n");
		print ('<p><img src="'.$hqr->getUrlQR().'" alt="for your mobile phone" />'."\n");
		print ('<img src="'. $this->path .$hqr->getUrlQR($hqr->url_local).'" alt="for your mobile phone" /></p>'."\n");
	}
?>
</div>
<div style="clear: both; margin-top: 40px; margin-bottom: 40px;">
      <p>
        <strong>
          <a href="javascript:history.go(-1);">Go Back</a>
        </strong>
      </p>
</div>
</body>
</html>
    