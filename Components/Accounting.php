<?php
/**
 * (c) endereco UG (haftungsbeschränkt) <info@endereco.de>
 *
 */
namespace EnderecoAMS\Components;

class Accounting
{
	private $container;

	public function __construct($container) {
		$this->container = $container;
	}

	/**
	 *  Send doAccontung request to all open transactions and reset counter.
	 */
	public function doAccounting()
	{

		$data = array(
			'jsonrpc' => '2.0',
			'method'  => 'doAccounting',
		);

		$data_string = json_encode($data);
		$transactions = unserialize($_COOKIE['EnderecoTIDs']);
		$hasTransactions = false;
		$transactionId = "";

		if ($transactions) {
			$config = Shopware()->Container()->get('config');
			$apiKey = $config->get('enderecoApiKey');

			$ch = curl_init('http://endereco-service.de/rpc/v1');
			foreach ($transactions as $session_tid => $counter) {
				if (0 < $counter) {
					$hasTransactions = true;
					$transactionId = $session_tid;

					curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
					curl_setopt($ch, CURLOPT_POSTFIELDS, $data_string);
					curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
					curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 4); // 4 seconds
					curl_setopt($ch, CURLOPT_TIMEOUT, 4); // 4 seconds
					curl_setopt(
						$ch,
						CURLOPT_HTTPHEADER,
						array(
							'Content-Type: application/json',
							'X-Auth-Key: ' . $apiKey,
							'X-Transaction-Id: ' . $session_tid,
							'X-Transaction-Referer: ' . $_SERVER['HTTP_REFERER'],
							'Content-Length: ' . strlen($data_string))
					);
					curl_exec($ch);
				}
			}

			if ($hasTransactions) {
				$data = array(
					'jsonrpc' => '2.0',
					'method'  => 'doConversion',
				);

				$data_string = json_encode($data);

				curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
				curl_setopt($ch, CURLOPT_POSTFIELDS, $data_string);
				curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
				curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 4); // 4 seconds
				curl_setopt($ch, CURLOPT_TIMEOUT, 4); // 4 seconds
				curl_setopt(
					$ch,
					CURLOPT_HTTPHEADER,
					array(
						'Content-Type: application/json',
						'X-Auth-Key: ' . $apiKey,
						'X-Transaction-Id: ' . $transactionId,
						'X-Transaction-Referer: ' . $_SERVER['HTTP_REFERER'],
						'Content-Length: ' . strlen($data_string))
				);
				curl_exec($ch);
			}

            setcookie("EnderecoTIDs", '', time()-3600, '/', parse_url($_SERVER['HTTP_REFERER'], PHP_URL_HOST));
		}

	}
}
