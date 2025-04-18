<?php
include "../include/db.php";
header('Content-Type: application/json');
include_once "../include/image_processing.php";
include_once "../include/api_functions.php";
include_once "../include/ajax_functions.php";
include_once "../include/api_bindings.php";
include_once "../include/login_functions.php";
include_once "../include/dash_functions.php";

# Get authentication mode (userkey, sessionkey or native)
$authmode = getval("authmode","userkey");

# Native authmode always required
if (!$enable_remote_apis && $authmode !== "native")
    {
    http_response_code(403);
    exit("API not enabled.");
    }

debug("API:");
define("API_CALL", true);

# Get parameters
$user = getval("user","");
$sign = getval("sign","");
$query = $_SERVER["QUERY_STRING"];
$pretty = filter_var(getval('pretty', ''), FILTER_VALIDATE_BOOLEAN); # Should response be prettyfied?

# Support POST request where 'query' is POSTed and is the full query string.
if (getval("query","")!="") {$query=getval("query","");}

# Remove the pretty, sign and authmode parameters if passed as these would not have been present when signed on the client.
# For example, pretty JSON is just how the client wants the response back, doesn't need to to be part of the signing key process.
parse_str($query, $query_params);
if (isset($query_params['sign']))
    {
    $query = str_ireplace("sign=" . $query_params['sign'], "!|!|", $query);
    }
if (isset($query_params['authmode']))
    {
    $query = str_ireplace("authmode=" . $query_params['authmode'], "!|!|", $query);
    }
if (isset($query_params['pretty']))
    {
    $query = str_ireplace("pretty=" . $query_params['pretty'], "!|!|", $query);
    }
$query = str_replace("&!|!|", "", ltrim($query, "!|!|&")); # remove joining &

$validauthmodes = array("userkey", "native", "sessionkey");
$function = getval("function","");
if(!in_array($authmode,$validauthmodes))
    {
    $authmode="userkey";
    }
if($function != "login")
    {
    if($authmode == "native")
        {
        define('API_AUTHMODE_NATIVE', true);
        include(__DIR__ . "/../include/authenticate.php");
        }
    else
        {
        # Authenticate based on the provided signature.
        if(!check_api_key($user, $query, $sign, $authmode))
            {
            debug("API: Invalid signature");
            http_response_code(401);
            exit("Invalid signature");
            }
    
        # Log user in (if permitted)
        $userref = get_user_by_username($user);
        $validuser = setup_user(get_user($userref));
        if(!$validuser)
            {
            ajax_send_response(
                401,
                ['error' => [
                    'status' => 401,
                    'title'  => $GLOBALS['lang']['unauthorized'],
                    'detail' => $GLOBALS['lang']['error-permissiondenied']
                ]]
            );
            }
            ps_query("UPDATE user 
                         SET last_active = NOW(),
                             last_ip = ?,
                             last_browser = ?
                       WHERE ref = ?",
                       ["s",get_ip(),"s","API","i",$userref], false, -1, true, 0);
        }
    }

echo execute_api_call($query, $pretty);
debug("API: finished execute_api_call({$query});");
