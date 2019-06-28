<?php
/**
 * (c) endereco UG (haftungsbeschränkt) <info@endereco.de>
 *
 */

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

$ch = curl_init('http://endereco-service.de/rpc/v1');

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
		'X-Transaction-Referer: ' . $_SERVER['HTTP_X_TRANSACTION_REFERER'],
		'Content-Length: ' . strlen($dataString))
);

$result = curl_exec($ch);

$resultArray = json_decode($result, true);

if (isset($resultArray['result'])) {

    if (isset($_COOKIE['EnderecoTIDs'])) {
        $tidsArray = unserialize($_COOKIE['EnderecoTIDs']);
    } else {
        $tidsArray = array();
    }

	if (!isset($tidsArray[$tid])) {
        $tidsArray[$tid] = 1;
	} else {
        $tidsArray[$tid] = $tidsArray[$tid] + 1;
	}

    setcookie("EnderecoTIDs", serialize($tidsArray), time()+3600, '/', parse_url($_SERVER['HTTP_REFERER'], PHP_URL_HOST));
}

header('Content-Type: application/json');
echo $result;
die();
