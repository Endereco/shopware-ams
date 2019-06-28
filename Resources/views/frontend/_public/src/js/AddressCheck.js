/**
 * Endereco SDK.
 *
 * @author Ilja Weber <ilja.weber@mobilemjo.de>
 * @copyright 2019 mobilemojo – Apps & eCommerce UG (haftungsbeschränkt) & Co. KG
 * {@link https://endereco.de}
 */
function AddressCheck(config) {

    var $self  = this;
    this.isSet = false;
    this.tid = 'not_set';
    this.config = config;
    this.requestBody = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "addressCheck",
        "params": {
            "street": "",
            "houseNumber": "",
            "postCode": "",
            "cityName": "",
            "country": "de",
            "language": "de",
        }
    }

    this.connector = new XMLHttpRequest();

    // Observe the website in a loop.
    setInterval( function() {
        var isNowSet = false;
        if(
            (null !== document.querySelector(config.streetSelector))
            && (null !== document.querySelector(config.houseNumberSelector))
            && (null !== document.querySelector(config.postCodeSelector))
            && (null !== document.querySelector(config.cityNameSelector))
            && (null !== document.querySelector(config.countrySelector))
        ) {
            isNowSet = true;
        }

        if (!$self.isSet && isNowSet) {
            $self.init();
        } else if($self.isSet && !isNowSet) {
            $self.isSet = false;
        }
    }, 300);

    this.init = function() {
        console.log('Initiate AddressCheck');
        $self.streetElement = document.querySelector(config.streetSelector);
        $self.houseNumberElement = document.querySelector(config.houseNumberSelector);
        $self.postCodeElement = document.querySelector(config.postCodeSelector);
        $self.cityNameElement = document.querySelector(config.cityNameSelector);
        $self.countryElement = document.querySelector(config.countrySelector);
        $self.timeOut = undefined;
        $self.overlay = undefined;
        $self.predictions = [];
        $self.anyChange = false;
        $self.activeIndex = -1;

        // Generate TID
        if (window.accounting) {
            $self.tid = window.accounting.generateTID();
        }

        $self.streetElement.addEventListener('change', function() {
            $self.anyChange = true;
        });

        $self.houseNumberElement.addEventListener('change', function() {
            $self.anyChange = true;
        });

        $self.postCodeElement.addEventListener('change', function() {
            $self.anyChange = true;
        });

        $self.cityNameElement.addEventListener('change', function() {
            $self.anyChange = true;
        });

        $self.countryElement.addEventListener('change', function() {
            $self.anyChange = true;
        });


        $self.streetElement.addEventListener('blur', function() {
            $self.runCheck();
        });

        $self.houseNumberElement.addEventListener('blur', function() {
            $self.runCheck();
        });

        $self.postCodeElement.addEventListener('blur', function() {
            $self.runCheck();
        });

        $self.cityNameElement.addEventListener('blur', function() {
            $self.runCheck();
        });

        $self.countryElement.addEventListener('blur', function() {
            $self.runCheck();
        });

        $self.streetElement.addEventListener('focus', function() {
            $self.connector.abort();
        });

        $self.houseNumberElement.addEventListener('focus', function() {
            $self.connector.abort();
        });

        $self.postCodeElement.addEventListener('focus', function() {
            $self.connector.abort();
        });

        $self.cityNameElement.addEventListener('focus', function() {
            $self.connector.abort();
        });

        $self.countryElement.addEventListener('focus', function() {
            $self.connector.abort();
        });

        $self.isSet = true;
    }


    this.isAnyFocused = function() {
        streetFocused = (document.activeElement === $self.streetElement);
        houseNumberFocused = (document.activeElement === $self.houseNumberElement);
        postCodeFocused = (document.activeElement === $self.postCodeElement);
        cityNameFocused = (document.activeElement === $self.cityNameElement);
        countryFocused = (document.activeElement === $self.countryElement);
        return streetFocused || houseNumberFocused || postCodeFocused || cityNameFocused || countryFocused;
    }

    this.isAnyEmpty = function() {
        streetEmpty = ('' === $self.streetElement.value.trim());
        houseNumberEmpty = ('' === $self.houseNumberElement.value.trim());
        postCodeEmpty = ('' === $self.postCodeElement.value.trim());
        cityNameEmpty = ('' === $self.cityNameElement.value.trim());
        countryEmpty = ('' === $self.countryElement.value.trim());
        return streetEmpty || houseNumberEmpty || postCodeEmpty || cityNameEmpty || countryEmpty;
    }

    this.removeOverlay = function() {
        if (undefined !== $self.overlay) {
            $self.overlay.remove();
            $self.overlay = undefined;
        }
    }

    this.markSuccess = function() {
        // Mark all fields as valid, because its selected
        event = new Event('endereco.valid');
        $self.streetElement.dispatchEvent(event);
        $self.houseNumberElement.dispatchEvent(event);
        $self.postCodeElement.dispatchEvent(event);
        $self.cityNameElement.dispatchEvent(event);
        $self.countryElement.dispatchEvent(event);
    }

    this.runCheck = function() {

        if (false === $self.anyChange) {
            return false;
        }

        if (undefined !== $self.timeOut) {
            clearTimeout($self.timeOut);
        }

        $self.timeOut = setTimeout(function() {
            if (!$self.isAnyFocused() && !$self.isAnyEmpty()) {
                $self.anyChange = false;
                $self.requestBody.params.street = $self.streetElement.value.trim();
                $self.requestBody.params.houseNumber = $self.houseNumberElement.value.trim();
                $self.requestBody.params.postCode = $self.postCodeElement.value.trim();
                $self.requestBody.params.cityName = $self.cityNameElement.value.trim();
                $self.requestBody.params.country = $self.countryElement.getAttribute('data-value').trim();
                $self.connector.abort();
                $self.streetElement.setAttribute('data-status', 'loading');
                $self.houseNumberElement.setAttribute('data-status', 'loading');
                $self.postCodeElement.setAttribute('data-status', 'loading');
                $self.cityNameElement.setAttribute('data-status', 'loading');
                $self.countryElement.setAttribute('data-status', 'loading');
                $self.connector.open('POST', $self.config.endpoint, true);
                $self.connector.setRequestHeader("Content-type", "application/json");
                $self.connector.setRequestHeader("X-Auth-Key", $self.config.apiKey);
                $self.connector.setRequestHeader("X-Transaction-Id", $self.tid);
                $self.connector.setRequestHeader("X-Transaction-Referer", window.location.href);

                $self.connector.send(JSON.stringify($self.requestBody));
            }
        }, 1);
    }

    this.renderVariants = function() {
        // Create overlay
        overlay_element = document.createElement('div');
        $self.overlay = overlay_element;
        overlay_element.style.position = 'fixed';
        overlay_element.style.padding = '0';
        overlay_element.style.top = '0';
        overlay_element.style.left = '0';
        overlay_element.style.width = '100%';
        overlay_element.style.height = '100%';
        overlay_element.style.zIndex = '90000';
        overlay_element.style.display = 'flex';
        overlay_element.style.justifyContent = 'center';
        overlay_element.style.alignItems = 'center';
        overlay_element.style.backgroundColor = 'rgba(0, 0, 0, 0.25)';

        // Window
        window_element = document.createElement('div');
        window_element.style.width = '100%';
        window_element.style.maxWidth = '480px';
        window_element.style.backgroundColor = '#fff';
        window_element.style.border = '1px solid #ccc';
        window_element.style.borderRadius = '4px';
        window_element.style.overflow = 'hidden';
        overlay_element.appendChild(window_element);

        // Window header
        window_header_element = document.createElement('div');
        window_header_element.style.width = '100%';
        window_header_element.style.padding = '8px 16px';
        window_header_element.style.color =  $self.config.colors.primaryColorText;
        window_header_element.style.display = 'flex';
        window_header_element.style.fontSize = '16px';
        window_header_element.style.lineHeight = '24px';
        window_header_element.style.justifyContent = 'space-between';
        window_header_element.style.backgroundColor = $self.config.colors.primaryColor;
        window_element.appendChild(window_header_element);

        // Header Title
        window_header_element.appendChild(document.createTextNode($self.config.texts.addressCheckHead));

        // Close button
        close_element = document.createElement('span');
        close_element.appendChild(document.createTextNode('✖'));
        close_element.style.cursor = 'pointer';
        close_element.addEventListener('click', function() {
            $self.removeOverlay();
        });
        window_header_element.appendChild(close_element);

        // Window body
        window_body_element = document.createElement('div');
        window_body_element.style.width = '100%';
        window_body_element.style.padding = '8px 16px';
        window_body_element.style.backgroundColor = '#fff';
        window_element.appendChild(window_body_element);

        headline1_element = document.createElement('p');
        headline1_element.style.margin = '15px 0 5px';
        headline1_element.appendChild(document.createTextNode($self.config.texts.addressCheckArea1));
        window_body_element.appendChild(headline1_element);

        // Create default choice
        default_label_element = document.createElement('label');
        default_label_element.style.fontWeight = '700';
        default_label_element.style.width = '100%';
        default_label_element.style.display = 'inline-block';
        default_label_element.setAttribute('data-offset', '-1');
        default_label_element.addEventListener('click', function() {
            $self.activeIndex = -1;
        });

        default_cb_element = document.createElement('input');
        default_cb_element.setAttribute('type', 'radio');
        default_cb_element.setAttribute('name', 'endereco-radio');
        default_cb_element.checked = true;
        default_cb_element.style.marginRight = '10px';
        default_label_element.appendChild(default_cb_element);
        var address = $self.postCodeElement.value.trim() +
                        ' ' +
                        $self.cityNameElement.value.trim() +
                        ' ' +
                        $self.streetElement.value.trim() +
                        ' ' +
                        $self.houseNumberElement.value.trim();
        default_label_element.appendChild(document.createTextNode(address));
        window_body_element.appendChild(default_label_element);

        headline2_element = document.createElement('p');
        headline2_element.style.margin = '15px 0 5px';
        headline2_element.appendChild(document.createTextNode($self.config.texts.addressCheckArea2));
        window_body_element.appendChild(headline2_element);

        // Create variants choice
        var counter = 0;
        $self.predictions.forEach(function(prediction) {
            default_label_element = document.createElement('label');
            default_label_element.style.fontWeight = '700';
            default_label_element.style.width = '100%';
            default_label_element.style.display = 'inline-block';
            default_label_element.setAttribute('data-offset', counter);
            default_label_element.addEventListener('click', function() {
                $self.activeIndex = this.getAttribute('data-offset');
            });

            default_cb_element = document.createElement('input');
            default_cb_element.setAttribute('type', 'radio');
            default_cb_element.setAttribute('name', 'endereco-radio');
            default_cb_element.style.marginRight = '10px';
            default_label_element.appendChild(default_cb_element);
            var address = prediction.postCode +
                            ' ' +
                            prediction.cityName +
                            ' ' +
                            prediction.street +
                            ' ' +
                            prediction.houseNumber;
            default_label_element.appendChild(document.createTextNode(address));
            window_body_element.appendChild(default_label_element);
            counter++;
        });

        // Window footer
        window_footer_element = document.createElement('div');
        window_footer_element.style.width = '100%';
        window_footer_element.style.padding = '8px 16px';
        window_footer_element.style.display = 'flex';
        window_footer_element.style.justifyContent = 'flex-end';
        window_footer_element.style.backgroundColor = '#fff';
        window_element.appendChild(window_footer_element);

        // Submit
        submit_element = document.createElement('button');
        submit_element.setAttribute('class', 'endereco-submit-btn')
        submit_element.appendChild(document.createTextNode($self.config.texts.addressCheckButton));
        // Default button style
        submit_element.style.color = $self.config.colors.primaryColorText;
        submit_element.style.backgroundColor = $self.config.colors.primaryColor;
        submit_element.style.border = '1px solid ' + $self.config.colors.primaryColorHover;
        submit_element.style.padding = '6px 12px';
        submit_element.style.fontSize = '14px';
        submit_element.style.borderRadius = '4px';
        submit_element.style.textAlign = 'center';

        submit_element.addEventListener('mouseover', function() {
            this.style.backgroundColor = $self.config.colors.primaryColorHover;
        });

        submit_element.addEventListener('mouseout', function() {
            this.style.backgroundColor = $self.config.colors.primaryColor;
        });

        submit_element.addEventListener('click', function() {

            $self.markSuccess();
            if(0 <= $self.activeIndex && undefined !== $self.predictions[$self.activeIndex]) {
                $self.streetElement.value = $self.predictions[$self.activeIndex].street;
                $self.houseNumberElement.value = $self.predictions[$self.activeIndex].houseNumber;
                $self.postCodeElement.value = $self.predictions[$self.activeIndex].postCode;
                $self.cityNameElement.value = $self.predictions[$self.activeIndex].cityName;
            }
            $self.activeIndex = -1;
            $self.removeOverlay();
        });

        window_footer_element.appendChild(submit_element);

        document.body.appendChild(overlay_element);
    }

    // On data receive
    this.connector.onreadystatechange = function() {
        if(4 === $self.connector.readyState) {
            if ($self.connector.responseText && '' !== $self.connector.responseText) {
                $data = JSON.parse($self.connector.responseText);
                if (undefined !== $data.result) {
                    $self.predictions = $data.result.predictions;
                    if ($data.result.status.includes('A1000') && !$data.result.status.includes('A1100')) {
                        $self.markSuccess();
                    }
                    if ($data.result.predictions.length > 1 || $data.result.status.includes('A1100')) {
                        $self.renderVariants();
                    }
                }
            }
        }

    }
}
