/**
 * Endereco SDK.
 *
 * @author Ilja Weber <ilja.weber@mobilemjo.de>
 * @copyright 2019 mobilemojo – Apps & eCommerce UG (haftungsbeschränkt) & Co. KG
 * {@link https://endereco.de}
 */
function StatusIndicator(config) {

    var $self  = this;
    this.isSet = false;

    this.config = config;
    this.statusIconElement = undefined;
    this.renderTimeout = undefined;


    // Observe the website in a loop.
    setInterval( function() {
        var isNowSet = false;
        if(
            (null !== document.querySelector(config.inputSelector))
            && (null !== document.querySelector(config.displaySelector))
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
        console.log('Initiate StatusIndicator');

        window.addEventListener('resize', function() {
            if (undefined !== $self.renderTimeout) {
                clearTimeout($self.renderTimeout)
            }
            $self.renderTimeout = setTimeout( function() {
                $self.calculatePosition();
            }, 200);
        });

        $self.inputElement = document.querySelector(config.inputSelector);
        $self.displayElement = document.querySelector(config.displaySelector);
        $self.defaultBorderColor = $self.displayElement.style.borderColor;

        //// Listen to events
        $self.inputElement.addEventListener('endereco.valid', function() {
            $self.displayElement.style.borderColor = $self.config.colors.successColor;
            //$self.renderSuccess();
        });

        $self.inputElement.addEventListener('endereco.check', function() {
            $self.displayElement.style.borderColor = $self.config.colors.warningColor;
            //$self.renderCheck();
        });

        $self.inputElement.addEventListener('endereco.loading', function() {
            $self.displayElement.style.borderColor = $self.defaultBorderColor;
            $self.renderClean();
        });

        $self.inputElement.addEventListener('endereco.clean', function() {
            $self.displayElement.style.borderColor = $self.defaultBorderColor;
            $self.renderClean();
        });

        $self.isSet = true;
    }

    this.calculatePosition = function() {
        if(!$self.isSet) {
            return;
        }
        var position = {
            top: 0,
            left: 0
        };

        var width = window.innerWidth
            || document.documentElement.clientWidth
            || document.body.clientWidth;

        if (width > 990) {
            position.top = ($self.displayElement.offsetTop);
            position.left = ($self.displayElement.offsetLeft + $self.displayElement.offsetWidth + 4);
        } else {
            position.top = $self.displayElement.offsetTop - 30;
            position.left = $self.displayElement.offsetLeft + $self.displayElement.offsetWidth - 20;
        }

        if (undefined !== $self.statusIconElement) {
            $self.statusIconElement.style.top = position.top + 'px';
            $self.statusIconElement.style.left = position.left + 'px';
        }

        return position;
    }

    // Render success icon
    this.renderSuccess = function() {
        if(!$self.isSet) {
            return;
        }
        if (undefined !== $self.statusIconElement) {
            $self.statusIconElement.remove();
            $self.statusIconElement = undefined;
        }

        this.statusIconElement = document.createElement('span');
        this.statusIconElement.appendChild(document.createTextNode('✓'));

        this.statusIconElement.style.position = 'absolute';
        this.statusIconElement.style.color = $self.config.colors.successColor;
        this.statusIconElement.style.fontSize = '22px';

        this.calculatePosition();

        $self.displayElement.parentNode.insertBefore(this.statusIconElement, $self.displayElement.nextSibling);
    }

    // Render success icon
    this.renderCheck = function() {
        if(!$self.isSet) {
            return;
        }
        if (undefined !== $self.statusIconElement) {
            $self.statusIconElement.remove();
            $self.statusIconElement = undefined;
        }

        this.statusIconElement = document.createElement('span');
        this.statusIconElement.appendChild(document.createTextNode('⚠'));

        this.statusIconElement.style.position = 'absolute';
        this.statusIconElement.style.color = $self.config.colors.warningColor;
        this.statusIconElement.style.fontSize = '22px';

        this.calculatePosition();

        $self.displayElement.parentNode.insertBefore(this.statusIconElement, $self.displayElement.nextSibling);
    }

    // Remove status icon
    this.renderClean = function() {
        if(!$self.isSet) {
            return;
        }
        if (undefined !== $self.statusIconElement) {
            $self.statusIconElement.remove();
            $self.statusIconElement = undefined;
        }
    }
}
