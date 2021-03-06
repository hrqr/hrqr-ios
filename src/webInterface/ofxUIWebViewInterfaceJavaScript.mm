/**
 * Created by Valentin Heun on 9/14/15.
 *
 * Copyright (c) 2015 Valentin Heun
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#import "ofxUIWebViewInterfaceJavaScript.h"

ofxUIWebViewInterfaceJavaScript::ofxUIWebViewInterfaceJavaScript() {
    isShowingView = false;
}

void ofxUIWebViewInterfaceJavaScript::initialize() {
    // use default delegate
    initializeWithCustomDelegate(0);// use default
}

void ofxUIWebViewInterfaceJavaScript::initializeWithCustomDelegate(ofxUIWebViewDelegateCpp *delegate) {
    // initialize the UIWebView instance
    
    
     
    CGRect frame;
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        frame = CGRectMake(0, 65, ofGetWindowWidth(),ofGetWindowHeight()-65);
    } else {
        frame = CGRectMake(0, 65, ofGetWindowHeight(), ofGetWindowWidth()-65);
    }
    uiWebViewInstance = [[UIWebView alloc] initWithFrame:frame];

    // make it transparent
    [uiWebViewInstance setOpaque:NO];
    [uiWebViewInstance setBackgroundColor:[UIColor clearColor]];
    [uiWebViewInstance.window makeKeyAndVisible];

    // make it NOT scrollable
    [[uiWebViewInstance scrollView] setScrollEnabled:YES];
    [[uiWebViewInstance scrollView] setBounces:YES];


  //  [uiWebViewInstance scalesPageToFit];

    uiWebViewInstance.scalesPageToFit = YES;
    
    // set delegate to handle events
    ofxUIWebViewDelegateObjC *delegateObjC = [[ofxUIWebViewDelegateObjC alloc] init];
    [delegateObjC setDelegate:delegate]; // WARNING: set to 0 when using default delegate
    [uiWebViewInstance setDelegate:delegateObjC];
}

void ofxUIWebViewInterfaceJavaScript::loadURL(string url) {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURL *nsURL = [NSURL URLWithString:[NSString stringWithCString:url.c_str() encoding:[NSString defaultCStringEncoding]]];

    [uiWebViewInstance loadRequest:[NSURLRequest requestWithURL:nsURL]];

}

void ofxUIWebViewInterfaceJavaScript::loadLocalFile(string folder, string filename) {
    NSString *_filename = [NSString stringWithCString:filename.c_str() encoding:[NSString defaultCStringEncoding]];
    NSString *_folder = [NSString stringWithCString:folder.c_str() encoding:[NSString defaultCStringEncoding]];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:_filename ofType:@"html" inDirectory:_folder]];
    [uiWebViewInstance loadRequest:[NSURLRequest requestWithURL:url]];

}

ofxUIWebViewInterfaceJavaScript::~ofxUIWebViewInterfaceJavaScript() {

}

void ofxUIWebViewInterfaceJavaScript::activateView() {
    if (!isShowingView) {
        [ofxiPhoneGetGLParentView() addSubview:uiWebViewInstance];
        isShowingView = true;
    }
}

void ofxUIWebViewInterfaceJavaScript::deactivateView() {
    if (isShowingView) {
        [uiWebViewInstance removeFromSuperview];
        isShowingView = false;
    }
}

void ofxUIWebViewInterfaceJavaScript::toggleView() {
    if (isShowingView) {
        deactivateView();
    } else {
        activateView();
    }
}

// relevant for sending the script
NSString *ofxUIWebViewInterfaceJavaScript::runJavaScriptFromString(NSString *script) {
    if (isShowingView) {
        return [uiWebViewInstance stringByEvaluatingJavaScriptFromString:script];
    } else {
        return @"";
    }
}

