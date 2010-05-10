<?php
/**
	hQR is a small class to convert hCard to QR-Taggs
	
	author: Matthias Pfefferle
	author url: http://notizblog.org
	script url: http://www.microform.at/hcard2qrcode/
*/

class hQR extends Transformr
{
	// kaywa api-key (http://api.qrcode.kaywa.com/services/api/key)
	var $apikey =	'6d9d83c3b82b70cc2723399c3b271092';
	
	// some vars
	var	$tiny_url =	'http://tinyurl.com/api-create.php?url=';
	var $url_x2v =	'http://microform.at/?type=hcard&url=';
	var $url_kaywa = 'http://qrcode.kaywa.com/img.php?s=6&amp;t=png&amp;d=';
	var $url_google = 'http://chart.apis.google.com/chart?chs=200x200&cht=qr&choe=UTF-8&chl=';
	
	function __construct() 
	{
		parent:: __construct();
	}
	
	// get the vCard parser url
	function getUrlVCard() {
		$url = $this->url_x2v . urlencode($this->url);
		return $url;        
    }
	
	// get the short url of the parser+vcard url
	function getTinyUrl() {
		$request = $this->tiny_url . $this->getUrlVCard();
		$url = $this->loadUrl($request);
		return $url;
	}
	
	// get the vCard code
	function getVCard() {
		$request = $this->getUrlVCard();
		$vcard = $this->loadUrl($request);
		return $vcard;        
    }
	
	// get the QR-Code of the short url
	function getUrlQR($qr_url = null) {
		if (!$qr_url) $qr_url = $this->url_google;
		$url = $qr_url . $this->getTinyUrl();
		return $url;        
    }
	
	// get the QR-Code of the full vCard
	function getVcardQR() {
		$qr = $this->url_kaywa . $this->getVCard();
		return $qr;        
    }
    
    function loadUrl($request) {
    	return $this->get_file_contents($request, $this->use_curl = 1);	
    }
}
?>
