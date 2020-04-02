<?php
/**
 * (c) endereco UG (haftungsbeschränkt) <info@endereco.de>
 *
 */

$agentInfo = "Endereco Shopware Client v2.2.1";

// Get settings.
$postData = json_decode(file_get_contents('php://input'), true);

$apiKey = trim($_SERVER['HTTP_X_AUTH_KEY']);

// Correct language
if (isset($postData['params']['language'])) {
    $tempLanguage = explode('_', $postData['params']['language']);
    $data['params']['language'] = strtolower($tempLanguage[0]);
}

// Correct country
if (isset($postData['params']['country'])) {
    if ('' == $postData['params']['country'] || 'de' == $postData['params']['country']) {
        $postData['params']['country'] = 'de';
    }
}

$dataString = json_encode($postData);

$ch = curl_init('https://endereco-service.de/rpc/v1');

if ($_SERVER['HTTP_X_TRANSACTION_ID']) {
    $tid = $_SERVER['HTTP_X_TRANSACTION_ID'];
} else {
    $tid = 'not_set';
}

curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
curl_setopt($ch, CURLOPT_POSTFIELDS, $dataString);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt(
    $ch,
    CURLOPT_HTTPHEADER,
    array(
        'Content-Type: application/json',
        'X-Auth-Key: ' . $apiKey,
        'X-Transaction-Id: ' . $tid,
        'X-Agent: ' . $agentInfo,
        'X-Transaction-Referer: ' . $_SERVER['HTTP_X_TRANSACTION_REFERER'],
        'Content-Length: ' . strlen($dataString))
);

$result = curl_exec($ch);

$resultArray = json_decode($result, true);
$tidPrefix = 'en_tid_';

if (isset($resultArray['result'])) {
    $tidBlacklist = array(
        'not_set',
        'not_required',
    );

    if (!in_array($tid, $tidBlacklist)) {
        if (isset($_COOKIE[$tidPrefix.$tid])) {
            $tidsAmount = intval($_COOKIE[$tidPrefix.$tid]) + 1;
        } else {
            $tidsAmount = 1;
        }
        setcookie($tidPrefix.$tid, $tidsAmount, time()+3600, '/', parse_url($_SERVER['HTTP_REFERER'], PHP_URL_HOST));
    }

    if (isset($resultArray['cmd']['use_tid'])) {
        setcookie($tidPrefix.$resultArray['cmd']['use_tid'], 1, time()+3600, '/', parse_url($_SERVER['HTTP_REFERER'], PHP_URL_HOST));
    }
}

header('Content-Type: application/json');
echo $result;
die();
