//
//  AudioTrackSelectorViewController.h
//  AVPlayerWithTrackSelection
//
//  Created by Brian Michel on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioTrackSelectorViewController;

@protocol AudioTrackSelectorDelegate <NSObject>
@optional
- (void)trackSelector:(AudioTrackSelectorViewController *)selector selectedMediaOption:(AVMediaSelectionOption *)option inGroup:(AVMediaSelectionGroup *)group;
@end

@interface AudioTrackSelectorViewController : UIViewController

@property (assign) id<AudioTrackSelectorDelegate> delegate;

+ (UIPopoverController *)trackSelectorInPopoverWithDelegate:(id<AudioTrackSelectorDelegate>)delegate player:(AVPlayer *)player;
+ (UINavigationController *)trackSelectorInNavigationControllerWithDelegate:(id<AudioTrackSelectorDelegate>)delegate player:(AVPlayer *)player;

@end
