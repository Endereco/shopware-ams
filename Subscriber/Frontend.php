<?php
/**
 * (c) endereco UG (haftungsbeschränkt) <info@endereco.de>
 *
 */
namespace EnderecoAMS\Subscriber;

use Enlight\Event\SubscriberInterface;
use Doctrine\Common\Collections\ArrayCollection;

class Frontend implements SubscriberInterface
{
	/**
	 * @var string
	 */
	private $pluginDir;
	private $accounting;

	/**
	 * @param string $pluginDir
	 */
	public function __construct($pluginDir, $accounting) {
		$this->pluginDir = $pluginDir;
		$this->accounting = $accounting;
	}

	/**
	 * {@inheritdoc}
	 */
	public static function getSubscribedEvents()
	{
		return [
			'Theme_Compiler_Collect_Plugin_Javascript' => 'onCollectJavascript',
			'Theme_Compiler_Collect_Plugin_Css' => 'onCollectCss',
			'Theme_Inheritance_Template_Directories_Collected' => 'onCollectTemplateDir',
			'Shopware\Models\Customer\Address::postUpdate' => 'afterUserUpdate',
            'Shopware_Modules_Admin_SaveRegister_Successful' => 'afterUserUpdate',
		];
	}

	public function afterUserUpdate(\Enlight_Event_EventArgs $args)
	{
		$this->accounting->doAccounting();
	}

	/**
	 * @return ArrayCollection
	 */
	public function onCollectJavascript()
	{
		$jsPath = [
			$this->pluginDir . '/Resources/views/frontend/_public/src/js/Accounting.js',
			$this->pluginDir . '/Resources/views/frontend/_public/src/js/AddressCheck.js',
			$this->pluginDir . '/Resources/views/frontend/_public/src/js/CityNameAutocomplete.js',
			$this->pluginDir . '/Resources/views/frontend/_public/src/js/EmailCheck.js',
			$this->pluginDir . '/Resources/views/frontend/_public/src/js/NameCheck.js',
			$this->pluginDir . '/Resources/views/frontend/_public/src/js/PostCodeAutocomplete.js',
			$this->pluginDir . '/Resources/views/frontend/_public/src/js/PrephoneCheck.js',
			$this->pluginDir . '/Resources/views/frontend/_public/src/js/StatusIndicator.js',
			$this->pluginDir . '/Resources/views/frontend/_public/src/js/StreetAutocomplete.js',
			$this->pluginDir . '/Resources/views/frontend/_public/src/js/StreetShadow.js',
			$this->pluginDir . '/Resources/views/frontend/_public/src/js/CountryWatcher.js',
		];

		return new ArrayCollection($jsPath);
	}

	/**
	 * @return ArrayCollection
	 */
	public function onCollectCss()
	{
		$jsPath = [
			$this->pluginDir . '/Resources/views/frontend/_public/src/css/endereco-styles.css',
		];

		return new ArrayCollection($jsPath);
	}

	/**
	 * @param \Enlight_Event_EventArgs $args
	 */
	public function onCollectTemplateDir(\Enlight_Event_EventArgs $args)
	{
		$dirs = $args->getReturn();
		$dirs[] = $this->pluginDir . '/Resources/views/';

		$args->setReturn($dirs);
	}
}
