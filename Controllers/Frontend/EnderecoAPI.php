<?php
/**
 * (c) endereco UG (haftungsbeschränkt) <info@endereco.de>
 *
 */
use Shopware\Components\CSRFWhitelistAware;

class Shopware_Controllers_Frontend_EnderecoAPI extends \Enlight_Controller_Action implements CSRFWhitelistAware
{
	public function indexAction()
	{
		// Get settings.
		$config = $this->container->get('config');
		$apiKey = $config->get('enderecoApiKey');
        $agentInfo = "Endereco Shopware Client v2.2.1";

		Shopware()->Plugins()->Controller()->ViewRenderer()->setNoRender();
		$postData = $this->request->getRawBody();
		$postData = json_decode($postData, true);


		// Correct language
		if (isset($postData['params']['language'])) {
			$shopContext = $this->get('shopware_storefront.context_service')->getShopContext();
			$locale = $shopContext->getShop()->getLocale()->getLocale();
			$partsOfLocale = explode('_', $locale);
			$data['params']['language'] = strtolower($partsOfLocale[0]);
		}

		// Correct country
		if (isset($postData['params']['country'])) {
			if ('' == $postData['params']['country'] || 'de' == $postData['params']['country']) {
				$postData['params']['country'] = 'de';
			} else {
				$countryRepository = $this->container->get('models')->getRepository(\Shopware\Models\Country\Country::class);
				$postData['params']['country'] = strtolower($countryRepository->find(intval($postData['params']['country']))->getIso());
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
				'X-Agent: ' . $agentInfo,
				'Content-Length: ' . strlen($dataString))
		);

		$result = curl_exec($ch);

		$resultData = json_decode($result, true);
		if (isset($resultData['result'])) {
			$this->container->get('endereco_ams.components.accounting')->countTransaction($tid);
		}

		$response = $this->Response();
		$response->setHeader('Content-Type', 'application/json', true);
		$response->setBody($result);
		$response->sendResponse();
		die();
	}

	public function countryAction() {

        $postData = $this->request->getRawBody();
        $postData = json_decode($postData, true);
        $countryRepository = $this->container->get('models')->getRepository(\Shopware\Models\Country\Country::class);

        $returnArray = array();

        foreach ($postData['params']['countryIds'] as $index => $countryId) {
            $countryId = intval($countryId);
            if (0 === $countryId) {
                $returnArray[$index] = "";
            } else {
                $returnArray[$index] = strtolower($countryRepository->find($countryId)->getIso());
            }
        }

        $responseArray = array(
            'jsonrpc' => '2.0',
            'id' => 1,
            'result' => array(
                'countryCodes' => $returnArray
            ),
        );

        $response = $this->Response();
        $response->setHeader('Content-Type', 'application/json', true);
        $response->setBody(json_encode($responseArray));
        $response->sendResponse();
        die();
	}

	public function tidAction() {
		Shopware()->Plugins()->Controller()->ViewRenderer()->setNoRender();
		$cookies = $_COOKIE;
		$tids = array();
		foreach ($cookies as $cookieName => $value) {
		    if (intval($value)>0 && (strpos($cookieName, 'en_tid_') !== false)) {
                $tids[] = str_replace('en_tid_', '', $cookieName);
            }
        }
		echo '<pre>';
        print_r($tids);
		die();
	}

	public function getWhitelistedCSRFActions()
	{
		return [
			'index',
			'country',
		];
	}
}
