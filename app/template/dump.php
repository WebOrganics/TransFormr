<div class="butt">
	<small> 
		<a href="http://wiki.github.com/WebOrganics/TransFormr" rel="nofollow">Wiki</a> | 
		<a href="http://github.com/WebOrganics/TransFormr" rel="nofollow">Source</a> | 
		<a href="http://github.com/WebOrganics/TransFormr/issues" rel="nofollow">Issues</a> 
		<?php if ($this->use_store == 1 ) 
			echo ' | <a href="'.$this->path.'endpoint/?" title="Sparql Endpoint">Endpoint</a> | ';
			echo '<a href="'.$this->path.'?type=dump" title="Store Dumps">Store Dumps</a> ';
		?>
	</small> 
</div>
<div class="heading">
<h1><a href="<?php echo $this->path ; ?>" title="Microformat Transformer"><img src="<?php echo $this->path; ?>images/microformat.png" alt="Microformat Transformer"></a></h1>
<q class="subtitle" cite="http://www.hp.com/hpinfo/execteam/speeches/fiorina/04openworld.html">The goal is to transform data into information and information into insight.</q>
</div>
<div style="text-align:left; margin: 30px 0;">
<h2>Microform.at Store Dumps</h2>
<p>This page lists all the <a href="http://www.wasab.dk/morten/blog/archives/2008/04/04/introducing-spog"><span title="Subject Predicate Object (Graph)">SPO(G)</span></a> store dumps (if any) made by the transformr store.</p>
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
$dir = @opendir($this->dump_location);
echo "<ol>\n";
if ($this->use_store == 1 ) {
	if ( get_dump_directory($this->dump_location) == 1) {
	
		while ($file = readdir($dir)) 
		{
			if($file!="." && $file!="..")
			echo "<li><a href=\"" . $this->dump_location . $file . "\">$file</a>,  size " . filesize($this->dump_location . $file) . "kb created on ". date('F d Y H:i:s', filemtime($this->dump_location . $file)) .".</li>\n";
		}
	}
	elseif (get_dump_directory($this->dump_location) == 3) echo "<li>Dump directory is invalid or unreadable by the webserver.</li>";
	else echo "<li>Sorry no store dumps here yet, please check back again soon.</li>";
}
else echo "<li><a href=\"http://arc.semsol.org/\">ARC2 Store</a> Disabled.</li>";
echo "</ol>\n";
closedir($dir);
?>
</div>