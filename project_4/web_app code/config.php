<?php
return [
    'db1' => [
        'host' => getenv('DB1_HOST') ?: 'localhost',
        'username' => getenv('DB1_USER') ?: 'username1',
        'password' => getenv('DB1_PASS') ?: 'password1',
        'database' => getenv('DB1_NAME') ?: 'database1',
    ],
    'db2' => [
        'host' => getenv('DB2_HOST') ?: 'localhost',
        'username' => getenv('DB2_USER') ?: 'username2',
        'password' => getenv('DB2_PASS') ?: 'password2',
        'database' => getenv('DB2_NAME') ?: 'database2',
    ]
];
?>