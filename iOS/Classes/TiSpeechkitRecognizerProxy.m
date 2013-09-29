/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiSpeechkitRecognizerProxy.h"
#import <AVFoundation/AVAudioSession.h>
#import <SpeechKit/SKRecognition.h>
#import "TiUtils.h"
#import "TiSpeechkitModule.h"

@implementation TiSpeechkitRecognizerProxy
-(void)_configure
{
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
    _isRecording = NO;
    _debug = NO;
	[super _configure];
}
-(void)_destroy
{
    self.outputCallback = nil;
	[super _destroy];
}

-(void) doCallListener:(NSString*)name
{
    if ([self _hasListeners:name]) {
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               NUMBOOL(YES),@"success",
                               nil
                               ];
        
        [self fireEvent:name withObject:event];
    }
}
-(NSNumber*)isPermitted:(id)unused
{
    return NUMBOOL(_isAllowed);
}
-(NSNumber*)isRecording:(id)unused
{
    return NUMBOOL(_isRecording);
}

-(void)startRecording:(id)args
{
    ENSURE_UI_THREAD(startRecording, args);
    ENSURE_SINGLE_ARG(args,NSDictionary);
    
    KrollCallback *callback = [args  objectForKey:@"onComplete"];
	ENSURE_TYPE(callback,KrollCallback);
    
    if(_isAllowed == NO){
        NSLog(@"[ERROR] No Microphone Access");
        NSDictionary *eventErrA = [NSDictionary dictionaryWithObjectsAndKeys:
                                   NUMBOOL(NO),@"success",
                                   @"No Microphone access",@"message",
                                   nil];
        
        [self _fireEventToListener:@"onComplete"
                        withObject:eventErrA listener:callback thisObject:nil];
        return;
    }
    
    if(_isRecording){
        NSLog(@"[ERROR] already recording");
        NSDictionary *eventErr2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   NUMBOOL(NO),@"success",
                                   @"already recording",@"message",
                                   nil];
        
        [self _fireEventToListener:@"onComplete"
                        withObject:eventErr2 listener:callback thisObject:nil];
        return;
        
    }
    
    _debug = [TiUtils boolValue:@"debug" properties:args def:NO];
    self.outputCallback = callback;
    
    if (voiceSearch){
        voiceSearch=nil;
    }
    if(_debug){
        NSLog(@"speechKitID [%@]",[self valueForUndefinedKey:@"speechKitID"]);
        NSLog(@"speechKitHost [%@]",[self valueForUndefinedKey:@"speechKitHost"]);
        NSLog(@"speechKitPort [%@]",[self valueForUndefinedKey:@"speechKitPort"]);
        NSLog(@"speechKitUseSSL [%@]",[self valueForUndefinedKey:@"speechKitUseSSL"]);
    }
    [SpeechKit setupWithID:[TiUtils stringValue:[self valueForUndefinedKey:@"speechKitID"]]
                      host:[TiUtils stringValue:[self valueForUndefinedKey:@"speechKitHost"]]
                      port:[TiUtils intValue:[self valueForUndefinedKey:@"speechKitPort"]]
                    useSSL:[TiUtils boolValue:[self valueForUndefinedKey:@"speechKitUseSSL"]]
                  delegate:self];
    
    _isRecording = YES;
    
    NSLocale *curLocale = [NSLocale currentLocale];
    
    if(_debug){
        NSLog(@"curLocale [%@]", [curLocale localeIdentifier]);
    }
    
    NSString *language = [TiUtils stringValue:@"language" properties:args def: [curLocale localeIdentifier]];
    
    if(_debug){
        NSLog(@"language [%@]",language);
    }
    
    int endOfSpeechDetection = [TiUtils intValue:@"endDetection"
                                      properties:args def:SKShortEndOfSpeechDetection];
    if(_debug){
        NSLog(@"endOfSpeechDetection [%i]",endOfSpeechDetection);
    }
    int recognizerType = [TiUtils intValue:@"recognizerType"
                                properties:args def:kBXBSearchRecognizerType];
    
    NSString* recoType = SKSearchRecognizerType;
    
    if(recognizerType == kBXBDictationRecognizerType){
        recoType = SKDictationRecognizerType;
    }
    if(_debug){
        NSLog(@"recoType [%@]",recoType);
    }
    
    voiceSearch = [[SKRecognizer alloc] initWithType:recoType
                                           detection:endOfSpeechDetection
                                            language:language
                                            delegate:self];
}

-(void)stopRecording:(id)unused
{
    ENSURE_UI_THREAD(stopRecording, unused);
    
    if(voiceSearch!=nil){
        [voiceSearch stopRecording];
    }
    voiceSearch=nil;
    _isRecording = NO;
}

-(void)cancelRecording:(id)unused
{
    ENSURE_UI_THREAD(cancelRecording, unused);
    
    if(voiceSearch!=nil){
        [voiceSearch cancel];
    }
    voiceSearch=nil;
    _isRecording = NO;
}
- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer
{
    if(_debug){
        NSLog(@"[DEBUG] recording started. Event Fired");
    }
    
    [self doCallListener:@"startedRecording"];
    _isRecording = YES;
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer
{
    if(_debug){
        NSLog(@"[DEBUG] recording finished. Event Fired");
    }
    _isRecording = YES;
    [self doCallListener:@"finishedRecording"];
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results
{
    if(_debug){
        NSLog(@"[DEBUG] Found Results");
        NSLog(@"Session id [%@].", [SpeechKit sessionID]);
        NSLog(@"First Results [%@].", [results firstResult]);
    }
    
    if(self.outputCallback!=nil){
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               NUMBOOL(YES),@"success",
                               @"completed",@"action",
                               [results firstResult],@"text",
                               nil];
        
        [self _fireEventToListener:@"onComplete"
                        withObject:event listener:self.outputCallback thisObject:nil];
    }
    
    voiceSearch = nil;
    _isRecording = NO;
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion
{
    if(_debug){
        NSLog(@"[DEBUG] Got error.");
        NSLog(@"[DEBUG] Session id [%@].", [SpeechKit sessionID]);
        NSLog(@"[DEBUG] Error %@", [error localizedDescription]);
    }
    if(self.outputCallback!=nil){
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               NUMBOOL(NO),@"success",
                               [error localizedDescription],@"message",
                               @"errored",@"action",
                               nil];
        
        [self _fireEventToListener:@"onComplete"
                        withObject:event listener:self.outputCallback thisObject:nil];
    }
	voiceSearch = nil;
    _isRecording = NO;
}

@end
