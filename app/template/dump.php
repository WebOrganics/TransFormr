<div style="text-align:left; margin: 30px 0;">
<h2>Microform.at Store Dumps</h2>
<p>This page lists all the <?php echo $this->backup_type != '' ? strtoupper($this->backup_type) : 'SPOG' ; ?> store dumps (if any) made by the transformr store.</p>
<?php 
function get_dump_directory($folder){
    $c=0;
    if(is_dir($folder) ){
        $files = opendir($folder);
        while ($file=readdir($files)){
            $c++;
            if ($c>2)
               return 1; // dir contains something
        }
        return 0; // empty dir
    }
    else return 3;// invalid dir
}

$dir = @opendir($this->dump_location); // touch 
echo "<ol>\n";
if ($this->use_store == 1 ) {
	if ( get_dump_directory($this->dump_location) == 1) {
	
		while ($file = readdir($dir)) 
		{
			if($file!="." && $file!="..")
			echo "	<li><a href=\"" . $this->dump_location . $file . "\">$file</a>,  size " . 
			filesize($this->dump_location . $file) . 
			"kb created on ". 
			date('F d Y', filemtime($this->dump_location . $file)) .
			" at around " . 
			date('H:i:s', filemtime($this->dump_location . $file)) . 
			".</li>\n";
		}
	}
	elseif (get_dump_directory($this->dump_location) == 3) echo "<li>Dump directory is invalid or unreadable by the webserver.</li>";
	else echo "<li>Sorry no store dumps made here yet, please check back again soon.</li>";
}
else echo "<li><a href=\"http://arc.semsol.org/\">ARC2 Store</a> Disabled.</li>";
echo "</ol>\n";
closedir($dir);
?>
</div>