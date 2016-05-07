/******************************************************************************\
* Copyright (C) 2012-2013 Leap Motion, Inc. All rights reserved.               *
* Leap Motion proprietary and confidential. Not for distribution.              *
* Use subject to the terms of the Leap Motion SDK Agreement available at       *
* https://developer.leapmotion.com/sdk_agreement, or another agreement         *
* between Leap Motion and you, your company or other organization.             *
\******************************************************************************/

#import "Sample.h"

@interface Sample () <SRWebSocketDelegate>

@end

@implementation Sample
{
    LeapController *controller;
    NSArray *fingerNames;
    NSArray *boneNames;
	
	bool isHandsClose;
	
	SRWebSocket *socket;
	bool isSockedOpened;
}

- (id)init
{
	
	isHandsClose = false;
	isSockedOpened = false;
	
    self = [super init];
	
    static const NSString *const fingerNamesInit[] = {
        @"Thumb", @"Index finger", @"Middle finger",
        @"Ring finger", @"Pinky"
    };
    static const NSString *const boneNamesInit[] = {
        @"Metacarpal", @"Proximal phalanx",
        @"Intermediate phalanx", @"Distal phalanx"
    };
    fingerNames = [[NSArray alloc] initWithObjects:fingerNamesInit count:5];
    boneNames = [[NSArray alloc] initWithObjects:boneNamesInit count:4];
    return self;
}

- (void)run
{
    controller = [[LeapController alloc] init];
	[controller addListener:self];
	NSLog(@"running");
	
	NSURL *url = [[NSURL alloc] initWithString:@"ws://taptappun.cloudapp.net:3001"];
	socket = [[SRWebSocket alloc] initWithURL:url];
	[socket setDelegate:self];
	[socket open];
	
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
	isSockedOpened = true;
	[webSocket send:@"Hello, world! from Mac"];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
	
}


#pragma mark - SampleListener Callbacks

- (void)onInit:(NSNotification *)notification
{
    NSLog(@"Initialized");
}

- (void)onConnect:(NSNotification *)notification
{
    NSLog(@"Connected");
//    LeapController *aController = (LeapController *)[notification object];
//    [aController enableGesture:LEAP_GESTURE_TYPE_CIRCLE enable:YES];
//    [aController enableGesture:LEAP_GESTURE_TYPE_KEY_TAP enable:YES];
//    [aController enableGesture:LEAP_GESTURE_TYPE_SCREEN_TAP enable:YES];
//    [aController enableGesture:LEAP_GESTURE_TYPE_SWIPE enable:YES];
}

- (void)onDisconnect:(NSNotification *)notification
{
    //Note: not dispatched when running in a debugger.
    NSLog(@"Disconnected");
}

- (void)onServiceConnect:(NSNotification *)notification
{
    NSLog(@"Service Connected");
}

- (void)onServiceDisconnect:(NSNotification *)notification
{
    NSLog(@"Service Disconnected");
}

- (void)onDeviceChange:(NSNotification *)notification
{
    NSLog(@"Device Changed");
}

- (void)onExit:(NSNotification *)notification
{
    NSLog(@"Exited");
}

- (void)onFrame:(NSNotification *)notification
{
    LeapController *aController = (LeapController *)[notification object];

    // Get the most recent frame and report some basic information
    LeapFrame *frame = [aController frame:0];
	
	if ([self closeHandsGesture:frame]) {
		if (isSockedOpened) {
			[socket send:@"{\"action\":\"V8\", \"data\":\"null\"}"];
		}
		NSLog(@"V8!");
	}
	
}

- (void)onFocusGained:(NSNotification *)notification
{
    NSLog(@"Focus Gained");
}

- (void)onFocusLost:(NSNotification *)notification
{
    NSLog(@"Focus Lost");
}

+ (NSString *)stringForState:(LeapGestureState)state
{
    switch (state) {
        case LEAP_GESTURE_STATE_INVALID:
            return @"STATE_INVALID";
        case LEAP_GESTURE_STATE_START:
            return @"STATE_START";
        case LEAP_GESTURE_STATE_UPDATE:
            return @"STATE_UPDATED";
        case LEAP_GESTURE_STATE_STOP:
            return @"STATE_STOP";
        default:
            return @"STATE_INVALID";
    }
}

- (BOOL) closeHandsGesture: (LeapFrame *)frame {
	
	if ([[frame hands] count] > 1) {
		LeapHand *hand1 = [[frame hands] objectAtIndex:0];
		LeapHand *hand2 = [[frame hands] objectAtIndex:1];
		
		if (fabsf(hand1.palmPosition.x - hand2.palmPosition.x) < 50) {
			if (!isHandsClose) {
				isHandsClose = true;
				return true;
				
			} else {
				return false;
			}
			
		}
		
	}
	
	isHandsClose = false;
	return false;
	
}

@end
