<div class="vcard" id="transformr">
<p>TransFormr: v<?php echo $this->version; ?>,  Updated: <span class="updated" title="<?php echo $this->updated[1]; ?>"><?php echo $this->updated[0]; ?></span>, is a <a href="http://pfefferle.org/">Pfefferle.org</a> and <a href="http://weborganics.co.uk/">WebOrganics</a> project.</p>
<!-- Licence -->
<p>Except where otherwise noted <a class="url org fn" href="http://github.com/WebOrganics/TransFormr">Transformr</a> is licensed under a GNU <a rel="license" href="files/gpl-3.0.txt">General Public Licence</a>.</p>
</div>
<script type="text/javascript">
<!--
function bookmarkUrl() 
{	
  var transformer = "<?php echo $this->path; ?>";	
  var type = document.getElementById('type').value;
  var bookmarklet = "javascript:void(location.href='"+transformer+"?type="+type+"&amp;url='+escape(location.href))";
  document.getElementById('bookmark').innerHTML = '<a href="'+bookmarklet+'">'+type+' bookmarklet</a>';
}

function Validate(form) 
{
  var expression = new RegExp();
  expression.compile("^[A-Za-z]+://[A-Za-z0-9-_]+\\.[A-Za-z0-9-_%&\#\?\/.=]+$");
	
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

function hideThis()
{
  document.getElementById('error').setAttribute('class', 'hidden');
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
