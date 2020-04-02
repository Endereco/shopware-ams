/**
 * Endereco SDK.
 *
 * @author Ilja Weber <ilja.weber@mobilemjo.de>
 * @copyright 2019 mobilemojo – Apps & eCommerce UG (haftungsbeschränkt) & Co. KG
 * {@link https://endereco.de}
 */
function FieldsManager(config) {
    this.isSet = false;
    this.config = config;
    var $self  = this;

    setInterval( function() {
        var isNowSet = false;
        if((null !== document.querySelector(config.streetNameSelector)) && (null !== document.querySelector(config.houseNumberSelector)) && (null !== document.querySelector(config.streetSelector))) {
            isNowSet = true;
        }

        if (!$self.isSet && isNowSet) {
            $self.init();
        } else if ($self.isSet && isNowSet) {
            $self.syncFields();
        } else {
            $self.isSet = false;
        }
    }, 300);

    this.init = function() {
        $self.inputStreetNameElement = document.querySelector($self.config.streetNameSelector);
        $self.inputNumberElement = document.querySelector($self.config.houseNumberSelector);
        $self.targetStreetElement = document.querySelector($self.config.streetSelector);


        $self.inputStreetNameElement.addEventListener('input', function() {
            $self.targetStreetElement.value = $self.inputStreetNameElement.value + ' ' + $self.inputNumberElement.value;
        });

        $self.inputNumberElement.addEventListener('input', function() {
            $self.targetStreetElement.value = $self.inputStreetNameElement.value + ' ' + $self.inputNumberElement.value;
        });

        $self.isSet = true;
        console.log('Fieldsmanager initiated');
    }

    this.syncFields = function() {
        if ('' !== $self.inputStreetNameElement.value) {
            $self.targetStreetElement.value = $self.inputStreetNameElement.value + ' ' + $self.inputNumberElement.value;
        }

        if ('' === $self.inputStreetNameElement.value) {
            var street = $self.targetStreetElement.value;

            // Trim
            street = street.trim();

            // Remove double whitespace
            street = street.replace(/\s{2,}/g, ' ');

            // Split street to words
            var words = street.split(' ');

            // Defined variables
            var streetName = words[0]; // first word is alway a street name.
            var houseNumber = ''; // Has to be found jet.
            var isNumber = false;

            for (var i = 1; i < words.length; i++) {
                if (!isNumber && $self.hasNumber(words[i])) {
                    isNumber = true;
                }

                if (isNumber) {
                    houseNumber += '' + words[i];
                } else {
                    streetName += ' ' + words[i];
                }
            }

            // Fill inputs.
            $self.inputStreetNameElement.value = streetName;
            $self.inputNumberElement.value = houseNumber;
        }

    }

    this.hasNumber = function(text) {
        return /\d/.test(text);
    }
}
