# Passwords

## How password hash is generated

```php
<?php

$scUserName = 'username';
$scPassword = 'mypassword';
$generatedHash =  rs_password_hash("RS{$scUserName}{$scPassword}");

```