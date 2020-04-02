/**
 * Endereco SDK.
 *
 * @author Ilja Weber <ilja@endereco.de>
 * @copyright 2019 mobilemojo – Apps & eCommerce UG (haftungsbeschränkt) & Co. KG
 * {@link https://endereco.de}
 */
function StatusIndicator(config) {
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

    this.statusIconElement = undefined;
    this.renderTimeout = undefined;

    this.defaultConfig = {
        'useWatcher': true,
        'showIcons': false
    };
    this.fieldsAreSet = false;
    this.dirty = false;
    this.config = $self.mergeObjects([this.defaultConfig, config]);


    this.init = function() {
        try {
            $self.inputElement = document.querySelector($self.config.inputSelector);
            $self.displayElement = document.querySelector($self.config.displaySelector);
            $self.defaultBorderColor = $self.displayElement.style.borderColor;

            //// Listen to events
            $self.inputElement.addEventListener('endereco.valid', function() {
                $self.displayElement.style.borderColor = $self.config.colors.successColor;
                if ($self.config.showIcons) {
                    $self.renderSuccess();
                }
            });

            $self.inputElement.addEventListener('endereco.check', function() {
                $self.displayElement.style.borderColor = $self.config.colors.warningColor;
                if ($self.config.showIcons) {
                    $self.renderCheck();
                }
            });

            $self.inputElement.addEventListener('endereco.loading', function() {
                $self.displayElement.style.borderColor = $self.defaultBorderColor;
                if ($self.config.showIcons) {
                    $self.renderClean();
                }
            });

            $self.inputElement.addEventListener('endereco.clean', function() {
                $self.displayElement.style.borderColor = $self.defaultBorderColor;

                if ($self.config.showIcons) {
                    $self.renderClean();;
                }
            });

        } catch(e) {
            console.log('Could not initiate StatusIndicator because of error', e);
            return;
        }

        window.addEventListener('resize', function() {
            if (undefined !== $self.renderTimeout) {
                clearTimeout($self.renderTimeout)
            }
            $self.renderTimeout = setTimeout( function() {
                $self.calculatePosition();
            }, 200);
        });

        $self.dirty = false;
        console.log('StatusIndicator initiated');
    }

    this.calculatePosition = function() {
        if($self.dirty) {
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
    };

    // Render success icon
    this.renderSuccess = function() {
        if($self.dirty) {
            return;
        }
        if (undefined !== $self.statusIconElement) {
            $self.statusIconElement.parentElement.removeChild($self.statusIconElement);
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
        if($self.dirty) {
            return;
        }
        if (undefined !== $self.statusIconElement) {
            $self.statusIconElement.parentElement.removeChild($self.statusIconElement);
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
        if($self.dirty) {
            return;
        }
        if (undefined !== $self.statusIconElement) {
            $self.statusIconElement.parentElement.removeChild($self.statusIconElement);
            $self.statusIconElement = undefined;
        }
    }

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
        if((null !== document.querySelector(config.inputSelector))
            && (null !== document.querySelector(config.displaySelector))) {
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
