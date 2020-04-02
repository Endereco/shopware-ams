<?php
/**
 * (c) endereco UG (haftungsbeschränkt) <info@endereco.de>
 *
 */
namespace EnderecoAMS\Components;

use Shopware\Components\Logger;
use Shopware\Components\HttpClient\HttpClientInterface;
use Symfony\Component\HttpFoundation\Response;

class Accounting
{
	private $container;

	public function __construct($container, $logger, $http) {
		$this->container = $container;
        $this->logger = $logger;
        $this->http = $http;
	}

	/**
	 *  Send doAccontung request to all open transactions and reset counter.
	 */
	public function doAccounting()
	{
        $agentInfo = "Endereco Shopware Client v2.2.1";
        $tidPrefix = 'en_tid_';
		$data = array(
			'jsonrpc' => '2.0',
			'method'  => 'doAccounting',
		);

		$dataString = json_encode($data);

		// Extract TID's from COOKIES.
		$transactions = array();
		$hasTransactions = false;
        $cookies = $_COOKIE;
        foreach ($cookies as $cookieName => $value) {
            if (intval($value)>0 && (strpos($cookieName, 'en_tid_') !== false)) {
                $transactions[] = str_replace($tidPrefix, '', $cookieName);
            }
        }

        // Trigger do_accounting for each.
		if ($transactions) {
			$config = Shopware()->Container()->get('config');
			$apiKey = $config->get('enderecoApiKey');

            foreach ($transactions as $session_tid) {
                $hasTransactions = true;
                try {
                    $this->http->post(
                        'https://endereco-service.de/rpc/v1',
                        array(
                            'Content-Type' => 'application/json',
                            'X-Auth-Key' => $apiKey,
                            'X-Transaction-Id' => $session_tid,
                            'X-Transaction-Referer' => $_SERVER['HTTP_REFERER'],
                            'X-Agent' => $agentInfo,
                        ),
                        $dataString
                    );
                } catch(\Exception $exception) {
                    $this->logger->addError($exception->getMessage());
                }

                setcookie($tidPrefix.$session_tid, '', time()-3600, '/', parse_url($_SERVER['HTTP_REFERER'], PHP_URL_HOST));
            }

            // Trigger singleton do_conversion.
			if ($hasTransactions) {
				$data = array(
					'jsonrpc' => '2.0',
					'method'  => 'doConversion',
				);

				$dataString = json_encode($data);

                try {
                    $this->http->post(
                        'https://endereco-service.de/rpc/v1',
                        array(
                            'Content-Type' => 'application/json',
                            'X-Auth-Key' => $apiKey,
                            'X-Transaction-Id' => 'not_required',
                            'X-Transaction-Referer' => $_SERVER['HTTP_REFERER'],
                            'X-Agent' => $agentInfo,
                        ),
                        $dataString
                    );
                } catch(\Exception $exception) {
                    $this->logger->addError($exception->getMessage());
                }
			}
		}

	}
}
