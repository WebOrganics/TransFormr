<?php 
if (isset($_GET['error']))
{
	switch($_GET['error']) 
	{
		case 'invalidDoc':
			$error = 'Sorry Unable to load document ' . $this->url;
		break;
			
		case 'noURL':
			$error = 'Sorry URL: '. $this->url .' is Invalid';
		break;
			
		case 'invalidID':
			$error = 'Sorry ID from : '. $this->url.' does not exist';
		break;
			
		case 'noPHPTidy':
			$error = 'Sorry PHP Tidy function does not exist, try tidy_option = "online" ';
		break;
			
		case 'noW3CTidy':
			$error = 'Sorry online W3C tidy service is unavailable at this time';
		break;
			
		case 'tidyFail':
			$error = 'Sorry failed to tidy document '. $this->url. ' using php tidy';
		break;
	}
	echo '<p id="error" class="errors" onclick="return hideThis();">'. $error .'</p>';
}
?>