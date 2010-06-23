<?php
define('_Transformr', true);

include_once('../app/config.php');
include_once('../app/arc/ARC2.php');

$arc_config = array(

  'db_host' => $host,
  'db_user' => $user,
  'db_pwd' => $pwd,
  'db_name' => $name,
  'store_name' => $storename,
  'endpoint_features' => array(
    'ask', 'select', 'describe', 'construct', 'delete'
  ),
  'endpoint_timeout' => 60, 
  'endpoint_max_limit' => 1000, 
  'serializer_type_nodes' => 1,
  'endpoint_write_key' => $writekey
);

/* init */
$endpoint = ARC2::getComponent('StoreTemplatePlugin', $arc_config);

if (!$endpoint->isSetUp()) {
  $endpoint->setUp(); /* create  tables */
}

/* go */
print $endpoint->go();
?>
