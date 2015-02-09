
// Checks the browser and adds classes to the body to reflect it.

$(document).ready(function(){
    var userAgent = navigator.userAgent.toLowerCase();
    $.browser.chrome = /chrome/.test(navigator.userAgent.toLowerCase());

    // Is this a version of IE?
    if($.browser.msie){
        $('body').addClass('ie');

        // Add the version number
        $('body').addClass('ie' + $.browser.version.substring(0,1));
    }

    // Is this a version of Chrome?
    if($.browser.chrome){

        $('body').addClass('chrome');

        //Add the version number
        userAgent = userAgent.substring(userAgent.indexOf('chrome/') +7);
        userAgent = userAgent.substring(0,1);
        $('body').addClass('chrome' + userAgent);

        // If it is chrome then jQuery thinks it's safari so we have to tell it it isn't
        $.browser.safari = false;
    }

    // Is this a version of Safari?
    if($.browser.safari){
        $('body').addClass('safari');

        // Add the version number
        userAgent = userAgent.substring(userAgent.indexOf('version/') +8);
        userAgent = userAgent.substring(0,1);
        $('body').addClass('safari' + userAgent);
    }

    // Is this a version of Mozilla?
    if($.browser.mozilla){

        //Is it Firefox?
        if(navigator.userAgent.toLowerCase().indexOf('firefox') != -1){
            $('body').addClass('firefox');

            // Add the version number
            userAgent = userAgent.substring(userAgent.indexOf('firefox/') +8);
            userAgent = userAgent.substring(0,1);
            $('body').addClass('firefox' + userAgent);
        }
        // If not then it must be another Mozilla
        else{
            $('body').addClass('mozilla');
        }
    }

    // Is this a version of Opera?
    if($.browser.opera){
        $('body').addClass('opera');
    }
});
