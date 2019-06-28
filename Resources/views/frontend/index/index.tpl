{extends file="parent:frontend/index/index.tpl"}

{block name="frontend_index_header_javascript"}
    {$smarty.block.parent}

    {$colorData = [
        'primaryColor' => {config name='enderecoUseprimaryColor' namespace="EnderecoAMS"},
        'primaryColorHover' => {config name='enderecoUseprimaryColorHover' namespace="EnderecoAMS"},
        'primaryColorText' => {config name='enderecoUseprimaryColorText' namespace="EnderecoAMS"},
        'secondaryColor' => {config name='enderecoUsesecondaryColor' namespace="EnderecoAMS"},
        'secondaryColorHover' => {config name='enderecoUsesecondaryColorHover' namespace="EnderecoAMS"},
        'secondaryColorText' => {config name='enderecoUsesecondaryColorText' namespace="EnderecoAMS"},
        'warningColor' => {config name='enderecoUsewarningColor' namespace="EnderecoAMS"},
        'warningColorHover' => {config name='enderecoUsewarningColorHover' namespace="EnderecoAMS"},
        'warningColorText' => {config name='enderecoUsewarningColorText' namespace="EnderecoAMS"},
        'successColor' => {config name='enderecoUsesuccessColor' namespace="EnderecoAMS"},
        'successColorHover' => {config name='enderecoUsesuccessColorHover' namespace="EnderecoAMS"},
        'successColorText' => {config name='enderecoUsesuccessColorText' namespace="EnderecoAMS"}
    ]}

    {$textData = [
        'addressCheckHead' => {"{s namespace='EnderecoAMS' name='addressCheckHead'}Adresse prüfen{/s}"},
        'addressCheckButton' => {"{s namespace='EnderecoAMS' name='addressCheckButton'}Adresse übernehmen{/s}"},
        'addressCheckArea1' => {"{s namespace='EnderecoAMS' name='addressCheckArea1'}Ihre Eingabe:{/s}"},
        'addressCheckArea2' => {"{s namespace='EnderecoAMS' name='addressCheckArea2'}Unsere Vorschläge:{/s}"}
    ]}

    {$enderecoConfig = [
        'enderecoUseStatus' => {config name='enderecoUseStatus' namespace="EnderecoAMS"},
        'enderecoUsePostcodeAutocomplete' => {config name='enderecoUsePostcodeAutocomplete' namespace="EnderecoAMS"},
        'enderecoUseCitynameAutocomplete' => {config name='enderecoUseCitynameAutocomplete' namespace="EnderecoAMS"},
        'enderecoUseStreetAutocomplete' => {config name='enderecoUseStreetAutocomplete' namespace="EnderecoAMS"},
        'enderecoUseEmailCheck' => {config name='enderecoUseEmailCheck' namespace="EnderecoAMS"},
        'enderecoUseNameCheck' => {config name='enderecoUseNameCheck' namespace="EnderecoAMS"},
        'enderecoUsePrephoneCheck' => {config name='enderecoUsePrephoneCheck' namespace="EnderecoAMS"},
        'enderecoPrephoneFormat' => {config name='enderecoUsePrephoneFormat' namespace="EnderecoAMS"},
        'enderecoUseAddressCheck' => {config name='enderecoUseAddressCheck' namespace="EnderecoAMS"},
        'enderecoLocale' => {$Shop->getLocale()->toString()},
        'apiKey' => {config name='enderecoApiKey' namespace="EnderecoAMS"},
        'countryEndpoint' => {url controller='enderecoapi' action='country' _seo=false},
        'aternateServiceUrl' => {url controller='enderecoapi' action='index' _seo=false},
        'serviceUrl' => {link file="frontend/_public/src/io.php"}
    ]}
    <script>
        var enderecoColorData = {$colorData|json_encode};
        var enderecoTextData = {$textData|json_encode};
        var enderecoConfig = {$enderecoConfig|json_encode};

        function checkIfLoaded() {
            if (typeof window !== 'undefined' && window.PostCodeAutocomplete) {
                initEnderecoClient()
            } else {
                setTimeout(checkIfLoaded, 300);
            }
        }

        function initNameCheck() {
            // Activate NameCheck Service
            if ('1' === enderecoConfig.enderecoUseNameCheck) {
                window.invNameCheck = new NameCheck({
                    'inputSelector': 'input[name="register[personal][firstname]"]',
                    'salutationElement': 'select[name="register[personal][salutation]"]',
                    'endpoint': enderecoConfig.serviceUrl,
                    'apiKey': enderecoConfig.apiKey,
                    'mapping': {
                        'M': 'mr',
                        'F': 'ms',
                        'N': '',
                        'X': ''
                    },
                    'colors' : enderecoColorData
                });

                window.adrNameCheck = new NameCheck({
                    'inputSelector': 'input[name="address[firstname]"]',
                    'salutationElement': 'select[name="address[salutation]"]',
                    'endpoint': enderecoConfig.serviceUrl,
                    'apiKey': enderecoConfig.apiKey,
                    'mapping': {
                        'M': 'mr',
                        'F': 'ms',
                        'N': '',
                        'X': ''
                    },
                    'colors' : enderecoColorData
                });

                // Register nameCheck for delivery address
                window.delNameCheck = new NameCheck({
                    'inputSelector': 'input[name="register[shipping][firstname]"]',
                    'salutationElement': 'select[name="register[shipping][salutation]"]',
                    'endpoint': enderecoConfig.serviceUrl,
                    'apiKey': enderecoConfig.apiKey,
                    'mapping': {
                        'M': 'mr',
                        'F': 'ms',
                        'N': '',
                        'X': ''
                    },
                    'colors' : enderecoColorData
                });

                window.profNameCheck = new NameCheck({
                    'inputSelector': 'input[name="profile[firstname]"]',
                    'salutationElement': 'select[name="profile[salutation]"]',
                    'endpoint': enderecoConfig.serviceUrl,
                    'apiKey': enderecoConfig.apiKey,
                    'mapping': {
                        'M': 'mr',
                        'F': 'ms',
                        'N': '',
                        'X': ''
                    },
                    'colors' : enderecoColorData
                });
            }

            // Activate NameCheck Status
            if ('1' === enderecoConfig.enderecoUseStatus) {
                setTimeout(function() {
                    new StatusIndicator({
                        'inputSelector': 'input[name="register[personal][firstname]"]',
                        'displaySelector': 'select[name="register[personal][salutation]"]',
                        'colors' : enderecoColorData
                    });
                }, 500);

                // Register emailCheck Status indicator for invoice address
                setTimeout(function() {
                    new StatusIndicator({
                        'inputSelector': 'input[name="address[firstname]"]',
                        'displaySelector': 'select[name="address[salutation]"]',
                        'colors' : enderecoColorData
                    });
                }, 500);

                // Register emailCheck Status indicator for invoice address
                setTimeout(function() {
                    new StatusIndicator({
                        'inputSelector': 'input[name="register[shipping][firstname]"]',
                        'displaySelector': 'select[name="register[shipping][salutation]"]',
                        'colors' : enderecoColorData
                    });
                }, 500);
                // Register emailCheck Status indicator for invoice address
                setTimeout(function() {
                    new StatusIndicator({
                        'inputSelector': 'input[name="profile[firstname]"]',
                        'displaySelector': 'select[name="profile[salutation]"]',
                        'colors' : enderecoColorData
                    });
                }, 500);
            }
        }

        function initEmailCheck() {
            // Activate NameCheck Service
            if ('1' === enderecoConfig.enderecoUseEmailCheck) {
                // Register emailCheck for invoice address
                new EmailCheck({
                    'inputSelector': 'input[name="register[personal][email]"]',
                    'endpoint': enderecoConfig.serviceUrl,
                    'apiKey': enderecoConfig.apiKey
                });

                new EmailCheck({
                    'inputSelector': 'input[name="email[email]"]',
                    'endpoint': enderecoConfig.serviceUrl,
                    'apiKey': enderecoConfig.apiKey
                });
            }

            // Activate NameCheck Status
            if ('1' === enderecoConfig.enderecoUseStatus) {
                // Register emailCheck Status indicator for invoice address
                setTimeout(function() {
                    window.invNameCheckStatusIndicator = new StatusIndicator({
                        'inputSelector': 'input[name="register[personal][email]"]',
                        'displaySelector': 'input[name="register[personal][email]"]',
                        'colors' : enderecoColorData
                    });
                }, 500);
            }
        }

        function initPrephoneCheck() {
            // TODO.
        }

        function initPostCodeAutocomplete() {
            // Activate NameCheck Service
            if ('1' === enderecoConfig.enderecoUsePostcodeAutocomplete) {
                window.invPostCodeAutocomplete = new PostCodeAutocomplete({
                    'inputSelector': 'input[name="register[billing][zipcode]"]',
                    'secondaryInputSelectors': {
                        'cityName': 'input[name="register[billing][city]"]',
                        'country': 'select[name="register[billing][country]"]'
                    },
                    'endpoint': enderecoConfig.serviceUrl,
                    'apiKey': enderecoConfig.apiKey,
                    'colors' : enderecoColorData
                });

                window.addrtPostCodeAutocomplete = new PostCodeAutocomplete({
                    'inputSelector': 'input[name="address[zipcode]"]',
                    'secondaryInputSelectors': {
                        'cityName': 'input[name="address[city]"]',
                        'country': 'select[name="address[country]"]'
                    },
                    'endpoint': enderecoConfig.serviceUrl,
                    'apiKey': enderecoConfig.apiKey,
                    'colors' : enderecoColorData
                });

                window.delPostCodeAutocomplete = new PostCodeAutocomplete({
                    'inputSelector': 'input[name="register[shipping][zipcode]"]',
                    'secondaryInputSelectors': {
                        'cityName': 'input[name="register[shipping][city]"]',
                        'country': 'select[name="register[shipping][country]"]'
                    },
                    'endpoint': enderecoConfig.serviceUrl,
                    'apiKey': enderecoConfig.apiKey,
                    'colors' : enderecoColorData
                });
            }

            if ('1' === enderecoConfig.enderecoUseStatus) {

                setTimeout(function() {
                    new StatusIndicator({
                        'inputSelector': 'input[name="register[billing][zipcode]"]',
                        'displaySelector': 'input[name="register[billing][zipcode]"]',
                        'colors' : enderecoColorData
                    });
                }, 500);

                setTimeout(function() {
                    new StatusIndicator({
                        'inputSelector': 'input[name="address[zipcode]"]',
                        'displaySelector': 'input[name="address[zipcode]"]',
                        'colors' : enderecoColorData
                    });
                }, 500);


                setTimeout(function() {
                    new StatusIndicator({
                        'inputSelector': 'input[name="register[shipping][zipcode]"]',
                        'displaySelector': 'input[name="register[shipping][zipcode]"]',
                        'colors' : enderecoColorData
                    });
                }, 500);
            }

        }

        function initCityNameAutocomplete() {
            // Activate NameCheck Service
            if ('1' === enderecoConfig.enderecoUseCitynameAutocomplete) {
                // Register cityNameAutocomplete for invoice address
                window.invCityNameAutocomplete = new CityNameAutocomplete({
                    'inputSelector': 'input[name="register[billing][city]"]',
                    'secondaryInputSelectors': {
                        'postCode': 'input[name="register[billing][zipcode]"]',
                        'country': 'select[name="register[billing][country]"]'
                    },
                    'endpoint': enderecoConfig.serviceUrl,
                    'apiKey': enderecoConfig.apiKey,
                    'colors' : enderecoColorData
                });

                // Register cityNameAutocomplete for invoice address
                window.adrCityNameAutocomplete = new CityNameAutocomplete({
                    'inputSelector': 'input[name="address[city]"]',
                    'secondaryInputSelectors': {
                        'postCode': 'input[name="address[zipcode]"]',
                        'country': 'select[name="address[country]"]'
                    },
                    'endpoint': enderecoConfig.serviceUrl,
                    'apiKey': enderecoConfig.apiKey,
                    'colors' : enderecoColorData
                });

                // Register cityNameAutocomplete for del address
                window.delCityNameAutocomplete = new CityNameAutocomplete({
                    'inputSelector': 'input[name="register[shipping][city]"]',
                    'secondaryInputSelectors': {
                        'postCode': 'input[name="register[shipping][zipcode]"]',
                        'country': 'select[name="register[shipping][country]"]'
                    },
                    'endpoint': enderecoConfig.serviceUrl,
                    'apiKey': enderecoConfig.apiKey,
                    'colors' : enderecoColorData
                });
            }

            // Activate NameCheck Status
            if ('1' === enderecoConfig.enderecoUseStatus) {
                // Register Status indicato
                setTimeout(function() {
                    new StatusIndicator({
                        'inputSelector': 'input[name="register[billing][city]"]',
                        'displaySelector': 'input[name="register[billing][city]"]',
                        'colors' : enderecoColorData
                    });
                }, 500);

                // Register Status indicator
                setTimeout(function() {
                    new StatusIndicator({
                        'inputSelector': 'input[name="register[shipping][city]"]',
                        'displaySelector': 'input[name="register[shipping][city]"]',
                        'colors' : enderecoColorData
                    });
                }, 500);

                // Register Status indicator
                setTimeout(function() {
                    new StatusIndicator({
                        'inputSelector': 'input[name="address[city]"]',
                        'displaySelector': 'input[name="address[city]"]',
                        'colors' : enderecoColorData
                    });
                }, 500);
            }
        }

        function initStreetAutocomplete() {
            if ('1' === enderecoConfig.enderecoUseStreetAutocomplete) {
                // Register streetAutocomplete for invoice address
                window.invStreetAutocomplete = new StreetAutocomplete({
                    'inputSelector': 'input[name="register[billing][streetname]"]',
                    'secondaryInputSelectors': {
                        'postCode': 'input[name="register[billing][zipcode]"]',
                        'cityName': 'input[name="register[billing][city]"]',
                        'country': 'select[name="register[billing][country]"]'
                    },
                    'endpoint': enderecoConfig.serviceUrl,
                    'apiKey': enderecoConfig.apiKey,
                    'colors' : enderecoColorData
                });

                // Register streetAutocomplete for invoice address
                window.invStreetAutocomplete = new StreetAutocomplete({
                    'inputSelector': 'input[name="address[streetname]"]',
                    'secondaryInputSelectors': {
                        'postCode': 'input[name="address[zipcode]"]',
                        'cityName': 'input[name="address[city]"]',
                        'country': 'select[name="address[country]"]'
                    },
                    'endpoint': enderecoConfig.serviceUrl,
                    'apiKey': enderecoConfig.apiKey,
                    'colors' : enderecoColorData
                });

                // Register streetAutocomplete for del address
                window.delStreetAutocomplete = new StreetAutocomplete({
                    'inputSelector': 'input[name="register[shipping][streetname]"]',
                    'secondaryInputSelectors': {
                        'postCode': 'input[name="register[shipping][zipcode]"]',
                        'cityName': 'input[name="register[shipping][city]"]',
                        'country': 'select[name="register[shipping][country]"]'
                    },
                    'endpoint': enderecoConfig.serviceUrl,
                    'apiKey': enderecoConfig.apiKey,
                    'colors' : enderecoColorData
                });
            }

            // Activate NameCheck Status
            if ('1' === enderecoConfig.enderecoUseStatus) {
                // Register Status indicato
                setTimeout(function() {
                    new StatusIndicator({
                        'inputSelector': 'input[name="register[billing][streetname]"]',
                        'displaySelector': 'input[name="register[billing][streetname]"]',
                        'colors' : enderecoColorData
                    });
                }, 500);

                setTimeout(function() {
                    new StatusIndicator({
                        'inputSelector': 'input[name="address[streetname]"]',
                        'displaySelector': 'input[name="address[streetname]"]',
                        'colors' : enderecoColorData
                    });
                }, 500);

                // Register Status indicator
                setTimeout(function() {
                    new StatusIndicator({
                        'inputSelector': 'input[name="register[shipping][streetname]"]',
                        'displaySelector': 'input[name="register[shipping][streetname]"]',
                        'colors' : enderecoColorData
                    });
                }, 500);
            }
        }

        function initAdressCheck() {
            if ('1' === enderecoConfig.enderecoUseAddressCheck) {
                // Register addressCheck for invoice address
                window.invAddressCheck = new AddressCheck({
                    'streetSelector': 'input[name="register[billing][streetname]"]',
                    'houseNumberSelector': 'input[name="register[billing][streetnumber]"]',
                    'postCodeSelector': 'input[name="register[billing][zipcode]"]',
                    'cityNameSelector': 'input[name="register[billing][city]"]',
                    'countrySelector': 'select[name="register[billing][country]"]',
                    'endpoint': enderecoConfig.serviceUrl,
                    'apiKey': enderecoConfig.apiKey,
                    'colors' : enderecoColorData,
                    'texts': enderecoTextData
                });

                window.invAddressCheck = new AddressCheck({
                    'streetSelector': 'input[name="address[streetname]"]',
                    'houseNumberSelector': 'input[name="address[streetnumber]"]',
                    'postCodeSelector': 'input[name="address[zipcode]"]',
                    'cityNameSelector': 'input[name="address[city]"]',
                    'countrySelector': 'select[name="address[country]"]',
                    'endpoint': enderecoConfig.serviceUrl,
                    'apiKey': enderecoConfig.apiKey,
                    'colors' : enderecoColorData,
                    'texts': enderecoTextData
                });

                // Register addressCheck for invoice address
                window.delAddressCheck = new AddressCheck({
                    'streetSelector': 'input[name="register[shipping][streetname]"]',
                    'houseNumberSelector': 'input[name="register[shipping][streetnumber]"]',
                    'postCodeSelector': 'input[name="register[shipping][zipcode]"]',
                    'cityNameSelector': 'input[name="register[shipping][city]"]',
                    'countrySelector': 'select[name="register[shipping][country]"]',
                    'endpoint': enderecoConfig.serviceUrl,
                    'apiKey': enderecoConfig.apiKey,
                    'colors' : enderecoColorData,
                    'texts': enderecoTextData
                });

                // Register nameCheck for delivery address
                new CountryWatcher({
                    'countrySelector': 'select[name="register[billing][country]"]',
                    'countryEndpoint': enderecoConfig.countryEndpoint
                });

                new CountryWatcher({
                    'countrySelector': 'select[name="register[shipping][country]"]',
                    'countryEndpoint': enderecoConfig.countryEndpoint
                });

                new CountryWatcher({
                    'countrySelector': 'select[name="address[country]"]',
                    'countryEndpoint': enderecoConfig.countryEndpoint
                });
            }

            // Activate NameCheck Status
            if ('1' === enderecoConfig.enderecoUseStatus) {
                // Register Status indicato
                setTimeout(function() {
                    new StatusIndicator({
                        'inputSelector': 'input[name="register[billing][streetnumber]"]',
                        'displaySelector': 'input[name="register[billing][streetnumber]"]',
                        'colors' : enderecoColorData
                    });
                }, 500);

                // Register Status indicator
                setTimeout(function() {
                    new StatusIndicator({
                        'inputSelector': 'input[name="register[shipping][streetnumber]"]',
                        'displaySelector': 'input[name="register[shipping][streetnumber]"]',
                        'colors' : enderecoColorData
                    });
                }, 500);

                setTimeout(function() {
                    new StatusIndicator({
                        'inputSelector': 'input[name="address[streetnumber]"]',
                        'displaySelector': 'input[name="address[streetnumber]"]',
                        'colors' : enderecoColorData
                    });
                }, 500);
            }
        }

        function initEnderecoClient() {

            initNameCheck();
            initEmailCheck();
            initPrephoneCheck();
            initPostCodeAutocomplete();
            initCityNameAutocomplete();
            initStreetAutocomplete();
            initAdressCheck();

            new StreetShadow({
                'streetNameSelector': 'input[name="register[billing][streetname]"]',
                'houseNumberSelector': 'input[name="register[billing][streetnumber]"]',
                'streetSelector': 'input[name="register[billing][street]"]',
            });

            new StreetShadow({
                'streetNameSelector': 'input[name="register[shipping][streetname]"]',
                'houseNumberSelector': 'input[name="register[shipping][streetnumber]"]',
                'streetSelector': 'input[name="register[shipping][street]"]',
            });

            new StreetShadow({
                'streetNameSelector': 'input[name="address[streetname]"]',
                'houseNumberSelector': 'input[name="address[streetnumber]"]',
                'streetSelector': 'input[name="address[street]"]',
            });

            // Activate accounting service. It generates TID.
            window.accounting = new Accounting();
        }

        document.addEventListener('DOMContentLoaded', function() {
            checkIfLoaded();
        });

    </script>


{/block}
