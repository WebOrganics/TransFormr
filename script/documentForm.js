// JavaScript Document
function bookmarkUrl() {
	
	var transformer = "http://transformr.co.uk/";
	
	var type = document.getElementsByTagName('select')[0].value;
	var bookmarklet = "javascript:void(location.href='"+transformer+"?type="+type+"&amp;url='+escape(location.href))";
	document.getElementById('bookmark').innerHTML = '<a href="'+bookmarklet+'">'+type+' bookmarklet</a>';
}
	
function initForm() {
	document.getElementsByTagName('input')[0].focus();
	bookmarkUrl();
}
window.onload = initForm;