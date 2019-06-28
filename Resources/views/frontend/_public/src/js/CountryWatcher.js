/**
 * Endereco SDK.
 *
 * @author Ilja Weber <ilja.weber@mobilemjo.de>
 * @copyright 2019 mobilemojo – Apps & eCommerce UG (haftungsbeschränkt) & Co. KG
 * {@link https://endereco.de}
 */
function CountryWatcher(config) {
    this.isSet = false;
    this.config = config;
    this.setElement = '';
    this.connector = new XMLHttpRequest();
    var $self  = this;

    setInterval( function() {
        var isNowSet = false;
        if((null !== document.querySelector(config.countrySelector))) {
            isNowSet = true;
        }

        if (!$self.isSet && isNowSet) {
            init();
        } else if ($self.isSet && isNowSet) {
            syncFields();
        } else {
            $self.isSet = false;
        }
    }, 500);

    function init() {
        console.log('initiate CountryWatcher');
        $self.countryElement = document.querySelector($self.config.countrySelector);
        $self.isSet = true;
    }

    function syncFields() {
        if ('' === $self.countryElement.value) {
            $self.countryElement.setAttribute('data-value', '');
            return;
        }

        if ($self.setElement !== $self.countryElement.value) {

            $self.connector.abort();
            $self.connector.open('POST', $self.config.countryEndpoint + '?id=' + $self.countryElement.value, false);
            $self.connector.send();
            $self.setElement = $self.countryElement.value;
        }
    }

    // On data receive
    this.connector.onreadystatechange = function() {
        if (4 === $self.connector.readyState) {
            if ($self.connector.responseText && '' !== $self.connector.responseText) {
                $self.countryElement.setAttribute('data-value', $self.connector.responseText);
            }
        }
    }
}
