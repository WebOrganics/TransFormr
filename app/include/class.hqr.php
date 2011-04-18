<?php
defined( '_Transformr' ) or die( 'Restricted access' );
/**
	hQR is a small class to convert hCard to QR-Tags
	author: Matthias Pfefferle
	author url: http://notizblog.org
	script url: http://www.microform.at/hcard2qrcode/
*/

class hQR extends Transformr
{	
	// some vars
	var	$tiny_url =	'http://tinyurl.com/api-create.php?url=';
	var $url_vcard = '?type=hcard&url=';
	var $url_local = 'app/include/QRCode/generate.php?s=6&e=Q&d=';
	var $url_google = 'http://chart.apis.google.com/chart?chs=200x200&cht=qr&choe=UTF-8&chl=';
	
	function __construct() 
	{
		parent::__construct();
	}
	
	// get the vCard parser url
	function getUrlVCard() {
		$url = $this->path. $this->url_vcard . urlencode($this->url);
		return $url;        
    }
	
	// get the short url of the parser+vcard url
	function getTinyUrl() {
		$request = $this->tiny_url . $this->getUrlVCard();
		$url = $this->loadUrl($request);
		return $url;
	}
	
	// get the first vCard code
	function getVCard() {
		$request = $this->getUrlVCard();
		$vcard = $this->loadUrl($request);
		$newcard = explode("END:VCARD",$vcard);
		$newcard = $newcard[0] . "END:VCARD"; 
		return $newcard;        
    }
	
	// get the QR-Code of the short url
	function getUrlQR($qr_url = null) {
		if (!$qr_url) $qr_url = $this->url_google;
		$url = $qr_url . $this->getTinyUrl();
		return $url;        
    }
	
	// get the QR-Code of the full vCard
	function getVcardQR() {
		$qr = $this->path. $this->url_local . $this->getVCard();
		return $qr;        
    }
    
    function loadUrl($request) {
    	return $this->get_file_contents($request, $this->use_curl = 1);	
    }
}
?>
