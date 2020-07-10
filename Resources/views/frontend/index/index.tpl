{extends file="parent:frontend/index/index.tpl"}

{block name="frontend_index_header_javascript"}
    {$smarty.block.parent}

    {$colorData = [
        'primaryColor' => {config name='enderecoUseprimaryColor' namespace="EnderecoAMS"},
        'primaryColorHover' => {config name='enderecoUseprimaryColorHover' namespace="EnderecoAMS"},
        'secondaryColor' => {config name='enderecoUsesecondaryColor' namespace="EnderecoAMS"},
        'warningColor' => {config name='enderecoUsewarningColor' namespace="EnderecoAMS"},
        'successColor' => {config name='enderecoUsesuccessColor' namespace="EnderecoAMS"}
    ]}

    {$textData = [
        'addressCheckHead' => {"{s namespace='EnderecoAMS' name='addressCheckHead'}Adresse prüfen{/s}"},
        'addressCheckButton' => {"{s namespace='EnderecoAMS' name='addressCheckButton'}Adresse übernehmen{/s}"},
        'addressCheckArea1' => {"{s namespace='EnderecoAMS' name='addressCheckArea1'}Ihre Eingabe:{/s}"},
        'addressCheckArea2' => {"{s namespace='EnderecoAMS' name='addressCheckArea2'}Unsere Vorschläge:{/s}"}
    ]}

    {$enderecoConfig = [
        'enderecoUseStatus' => {config name='enderecoUseStatus' namespace="EnderecoAMS"},
        'enderecoUseAddressServices' => {config name='enderecoUseAddressServices' namespace="EnderecoAMS"},
        'enderecoUseEmailCheck' => {config name='enderecoUseEmailCheck' namespace="EnderecoAMS"},
        'enderecoUseNameCheck' => {config name='enderecoUseNameCheck' namespace="EnderecoAMS"},
        'enderecoUsePrephoneCheck' => {config name='enderecoUsePrephoneCheck' namespace="EnderecoAMS"},
        'enderecoPrephoneFormat' => {config name='enderecoUsePrephoneFormat' namespace="EnderecoAMS"},

        'enderecoLocale' => {$Shop->getLocale()->toString()},
        'apiKey' => {config name='enderecoApiKey' namespace="EnderecoAMS"},
        'countryEndpoint' => {url controller='enderecoapi' action='country' _seo=false},
        'aternateServiceUrl' => {url controller='enderecoapi' action='index' _seo=false},
        'serviceUrl' => {link file="frontend/_public/src/io.php"}
    ]}

    <script>
        window.enderecoGlobal = {
            enderecoConfig: {$enderecoConfig|json_encode},
            connection: false,
            popUpId: '',
            referer: document.querySelector('body').className,
            textDirection: function() {
              return 'ltr';
            },
            enderecoColorData: {$colorData|json_encode},
            enderecoTextData: {$textData|json_encode}
        }
    </script>
    <script>

    </script>
    <script>
        function enSetCookie(name,value,days) {
            var expires = "";
            if (days) {
                var date = new Date();
                date.setTime(date.getTime() + (days*24*60*60*1000));
                expires = "; expires=" + date.toUTCString();
            }
            document.cookie = name + "=" + (value || "")  + expires + "; path=/";
        }
        function enGetCookie(name) {
            var nameEQ = name + "=";
            var ca = document.cookie.split(';');
            for(var i=0;i < ca.length;i++) {
                var c = ca[i];
                while (c.charAt(0)==' ') c = c.substring(1,c.length);
                if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
            }
            return null;
        }

        function checkConnection() {
            var request = {
                'jsonrpc': '2.0',
                'id': 1,
                'method': 'readinessCheck'
            };

            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function() {
                var response;
                if(4 === xhr.readyState) {
                    response = JSON.parse(xhr.responseText);
                    if (undefined !== response.result && 'ready' === response.result.status) {
                        window.enderecoGlobal.connection = true;
                        window.shouldInitiate = false;
                    } else {
                        window.enderecoGlobal.connection = false;
                    }
                }
            };
            xhr.open('POST', window.enderecoGlobal.enderecoConfig.serviceUrl, true);
            xhr.setRequestHeader("Content-type", "application/json");
            xhr.setRequestHeader("X-Auth-Key", window.enderecoGlobal.enderecoConfig.apiKey);
            xhr.setRequestHeader("X-Transaction-Id", 'not_required');
            xhr.setRequestHeader("X-Transaction-Referer", window.enderecoGlobal.referer);
            xhr.send(JSON.stringify(request));
        }
    </script>


    <script>
        var connectionListener;

        function initConfigs() {
            if (undefined === window.enderecoGlobal) {
                window.enderecoGlobal = {};
            }

            window.enderecoGlobal.colorsStatusIndicator = {
                'warningColor': window.enderecoGlobal.enderecoColorData.warningColor,
                'successColor':  window.enderecoGlobal.enderecoColorData.successColor,
            };

            window.enderecoGlobal.colorsAddressCheck = {
                'primaryColor':  window.enderecoGlobal.enderecoColorData.primaryColor,
                'primaryColorHover':  window.enderecoGlobal.enderecoColorData.primaryColorHover,
                'primaryColorText': '#fff',
            };

            window.enderecoGlobal.colorsInputAssistant = {
                'secondaryColor':  window.enderecoGlobal.enderecoColorData.secondaryColor,
            };

            window.enderecoGlobal.texts = {
                'addressCheckHead':  window.enderecoGlobal.enderecoTextData.addressCheckHead,
                'addressCheckButton':  window.enderecoGlobal.enderecoTextData.addressCheckButton,
                'addressCheckArea1':  window.enderecoGlobal.enderecoTextData.addressCheckArea1,
                'addressCheckArea2':  window.enderecoGlobal.enderecoTextData.addressCheckArea2,
            };
        }

        function initiateAddressServices() {
            var serviceGroupDef = [], serviceGroupInv = [], serviceGroupDel= [];
            window.enderecoGlobal.countryAutocompleteDef = new CountryAutocomplete({
                'countrySelector': 'select[name="address[country]',
                'countryEndpoint': window.enderecoGlobal.enderecoConfig.countryEndpoint,
            });
            window.enderecoGlobal.countryAutocompleteDef.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );
            window.enderecoGlobal.countryAutocompleteInv = new CountryAutocomplete({
                'countrySelector': 'select[name="register[billing][country]"]',
                'countryEndpoint': window.enderecoGlobal.enderecoConfig.countryEndpoint,
            });
            window.enderecoGlobal.countryAutocompleteInv.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );
            window.enderecoGlobal.countryAutocompleteDel = new CountryAutocomplete({
                'countrySelector': 'select[name="register[shipping][country]"]',
                'countryEndpoint': window.enderecoGlobal.enderecoConfig.countryEndpoint,
            });
            window.enderecoGlobal.countryAutocompleteDel.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );

            // Street shadowing.
            window.enderecoGlobal.streetShadowInv = new FieldsManager({
                'streetNameSelector': 'input[name="register[billing][streetname]"]',
                'houseNumberSelector': 'input[name="register[billing][streetnumber]"]',
                'streetSelector': 'input[name="register[billing][street]"]'
            });

            window.enderecoGlobal.streetShadowDel = new FieldsManager({
                'streetNameSelector': 'input[name="register[shipping][streetname]"]',
                'houseNumberSelector': 'input[name="register[shipping][streetnumber]"]',
                'streetSelector': 'input[name="register[shipping][street]"]'
            });
            window.enderecoGlobal.streetShadowDef = new FieldsManager({
                'streetNameSelector': 'input[name="address[streetname]"]',
                'houseNumberSelector': 'input[name="address[streetnumber]"]',
                'streetSelector': 'input[name="address[street]"]'
            });

            window.enderecoGlobal.addressCheckInv = new AddressCheck({
                'streetSelector': 'input[name="register[billing][streetname]"]',
                'houseNumberSelector': 'input[name="register[billing][streetnumber]"]',
                'postCodeSelector': 'input[name="register[billing][zipcode]"]',
                'cityNameSelector': 'input[name="register[billing][city]"]',
                'countrySelector': 'select[name="register[billing][country]"]',
                'apiKey': window.enderecoGlobal.enderecoConfig.apiKey,
                'endpoint': window.enderecoGlobal.enderecoConfig.serviceUrl,
                'colors' : window.enderecoGlobal.colorsAddressCheck,
                'texts': window.enderecoGlobal.texts
            });
            window.enderecoGlobal.addressCheckInv.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );
            window.enderecoGlobal.addressCheckDel = new AddressCheck({
                'streetSelector': 'input[name="register[shipping][streetname]"]',
                'houseNumberSelector': 'input[name="register[shipping][streetnumber]"]',
                'postCodeSelector': 'input[name="register[shipping][zipcode]"]',
                'cityNameSelector': 'input[name="register[shipping][city]"]',
                'countrySelector': 'select[name="register[shipping][country]"]',
                'apiKey': window.enderecoGlobal.enderecoConfig.apiKey,
                'endpoint': window.enderecoGlobal.enderecoConfig.serviceUrl,
                'colors' : window.enderecoGlobal.colorsAddressCheck,
                'texts': window.enderecoGlobal.texts
            });
            window.enderecoGlobal.addressCheckDel.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );
            window.enderecoGlobal.addressCheckDef = new AddressCheck({
                'streetSelector': 'input[name="address[streetname]"]',
                'houseNumberSelector': 'input[name="address[streetnumber]"]',
                'postCodeSelector': 'input[name="address[zipcode]"]',
                'cityNameSelector': 'input[name="address[city]"]',
                'countrySelector': 'select[name="address[country]"]',
                'apiKey': window.enderecoGlobal.enderecoConfig.apiKey,
                'endpoint': window.enderecoGlobal.enderecoConfig.serviceUrl,
                'colors' : window.enderecoGlobal.colorsAddressCheck,
                'texts': window.enderecoGlobal.texts
            });
            window.enderecoGlobal.addressCheckDef.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );

            // Register postCodeAutocomplete for invoice address
            window.enderecoGlobal.postCodeAutocompleteInv = new PostCodeAutocomplete({
                'inputSelector': 'input[name="register[billing][zipcode]"]',
                'secondaryInputSelectors': {
                    'cityName': 'input[name="register[billing][city]"]',
                    'country': 'select[name="register[billing][country]"]'
                },
                'apiKey': window.enderecoGlobal.enderecoConfig.apiKey,
                'endpoint': window.enderecoGlobal.enderecoConfig.serviceUrl,
                'serviceGroup': serviceGroupInv,
                'colors' : window.enderecoGlobal.colorsInputAssistant
            });
            serviceGroupInv.push(window.enderecoGlobal.postCodeAutocompleteInv);
            window.enderecoGlobal.postCodeAutocompleteInv.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );
            // Register postCodeAutocomplete for del address
            window.enderecoGlobal.postCodeAutocompleteDel = new PostCodeAutocomplete({
                'inputSelector': 'input[name="register[shipping][zipcode]"]',
                'secondaryInputSelectors': {
                    'cityName': 'input[name="register[shipping][city]"]',
                    'country': 'select[name="register[shipping][country]"]'
                },
                'apiKey': window.enderecoGlobal.enderecoConfig.apiKey,
                'endpoint': window.enderecoGlobal.enderecoConfig.serviceUrl,
                'serviceGroup': serviceGroupDel,
                'colors' : window.enderecoGlobal.colorsInputAssistant
            });
            serviceGroupDel.push(window.enderecoGlobal.postCodeAutocompleteDel);
            window.enderecoGlobal.postCodeAutocompleteDel.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );
            // Register postCodeAutocomplete for del address
            window.enderecoGlobal.postCodeAutocompleteDef = new PostCodeAutocomplete({
                'inputSelector': 'input[name="address[zipcode]"]',
                'secondaryInputSelectors': {
                    'cityName': 'input[name="address[city]"]',
                    'country': 'select[name="address[country]"]'
                },
                'apiKey': window.enderecoGlobal.enderecoConfig.apiKey,
                'endpoint': window.enderecoGlobal.enderecoConfig.serviceUrl,
                'serviceGroup': serviceGroupDef,
                'colors' : window.enderecoGlobal.colorsInputAssistant
            });
            serviceGroupDef.push(window.enderecoGlobal.postCodeAutocompleteDef);
            window.enderecoGlobal.postCodeAutocompleteDef.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );

            // Register cityNameAutocomplete for invoice address
            window.enderecoGlobal.cityNameAutocompleteInv = new CityNameAutocomplete({
                'inputSelector': 'input[name="register[billing][city]"]',
                'secondaryInputSelectors': {
                    'postCode': 'input[name="register[billing][zipcode]"]',
                    'country': 'select[name="register[billing][country]"]'
                },
                'apiKey': window.enderecoGlobal.enderecoConfig.apiKey,
                'endpoint': window.enderecoGlobal.enderecoConfig.serviceUrl,
                'serviceGroup': serviceGroupInv,
                'colors' : window.enderecoGlobal.colorsInputAssistant
            });
            serviceGroupInv.push(window.enderecoGlobal.cityNameAutocompleteInv);
            window.enderecoGlobal.cityNameAutocompleteInv.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );
            // Register cityNameAutocomplete for del address
            window.enderecoGlobal.cityNameAutocompleteDel = new CityNameAutocomplete({
                'inputSelector': 'input[name="register[shipping][city]"]',
                'secondaryInputSelectors': {
                    'postCode': 'input[name="register[shipping][zipcode]"]',
                    'country': 'select[name="register[shipping][country]"]'
                },
                'apiKey': window.enderecoGlobal.enderecoConfig.apiKey,
                'endpoint': window.enderecoGlobal.enderecoConfig.serviceUrl,
                'serviceGroup': serviceGroupDel,
                'colors' : window.enderecoGlobal.colorsInputAssistant
            });
            serviceGroupDel.push(window.enderecoGlobal.cityNameAutocompleteDel);
            window.enderecoGlobal.cityNameAutocompleteDel.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );
            // Register cityNameAutocomplete for del address
            window.enderecoGlobal.cityNameAutocompleteDef = new CityNameAutocomplete({
                'inputSelector': 'input[name="address[city]"]',
                'secondaryInputSelectors': {
                    'postCode': 'input[name="address[zipcode]"]',
                    'country': 'select[name="address[country]"]'
                },
                'apiKey': window.enderecoGlobal.enderecoConfig.apiKey,
                'endpoint': window.enderecoGlobal.enderecoConfig.serviceUrl,
                'serviceGroup': serviceGroupDef,
                'colors' : window.enderecoGlobal.colorsInputAssistant
            });
            serviceGroupDef.push(window.enderecoGlobal.cityNameAutocompleteDef);
            window.enderecoGlobal.cityNameAutocompleteDef.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );

            // Register streetAutocomplete for invoice address
            window.enderecoGlobal.streetAutocompleteInv = new StreetAutocomplete({
                'inputSelector': 'input[name="register[billing][streetname]"]',
                'secondaryInputSelectors': {
                    'postCode': 'input[name="register[billing][zipcode]"]',
                    'cityName': 'input[name="register[billing][city]"]',
                    'country': 'select[name="register[billing][country]"]'
                },
                'apiKey': window.enderecoGlobal.enderecoConfig.apiKey,
                'endpoint': window.enderecoGlobal.enderecoConfig.serviceUrl,
                'serviceGroup': serviceGroupInv,
                'colors' : window.enderecoGlobal.colorsInputAssistant
            });
            serviceGroupInv.push(window.enderecoGlobal.streetAutocompleteInv);
            window.enderecoGlobal.streetAutocompleteInv.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );
            // Register streetAutocomplete for del address
            window.enderecoGlobal.streetAutocompleteDel = new StreetAutocomplete({
                'inputSelector': 'input[name="register[shipping][streetname]"]',
                'secondaryInputSelectors': {
                    'postCode': 'input[name="register[shipping][zipcode]"]',
                    'cityName': 'input[name="register[shipping][city]"]',
                    'country': 'select[name="register[shipping][country]"]'
                },
                'apiKey': window.enderecoGlobal.enderecoConfig.apiKey,
                'endpoint': window.enderecoGlobal.enderecoConfig.serviceUrl,
                'serviceGroup': serviceGroupDel,
                'colors' : window.enderecoGlobal.colorsInputAssistant
            });
            serviceGroupDel.push(window.enderecoGlobal.streetAutocompleteDel);
            window.enderecoGlobal.streetAutocompleteDel.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );
            // Register streetAutocomplete for del address
            window.enderecoGlobal.streetAutocompleteDef = new StreetAutocomplete({
                'inputSelector': 'input[name="address[streetname]"]',
                'secondaryInputSelectors': {
                    'postCode': 'input[name="address[zipcode]"]',
                    'cityName': 'input[name="address[city]"]',
                    'country': 'select[name="address[country]"]'
                },
                'apiKey': window.enderecoGlobal.enderecoConfig.apiKey,
                'endpoint': window.enderecoGlobal.enderecoConfig.serviceUrl,
                'serviceGroup': serviceGroupDef,
                'colors' : window.enderecoGlobal.colorsInputAssistant
            });
            serviceGroupDef.push(window.enderecoGlobal.streetAutocompleteDef);
            window.enderecoGlobal.streetAutocompleteDef.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );


            // Make street fields not required.
            if (document.querySelector('input[name="register[billing][street]"]')) {
                document.querySelector('input[name="register[billing][street]"]').required = false;
            }
            if (document.querySelector('input[name="register[shipping][street]"]')) {
                document.querySelector('input[name="register[shipping][street]"]').required = false;
            }
            if (document.querySelector('input[name="address[street]"]')) {
                document.querySelector('input[name="address[street]"]').required = false;
            }

            renderBlockingWindow('.register--submit');
            renderBlockingWindow('.address--form-actions .address--form-submit:nth-child(1)');
            renderBlockingWindow('.address--form-actions .address--form-submit:nth-child(2)');

        }

        /**
         * Adds a transparent div before the button, to intercept clicks.
         * If in that time to window is rendered, then simulate click on submit.
         *
         * @param buttonSelector A sting DOM selector of the button.
         */
        function renderBlockingWindow(buttonSelector) {
            if(!document.querySelector(buttonSelector)) {
                return;
            }
            var blockingWindow;
            var parentNode = document.querySelector(buttonSelector).parentNode;
            parentNode.style.position = "relative";

            // Create blocking window.
            blockingWindow = document.createElement('div');
            blockingWindow.className = 'endereco-blocking-overlay';
            blockingWindow.style.cursor = 'pointer';
            blockingWindow.style.position = 'absolute';
            blockingWindow.style.top = document.querySelector(buttonSelector).offsetTop+'px';
            blockingWindow.style.left = document.querySelector(buttonSelector).offsetLeft+'px';
            blockingWindow.style.width = document.querySelector(buttonSelector).offsetWidth+'px';
            blockingWindow.style.height = '100%';
            blockingWindow.style.zIndex = '9999';

            // Add child to buttons parent.
            parentNode.appendChild(blockingWindow);

            blockingWindow.addEventListener('click', function() {
                setTimeout( function(){
                    blockingWindow.parentNode.removeChild(blockingWindow);
                    if (anyKindOfAddressCheckActivity()) {
                        // Register callback
                        if (window.enderecoGlobal.addressCheckInv.wip) {
                            window.enderecoGlobal.addressCheckInv.successCallback.push(function(data) {
                                if (undefined !== data.result.predictions && 1 < data.result.predictions.length) {
                                    return;
                                }

                                if (-1 !== data.result.status.indexOf('A1100')) {
                                    return;
                                }

                                document.querySelector(buttonSelector).click(); // Click the button.
                            });
                            window.enderecoGlobal.addressCheckInv.errorCallback.push(function(data) {
                                document.querySelector(buttonSelector).click(); // Click the button.
                            });
                        }
                        if (window.enderecoGlobal.addressCheckDel.wip) {
                            window.enderecoGlobal.addressCheckDel.successCallback.push(function(data) {
                                if (undefined !== data.result.predictions && 1 < data.result.predictions.length) {
                                    return;
                                }

                                if (-1 !== data.result.status.indexOf('A1100')) {
                                    return;
                                }

                                document.querySelector(buttonSelector).click(); // Click the button.
                            });
                            window.enderecoGlobal.addressCheckDel.errorCallback.push(function(data) {
                                document.querySelector(buttonSelector).click(); // Click the button.
                            });
                        }
                        if (window.enderecoGlobal.addressCheckDef.wip) {
                            window.enderecoGlobal.addressCheckDef.successCallback.push(function(data) {
                                if (undefined !== data.result.predictions && 1 < data.result.predictions.length) {
                                    return;
                                }

                                if (-1 !== data.result.status.indexOf('A1100')) {
                                    return;
                                }

                                document.querySelector(buttonSelector).click(); // Click the button.
                            });
                            window.enderecoGlobal.addressCheckDef.errorCallback.push(function(data) {
                                document.querySelector(buttonSelector).click(); // Click the button.
                            });
                        }

                    } else {
                        document.querySelector(buttonSelector).click(); // Click the button.
                    }
                }, 100);
            });

            function anyKindOfAddressCheckActivity() {
                return (undefined !== window.enderecoGlobal.popupId && '' !== window.enderecoGlobal.popupId) || window.enderecoGlobal.addressCheckInv.wip || window.enderecoGlobal.addressCheckDel.wip || window.enderecoGlobal.addressCheckDef.wip;
            }
        }

        function initiateEmailServices() {
            // Register emailCheck for invoice address
            window.enderecoGlobal.emailCheckInv = new EmailCheck({
                'inputSelector': 'input[name="register[personal][email]"]',
                'apiKey': window.enderecoGlobal.enderecoConfig.apiKey,
                'endpoint': window.enderecoGlobal.enderecoConfig.serviceUrl
            });
            window.enderecoGlobal.emailCheckInv.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );
        }

        function initiateNameServices() {
            window.enderecoGlobal.nameCheckInv = new NameCheck({
                'inputSelector': 'input[name="register[personal][firstname]"]',
                'salutationElement': 'select[name="register[personal][salutation]"]',
                'apiKey': window.enderecoGlobal.enderecoConfig.apiKey,
                'endpoint': window.enderecoGlobal.enderecoConfig.serviceUrl,
                'mapping': {
                    'M': 'mr',
                    'F': 'ms',
                    'N': '',
                    'X': ''
                }
            });
            window.enderecoGlobal.nameCheckInv.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );

            // Register nameCheck for delivery address
            window.enderecoGlobal.nameCheckDel = new NameCheck({
                'inputSelector': 'input[name="register[shipping][firstname]"]',
                'salutationElement': 'select[name="register[shipping][salutation]"]',
                'apiKey': window.enderecoGlobal.enderecoConfig.apiKey,
                'endpoint': window.enderecoGlobal.enderecoConfig.serviceUrl,
                'mapping': {
                    'M': 'mr',
                    'F': 'ms',
                    'N': '',
                    'X': ''
                }
            });
            window.enderecoGlobal.nameCheckDel.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );

            // Register nameCheck for delivery address
            window.enderecoGlobal.nameCheckDef = new NameCheck({
                'inputSelector': 'input[name="address[firstname]"]',
                'salutationElement': 'select[name="address[salutation]"]',
                'apiKey': window.enderecoGlobal.enderecoConfig.apiKey,
                'endpoint': window.enderecoGlobal.enderecoConfig.serviceUrl,
                'mapping': {
                    'M': 'mr',
                    'F': 'ms',
                    'N': '',
                    'X': ''
                }
            });
            window.enderecoGlobal.nameCheckDef.updateConfig(
                {
                    'referer': window.enderecoGlobal.referer
                }
            );
        }

        function initiatePhoneServices() {
            // No phone fields found.
        }

        function initiateStatusIndicator() {
            // Register emailCheck Status indicator for invoice address
            setTimeout(function() {
                window.enderecoGlobal.nameCheckStatusIndicatorInv = new StatusIndicator({
                    'inputSelector': 'input[name="register[personal][firstname]"]',
                    'displaySelector': 'select[name="register[personal][salutation]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);

            // Register emailCheck Status indicator for invoice address
            setTimeout(function() {
                window.enderecoGlobal.nameCheckStatusIndicatorDel = new StatusIndicator({
                    'inputSelector': 'input[name="register[shipping][firstname]"]',
                    'displaySelector': 'select[name="register[shipping][salutation]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);
            // Register emailCheck Status indicator for invoice address
            setTimeout(function() {
                window.enderecoGlobal.nameCheckStatusIndicatorDef = new StatusIndicator({
                    'inputSelector': 'input[name="address[firstname]"]',
                    'displaySelector': 'select[name="address[salutation]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);

            // Register emailCheck Status indicator for invoice address
            window.enderecoGlobal.emailCheckStatusIndicatorInv = new StatusIndicator({
                'inputSelector': 'input[name="register[personal][email]"]',
                'displaySelector': 'input[name="register[personal][email]"]',
                'colors' : window.enderecoGlobal.colorsStatusIndicator,
                'showIcons': false
            });

            // Register postCodeAutocomplete Status indicator for invoice address
            setTimeout(function() {
                window.enderecoGlobal.addressCheckStatusIndicatorInv = new StatusIndicator({
                    'inputSelector': '*[name="register[billing][country]"]',
                    'displaySelector': '*[name="register[billing][country]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);

            // Register postCodeAutocomplete Status indicator for invoice address
            setTimeout(function() {
                window.enderecoGlobal.addressCheckStatusIndicatorDel = new StatusIndicator({
                    'inputSelector': '*[name="register[shipping][country]"]',
                    'displaySelector': '*[name="register[shipping][country]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);

            // Register postCodeAutocomplete Status indicator for invoice address
            setTimeout(function() {
                window.enderecoGlobal.addressCheckStatusIndicatorDef = new StatusIndicator({
                    'inputSelector': '*[name="address[country]"]',
                    'displaySelector': '*[name="address[country]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);

            // Register postCodeAutocomplete Status indicator for invoice address
            setTimeout(function() {
                window.enderecoGlobal.postCodeAutocompleteStatusIndicatorInv = new StatusIndicator({
                    'inputSelector': 'input[name="register[billing][zipcode]"]',
                    'displaySelector': 'input[name="register[billing][zipcode]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);

            // Register postCodeAutocomplete Status indicator for del address
            setTimeout(function() {
                window.enderecoGlobal.postCodeAutocompleteStatusIndicatorDel = new StatusIndicator({
                    'inputSelector': 'input[name="register[shipping][zipcode]"]',
                    'displaySelector': 'input[name="register[shipping][zipcode]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);

            // Register postCodeAutocomplete Status indicator for del address
            setTimeout(function() {
                window.enderecoGlobal.postCodeAutocompleteStatusIndicatorDef = new StatusIndicator({
                    'inputSelector': 'input[name="address[zipcode]"]',
                    'displaySelector': 'input[name="address[zipcode]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);

            // Register postCodeAutocomplete Status indicator for invoice address
            setTimeout(function() {
                window.enderecoGlobal.cityNameAutocompleteStatusIndicatorInv = new StatusIndicator({
                    'inputSelector': 'input[name="register[billing][city]"]',
                    'displaySelector': 'input[name="register[billing][city]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);

            // Register postCodeAutocomplete Status indicator for del address
            setTimeout(function() {
                window.enderecoGlobal.cityNameAutocompleteStatusIndicatorDel = new StatusIndicator({
                    'inputSelector': 'input[name="register[shipping][city]"]',
                    'displaySelector': 'input[name="register[shipping][city]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);
            // Register postCodeAutocomplete Status indicator for del address
            setTimeout(function() {
                window.enderecoGlobal.cityNameAutocompleteStatusIndicatorDef = new StatusIndicator({
                    'inputSelector': 'input[name="address[city]"]',
                    'displaySelector': 'input[name="address[city]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);

            // Register postCodeAutocomplete Status indicator for invoice address
            setTimeout(function() {
                window.enderecoGlobal.streetAutocompleteStatusIndicatorInv = new StatusIndicator({
                    'inputSelector': 'input[name="register[billing][streetname]"]',
                    'displaySelector': 'input[name="register[billing][streetname]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);
            // Register postCodeAutocomplete Status indicator for del address
            setTimeout(function() {
                window.enderecoGlobal.streetAutocompleteStatusIndicatorDel = new StatusIndicator({
                    'inputSelector': 'input[name="register[shipping][streetname]"]',
                    'displaySelector': 'input[name="register[shipping][streetname]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);
            // Register postCodeAutocomplete Status indicator for del address
            setTimeout(function() {
                window.enderecoGlobal.streetAutocompleteStatusIndicatorDef = new StatusIndicator({
                    'inputSelector': 'input[name="address[streetname]"]',
                    'displaySelector': 'input[name="address[streetname]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);

            // Register house number Status indicator for invoice address
            setTimeout(function() {
                window.enderecoGlobal.houseNumberStatusIndicatorInv = new StatusIndicator({
                    'inputSelector': 'input[name="register[billing][streetnumber]"]',
                    'displaySelector': 'input[name="register[billing][streetnumber]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);
            // Register house number Status indicator for invoice address
            setTimeout(function() {
                window.enderecoGlobal.houseNumberStatusIndicatorDel = new StatusIndicator({
                    'inputSelector': 'input[name="register[shipping][streetnumber]"]',
                    'displaySelector': 'input[name="register[shipping][streetnumber]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);
            // Register house number Status indicator for invoice address
            setTimeout(function() {
                window.enderecoGlobal.houseNumberStatusIndicatorDef = new StatusIndicator({
                    'inputSelector': 'input[name="address[streetnumber]"]',
                    'displaySelector': 'input[name="address[streetnumber]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);

            // Register house number Status indicator for invoice address
            setTimeout(function() {
                window.enderecoGlobal.countryStatusIndicatorInv = new StatusIndicator({
                    'inputSelector': 'select[name="register[billing][country]"]',
                    'displaySelector': 'select[name="register[billing][country]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);
            // Register house number Status indicator for invoice address
            setTimeout(function() {
                window.enderecoGlobal.countryStatusIndicatorDel = new StatusIndicator({
                    'inputSelector': 'select[name="register[shipping][country]"]',
                    'displaySelector': 'select[name="register[shipping][country]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);
            // Register house number Status indicator for invoice address
            setTimeout(function() {
                window.enderecoGlobal.countryStatusIndicatorDef = new StatusIndicator({
                    'inputSelector': 'select[name="address[country]"]',
                    'displaySelector': 'select[name="address[country]"]',
                    'colors' : window.enderecoGlobal.colorsStatusIndicator,
                    'showIcons': false
                });
            }, 500);
        }
        connectionListener = setInterval(
            function() {
                if (window.enderecoGlobal.connection) {
                    clearInterval(connectionListener);
                    initConfigs();

                    if (1 === parseInt(window.enderecoGlobal.enderecoConfig.enderecoUseAddressServices)) {
                        initiateAddressServices();
                    }
                    if (1 === parseInt(window.enderecoGlobal.enderecoConfig.enderecoUseNameCheck)) {
                        initiateNameServices();
                    }
                    if (1 === parseInt(window.enderecoGlobal.enderecoConfig.enderecoUsePrephoneCheck)) {
                        initiatePhoneServices();
                    }
                    if (1 === parseInt(window.enderecoGlobal.enderecoConfig.enderecoUseStatus)) {
                        initiateStatusIndicator();
                    }
                    if (1 === parseInt(window.enderecoGlobal.enderecoConfig.enderecoUseEmailCheck)) {
                        initiateEmailServices();
                    }
                }
            },
            300
        );

        window.shouldInitiate = true;
        function checkIfFieldsAreSet() {
            if (enAmsCheckIfDelAddrIsSet() || enAmsCheckIfInvAddrIsSet() || enAmsCheckIfDefaultAddrIsSet()) {
                if (window.shouldInitiate) {
                    checkConnection();
                }

            } else {
                window.shouldInitiate = true;
            }
        }

        if (
            document.readyState === 'complete' ||
            (document.readyState !== 'loading' && !document.documentElement.doScroll)
        ) {
            setInterval(checkIfFieldsAreSet, 100);
        } else {
            document.addEventListener("DOMContentLoaded", function() {
                setInterval(checkIfFieldsAreSet, 100);
            });
        }
        function enAmsCheckIfDelAddrIsSet() {
            var field = document.querySelector('*[name="register[shipping][country]"]');
            return !!field;
        }
        function enAmsCheckIfInvAddrIsSet() {
            var field = document.querySelector('*[name="register[billing][country]"]');
            return !!field;
        }
        function enAmsCheckIfDefaultAddrIsSet() {
            var field = document.querySelector('*[name="address[country]"]');
            return !!field;
        }
    </script>


{/block}
