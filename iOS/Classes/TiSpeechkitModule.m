/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiSpeechkitModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import <AVFoundation/AVAudioSession.h>
#import <SpeechKit/SKRecognition.h>
#import <SpeechKit/SpeechKit.h>
#import "Credentials.h"

int const kBXBSearchRecognizerType = 0;
int const kBXBDictationRecognizerType = 1;

@implementation TiSpeechkitModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"93c7f7d7-5da7-4038-b946-c3541118f1cc";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ti.speechkit";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

-(NSNumber*)requestPermission:(id)unused
{
    BOOL _isAllowed = YES;
    __block BOOL isAllowed = YES;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_0
    if([[AVAudioSession sharedInstance]
        respondsToSelector:@selector(requestRecordPermission)])
    {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL allowed){
            NSLog(@"Allow microphone use? %d", allowed);
            isAllowed = allowed;
        }];
    }
#endif
    _isAllowed= isAllowed;
    
    return NUMBOOL(_isAllowed);
}

MAKE_SYSTEM_PROP(NO_END_OF_SPEECH,SKNoEndOfSpeechDetection);
MAKE_SYSTEM_PROP(SHORT_END_OF_SPEECH,SKShortEndOfSpeechDetection);
MAKE_SYSTEM_PROP(LONG_END_OF_SPEECH,SKLongEndOfSpeechDetection);

MAKE_SYSTEM_PROP(SEARCH_RECOGNIZER_TYPE,kBXBSearchRecognizerType);
MAKE_SYSTEM_PROP(DICTATION_RECOGNIZER_TYPE,kBXBDictationRecognizerType);

@end
