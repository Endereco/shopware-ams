{extends file="parent:frontend/address/form.tpl"}

{block name='frontend_address_form_input_salutation'}
    {capture name='c_frontend_address_form_input_salutation'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_register_personal_fieldset_input_title'}
    {capture name='c_frontend_register_personal_fieldset_input_title'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_address_form_input_firstname'}
    {capture name='c_frontend_address_form_input_firstname'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_address_form_input_lastname'}
    {capture name='c_frontend_address_form_input_lastname'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_address_form_input_street'}
    {capture name='c_frontend_address_form_input_street'}
        {$smarty.block.parent}
        <input type="hidden" name="address_form_prefix" value="{$inputPrefix}"/>
        <div class="address--zip-city address--street-name-number">
            <input autocomplete="section-billing billing street-address"
                   name="{$inputPrefix}[streetname]"
                   type="text"
                   required="required"
                   aria-required="true"
                   placeholder="{s name='RegisterPlaceholderStreetName' namespace='EnderecoAMS'}Straße{/s}{s name="RequiredField" namespace="frontend/register/index"}{/s}"
                   id="address_streetname"
                   value=""
                   class="address--field address--spacer address--field-streetname address--field-city is--required{if $error_flags.street} has--error{/if}"/>
            <input autocomplete="section-billing billing street-address"
                   name="{$inputPrefix}[streetnumber]"
                   type="text"
                   required="required"
                   aria-required="true"
                   placeholder="{s name='RegisterPlaceholderStreetNumber' namespace='EnderecoAMS'}Hausnummer{/s}{s name="RequiredField" namespace="frontend/register/index"}{/s}"
                   id="address_streetnumber"
                   value=""
                   class="address--field address--field-streetnumber address--field-zipcode is--required"/>
        </div>
        <div style="clear: both"></div>
    {/capture}
{/block}
{block name='frontend_address_form_input_addition_address_line1'}
    {capture name='c_frontend_address_form_input_addition_address_line1'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_address_form_input_addition_address_line2'}
    {capture name='c_frontend_address_form_input_addition_address_line2'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_address_form_input_zip_and_city'}
    {capture name='c_frontend_address_form_input_zip_and_city'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_address_form_input_country'}
    {capture name='c_frontend_address_form_input_country'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_address_form_input_country_states'}
    {capture name='c_frontend_address_form_input_country_states'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_address_form_input_phone'}
    {capture name='c_frontend_address_form_input_phone'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_address_form_input_set_default_shipping'}
    {capture name='c_frontend_address_form_input_set_default_shipping'}
        {$smarty.block.parent}
    {/capture}
{/block}
{block name='frontend_address_form_input_set_default_billing'}
    {capture name='c_frontend_address_form_input_set_default_billing'}
        {$smarty.block.parent}
    {/capture}
{/block}

{block name='frontend_address_form_fieldset_address'}
    {$smarty.block.parent}
    {$smarty.capture.c_frontend_address_form_input_salutation}
    {$smarty.capture.c_frontend_register_personal_fieldset_input_title}
    {$smarty.capture.c_frontend_address_form_input_firstname}
    {$smarty.capture.c_frontend_address_form_input_lastname}
    {$smarty.capture.c_frontend_address_form_input_country}
    {$smarty.capture.c_frontend_address_form_input_country_states}
    {$smarty.capture.c_frontend_address_form_input_zip_and_city}
    <div style="clear: both"></div>
    {$smarty.capture.c_frontend_address_form_input_street}
    {$smarty.capture.c_frontend_address_form_input_addition_address_line1}
    {$smarty.capture.c_frontend_address_form_input_addition_address_line2}
    {$smarty.capture.c_frontend_address_form_input_phone}
    {$smarty.capture.c_frontend_address_form_input_set_default_shipping}
    {$smarty.capture.c_frontend_address_form_input_set_default_billing}

    <script>
        (function() {
            function handleSelect(wunschSelector) {
                var streetNameBlock = wunschSelector.form.querySelector('.address--street-name-number');
                var streetNamefullBlock = wunschSelector.form.querySelector('.address--street');
                if ('address' === wunschSelector.value) {
                    if (streetNameBlock) {
                        streetNameBlock.style.setProperty('display', 'block', 'important');
                        streetNameBlock.querySelector('[name="{$inputPrefix}[streetname]"]').required = true;
                        streetNameBlock.querySelector('[name="{$inputPrefix}[streetnumber]"]').required = false;
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
                        streetNameBlock.querySelector('[name="{$inputPrefix}[streetname]"]').value = '';
                        streetNameBlock.querySelector('[name="{$inputPrefix}[streetnumber]"]').value = '';
                        streetNameBlock.querySelector('[name="{$inputPrefix}[streetname]"]').required = false;
                        streetNameBlock.querySelector('[name="{$inputPrefix}[streetnumber]"]').required = false;
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
                var wunschSelector = document.querySelector('[name="{$inputPrefix}[attribute][moptwunschpaketaddresstype]"]');
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
                    var wunschSelector = document.querySelector('[name="{$inputPrefix}[attribute][moptwunschpaketaddresstype]"]');
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
