/**
 * Endereco SDK.
 *
 * @author Ilja Weber <ilja@endereco.de>
 * @copyright 2019 mobilemojo – Apps & eCommerce UG (haftungsbeschränkt) & Co. KG
 * {@link https://endereco.de}
 */
function PrephoneCheck(config) {
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

    this.requestBody = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "prephoneCheck",
        "params": {
            "prephoneNumber": "",
            "format": 8
        }
    }
    this.defaultConfig = {
        'useWatcher': true,
        'referer': 'not_set',
        'tid': 'not_set'
    };
    this.fieldsAreSet = false;
    this.dirty = false;
    this.config = $self.mergeObjects([this.defaultConfig, config]);
    this.format = config.format;
    this.connector = new XMLHttpRequest();

    //// Functions
    this.init = function() {
        try {
            $self.inputElement = document.querySelector($self.config.inputSelector);
        } catch(e) {
            console.log('Could not initiate PrephoneCheck because of error', e);
            return;
        }

        // Disable browser autocomplete
        if ($self.isChrome()) {
            $self.inputElement.setAttribute('autocomplete', 'autocomplete_' + Math.random().toString(36).substring(2) + Date.now());
        } else {
            $self.inputElement.setAttribute('autocomplete', 'off' );
        }

        //// Rendering
        $self.inputElement.addEventListener('change', function() {
            var event;
            var $this = this;

            if ('' === $this.value.trim()) {
                event = $self.createEvent('endereco.clean');
                $self.inputElement.dispatchEvent(event);
                return;
            }

            $self.checkPrephone().then(function($data) {
                var event;
                if ($data.result.status.includes('A1000')) {
                    $self.inputElement.value = $data.result.prephoneNumber;
                    event = $self.createEvent('endereco.valid');
                    $self.inputElement.dispatchEvent(event);
                } else {
                    event = $self.createEvent('endereco.clean');
                    $self.inputElement.dispatchEvent(event);
                }

                if ($data.cmd && $data.cmd.use_tid) {
                    $self.config.tid = $data.cmd.use_tid;

                    if ($self.config.serviceGroup && 0 < $self.config.serviceGroup.length) {
                        $self.config.serviceGroup.forEach( function(serviceObject) {
                            serviceObject.updateConfig({'tid': $data.cmd.use_tid});
                        })
                    }
                }
            });

        });

        $self.dirty = false;
        console.log('PrephoneCheck initiated.');
    }

    // Check if the browser is chrome
    this.isChrome = function() {
        return /chrom(e|ium)/.test( navigator.userAgent.toLowerCase( ) );
    }

    this.checkPrephone = function() {

        return new Promise(function(resolve, reject) {
            $self.connector.onreadystatechange = function() {
                var $data = {};
                if(4 === $self.connector.readyState) {
                    if ($self.connector.responseText && '' !== $self.connector.responseText) {
                        try {
                            $data = JSON.parse($self.connector.responseText);
                        } catch(e) {
                            console.log('Could not parse JSON', e);
                            reject($data);
                        }

                        if (undefined !== $data.result) {
                            resolve($data);
                        } else {
                            reject($data);
                        }
                    } else {
                        reject($data);
                    }
                }
            };

            /**
             * Backward compatibility for referer
             * If not set, it will use the browser url.
             */
            if ('not_set' === $self.config.referer) {
                $self.config.referer = window.location.href;
            }

            $self.requestBody.params.prephoneNumber = $self.inputElement.value.trim();
            $self.requestBody.params.format = $self.format;
            $self.connector.open('POST', $self.config.endpoint, true);
            $self.connector.setRequestHeader("Content-type", "application/json");
            $self.connector.setRequestHeader("X-Auth-Key", $self.config.apiKey);
            $self.connector.setRequestHeader("X-Transaction-Id", $self.config.tid);
            $self.connector.setRequestHeader("X-Transaction-Referer", $self.config.referer);

            $self.connector.send(JSON.stringify($self.requestBody));
        });
    };

    /**
     * Helper function creates event that is compatible with IE 11.
     *
     * @param eventName
     * @returns {Event}
     */
    this.createEvent = function(eventName) {
        var event;
        if(typeof(Event) === 'function') {
            event = new Event(eventName);
        }else{
            event = document.createEvent('Event');
            event.initEvent(eventName, true, true);
        }
        return event;
    };

    /**
     * Helper function to update existing config, overwriting existing fields.
     *
     * @param newConfig
     */
    this.updateConfig = function(newConfig) {
        $self.config = $self.mergeObjects([$self.config, newConfig]);
    };

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
    };

    // Check if the browser is chrome
    this.isChrome = function() {
        return /chrom(e|ium)/.test( navigator.userAgent.toLowerCase( ) );
    };

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
