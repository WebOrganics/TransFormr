<!-- Licence -->
<div class="vcard" id="transformr">
<p>Except where otherwise noted, <a class="url org fn" href="<?php echo PATH; ?>">Transformr</a> is licensed under a GNU <a rel="license" href="files/gpl-3.0.txt">General Public Licence</a>.</p>
<p>TransFormr Version: <?php echo VERSION; ?> Updated: <?php echo UPDATED; ?>, Contact: <a class="email" href="mailto:info@weborganics.co.uk" id="sha1:77672c776f26b568548bc5b544967612b36de9a6">info@weborganics.co.uk</a></p>
</div>
<script src="script/ValidationTextField.js" type="text/javascript"></script>
<script type="text/javascript">
<!--
	var urlfield = new Spry.Widget.ValidationTextField("urlfield", "url");
//-->
</script>
<script type="text/javascript">
<!--
function bookmarkUrl() {
	
	var transformer = "<?php echo PATH; ?>";
	
	var type = document.getElementsByTagName('select')[0].value;
	var bookmarklet = "javascript:void(location.href='"+transformer+"?type="+type+"&amp;url='+escape(location.href))";
	document.getElementById('bookmark').innerHTML = '<a href="'+bookmarklet+'">'+type+' bookmarklet</a>';
}
	
function initForm() {
	document.getElementsByTagName('input')[0].focus();
	bookmarkUrl();
}
window.onload = initForm;
//-->
</script>
</body>
</html>
<? exit; ?>
