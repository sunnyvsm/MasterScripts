<?php
$url='http://usvaopmq01.videologygroup.com:8162/admin/queues.jsp';
$username = 'admin';
$password = 'admin';

$context = stream_context_create(array(
    'http' => array(
        'header'  => "Authorization: Basic " . base64_encode("$username:$password")
    )
));
$data = file_get_contents($url, false, $context);

echo $data
 ?>
