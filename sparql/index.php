<?php
define('_Transformr', true);
ini_set('display_errors',  0 );
include_once('../app/config.php');

$arc_config = array(

  'db_host' => $host,
  'db_user' => $user,
  'db_pwd' => $pwd,
  'db_name' => $name,

  'store_name' => $storeName,

  'endpoint_features' => array(
    'ask', 'select', 'describe', 'construct', 'delete'
  ),
  
  'endpoint_timeout' => 60, 
  'endpoint_max_limit' => 1000, 
  'serializer_type_nodes' => 1,
  'endpoint_write_key' => $writekey,
  
  'ns' => $ns,
);

/* init */
$endpoint = ARC2::getComponent('StoreTemplatePlugin', $arc_config);

if (!$endpoint->isSetUp()) {
  $endpoint->setUp(); /* create  tables */
}

/* go */
print $endpoint->go();
?>
