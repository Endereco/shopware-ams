/**
 * Endereco SDK.
 *
 * @author Ilja Weber <ilja.weber@mobilemjo.de>
 * @copyright 2019 mobilemojo – Apps & eCommerce UG (haftungsbeschränkt) & Co. KG
 * {@link https://endereco.de}
 */
function EmailCheck(config) {

    var $self  = this;
    this.tid = 'not_set';
    this.isSet = false;
    this.config = config;

    this.requestBody = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "emailCheck",
        "params": {
            "email": ""
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
        console.log('Initiate EmailCheck');
        $self.inputElement = document.querySelector(config.inputSelector);
        $self.gender = 'X';

        //// DOM modifications

        // Set mark
        $self.inputElement.setAttribute('data-service', 'emailCheck');
        $self.inputElement.setAttribute('data-status', 'instantiated');

        // Generate TID
        if (window.accounting) {
            $self.tid = window.accounting.generateTID();
        }

        // Disable browser autocomplete
        if ($self.isChrome()) {
            $self.inputElement.setAttribute('autocomplete', 'autocomplete_' + Math.random().toString(36).substring(2) + Date.now());
        } else {
            $self.inputElement.setAttribute('autocomplete', 'off' );
        }

        //// Rendering
        $self.inputElement.addEventListener('change', function() {
            $this = this;
            $self.requestBody.params.email = $this.value.trim();
            $self.connector.abort();
            $self.inputElement.setAttribute('data-status', 'loading');
            $self.connector.open('POST', $self.config.endpoint, true);
            $self.connector.setRequestHeader("Content-type", "application/json");
            $self.connector.setRequestHeader("X-Auth-Key", $self.config.apiKey);
            $self.connector.setRequestHeader("X-Transaction-Id", $self.tid);
            $self.connector.setRequestHeader("X-Transaction-Referer", window.location.href);

            $self.connector.send(JSON.stringify($self.requestBody));
        });

        $self.isSet = true;
    }


    // Check if the browser is chrome
    this.isChrome = function() {
        return /chrom(e|ium)/.test( navigator.userAgent.toLowerCase( ) );
    }

    // On data receive
    this.connector.onreadystatechange = function() {
        if(4 === $self.connector.readyState) {
            if ($self.connector.responseText && '' !== $self.connector.responseText) {
                $data = JSON.parse($self.connector.responseText);
                if (undefined !== $data.result) {
                    if ($data.result.status.includes('A1000')) {
                        event = new Event('endereco.valid');
                        $self.inputElement.dispatchEvent(event);
                    }

                    if ($data.result.status.includes('A4000')) {
                        event = new Event('endereco.check');
                        $self.inputElement.dispatchEvent(event);
                    }

                    if ($data.result.status.includes('A5000')) {
                        event = new Event('endereco.check');
                        $self.inputElement.dispatchEvent(event);
                    }
                }
            }
        }

    }
}
