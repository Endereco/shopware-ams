/**
 * Endereco SDK.
 *
 * @author Ilja Weber <ilja@endereco.de>
 * @copyright 2019 mobilemojo – Apps & eCommerce UG (haftungsbeschränkt) & Co. KG
 * {@link https://endereco.de}
 */
function CountryAutocomplete(config) {

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
        "method": "getCountryCodes",
        "params": {
            "countryIds": []
        }
    };
    this.defaultConfig = {
        'useWatcher': true,
        'tid': 'not_set'
    };
    this.fieldsAreSet = false;
    this.dirty = false;
    this.ready = false;
    this.config = $self.mergeObjects([this.defaultConfig, config]);
    this.connector = new XMLHttpRequest();



    /**
     * Updates the config.
     */
    this.updateConfig = function(newConfig) {
        $self.config = $self.mergeObjects([$self.config, newConfig]);
    }

    /**
     * Checks if fields are set.
     */
    this.checkIfFieldsAreSet = function() {
        var areFieldsSet = false;
        if((null !== document.querySelector($self.config.countrySelector))) {
            areFieldsSet = true;
        }

        if (!$self.fieldsAreSet && areFieldsSet) {

            // Fields are now set. Mark addresscheck as dirty to trigger reinitiation.
            $self.dirty = true;
            $self.fieldsAreSet = true;
        } else if($self.fieldsAreSet && !areFieldsSet) {

            // Fields have been removed.
            $self.fieldsAreSet = false;
        }
    }

    this.init = function() {
        try {
            $self.countryElement = document.querySelector($self.config.countrySelector);

            // Define callback function.
            $self.connector.onreadystatechange = function() {
                if (4 === $self.connector.readyState) {
                    if ($self.connector.responseText && '' !== $self.connector.responseText) {
                        try {
                            $data = JSON.parse($self.connector.responseText);
                        } catch(e) {
                            console.log('Parsing error', e);
                        }

                        $self.setCountryCodes($data.result.countryCodes);
                    }
                }
            }

            $self.requestBody.params.countryIds = $self.getCountryIds();

            $self.connector.abort();
            $self.connector.open('POST', $self.config.countryEndpoint, true);
            $self.connector.send((JSON.stringify($self.requestBody)));

            $self.dirty = false;
            console.log('CountryAutocomplete initiated.')
        } catch(e) {
            console.log('Could not initiate CountryAutocomplete because of error:', e);
        }
    }

    this.getCountryIds = function() {
        var options;
        var idsArray = {};
        if (!$self.fieldsAreSet) {
            return [];
        }

        options = document.querySelector($self.config.countrySelector).options;

        for (var i = 0; i < options.length; i++) {
            idsArray[i] = options[i].value;
        }

        return idsArray;
    }

    this.setCountryCodes = function(countryCodes) {
        var options;
        options = document.querySelector($self.config.countrySelector).options;
        for (var i = 0; i < options.length; i++) {
            options[i].setAttribute('data-code', countryCodes[i]);
        }
        this.ready = true;
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
