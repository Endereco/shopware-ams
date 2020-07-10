{extends file="parent:frontend/register/index.tpl"}

{block name='frontend_register_billing_fieldset_input_country'}
    {capture name='c_frontend_register_billing_fieldset_input_country'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_register_billing_fieldset_input_country_states'}
    {capture name='c_frontend_register_billing_fieldset_input_country_states'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_register_billing_fieldset_input_zip_and_city'}
    {capture name='c_frontend_register_billing_fieldset_input_zip_and_city'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_register_billing_fieldset_different_shipping'}
    {capture name='c_frontend_register_billing_fieldset_different_shipping'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_register_billing_fieldset_input_street'}
    {capture name='c_frontend_register_billing_fieldset_input_street'}
        {$smarty.block.parent}
        <div class="register--street-name-number">
            <input autocomplete="section-billing billing street-address-name"
                   name="register[billing][streetname]"
                   type="text"
                   required="required"
                   aria-required="true"
                   placeholder="{s name='RegisterPlaceholderStreetName' namespace='EnderecoAMS'}Straße{/s}{s name='RequiredField' namespace='frontend/register/index'}{/s}"
                   id="billing_streetname"
                   value=""
                   class="register--field register--spacer register--field-streetname register--field-city is--required{if isset($error_flags.street)} has--error{/if}" />
            <input autocomplete="section-billing billing street-address-number"
                   name="register[billing][streetnumber]"
                   type="text"
                   required="required"
                   aria-required="true"
                   placeholder="{s name='RegisterPlaceholderStreetNumber' namespace='EnderecoAMS'}Hausnummer{/s}{s name="RequiredField" namespace="frontend/register/index"}{/s}"
                   id="billing_streetnumber"
                   value=""
                   class="register--field register--field-streetnumber address--field-zipcode is--required" />
        </div>
        <div style="clear: both"></div>
    {/capture}
{/block}
{block name='frontend_register_billing_fieldset_input_addition_address_line1'}
    {capture name='c_frontend_register_billing_fieldset_input_addition_address_line1'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_register_billing_fieldset_input_addition_address_line2'}
    {capture name='c_frontend_register_billing_fieldset_input_addition_address_line2'}
        {$smarty.block.parent}
    {/capture}
{/block}

{block name='frontend_register_billing_fieldset_body'}
    <div hidden="true">
        {$smarty.block.parent}
    </div>
    <div class="panel--body is--wide">
        {$smarty.capture.c_frontend_register_billing_fieldset_input_country}
        {$smarty.capture.c_frontend_register_billing_fieldset_input_country_states}
        {$smarty.capture.c_frontend_register_billing_fieldset_input_zip_and_city}
        {$smarty.capture.c_frontend_register_billing_fieldset_input_street}
        {$smarty.capture.c_frontend_register_billing_fieldset_input_addition_address_line1}
        {$smarty.capture.c_frontend_register_billing_fieldset_input_addition_address_line2}
        {$smarty.capture.c_frontend_register_billing_fieldset_different_shipping}
    </div>

{/block}


{block name='frontend_register_shipping_fieldset_input_salutation'}
    {capture name='c_frontend_register_shipping_fieldset_input_salutation'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_register_shipping_fieldset_input_firstname'}
    {capture name='c_frontend_register_shipping_fieldset_input_firstname'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_register_shipping_fieldset_input_lastname'}
    {capture name='c_frontend_register_shipping_fieldset_input_lastname'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_register_shipping_fieldset_input_country'}
    {capture name='c_frontend_register_shipping_fieldset_input_country'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_register_shipping_fieldset_input_country_states'}
    {capture name='c_frontend_register_shipping_fieldset_input_country_states'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_register_shipping_fieldset_input_zip_and_city'}
    {capture name='c_frontend_register_shipping_fieldset_input_zip_and_city'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_register_shipping_fieldset_different_shipping'}
    {capture name='c_frontend_register_shipping_fieldset_different_shipping'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_register_shipping_fieldset_input_street'}
    {capture name='c_frontend_register_shipping_fieldset_input_street'}
        {$smarty.block.parent}
        <div class="register--street-name-number">
            <input autocomplete="section-shipping shipping street-address-name"
                   name="register[shipping][streetname]"
                   type="text"
                   required="required"
                   aria-required="true"
                   placeholder="{s name='RegisterPlaceholderStreetName' namespace='EnderecoAMS'}Street{/s}{s name='RequiredField' namespace='frontend/register/index'}{/s}"
                   id="shipping_streetname"
                   value=""
                   class="register--field register--spacer register--field-streetname register--field-city is--required{if isset($error_flags.street)} has--error{/if}" />
            <input autocomplete="section-shipping shipping street-address-number"
                   name="register[shipping][streetnumber]"
                   type="text"
                   required="required"
                   aria-required="true"
                   placeholder="{s name='RegisterPlaceholderStreetNumber' namespace='EnderecoAMS'}Number{/s}{s name="RequiredField" namespace="frontend/register/index"}{/s}"
                   id="shipping_streetnumber"
                   value=""
                   class="register--field register--field-streetnumber address--field-zipcode is--required" />
        </div>
        <div style="clear: both"></div>
    {/capture}
{/block}
{block name='frontend_register_shipping_fieldset_input_addition_address_line1'}
    {capture name='c_frontend_register_shipping_fieldset_input_addition_address_line1'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_register_shipping_fieldset_input_addition_address_line2'}
    {capture name='c_frontend_register_shipping_fieldset_input_addition_address_line2'}
        {$smarty.block.parent}
    {/capture}
{/block}

{block name='frontend_register_shipping_fieldset_body'}
    <div>
        {$smarty.block.parent}
    </div>
    <div class="panel--body is--wide" style="padding-top:0">
        {$smarty.capture.c_frontend_register_shipping_fieldset_input_salutation}
        {$smarty.capture.c_frontend_register_shipping_fieldset_input_firstname}
        {$smarty.capture.c_frontend_register_shipping_fieldset_input_lastname}
        {$smarty.capture.c_frontend_register_shipping_fieldset_input_country}
        {$smarty.capture.c_frontend_register_shipping_fieldset_input_country_states}
        {$smarty.capture.c_frontend_register_shipping_fieldset_input_zip_and_city}
        {$smarty.capture.c_frontend_register_shipping_fieldset_input_street}
        {$smarty.capture.c_frontend_register_shipping_fieldset_input_addition_address_line1}
        {$smarty.capture.c_frontend_register_shipping_fieldset_input_addition_address_line2}
        {$smarty.capture.c_frontend_register_shipping_fieldset_different_shipping}
    </div>
    <script>
        (function() {
            function handleSelect(wunschSelector) {
                var streetNameBlock = wunschSelector.form.querySelector('.register--shipping .register--street-name-number');
                var streetNamefullBlock = wunschSelector.form.querySelector('.register--shipping .register--street');
                if ('address' === wunschSelector.value) {
                    if (streetNameBlock) {
                        streetNameBlock.style.setProperty('display', 'block', 'important');
                        streetNameBlock.querySelector('[name="register[shipping][streetname]"]').required = true;
                        streetNameBlock.querySelector('[name="register[shipping][streetnumber]"]').required = false;
                    }
                    if (streetNamefullBlock) {
                        streetNamefullBlock.style.setProperty('display', 'none', 'important');
                    }
                    var interval = setInterval( function() {
                        if (undefined !== window.enderecoGlobal.streetShadowDef) {
                            if (window.enderecoGlobal.streetShadowDel) {
                                window.enderecoGlobal.streetShadowDel.config.streetSelector = window.enderecoGlobal.streetShadowDel.config.streetSelector.replace('rinput', 'input');
                            }
                            if (window.enderecoGlobal.streetShadowDef) {
                                window.enderecoGlobal.streetShadowDef.config.streetSelector = window.enderecoGlobal.streetShadowDef.config.streetSelector.replace('rinput', 'input');
                            }
                            clearInterval(interval)
                        }
                    }, 100);

                } else {
                    if (streetNameBlock) {
                        streetNameBlock.style.setProperty('display', 'none', 'important');
                        streetNameBlock.querySelector('[name="register[shipping][streetname]"]').value = '';
                        streetNameBlock.querySelector('[name="register[shipping][streetnumber]"]').value = '';
                        streetNameBlock.querySelector('[name="register[shipping][streetname]"]').required = false;
                        streetNameBlock.querySelector('[name="register[shipping][streetnumber]"]').required = false;
                    }
                    if (streetNamefullBlock) {
                        streetNamefullBlock.style.setProperty('display', 'block', 'important');
                    }

                    var interval = setInterval( function() {
                        if (undefined !== window.enderecoGlobal.streetShadowDef) {
                            if (window.enderecoGlobal.streetShadowDel) {
                                window.enderecoGlobal.streetShadowDel.config.streetSelector = window.enderecoGlobal.streetShadowDel.config.streetSelector.replace('input', 'rinput');
                            }
                            if (window.enderecoGlobal.streetShadowDef) {
                                window.enderecoGlobal.streetShadowDef.config.streetSelector = window.enderecoGlobal.streetShadowDef.config.streetSelector.replace('input', 'rinput');
                            }
                            clearInterval(interval)
                        }
                    }, 100);
                }

            }

            if (document.readyState === "complete") {
                var wunschSelector = document.querySelector('[name="register[shipping][attribute][moptwunschpaketaddresstype]"]');
                if (wunschSelector) {
                    wunschSelector.addEventListener('change', function(e) {
                        handleSelect(e.target);
                    });
                    var interval = setInterval( function() {
                        if (undefined !== window.enderecoGlobal.connection) {
                            handleSelect(wunschSelector);
                            clearInterval(interval)
                        }
                    }, 100);

                }
            } else {
                document.addEventListener("DOMContentLoaded", function() {
                    var wunschSelector = document.querySelector('[name="register[shipping][attribute][moptwunschpaketaddresstype]"]');
                    if (wunschSelector) {
                        wunschSelector.addEventListener('change', function(e) {
                            handleSelect(e.target);
                        });
                        var interval = setInterval( function() {
                            if (undefined !== window.enderecoGlobal.connection) {
                                handleSelect(wunschSelector);
                                clearInterval(interval)
                            }
                        }, 100);

                    }
                });
            }
        })();
    </script>
{/block}

