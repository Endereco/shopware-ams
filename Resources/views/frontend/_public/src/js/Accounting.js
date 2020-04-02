/**
 * Endereco SDK.
 *
 * @author Ilja Weber <ilja@endereco.de>
 * @copyright 2019 mobilemojo – Apps & eCommerce UG (haftungsbeschränkt) & Co. KG
 * {@link https://endereco.de}
 */
function Accounting() {
    var $self  = this;

    this.generateTID = function() {
        prename = Math.random().toString(36).substring(2) + Date.now() + '_' + $self.hashCode(window.location.href);
        return btoa($self.caesarCipher(prename, 5));
    }

    this.caesarCipher = function(string, offset) {
        string = string.toLowerCase();
        var result = '';
        var charcode = 0;
        for (var i = 0; i < string.length; i++) {
            charcode = (string[i].charCodeAt()) + offset;
            result += String.fromCharCode(charcode);
        }
        return result;
    }

    this.hashCode = function(string) {
        var hash = 0, i, chr;
        if (0 === string.length) {
            return hash;
        }
        for (i = 0; i < string.length; i++) {
            chr   = string.charCodeAt(i);
            hash  = ((hash << 5) - hash) + chr;
            hash |= 0;
        }
        return hash;
    }
}
