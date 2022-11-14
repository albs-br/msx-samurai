EBG = window.EBG || {};
if (EBG.declareNamespace) {
    EBG.declareNamespace("URLUtil");
}

// URLUtil
EBG.URLUtil = function (reportCallback, options) {
    this._maximumUrlLength = options ? options.maximumUrlLength : null;
    this._maximumAorgUrls = options ? options.maximumAorgUrls : null;
    this.TOP_WINDOW = EBG.URLUtil.getTopAccessibleWindow(false);

    if (reportCallback) {
        reportCallback({
            referrer: this.getReferrerUrl(),
            top: this.getTopUrl(),
            aorg: this.getAncestorOriginsUrls(this._maximumAorgUrls)
        });
    }
};

EBG.URLUtil.prototype = {
    capUrl: function (url) {
        if (!url || !this._maximumUrlLength) {
            return url;
        }
        return url.substring(0, this._maximumUrlLength);
    },

    getReferrerUrl: function () {
        return this.capUrl(this.TOP_WINDOW.document.referrer);
    },

    getTopUrl: function () {
        return this.capUrl(this.TOP_WINDOW.location.href);
    },

    getAncestorOriginsUrls: function (maximumUrls) {
        // Returns an array of domains (not urls! even though the function name says so) that are stored in window.location.ancestorOrigins
        // maximumUrls - what is the maximum number of domains to return. if false or 0, will be uncapped.
        var aorg = [];

        if (window && window.location && window.location.ancestorOrigins && typeof window.URL == "function") {
            var a = window.location.ancestorOrigins;
            if (a.length > 0) {
                var len = maximumUrls ? Math.min(maximumUrls, a.length) : a.length;
                for (var i = 0; i < len; i++) {
                    if (location.ancestorOrigins[i]) {
                        aorg.push(this.capUrl(location.ancestorOrigins[i]));
                    }
                }
            }
        }
        return aorg;
    }
};

// needs to be removed after we'll have infra/adaptor for the modules.
EBG.URLUtil.getTopAccessibleWindow = function (contiguous) {
    contiguous = typeof contiguous == 'boolean' ? contiguous : true;
    var win = window;
    var doIfAccessible = function () {
        win = this;
    };
    EBG.Adaptors.StdWebAdaptor._walkUpIframes(doIfAccessible, null, window, !contiguous);
    return win;
};

// needs to be removed after we'll have infra/adaptor for the modules.
EBG.URLUtil._walkUpIframes = function (doIfAccessible, doIfNotAccessible, win, iterateUnfriendly) {
    var startWin = win || window,
        startOrigin = startWin.location.origin || (startWin.location.protocol + "/" + "/" + startWin.location.host),  //IE doesn't have "origin" so rebuild it.
        currWin = startWin,
        isFriendly = false,
        parentOrigin = "";
    iterateUnfriendly = !!iterateUnfriendly;
    try {
        //try ancestorOrigins, to keep Safari happy.
        if (startWin.location.ancestorOrigins) {
            //call 'friendly' callback for self / ground floor
            doIfAccessible && doIfAccessible.call(currWin);
            //ok lets iterate the ancestors.
            for (var i = 0; i < startWin.location.ancestorOrigins.length; i++) {

                // Now that we know ancestorOrigins is not empty, compensate for "null" origin. The actual security origin is inherited from the parent.
                // Remember it's *ancestor* origins, so the 0th item in the list is the parent of the target/bottom/script window.
                if (i == 0 && startOrigin == "null") {
                    startOrigin = startWin.location.ancestorOrigins[0];
                }

                // Walk up.
                currWin = currWin.parent;
                isFriendly = false;
                if (startWin.location.ancestorOrigins[i] == startOrigin) {
                    try {
                        // Changes to document.domain are not reflected in ancestorOrigins for some reason, so if domain of startWin or currWin was changed and the other wasn't, they will be unfriendly
                        // even tho ancestorOrigins says they are friendly. I don't see why anybody would want to force windows to be unfriendly like this, but we might as well check for it just in case.
                        parentOrigin = currWin.location.origin;
                        isFriendly = true;
                    }
                    catch (e) {
                        isFriendly = false;
                    }
                }

                if (isFriendly) {
                    //Same origin - currWin is accessible from startWin
                    doIfAccessible && doIfAccessible.call(currWin);
                }
                else {
                    //currWin is not accessible from startWin
                    try {
                        //NB 'this' is going to be an unfriendly Window in the callback. Danger danger!
                        doIfNotAccessible && doIfNotAccessible.call(currWin);
                    } catch (e) {
                    }

                    if (!iterateUnfriendly) {
                        // bail out at first unfriendly
                        break;
                    }
                }
            }
        }
        else {
            //call 'friendly' callback for self / ground floor
            doIfAccessible && doIfAccessible.call(currWin);
            while (currWin !== currWin.parent) {
                //Move up until there's no where to go
                currWin = currWin.parent;

                //Use try/catch to detect friendly/unfriendly
                parentOrigin = null;
                try {
                    //If we're in an unfriendly iframe - the following lines will produce an exception which we'd catch in the next catch block
                    parentOrigin = currWin.location.origin || (currWin.location.protocol + "/" + "/" + currWin.location.host);//IE doesn't have "origin" so rebuild it.

                    // Now that we know currWin is an ancestor window of startWin, compensate for "null" origin. The actual security origin is inherited from the parent.
                    if (startOrigin == "null" || startOrigin == ("about:/" + "/")) {
                        startOrigin = parentOrigin;
                    }
                }
                catch (e) {
                }
                if (parentOrigin === startOrigin) {
                    //parent Same hostname as current - we're in a friendly iframe
                    doIfAccessible && doIfAccessible.call(currWin);
                }
                else {
                    //Reached the upper level of friendly iframes
                    //currWin is not accessible from startWin
                    try {
                        doIfNotAccessible && doIfNotAccessible.call(currWin);
                    } catch (e) {
                    }

                    if (!iterateUnfriendly) {
                        // bail out at first unfriendly
                        break;
                    }
                }
            }
        }
    }
    catch (e) {
    }
};

if (EBG.declareClass) {
    EBG.declareClass(EBG.URLUtil, null);
}