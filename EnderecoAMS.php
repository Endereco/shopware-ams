<?php
/**
 * (c) endereco UG (haftungsbeschränkt) <info@endereco.de>
 *
 */
namespace EnderecoAMS;

use Shopware\Components\Plugin;
use Shopware\Components\Plugin\Context\ActivateContext;
use Shopware\Components\Plugin\Context\DeactivateContext;
use Shopware\Components\Plugin\Context\UninstallContext;
use Symfony\Component\DependencyInjection\ContainerBuilder;

class EnderecoAMS extends Plugin
{
	/**
	 * {@inheritdoc}
	 */
	public function build(ContainerBuilder $container)
	{
		$container->setParameter('endereco_ams.plugin_dir', $this->getPath());
		parent::build($container);
	}

	public function activate(ActivateContext $activateContext)
	{
		$activateContext->scheduleClearCache(ActivateContext::CACHE_LIST_ALL);
	}

	public function deactivate(DeactivateContext $deactivateContext)
	{
		$deactivateContext->scheduleClearCache(DeactivateContext::CACHE_LIST_ALL);
	}

	public function uninstall(UninstallContext $uninstallContext)
	{
		$uninstallContext->scheduleClearCache(UninstallContext::CACHE_LIST_ALL);
	}
}
