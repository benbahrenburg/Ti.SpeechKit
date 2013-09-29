//
//  SpeechKit.h
//  SpeechKit
//
// Copyright 2010, Nuance Communications Inc. All rights reserved.
//
// Nuance Communications, Inc. provides this document without representation 
// or warranty of any kind. The information in this document is subject to 
// change without notice and does not represent a commitment by Nuance 
// Communications, Inc. The software and/or databases described in this 
// document are furnished under a license agreement and may be used or 
// copied only in accordance with the terms of such license agreement.  
// Without limiting the rights under copyright reserved herein, and except 
// as permitted by such license agreement, no part of this document may be 
// reproduced or transmitted in any form or by any means, including, without 
// limitation, electronic, mechanical, photocopying, recording, or otherwise, 
// or transferred to information storage and retrieval systems, without the 
// prior written permission of Nuance Communications, Inc.
// 
// Nuance, the Nuance logo, Nuance Recognizer, and Nuance Vocalizer are 
// trademarks or registered trademarks of Nuance Communications, Inc. or its 
// affiliates in the United States and/or other countries. All other 
// trademarks referenced herein are the property of their respective owners.
//

#import <Foundation/Foundation.h>

#import <SpeechKit/SKEarcon.h>
#import <SpeechKit/SKRecognition.h>
#import <SpeechKit/SKRecognizer.h>
#import <SpeechKit/SKVocalizer.h>
#import <SpeechKit/SpeechKitErrors.h>

/*!
 @abstract This global variable defines the SpeechKit application key used for 
 server authentication.
 */
extern const unsigned char SpeechKitApplicationKey[];

@protocol SpeechKitDelegate;

/*!
 @class SpeechKit
 @abstract This is the SpeechKit core class providing setup and utility methods.
 
 @discussion SpeechKit does not provide any instance methods and is not 
 designed to be initialized.  Instead, this class provides methods to assist in 
 initializing the SpeechKit core networking, recognition and audio sytem 
 components.
 
 @namespace SpeechKit
 */
@interface SpeechKit : NSObject

/*!
 @abstract This method configures the SpeechKit subsystems.
 
 @param ID Application identification
 @param host The Nuance speech server hostname or IP address
 @param port The Nuance speech server port
 @param useSSL Whether or not SpeechKit should use SSL to
 communicate with the Nuance speech server
 @param delegate The receiver for the setup message responses.  If the user
 wishes to destroy and re-connect to the SpeechKit servers, the delegate must
 implement the SpeechKitDelegate protocol and observe the destroyed method
 as described below.
 
 @discussion This method starts the necessary underlying components of the 
 SpeechKit framework.  Ensure that the SpeechKitApplicationKey variable 
 contains your application key prior to calling this method.  On calling this 
 method, a connection is established with the speech server and authorization 
 details are exchanged.  This provides the necessary setup to perform 
 recognitions and vocalizations.  In addition, having the established connection 
 results in improved response times for speech requests made soon after as the 
 recorded audio can be sent without waiting for a connection.  Once the system
 has been initialized with this function, future calls to setupWithID will be
 ignored.  If you wish to connect to a different server or call this function
 again for any reason, you must call [SpeechKit destroy] and wait for the 
 destroyed delegate method to be called.
 */
+ (void)setupWithID:(NSString*)ID 
               host:(NSString*)host 
               port:(long)port
             useSSL:(BOOL)useSSL
           delegate:(id <SpeechKitDelegate>)delegate;

/*!
 @abstract This method tears down the SpeechKit subsystems.
 
 @discussion This method frees the resources of the SpeechKit framework and 
 tears down any existing connections to the server.  It is usually not necessary
 to call this function, however, if you need to connect to a different server or
 port, it is necessary to call this function before calling setupWithID again.
 You must wait for the destroyed delegate method of the SpeechKitDelegate
 protocol to be called before calling setupWithID again.  Note also you will need
 to call setEarcon again to set up all your earcons after using this method.
 This function should NOT be called during an active recording or vocalization -
 you must first cancel the active transaction.  Calling it while the system is
 not idle may cause unpredictable results.
 */
+ (void)destroy;

/*!
 @abstract This method provides the most recent session ID.
 
 @result Session ID as a string or nil if no connection has been established yet.
 
 @discussion If there is an active connection to the server, this method provides 
 the session ID of that connection.  If no connection to the server currently 
 exists, this method provides the session ID of the previous connection.  If no
 connection to the server has yet been made, this method returns nil.
 
 */
+ (NSString*)sessionID;


/*!
 @abstract This method configures an earcon (audio cue) to be played.
 
 @param earcon Audio earcon to be set
 @param type Earcon type
 
 @discussion Earcons are defined for the following events: start, record, stop, and cancel.
 
 */
+ (void)setEarcon:(SKEarcon *)earcon forType:(SKEarconType)type;

@end


/*!
 @discussion The SpeechKitDelegate protocol defines the messages sent to a 
 delegate object registered as part of the call to setupWithID.
 */
@protocol SpeechKitDelegate <NSObject>

@optional

/*!
 @abstract Sent when the destruction process is complete.
 
 @discussion This allows the delegate to monitor the destruction process.
 Note that subsequent calls to destroy and setupWithID will be ignored until
 this delegate method is called, so if you need to call setupWithID 
 again to connect to a different server, you must wait for this.
 */
- (void)destroyed;

@end

