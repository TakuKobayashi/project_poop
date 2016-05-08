/******************************************************************************\
* Copyright (C) 2012-2013 Leap Motion, Inc. All rights reserved.               *
* Leap Motion proprietary and confidential. Not for distribution.              *
* Use subject to the terms of the Leap Motion SDK Agreement available at       *
* https://developer.leapmotion.com/sdk_agreement, or another agreement         *
* between Leap Motion and you, your company or other organization.             *
\******************************************************************************/

#import "Anko.h"

struct ShoulderPosition {
	float x;
	float y;
};

@implementation Anko
{
    LeapController *controller;
    NSArray *fingerNames;
    NSArray *boneNames;
	
	int interval;
	
	bool isHandsClose;
	bool isGuPGood;
	
	struct ShoulderPosition lLastPosition;
	struct ShoulderPosition rLastPosition;
	
	struct ShoulderPosition lCurrentPosition;
	struct ShoulderPosition rCurrentPosition;
	
	SRWebSocket *socket;
	bool isSockedOpened;
	bool isRightHandSwipingToRight;
}

- (id)init
{
	
	interval = 0;
	
	isHandsClose = false;
	isGuPGood = false;
	
	lCurrentPosition.x = 0;
	lCurrentPosition.y = 0;
	rCurrentPosition.x = 0;
	rCurrentPosition.y = 0;
	
	lLastPosition.x = 0;
	lLastPosition.y = 0;
	rLastPosition.x = 0;
	rLastPosition.y = 0;
	
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
	
	[self createSocket];
	
}

- (void)createSocket {
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

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
	
	isSockedOpened = false;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[self createSocket];
		NSLog(@"Reconnected");
	});
	
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
	if (interval >= 15) {
		interval = 0;
	}
	
	if (interval == 0) {
		[self setHandsPositions:frame];
		[self setGuPGood:frame];
	}
	
	if ([self closeHandsGesture:frame]) {
		if (isSockedOpened) {
			[socket send:@"{\"action\":\"V8\", \"data\":null}"];
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



- (void)resetHandsPositions {
	
	struct ShoulderPosition initialPosition;
	initialPosition.x = 0;
	initialPosition.y = 0;
	
	if (fabs(initialPosition.x - lLastPosition.x) > 0.2 || fabs(initialPosition.y - lLastPosition.y) > 0.2 ||
		fabs(initialPosition.x - rLastPosition.x) > 0.2 || fabs(initialPosition.y - rLastPosition.y) > 0.2) {
		lCurrentPosition = initialPosition;
		rCurrentPosition = initialPosition;
		
		lLastPosition = initialPosition;
		rLastPosition = initialPosition;
		
		if (isSockedOpened) {
			[socket send:@"{\"action\":\"reset\", \"data\": null}"];
		}
	}
	
}

- (void)setHandsPositions: (LeapFrame *)frame {
	
	NSArray *array = [frame hands];
	
	if ([array count] == 0) {
		[self resetHandsPositions];
		return;
	}
	
	for (LeapHand *hand in array) {
		if (hand.isLeft) {
			float x = hand.palmPosition.x;
			float y = hand.palmPosition.y;
			x += 110;
			x /= -50;
			if (x < -1) {
				x = -1;
			} else if (x > 1) {
				x = 1;
			}
			
			y -= 250;
			y /= -150;
			if (y < -1) {
				y = -1;
			} else if (y > 1) {
				y = 1;
			}
			
			if (fabs(x - lCurrentPosition.x) > 0.2 || fabs(y - lCurrentPosition.y) > 0.2) {
				lCurrentPosition.x = x;
				lCurrentPosition.y = y;
				
			} else {
				if (fabs(x - lLastPosition.x) > 0.2 || fabs(y - lLastPosition.y) > 0.2) {
					lCurrentPosition.x = x;
					lCurrentPosition.y = y;
					
					lLastPosition.x = x;
					lLastPosition.y = y;
					
					if (isSockedOpened) {
						NSString *shoulder = @"move_lshoulder";
						NSString *message = [NSString stringWithFormat:@"{\"action\":\"%@\", \"data\":\"[%f, %f]\"}", shoulder, x, y];
						[socket send:message];
					}
				}
			}
			
		} else if (hand.isRight) {
			float x = hand.palmPosition.x;
			float y = hand.palmPosition.y;
			x -= 110;
			x /= -50;
			if (x < -1) {
				x = -1;
			} else if (x > 1) {
				x = 1;
			}
			
			y -= 250;
			y /= -150;
			if (y < -1) {
				y = -1;
			} else if (y > 1) {
				y = 1;
			}
			
			if (fabs(x - rCurrentPosition.x) > 0.2 || fabs(y - rCurrentPosition.y) > 0.2) {
				rCurrentPosition.x = x;
				rCurrentPosition.y = y;
				
			} else {
				if (fabs(x - rLastPosition.x) > 0.2 || fabs(y - rLastPosition.y) > 0.2) {
					rCurrentPosition.x = x;
					rCurrentPosition.y = y;
					
					rLastPosition.x = x;
					rLastPosition.y = y;
					
					if (isSockedOpened) {
						NSString *shoulder = @"move_rshoulder";
						NSString *message = [NSString stringWithFormat:@"{\"action\":\"%@\", \"data\":\"[%f, %f]\"}", shoulder, x, y];
						[socket send:message];
					}
				}
			}
			
		}
		
	}
	
}

- (void)setGuPGood: (LeapFrame *)frame {
	
	if (isSockedOpened) {
		
		NSArray *array = [frame hands];
		if ([array count] == 0) {
			if (isGuPGood) {
				isGuPGood = false;
				[socket send:@"{\"backgroundImage\":\"remove\"}"];
			}
			return;
		}
		
		for (LeapHand *hand in array) {
			if (hand.isRight) {
				float y = hand.palmPosition.y;
				if (y > 400 && !isGuPGood) {
					isGuPGood = true;
					[socket send:@"{\"backgroundImage\":\"garupan\"}"];
					
				} else if (y < 300 && isGuPGood) {
					isGuPGood = false;
					[socket send:@"{\"backgroundImage\":\"remove\"}"];
				}
			}
		}
	}
	
}

@end
