/**
 * Created by Valentin Heun on 9/14/15.
 *
 * Copyright (c) 2015 Valentin Heun
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#pragma once

///#import <Foundation/Foundation.h>

@class ofxUIWebViewDelegateObjC; // forward declaration

// An abstract class
class ofxUIWebViewDelegateCpp {

public:
    /******************* !!!! *************************************************
    Interface designers MUST override handleCustomRequest() when subclassing
    this class. Designers then define their own protocol to communicate
    from the HTML/JS layer to the C++ layer.
    **************************************************************************/
    virtual void handleCustomRequest(NSString *request) = 0;

private:
    ofxUIWebViewDelegateObjC *delegate;
};

@interface ofxUIWebViewDelegateObjC : NSObject <UIWebViewDelegate>

@property(nonatomic, assign) ofxUIWebViewDelegateCpp *delegate;

@end
