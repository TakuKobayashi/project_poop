var Sherlock = (function () {
    function Sherlock() {
        this._APIKEY = {
            bluemix: { url: "", password: "", username: "" },
            docomo: null
        };
        this._availability = {
            bluemix: false
        };
    }
    Sherlock.prototype.setAPI = function (service, credentials) {
        if (service === "bluemix") {
            this._APIKEY.bluemix = credentials;
            this._availability.bluemix = true;
        }
    };
    Sherlock.prototype.checkAvailability = function () {
    };
    Sherlock.prototype.recognize = function (text, lang) {
        var def = $.Deferred();
        return def;
    };
    return Sherlock;
})();
//# sourceMappingURL=app.js.map