/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <SpeechKit/SpeechKit.h>

@interface TiSpeechkitRecognizerProxy :TiProxy<SpeechKitDelegate, SKRecognizerDelegate> {
@private
    BOOL _isAllowed;
    BOOL _isRecording;
    BOOL _debug;
    SKRecognizer* voiceSearch;
}
@property (nonatomic, strong) KrollCallback *outputCallback;

@end
