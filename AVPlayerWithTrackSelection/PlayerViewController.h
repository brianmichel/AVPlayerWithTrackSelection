//
//  PlayerViewController.h
//  AVPlayerWithTrackSelection
//
//  Created by Brian Michel on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayerView;

@interface PlayerViewController : UIViewController

@property (nonatomic, retain) AVPlayer *player;
@property (nonatomic, retain) PlayerView *playerView;
@property (retain) AVPlayerItem *playerItem;


@end
