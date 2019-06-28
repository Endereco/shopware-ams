/**
 * Endereco SDK.
 *
 * @author Ilja Weber <ilja.weber@mobilemjo.de>
 * @copyright 2019 mobilemojo – Apps & eCommerce UG (haftungsbeschränkt) & Co. KG
 * {@link https://endereco.de}
 */
function CityNameAutocomplete(config) {

    var $self  = this;
    this.isSet = false;

    this.config = config;
    this.tid = 'not_set';
    this.requestBody = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "cityNameAutocomplete",
        "params": {
            "cityName": "",
            "country": "de",
            "language": "de"
        }
    }

    this.connector = new XMLHttpRequest();

    // Observe the website in a loop.
    setInterval( function() {
        var isNowSet = false;
        if(
            (null !== document.querySelector(config.inputSelector))
        ) {
            isNowSet = true;
        }

        if (!$self.isSet && isNowSet) {
            $self.init();
        } else if($self.isSet && !isNowSet) {
            $self.isSet = false;
        }
    }, 300);

    //// Functions

    this.init = function() {
        console.log('Initiate CityNameAutocomplete');

        $self.inputElement = document.querySelector(config.inputSelector);
        $self.dropdown = undefined;
        $self.dropdownDraw = true;
        $self.renderTimeout = undefined;
        $self.mouseDownHappened = false;
        $self.predictions = [];
        $self.activeElementIndex = -1;

        //// DOM modifications

        // Set mark
        $self.inputElement.setAttribute('data-service', 'cityNameAutocomplete');
        $self.inputElement.setAttribute('data-status', 'instantiated');

        // Generate TID
        if (window.accounting) {
            $self.tid = window.accounting.generateTID();
        }

        // Disable browser autocomplete
        if ($self.isChrome()) {
            this.inputElement.setAttribute('autocomplete', 'autocomplete_' + Math.random().toString(36).substring(2) + Date.now());
        } else {
            this.inputElement.setAttribute('autocomplete', 'off' );
        }

        //// Rendering

        // Register events
        $self.inputElement.addEventListener('input', function() {
            $this = this;
            $self.activeElementIndex = -1;
            $self.dropdownDraw = true;

            if (true) {
                $self.requestBody.params.cityName = $this.value.trim();
                if (undefined !== $self.config.country && '' !== $self.config.country) {
                    $self.requestBody.params.country = $self.config.country;
                }
                if (undefined !== $self.config.secondaryInputSelectors.country && '' !== document.querySelector($self.config.secondaryInputSelectors.country).value.trim()) {
                    $self.requestBody.params.country = document.querySelector($self.config.secondaryInputSelectors.country).getAttribute('data-value').trim();
                }
                if (undefined !== $self.config.language && '' !== $self.config.language) {
                    $self.requestBody.params.language = $self.config.language;
                }

                $self.connector.abort();
                $self.inputElement.setAttribute('data-status', 'loading');
                $self.connector.open('POST', $self.config.endpoint, true);
                $self.connector.setRequestHeader("Content-type", "application/json");
                $self.connector.setRequestHeader("X-Auth-Key", $self.config.apiKey);
                $self.connector.setRequestHeader("X-Transaction-Id", $self.tid);
                $self.connector.setRequestHeader("X-Transaction-Referer", window.location.href);

                $self.connector.send(JSON.stringify($self.requestBody));
            }
        });

        $self.inputElement.addEventListener('blur', function() {
            if ($self.mouseDownHappened) {
                $self.mouseDownHappened = false;
                this.focus();
            }
            setTimeout(function() {
                if(undefined !== $self.dropdown && null !== $self.dropdown) {
                    $self.dropdown.remove();
                }

                $self.dropdownDraw = false;

                $self.dropdown = undefined;
            }, 100);
        });

        $self.inputElement.addEventListener('change', function() {
            setTimeout(function() {
                if ('chosen' !== $self.inputElement.getAttribute('data-status')) {
                    hasInput = false;
                    $self.predictions.forEach( function(prediction) {
                        if (prediction.cityName === $self.inputElement.value.trim()){
                            hasInput = true;
                        }
                    });

                    if (0 < $self.predictions.length) {
                        if (!hasInput) {
                            event = new Event('endereco.check');
                            $self.inputElement.dispatchEvent(event);
                        } else {
                            event = new Event('endereco.valid');
                            $self.inputElement.dispatchEvent(event);
                        }
                    } else {
                        event = new Event('endereco.clean');
                        $self.inputElement.dispatchEvent(event);
                    }
                }
            }, 1000);
        });

        $self.inputElement.addEventListener('keydown', function(e) {
            e = e || window.event;
            if (40 == e.keyCode && $self.activeElementIndex < ($self.predictions.length-1)) {
                e.preventDefault();
                $self.activeElementIndex++;
                $self.renderDropdown();
                $self.renderDropdownElements();

            } else if(38 == e.keyCode && $self.activeElementIndex > 0) {
                e.preventDefault();
                $self.activeElementIndex--;
                $self.renderDropdown();
                $self.renderDropdownElements();
            } else if(13 == e.keyCode) {
                if($self.activeElementIndex >= 0 && $self.activeElementIndex <= $self.predictions.length) {
                    e.preventDefault();
                    $self.inputElement.value = $self.predictions[$self.activeElementIndex].cityName;
                    event = new Event('endereco.valid');
                    $self.inputElement.dispatchEvent(event);
                    $self.inputElement.setAttribute('data-status', 'chosen');

                    // Process secondary input selectors
                    postCodeField = document.querySelector($self.config.secondaryInputSelectors.postCode);
                    if (postCodeField && $self.predictions[$self.activeElementIndex].postCode && '' !== $self.predictions[$self.activeElementIndex].postCode) {
                        postCodeField.value = $self.predictions[$self.activeElementIndex].postCode.trim();
                        event = new Event('endereco.valid');
                        postCodeField.dispatchEvent(event);
                        postCodeField.setAttribute('data-status', 'chosen');
                    }

                    $self.activeElementIndex = -1
                    $self.dropdown.style.display = 'none';
                }
            }
        });
        $self.isSet = true;
    }

    // Check if the browser is chrome
    this.isChrome = function() {
        return /chrom(e|ium)/.test( navigator.userAgent.toLowerCase( ) );
    }

    // Create ul dropdown
    this.renderDropdown = function() {
        if(undefined !== $self.dropdown && undefined !== $self.dropdown) {
            $self.dropdown.remove();
        }

        $self.dropdown = undefined;
        var ul = document.createElement('ul');
        ul.style.display = 'none';
        ul.style.zIndex = '9001';
        ul.style.borderRadius = '4px';
        ul.style.backgroundColor = '#fff',
        ul.style.border = '1px solid #dedede';
        ul.style.listStyle = 'none';
        ul.style.padding = '4px 4px';
        ul.style.margin = 0;
        ul.style.position = 'absolute';
        ul.style.top = 4 + $self.inputElement.offsetTop + $self.inputElement.offsetHeight + 'px';
        ul.style.left = $self.inputElement.offsetLeft + 'px';
        ul.setAttribute('class', 'endereco-dropdown')
        $self.dropdown = ul;
        $self.inputElement.parentNode.insertBefore(ul, $self.inputElement.nextSibling);
    }

    // Create dropdown elements
    this.renderDropdownElements = function() {
        var li;
        var input = $self.inputElement.value.trim();
        var counter = 0;

        // Remove all existing elements
        while ($self.dropdown.hasChildNodes()) {
            $self.dropdown.removeChild($self.dropdown.lastChild);
        }

        // Iterate through list and create new elements
        $self.predictions.forEach( function(element) {
            li = document.createElement('li');
            li.style.cursor = 'pointer';
            li.style.color = '#000';
            li.style.padding = '2px 4px';
            li.style.margin = '0';
            if (counter === $self.activeElementIndex) {
                li.style.backgroundColor = 'rgba(0, 137, 167, 0.25)';
            } else {
                li.style.backgroundColor = 'transparent';
            }
            li.addEventListener('mouseover', function() {
                this.style.backgroundColor = 'rgba(0, 137, 167, 0.25)';
            });

            li.addEventListener('mouseout', function() {
                this.style.backgroundColor =  'transparent';
            });

            var regEx = new RegExp('(' + input + ')', 'ig');
            var replaceMask = '<mark style="background-color: transparent; padding: 0; margin: 0; font-weight: 700; color: ' +  $self.config.colors.secondaryColor + '">$1</mark>';
            cityName = element.cityName.replace(regEx, replaceMask);
            li.innerHTML = cityName;
            li.setAttribute('data-city-name', element.cityName);
            if (undefined !== element.postCode && '' !== element.postCode) {
                li.innerHTML = element.postCode + ' ' + li.innerHTML;
                li.setAttribute('data-post-code', element.postCode);
            }

			// Register event
            li.addEventListener('mousedown', function() {
                $self.mouseDownHappened = true;
                selectedCityName = this.getAttribute('data-city-name');
                $self.inputElement.value = selectedCityName;
                $self.inputElement.setAttribute('data-status', 'chosen');
                event = new Event('endereco.valid');
                $self.inputElement.dispatchEvent(event);

                selectedPostCode = this.getAttribute('data-post-code');
                postCodeField = document.querySelector($self.config.secondaryInputSelectors.postCode);
                if (selectedPostCode && postCodeField) {
                    postCodeField.value = selectedPostCode.trim();
                    event = new Event('endereco.valid');
                    postCodeField.dispatchEvent(event);
                    postCodeField.setAttribute('data-status', 'chosen');
                }
            });

            $self.dropdown.appendChild(li);

            counter++;
        });

        if ($self.predictions.length === 0) {
            $self.dropdown.style.display = 'none';
        } else {
            $self.dropdown.style.display = 'block';
        }
    }

    // On data receive
    this.connector.onreadystatechange = function() {
        if(4 === $self.connector.readyState && $self.dropdownDraw) {
            if ($self.connector.responseText && '' !== $self.connector.responseText) {
                $data = JSON.parse($self.connector.responseText);
                if (undefined !== $data.result) {
                    $self.predictions = $data.result.predictions;
                } else {
                    $self.predictions = [];
                }

            } else {
                $self.predictions = [];
            }

            $self.renderDropdown();
            $self.renderDropdownElements();
            $self.inputElement.setAttribute('data-status', 'list-rendered');
        }

    }
}
