/******************************************************************************\
* Copyright (C) 2012-2013 Leap Motion, Inc. All rights reserved.               *
* Leap Motion proprietary and confidential. Not for distribution.              *
* Use subject to the terms of the Leap Motion SDK Agreement available at       *
* https://developer.leapmotion.com/sdk_agreement, or another agreement         *
* between Leap Motion and you, your company or other organization.             *
\******************************************************************************/

#import "Anko.h"

@implementation Anko
{
    LeapController *controller;
    NSArray *fingerNames;
    NSArray *boneNames;
	
	bool isHandsClose;
	
	int interval;
	
	SRWebSocket *socket;
	bool isSockedOpened;
	bool isRightHandSwipingToRight;
}

- (id)init
{
	
	isHandsClose = false;
	
	interval = 0;
	
	isSockedOpened = false;
	isRightHandSwipingToRight = false;
	
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

#pragma mark - SRWebSocketDelegate Calbacks

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
	LeapController *notificationController = [notification object];
	[notificationController enableGesture:LEAP_GESTURE_TYPE_SWIPE enable:YES];
}

- (void)onFrame:(NSNotification *)notification
{
    LeapController *aController = (LeapController *)[notification object];

    // Get the most recent frame and report some basic information
    LeapFrame *frame = [aController frame:0];
	
	interval++;
	if (interval >= 30) {
		interval = 0;
	}
	
	if (interval == 0) {
		[self setHandsPositions:frame];
	}
	
	if ([self closeHandsGesture:frame]) {
		if (isSockedOpened) {
			[socket send:@"{\"action\":\"V8\", \"data\":\"null\"}"];
		}
		NSLog(@"V8!");
		
	}
	
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

#pragma mark - Gestures

- (BOOL)closeHandsGesture: (LeapFrame *)frame {
	
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



- (void)setHandsPositions: (LeapFrame *)frame {
	
	NSArray *array = [frame hands];
	for (LeapHand *hand in array) {
		float x = hand.palmPosition.x;
		float y = hand.palmPosition.y;
		x /= -100;
		x += 0.5;
		if (x < -1) {
			x = -1;
		} else if (x > 1) {
			x = 1;
		}
		
		y -= 300;
		y /= -250;
		if (y < -1) {
			y = -1;
		} else if (y > 1) {
			y = 1;
		}
		
		NSString *shoulder = @"shoulder";
		if (hand.isLeft) {
			shoulder = [@"move_l" stringByAppendingString:shoulder];
		} else if (hand.isRight) {
			shoulder = [@"move_r" stringByAppendingString:shoulder];
		}
		
		NSString *message = [NSString stringWithFormat:@"{\"action\":\"%@\", \"data\":\"[%f, %f]\"}", shoulder, x, y];
		[socket send:message];
	}
	
}

@end
