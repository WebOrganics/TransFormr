<!-- Licence -->
<div class="vcard" id="transformr">
<p>Except where otherwise noted, <a class="url org fn" href="<?php echo $this->path; ?>">Transformr</a> is licensed under a GNU <a rel="license" href="files/gpl-3.0.txt">General Public Licence</a>.</p>
<p>TransFormr Version: <?php echo $this->version; ?> Updated: <?php echo $this->updated; ?>, Contact: <a class="email" href="mailto:info@weborganics.co.uk" id="sha1:77672c776f26b568548bc5b544967612b36de9a6">info@weborganics.co.uk</a></p>
</div>
<script type="text/javascript">
<!--
function bookmarkUrl() 
{	
  var transformer = "<?php echo $this->path; ?>";	
  var type = document.getElementById('type').value;
  var bookmarklet = "javascript:void(location.href='"+transformer+type+"/'+location.href)";
  document.getElementById('bookmark').innerHTML = '<a href="'+bookmarklet+'">'+type+' bookmarklet</a>';
}

function Validate(form) 
{
  var expression = new RegExp();
  expression.compile("^[A-Za-z]+://[A-Za-z0-9-_]+\\.[A-Za-z0-9-_%&\?\/.=]+$");
	
  if (!expression.test(form["url"].value)) 
  {
	form["url"].setAttribute("class", "Invalid");
	return false;
  }
  else
  {
	form["url"].setAttribute("class", "Valid");
	return true;
  }
}

function urlFocus() 
{
  document.getElementById('url').setAttribute("class", "Focus");
}

function urlReset() 
{
  document.getElementById('url').setAttribute("class", "Reset");
}	

function observeEvents() 
{
  var url = document.getElementById('url');
  var type = document.getElementById('type');
  
  url.focus();
  url.onblur = urlReset;
  url.onclick = urlFocus;
  
  type.onblur = bookmarkUrl;
  type.onclick = bookmarkUrl;
  
  this.urlFocus();
  this.bookmarkUrl();
}
window.onload = observeEvents;
// -->
</script>
</body>
</html>
<? exit; ?>
