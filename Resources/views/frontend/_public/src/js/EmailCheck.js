/**
 * Endereco SDK.
 *
 * @author Ilja Weber <ilja@endereco.de>
 * @copyright 2019 mobilemojo – Apps & eCommerce UG (haftungsbeschränkt) & Co. KG
 * {@link https://endereco.de}
 */
function EmailCheck(config) {

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
        "method": "emailCheck",
        "params": {
            "email": ""
        }
    };
    this.defaultConfig = {
        'useWatcher': true,
        'referer': 'not_set',
        'tid': 'not_set'
    };
    this.fieldsAreSet = false;
    this.dirty = false;
    this.config = $self.mergeObjects([this.defaultConfig, config]);
    this.connector = new XMLHttpRequest();


    //// Functions
    this.init = function() {
        try {
            $self.inputElement = document.querySelector($self.config.inputSelector);
            $self.gender = 'X';
        } catch(e) {
            console.log('Could not initiate EmailCheck because of error.', e);
        }

        // Disable browser autocomplete
        if ($self.isChrome()) {
            $self.inputElement.setAttribute('autocomplete', 'autocomplete_' + Math.random().toString(36).substring(2) + Date.now());
        } else {
            $self.inputElement.setAttribute('autocomplete', 'off' );
        }

        //// Rendering
        $self.inputElement.addEventListener('change', function() {
            $aCheck = $self.checkEmail();
            $aCheck.then(function($data) {
                var event;
                if ($data.result.status.includes('A1000')) {
                    event = $self.createEvent('endereco.valid');
                    $self.inputElement.dispatchEvent(event);
                }

                if ($data.result.status.includes('A4000')) {
                    event = $self.createEvent('endereco.check');
                    $self.inputElement.dispatchEvent(event);
                }

                if ($data.result.status.includes('A5000')) {
                    event = $self.createEvent('endereco.check');
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

            }, function($data) {
                var event;
                event = $self.createEvent('endereco.clean');
                $self.inputElement.dispatchEvent(event);

                if ($data.cmd && $data.cmd.use_tid) {
                    $self.config.tid = $data.cmd.use_tid;

                    if ($self.config.serviceGroup && 0 < $self.config.serviceGroup.length) {
                        $self.config.serviceGroup.forEach( function(serviceObject) {
                            serviceObject.updateConfig({'tid': $data.cmd.use_tid});
                        })
                    }
                }
            })

        });

        $self.dirty = false;
        console.log('EmailCheck initiated.')
    }

    this.checkEmail = function() {
        return new Promise(function(resolve, reject){

            $self.connector.onreadystatechange = function() {
                if(4 === $self.connector.readyState) {
                    if ($self.connector.responseText && '' !== $self.connector.responseText) {
                        try {
                            $data = JSON.parse($self.connector.responseText);

                            if ($data.result) {
                                resolve($data);
                            } else {
                                reject($data);
                            }
                        } catch(e) {
                            console.log('Error in EmailCheck', e);
                            reject($data);
                        }
                    } else {
                        reject({});
                    }
                }
            }

            /**
             * Backward compatibility for referer
             * If not set, it will use the browser url.
             */
            if ('not_set' === $self.config.referer) {
                $self.config.referer = window.location.href;
            }

            $self.requestBody.params.email = $self.inputElement.value.trim();
            $self.connector.open('POST', $self.config.endpoint, true);
            $self.connector.setRequestHeader("Content-type", "application/json");
            $self.connector.setRequestHeader("X-Auth-Key", $self.config.apiKey);
            $self.connector.setRequestHeader("X-Transaction-Id", $self.config.tid);
            $self.connector.setRequestHeader("X-Transaction-Referer", $self.config.referer);

            $self.connector.send(JSON.stringify($self.requestBody));

            setTimeout( function() {
                if (1 === $self.connector.readyState) {
                    console.log('Timeout cancelling for EmailCheck');
                    $self.connector.abort();
                    reject({});
                }

            }, 4000);
        });
    };


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
