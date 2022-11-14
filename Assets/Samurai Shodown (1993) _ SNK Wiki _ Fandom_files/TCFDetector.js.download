
EBG = EBG || {};
EBG.Adaptors = EBG.Adaptors || {};

/* REASONS: 

    We report to debugData the following cases:
    __tcfapi does not exists - 0
    __tcfapi getConsentData timed out - (-1)
    __tcfapi getConsentData success - 1
    __tcfapi getConsentData failed - 2

*/


EBG.Adaptors.TCFDetector = function (options) {
    this.init(options);
};

EBG.Adaptors.TCFDetector.prototype = {
    exists: false,
    initialized: false,
    subscriptions: [],
    _time: -1,
    _timeoutActualTime: -1,
    __tcfapi: function () {
        window.__tcfapi.apply(window, arguments);
    },
    init: function (options) {
        var $this = this;
        options = options || { timeout: 300, accurateTimeout: 0 };
        if (window.__tcfapi && typeof window.__tcfapi == "function") {
            this.exists = true;
        } else {
            this._detectTCFLocator();
        }

        // If __tcfapi is not applied for this page/site, we should stop here
        if (!this.exists) {
            this._setReason(0);
            this._setDefaultValue();
            return;
        }

        // TODO: product decision
        // Check for max of 300 miliseocnds
        // Keep in mind, products that uses this module need that information to make their job
        // Any delay here delays ad serving or OneTag generated request
        setTimeout(function () {
            // Mark timeout has exceeded
            var callee = arguments.callee;

            $this._timeoutActualTime = new Date().getTime() - $this._startTime;

            // TODO : product decision
            // I am not sure if this code may be harmful.
            // cant think of a way it will loop infinity but would like to review it
            // It suppose to promiss timeout will expire when we want it and not sooner as we seen in reports
            if (options.accurateTimeout) {
                options.accurateTimeout--;
                if ($this._timeoutActualTime < options.timeout) {
                    if (!$this._timeoutTimeGap) {
                        $this._timeoutTimeGap = options.timeout - $this._timeoutActualTime;
                    }

                    setTimeout(function () {
                        callee.apply($this, []);
                    }, Math.max(options.timeout - $this._timeoutActualTime, 1));
                    return;
                }
            }

            $this.cmpCheckTimedout = true;

            if (typeof $this.consentData == "undefined") {
                $this._setReason(-1);
                $this._setDefaultValue();
                $this._publishConsentData();
            }
        }, options.timeout);

        // Collect start time for estimation how much time it takes in average to grab user's consent data
        this._startTime = new Date().getTime();

        try {
            (function () {
                var callee = arguments.callee;
                $this.__tcfapi("ping", 2, function (res, success) {
                    if ((typeof success != "undefined" ? success : true) && res && res.cmpLoaded) {
                        $this.initialized = true;
                        $this._getConsentData(function (consent) {
                            $this.handleConsentReceived(consent);
                        });
                    } else {
                        // Try again in 5 miliseconds
                        if (!$this.cmpCheckTimedout) {
                            setTimeout(function () {
                                callee.apply($this, []);
                            }, 5);
                        }
                    }
                });
            })();
        } catch (e) {
            // Something went wrong, we need to set default
            $this._setDefaultValue();
            $this._publishConsentData();
        }
    },
    _detectTCFLocator: function () {
        //start here at our window
        var frame = window;
        // if we locate the CMP iframe we will reference it with this
        var cmpFrame;
        // map of calls
        var cmpCallbacks = {};
        while (frame) {
            try {
                if (frame.frames['__tcfapiLocator']) {
                    cmpFrame = frame;
                    break;
                }
            } catch (ignore) { }
            if (frame === window.top) {
                break;
            }
            frame = frame.parent;
        }

        /* Set up a __tcfapi proxy method to do the postMessage and map the callback.
         * From the caller's perspective, this function behaves identically to the
         * CMP API's __tcfapi call
         */

        if (cmpFrame) {
            this.exists = true;

            this.__tcfapi = function (cmd, version, callback, arg) {
                if (!cmpFrame) {
                    callback({ msg: 'CMP not found' }, false);
                } else {
                    var callId = Math.random() + '';
                    var msg = {
                        __tcfapiCall: {
                            command: cmd,
                            parameter: arg,
                            version: version,
                            callId: callId
                        }
                    };

                    /**
                     * map the callback for lookup on response
                     */
                    cmpCallbacks[callId] = callback;
                    cmpFrame.postMessage(msg, '*');

                    // Check if handler got called if not, retrigger this request
                    var interval = setInterval(function () {
                        if (cmpCallbacks[callId]) {
                            cmpFrame.postMessage(msg, '*');
                        } else {
                            clearInterval(interval);
                        }
                    }, 20);
                }
            };

            function postMessageHandler(event) {
                var json = {};
                try {
                    json = typeof event.data === 'string' ? JSON.parse(event.data) : event.data;
                } catch (ignore) { }

                var payload = json.__tcfapiReturn;
                if (payload) {
                    if (typeof cmpCallbacks[payload.callId] === 'function') {
                        cmpCallbacks[payload.callId](payload.returnValue, payload.success);
                        cmpCallbacks[payload.callId] = null;
                    }
                }
            }

            window.addEventListener('message', postMessageHandler, false);
        }
    },

    handleConsentReceived: function (consent) {
        this._time = new Date().getTime() - this._startTime;
        if (typeof this.consentData == "undefined") {
            if (consent && typeof consent.gdprApplies == "number") {
                // convert gdpr number to string (to avoid 0 from being detected as a falsy value)
                consent.gdprApplies = consent.gdprApplies + "";
            }
            this.consentData = { gdprApplies: consent.gdprApplies, consentData: consent.tcString };
            this._publishConsentData();
        }
    },

    _getConsentData: function (callback) {
        var $this = this;

        var handleFailure = function () {
            $this._setReason(2);  // getConsentData failed
            callback.apply($this, [null]);
        };

        var callbackCalled = false;
        var handleSuccess = function (tcData) {
            if (!callbackCalled) {
                callbackCalled = true;
                $this._setReason(1);
                callback.apply($this, [tcData]);
            }
        };

        try {
            (function () {
                var callee = arguments.callee;
                if ($this.exists && $this.initialized && !$this.cmpCheckTimedout) {

                    // If "ping" indicated __tcfapi is ready
                    // then we request in parallel 
                    $this.__tcfapi('addEventListener', 2, function (tcData, success) {
                        if (success && tcData.tcString && (tcData.eventStatus == "tcloaded" || tcData.eventStatus == "useractioncomplete")) {
                            // getConsentData succeeded
                            handleSuccess(tcData);

                            if (tcData.listenerId) {
                                $this.__tcfapi('removeEventListener', 2, function () { }, tcData.listenerId);
                            }
                        } else {
                            // TODO: product decision
                            // Its weird if we got tcloaded without tcString, if so abort and set default
                            // handleFailure();
                        }
                    });

                    (function () {
                        var callee = arguments.callee;
                        try {
                            $this.__tcfapi('getTCData', 2, function (tcData, success) {
                                if (success && tcData.tcString) {
                                    // getConsentData succeeded
                                    handleSuccess(tcData);
                                } else {
                                    if (!$this.cmpCheckTimedout) {
                                        setTimeout(function () {
                                            callee.apply($this, []);
                                        }, 5)
                                    }
                                }
                            });
                        } catch (e) {
                            if (!$this.cmpCheckTimedout) {
                                setTimeout(function () {
                                    callee.apply($this, []);
                                }, 5)
                            }
                        }
                    })();

                }
            })();
        } catch (e) {
            handleFailure();
        }
    },

    getConsentData: function (cb, context) {
        if (typeof this.consentData != "undefined") {
            cb.apply(context, [this.consentData]);
        } else {
            this.subscriptions.push({ callback: cb, context: context || this });
        }
    },

    _setDefaultValue: function () {
        // We failed getting consent data
        // Setting consentData to default
        // TODO: product decision
        this.initialized = true;
        this.consentData = this.defaultConsentData;
    },

    _publishConsentData: function () {
        if (typeof this.consentData == "undefined") {
            // Its not right to call this function before setting consentData
            return;
        }

        for (var i = 0; i < this.subscriptions.length; i++) {
            var sub = this.subscriptions[i];
            try {
                sub.callback.apply(sub.context, [this.consentData]);
            } catch (e) {
                // Incase the callback function throws an unhandled exception
            }
        }

        // Clear subscriptions
        this.subscriptions = [];
    },

    _setReason: function (code) {
        if (typeof this._reason == "undefined") {
            this._reason = code;
        }
    },

    defaultConsentData: null // used to be : { 'gdprApplies': 0, 'hasGlobalScope': false, 'consentData': "" }
};