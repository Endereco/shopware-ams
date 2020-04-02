<?php
/**
 * (c) endereco UG (haftungsbeschränkt) <info@endereco.de>
 *
 */
namespace EnderecoAMS\Subscriber;

use Enlight\Event\SubscriberInterface;
use Doctrine\Common\Collections\ArrayCollection;
use Shopware\Components\Logger;

class Frontend implements SubscriberInterface
{
	/**
	 * @var string
	 */
	private $pluginDir;
	private $accounting;
	private $logger;

	/**
	 * @param string $pluginDir
	 */
	public function __construct($pluginDir, $accounting, $logger) {
		$this->pluginDir = $pluginDir;
		$this->accounting = $accounting;
		$this->logger = $logger;
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
            'Shopware_Controllers_Backend_Config_After_Save_Config_Element' => 'afterPluginSave'
		];
	}

	public function afterUserUpdate(\Enlight_Event_EventArgs $args)
	{
		$this->accounting->doAccounting();
	}

    /**
     * Clears the config cache after saving module.
     * Required to make the test button work properly.
     * @see https://forum.shopware.com/discussion/9317/event-beim-speichern-der-einstellungen-eines-plugins#Comment_200182
     *
     * @param \Enlight_Event_EventArgs $args
     */
    public function afterPluginSave(\Enlight_Event_EventArgs $args)
    {
        if (!$this->lastSave) {
            $select = "SELECT cp.name FROM s_core_plugins cp
                    JOIN s_core_config_forms cf ON cf.plugin_id = cp.id
                    JOIN s_core_config_elements ce ON ce.form_id = cf.id
                    WHERE ce.id = :element_id";

            /** @var  $element Shopware/Models/Config/Element */
            $element = $args->get('element');
            $id = $element->getId();

            $result = Shopware()->Db()->fetchRow($select, [':element_id' => $id]);
            if ($result && $result['name'] == 'EnderecoAMS') {
                $cacheManager = Shopware()->Container()->get('shopware.cache_manager');
                $cacheManager->clearConfigCache();
                $cacheManager->clearHttpCache();
                $this->lastSave = true;
            }
        }
    }

	/**
	 * @return ArrayCollection
	 */
	public function onCollectJavascript()
	{
		$jsPath = [
			$this->pluginDir . '/Resources/views/frontend/_public/src/js/Accounting.js',
            $this->pluginDir . '/Resources/views/frontend/_public/src/js/StatusIndicator.js',

			$this->pluginDir . '/Resources/views/frontend/_public/src/js/AddressCheck.js',

            $this->pluginDir . '/Resources/views/frontend/_public/src/js/CountryAutocomplete.js',
			$this->pluginDir . '/Resources/views/frontend/_public/src/js/CityNameAutocomplete.js',
            $this->pluginDir . '/Resources/views/frontend/_public/src/js/PostCodeAutocomplete.js',
            $this->pluginDir . '/Resources/views/frontend/_public/src/js/StreetAutocomplete.js',
            $this->pluginDir . '/Resources/views/frontend/_public/src/js/FieldsManager.js',

			$this->pluginDir . '/Resources/views/frontend/_public/src/js/EmailCheck.js',
			$this->pluginDir . '/Resources/views/frontend/_public/src/js/NameCheck.js',
			$this->pluginDir . '/Resources/views/frontend/_public/src/js/PrephoneCheck.js',
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
