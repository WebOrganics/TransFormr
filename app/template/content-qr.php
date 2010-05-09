<div class="heading" style="clear:both;">
<h1><a href="<?php echo $this->path ; ?>" title="Microformats Transformer"><img src="images/transformr.png" alt="Microformats Transformer"></a></h1>
<q class="subtitle" cite="http://www.hp.com/hpinfo/execteam/speeches/fiorina/04openworld.html">The goal is to transform data into information and information into insight.</q>
</div>
<div id="content" class="hslice">
<?php
	print ('<h2>hCard to QRCode Result</h2>'."\n");
	print ('<h4>From <a href="'. $this->url .'">'. $this->url .'</a></h4>'."\n");
		
	// to load faster
	if( isset($_GET['full']) == true) {
		print ('<pre>'.$hqr->getVCard().'</pre>'."\n");
	}
		
	print ('<p><a href="'.$hqr->getUrlVCard().'">Save hCard as vCard</a> (Tiny Url: <a href="'.$hqr->getTinyUrl().'">'.$hqr->getTinyUrl().'</a>)</p>'."\n");
	print ('<h4>QR-Codes</h4>'."\n");
	print ('<p>QR-Code of the Tiny URL</p>'."\n");
	print ('<p><img src="'.$hqr->getUrlQR().'" alt="for your mobile phone" />'."\n");
	print ('<img src="'.$hqr->getUrlQR($hqr->url_kaywa).'" alt="for your mobile phone" /></p>'."\n");
	// to load faster
	if(isset($_GET['full']) == true) {
		print ('<p>QR-Code of the vCard</p>'."\n");
		print ('<p><img src="'.$hqr->getVcardQR().'" alt="for your mobile phone" /></p>'."\n");
	}
	print ('<small>Use the <a href="http://reader.kaywa.com/">kaywa reader</a> to save the hcard to your phone.</small>'."\n");
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
    