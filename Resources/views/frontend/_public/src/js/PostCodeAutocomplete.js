/**
 * Endereco SDK.
 *
 * @author Ilja Weber <ilja.weber@mobilemjo.de>
 * @copyright 2019 mobilemojo – Apps & eCommerce UG (haftungsbeschränkt) & Co. KG
 * {@link https://endereco.de}
 */
function PostCodeAutocomplete(config) {
    var $self  = this;
    /**
     * Combine object, IE 11 compatible.
     */
    this.mergeObjects = function(objects) {
        return objects.reduce(function (r, o) {
            Object.keys(o).forEach(function (k) {
                r[k] = o[k];
            });
            return r;
        }, {})
    };
    this.requestBody = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "postCodeAutocomplete",
        "params": {
            "postCode": "",
            "country": "de",
            "language": "de"
        }
    }
    this.defaultConfig = {
        'useWatcher': true,
        'referer': 'not_set',
        'tid': 'not_set'
    };
    this.fieldsAreSet = false;
    this.dirty = false;
    this.originalInput;
    this.originalCity;
    this.blockInput = false;
    this.lastInputError = true;
    this.config = $self.mergeObjects([this.defaultConfig, config]);
    this.connector = new XMLHttpRequest();

    // Includes polyfill for IE
    if (!Array.prototype.includes) {
        Object.defineProperty(Array.prototype, "includes", {
            enumerable: false,
            value: function(obj) {
                var newArr = this.filter(function(el) {
                    return el == obj;
                });
                return newArr.length > 0;
            }
        });
    }

    this.createEvent = function(eventName) {
        var event;
        if(typeof(Event) === 'function') {
            event = new Event(eventName);
        }else{
            event = document.createEvent('Event');
            event.initEvent(eventName, true, true);
        }
        return event;
    }

    /**
     * Helper function to update existing config, overwriting existing fields.
     *
     * @param newConfig
     */
    this.updateConfig = function(newConfig) {
        $self.config = $self.mergeObjects([$self.config, newConfig]);
    }

    /**
     * Checks if fields are set.
     */
    this.checkIfFieldsAreSet = function() {
        var areFieldsSet = false;
        if((null !== document.querySelector($self.config.inputSelector))) {
            areFieldsSet = true;
        }

        if (!$self.fieldsAreSet && areFieldsSet) {
            $self.dirty = true;
            $self.fieldsAreSet = true;
        } else if($self.fieldsAreSet && !areFieldsSet) {
            $self.fieldsAreSet = false;
        }
    }

    /**
     * Get predictions for the provided input.
     */
    this.getPredictions = function() {
        $self.activeElementIndex = -1;
        return new Promise( function(resolve, reject) {
            var countryCode = 'de';
            var countryElement;
            // On data receive
            $self.connector.onreadystatechange = function() {
                var $data = {};
                if(4 === $self.connector.readyState) {
                    if ($self.connector.responseText && '' !== $self.connector.responseText) {
                        $data = JSON.parse($self.connector.responseText);
                        if ($data.result) {
                            $self.lastInputError = false;
                            resolve($data);
                        } else {
                            $self.lastInputError = true;
                            reject($data);
                        }
                    } else {
                        $self.lastInputError = true;
                        reject($data);
                    }
                }
            };

            // Set request values.
            if ($self.inputElement) {
                $self.requestBody.params.postCode = $self.inputElement.value.trim();
            }

            // Set country
            countryElement = document.querySelector($self.config.secondaryInputSelectors.country);
            if ((undefined !== countryElement) && (null !== countryElement)) {
                countryCode = countryElement.options[countryElement.selectedIndex].getAttribute('data-code');
                if ('' === countryCode) {
                    countryCode = countryElement.options[countryElement.selectedIndex].value;
                }
                if ('' === countryCode) {
                    countryCode = 'de';
                }
                $self.requestBody.params.country = countryCode;
            }

            // Set language
            if (undefined !== $self.config.language && '' !== $self.config.language) {
                $self.requestBody.params.language = $self.config.language;
            }

            /**
             * Backward compatibility for referer
             * If not set, it will use the browser url.
             */
            if ('not_set' === $self.config.referer) {
                $self.config.referer = window.location.href;
            }

            $self.connector.open('POST', $self.config.endpoint, true);
            $self.connector.setRequestHeader("Content-type", "application/json");
            $self.connector.setRequestHeader("X-Auth-Key", $self.config.apiKey);
            $self.connector.setRequestHeader("X-Transaction-Id", $self.config.tid);
            $self.connector.setRequestHeader("X-Transaction-Referer", $self.config.referer);
            $self.connector.send(JSON.stringify($self.requestBody));
        });
    }

    /**
     * Renders predictions in a dropdown.
     */
    this.renderDropdown = function() {
        var ul;
        var li;
        var postCode;
        var input;
        if ('' === $self.originalInput) {
            input = $self.inputElement.value.trim();
            $self.originalInput = input;
        } else {
            input = $self.originalInput;
        }
        var direction = getComputedStyle($self.inputElement).direction;
        var counter = 0;
        var regEx;
        var replaceMask;
        var event;
        var selectedPostCode;
        var selectedCityName;
        var cityNameField;
        var cityNameSet = false;

        $self.removeDropdown();

        if (0 === $self.predictions.length) {
            return;
        }

        ul = document.createElement('ul');
        if ('rtl' === direction) {
            ul.style.textAlign = 'right';
        } else {
            ul.style.textAlign = 'left';
        }
        ul.style.zIndex = '9001';
        ul.style.borderRadius = '4px';
        ul.style.backgroundColor = '#fff';
        ul.style.border = '1px solid #dedede';
        ul.style.listStyle = 'none';
        ul.style.padding = '4px 4px';
        ul.style.margin = 0;
        ul.style.position = 'absolute';
        ul.style.top = 4 + $self.inputElement.offsetTop + $self.inputElement.offsetHeight + 'px';
        if ('rtl' === direction) {
            ul.style.right = $self.inputElement.offsetParent.offsetWidth - $self.inputElement.offsetLeft - $self.inputElement.offsetWidth + 'px';
        } else {
            ul.style.left = $self.inputElement.offsetLeft + 'px';
        }

        ul.setAttribute('class', 'endereco-dropdown');
        $self.dropdown = ul;
        $self.inputElement.parentNode.insertBefore(ul, $self.inputElement.nextSibling);

        ul.addEventListener('mouseout', function() {
            $self.inputElement.value = $self.originalInput;
            if (document.querySelector($self.config.secondaryInputSelectors.cityName)) {
                document.querySelector($self.config.secondaryInputSelectors.cityName).value = $self.originalCity;
            }
        });

        // Iterate through list and create new elements
        $self.predictions.forEach( function(element) {
            li = document.createElement('li');
            li.style.cursor = 'pointer';
            li.style.color = '#000';
            li.style.padding = '2px 4px';
            li.style.margin = '0';
            li.setAttribute('data-index', counter);
            if (counter === $self.activeElementIndex) {
                li.style.backgroundColor = 'rgba(0, 137, 167, 0.25)';
            } else {
                li.style.backgroundColor = 'transparent';
            }
            li.addEventListener('mouseover', function() {
                this.style.backgroundColor = 'rgba(0, 137, 167, 0.25)';
                $self.blockInput = true;
            });

            li.addEventListener('mouseout', function() {
                this.style.backgroundColor =  'transparent';
                $self.blockInput = false;
            });

            regEx = new RegExp('(' + input + ')', 'ig');
            replaceMask = '<mark style="background-color: transparent; padding: 0; margin: 0; font-weight: 700; color: ' +  $self.config.colors.secondaryColor + '">$1</mark>';
            postCode = element.postCode.replace(regEx, replaceMask);
            li.innerHTML = postCode;
            li.setAttribute('data-post-code', element.postCode);
            if (undefined !== element.cityName && '' !== element.cityName) {
                li.innerHTML = li.innerHTML + ' ' + element.cityName;
                li.setAttribute('data-city-name', element.cityName);
            }

            // Register event
            li.addEventListener('mouseover', function(mEvent) {
                mEvent.preventDefault();

                selectedPostCode = this.getAttribute('data-post-code');
                $self.inputElement.value = selectedPostCode;
                $self.activeElementIndex = this.getAttribute('data-index') * 1;

                if ($self.config.secondaryInputSelectors && $self.config.secondaryInputSelectors.cityName) {

                    selectedCityName = this.getAttribute('data-city-name');
                    cityNameField = document.querySelector($self.config.secondaryInputSelectors.cityName);
                    if (cityNameField && selectedCityName) {
                        cityNameField.value = selectedCityName.trim();
                        cityNameSet = true;
                    } else {
                        cityNameSet = false;
                    }
                }
            });

            li.addEventListener( 'mousedown', function(mEvent) {
                mEvent.preventDefault();

                event = $self.createEvent('endereco.valid');
                $self.inputElement.dispatchEvent(event);

                if ($self.config.secondaryInputSelectors && $self.config.secondaryInputSelectors.cityName && cityNameSet) {
                    event = $self.createEvent('endereco.valid');
                    cityNameField.dispatchEvent(event);
                }

                $self.saveOriginal();
                $self.removeDropdown();
            });

            $self.dropdown.appendChild(li);

            counter++;
        });
    }

    /**
     * Removes dropdown from DOM.
     */
    this.removeDropdown = function() {
        if (null !== $self.dropdown && undefined !== $self.dropdown ) {
            $self.dropdown.parentElement.removeChild($self.dropdown);
            $self.dropdown = undefined;
        }
        $self.blockInput = false;
    }

    /**
     * Resotre original values.
     */
    this.restoreOriginal = function() {
        cityNameField = document.querySelector($self.config.secondaryInputSelectors.cityName);
        if (cityNameField) {
            cityNameField.value = $self.originalCity
        }
        $self.inputElement.value = $self.originalInput;
    }

    /**
     * Save original state.
     */
    this.saveOriginal = function() {
        var cityNameField = document.querySelector($self.config.secondaryInputSelectors.cityName);
        if (cityNameField) {
            $self.originalCity = cityNameField.value;
        }
        $self.originalInput = $self.inputElement.value;
    }

    /**
     * Validate fields.
     */
    this.validate = function() {
        var input = $self.inputElement.value.trim();
        var event;
        var includes = false;

        if ($self.lastInputError) {
            return;
        }

        $self.predictions.forEach( function(prediction) {
            if (input === prediction.postCode) {
                includes = true;
            }
        });

        if (includes) {
            event = $self.createEvent('endereco.valid');
            $self.inputElement.dispatchEvent(event);
        } else if('' === input) {
            event = $self.createEvent('endereco.clean');
            $self.inputElement.dispatchEvent(event);
        } else {
            event = $self.createEvent('endereco.check');
            $self.inputElement.dispatchEvent(event);
        }
    };

    /**
     * Init postCodeAutocomplete.
     */
    this.init = function() {
        var cityNameSet = false;
        try {
            $self.inputElement = document.querySelector($self.config.inputSelector);
            $self.dropdown = undefined;
            $self.dropdownDraw = true;
            $self.predictions = [];
            $self.activeElementIndex = -1;

            $self.saveOriginal();
        } catch(e) {
            console.log('Could not initiate PostCodeAutocomplete because of error.');
        }

        // Disable browser autocomplete
        if ($self.isChrome()) {
            $self.inputElement.setAttribute('autocomplete', 'autocomplete_' + Math.random().toString(36).substring(2) + Date.now());
        } else {
            $self.inputElement.setAttribute('autocomplete', 'off' );
        }

        // Register events
        $self.inputElement.addEventListener('input', function() {
            var $this = this;
            var acCall = $self.getPredictions();
            $self.originalInput = this.value;
            acCall.then( function($data) {
                $self.predictions = $data.result.predictions;
                if ($this === document.activeElement) {
                    $self.renderDropdown();
                }
                if ($data.cmd && $data.cmd.use_tid) {
                    $self.config.tid = $data.cmd.use_tid;

                    if (0 < $self.config.serviceGroup.length) {
                        $self.config.serviceGroup.forEach( function(serviceObject) {
                            serviceObject.updateConfig({'tid': $data.cmd.use_tid});
                        })
                    }
                }
            }, function($data){console.log('Rejected with data:', $data)});
        });

        $self.inputElement.addEventListener('focus', function() {
            $self.saveOriginal();
            if ('' === this.value && 'not_set' !== $self.config.tid) {
                return;
            }
            var acCall = $self.getPredictions();
            acCall.then( function($data) {
                $self.predictions = $data.result.predictions;
                $self.validate();
                if ($data.cmd && $data.cmd.use_tid) {
                    $self.config.tid = $data.cmd.use_tid;

                    if (0 < $self.config.serviceGroup.length) {
                        $self.config.serviceGroup.forEach( function(serviceObject) {
                            serviceObject.updateConfig({'tid': $data.cmd.use_tid});
                        })
                    }
                }
            }, function($data){console.log('Rejected with data:', $data)});
        });

        // Register blur event
        $self.inputElement.addEventListener('blur', function() {
            $self.removeDropdown();
            $self.saveOriginal();
            $self.validate();
        });

        // Register mouse navigation
        $self.inputElement.addEventListener('keydown', function(mEvent) {
            var selectedCityName, cityNameField, event;
            if ('ArrowUp' === mEvent.key || 'Up' === mEvent.key) {
                mEvent.preventDefault();

                if (0 === $self.activeElementIndex) {
                    $self.activeElementIndex = -1;
                    $self.inputElement.value = $self.originalInput;
                    if (document.querySelector($self.config.secondaryInputSelectors.cityName)) {
                        document.querySelector($self.config.secondaryInputSelectors.cityName).value = $self.originalCity;
                    }
                }

                if (0 < $self.activeElementIndex) {
                    $self.activeElementIndex--;
                    // Prefill selection to input
                    if (0 < $self.predictions.length) {
                        $self.inputElement.value = $self.predictions[$self.activeElementIndex].postCode;
                        selectedCityName = $self.predictions[$self.activeElementIndex].cityName;
                        cityNameField = document.querySelector($self.config.secondaryInputSelectors.cityName);
                        if (selectedCityName && cityNameField) {
                            cityNameField.value = selectedCityName.trim();
                            cityNameSet = true;
                        } else {
                            cityNameSet = false;
                        }
                    }
                }
                $self.renderDropdown();
            }

            if ('ArrowDown' === mEvent.key || 'Down' === mEvent.key) {
                mEvent.preventDefault();
                if ($self.activeElementIndex < ($self.predictions.length-1)) {
                    $self.activeElementIndex++;
                }

                // Prefill selection to input
                if (0 < $self.predictions.length) {
                    $self.inputElement.value = $self.predictions[$self.activeElementIndex].postCode;
                    selectedCityName = $self.predictions[$self.activeElementIndex].cityName;
                    cityNameField = document.querySelector($self.config.secondaryInputSelectors.cityName);
                    if (selectedCityName && cityNameField) {
                        cityNameField.value = selectedCityName.trim();
                        cityNameSet = true;
                    } else {
                        cityNameSet = false;
                    }
                }

                $self.renderDropdown();
            }

            if ('Enter' === mEvent.key || 'Enter' === mEvent.key) {
                mEvent.preventDefault();

                // If only one prediction
                if (1 === $self.predictions.length) {
                    // Prefill selection to input
                    $self.inputElement.value = $self.predictions[0].postCode;
                    selectedCityName = $self.predictions[0].cityName;
                    cityNameField = document.querySelector($self.config.secondaryInputSelectors.cityName);
                    if (cityNameField && ('' !== selectedCityName)) {
                        cityNameField.value = selectedCityName.trim();
                        cityNameSet = true;
                    }
                }

                // Then
                event = $self.createEvent('endereco.valid');
                $self.inputElement.dispatchEvent(event);

                cityNameField = document.querySelector($self.config.secondaryInputSelectors.cityName);
                if (cityNameField && cityNameSet) {
                    event = $self.createEvent('endereco.valid');
                    cityNameField.dispatchEvent(event);
                }

                $self.saveOriginal();
                $self.removeDropdown();
            }

            if ('Tab' === mEvent.key || 'Tab' === mEvent.key) {
                $self.saveOriginal();
                $self.removeDropdown();
            }

            if ($self.blockInput) {
                mEvent.preventDefault();
                return;
            }
        });

        $self.dirty = false;

        console.log('PostcodeAutocomplete initiated.');
    }

    // Check if the browser is chrome
    this.isChrome = function() {
        return /chrom(e|ium)/.test( navigator.userAgent.toLowerCase( ) );
    }

    // Service loop.
    setInterval( function() {

        if ($self.config.useWatcher) {
            $self.checkIfFieldsAreSet();
        }

        if ($self.dirty) {
            $self.init();
        }
    }, 300);
}
