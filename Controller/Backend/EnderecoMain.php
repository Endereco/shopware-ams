<?php
/**
 * (c) endereco UG (haftungsbeschränkt) <info@endereco.de>
 *
 */

namespace EnderecoAMS\Controller\Backend;

use Shopware\Components\Logger;
use Shopware\Components\HttpClient\HttpClientInterface;
use Symfony\Component\HttpFoundation\Response;

class EnderecoMain extends \Shopware_Controllers_Backend_ExtJs
{
    /**
     * @var Logger
     */
    private $logger;
    private $http;

    public function __construct(HttpClientInterface $http, Logger $logger)
    {
        $this->logger = $logger;
        $this->http = $http;
        parent::__construct();
    }

    /**
     * This function creates a readiness check request to remote server.
     * It tries to figure out 2 things:
     * 1. Is the server available
     * 2. Is the API Key correct
     *
     */
    public function testApiConfigAction()
    {
        $readinessCheckRequest = array(
            'jsonrpc' => '2.0',
            'id' => 1,
            'method' => 'readinessCheck',
        );
        $dataString = json_encode($readinessCheckRequest);

        $config = Shopware()->Container()->get('config');
        $apiKey = $config->get('enderecoApiKey');
        $agentInfo = 'Endereco Shopware Client v2.2.1';

        try {
            $response = $this->http->post(
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

            $status = json_decode($response->getBody(), true);
            if ('ready' === $status['result']['status']) {
                $this->View()->assign('response', Shopware()->Snippets()->getNamespace('EnderecoAMS')->get('apiOK'));
            }
        } catch (\Exception $exception) {
            $errorMessage = $exception->getMessage();
            // Log it.
            $this->logger->addError($exception->getMessage());

            $this->response->setStatusCode(Response::HTTP_INTERNAL_SERVER_ERROR);

            if (strpos($errorMessage, '400') !== false) {
                $this->View()->assign('response', Shopware()->Snippets()->getNamespace('EnderecoAMS')->get('apiError'));
            } else {
                $this->View()->assign('response', $exception->getMessage());
            }
        }
    }
}
