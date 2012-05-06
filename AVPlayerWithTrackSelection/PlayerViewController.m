//
//  PlayerViewController.m
//  AVPlayerWithTrackSelection
//
//  Created by Brian Michel on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioTrackSelectorViewController.h"
#import "PlayerViewController.h"
#import "PlayerView.h"

/* Some notes on the video defined at kPlayerViewControllerDefaultURL
 I made this video myself, it's a sample Apple video that I've added some more track
 info to. You should see 4 subtitle tracks (two English, two Japanese), please **NOTE**
 only the first subtitle of each language actually contains some subtitles. I would **HIGHLY**
 recommend that you find a better video, but I'll leave this in just incase anyone wants to see.
 
 -Brian Michel
 */
#define kPlayerViewControllerDefaultURL @"http://f.cl.ly/items/3w1i3g2x3p1K090T2D3P/sample_withsubs.mp4"

static const NSString *ItemStatusAndTracksContext = @"ItemStatusAndTracksContext";


@interface PlayerViewController ()

- (void)syncUI;
- (void)play:(UIButton *)sender;
- (void)pause:(UIButton *)sender;
- (void)adjustAudioSettings:(UIButton *)sender;

@property (nonatomic, retain) UIButton *playButton;
@property (nonatomic, retain) UIButton *pauseButton;
@property (nonatomic, retain) UIButton *audioSettingsButton;

@property (nonatomic, retain) UIPopoverController *currentPopover;

@end

@implementation PlayerViewController

@synthesize player = _player;
@synthesize playerItem = _playerItem;
@synthesize playerView = _playerView;

//Controls
@synthesize playButton = _playButton;
@synthesize pauseButton = _pauseButton;
@synthesize audioSettingsButton = _audioSettingsButton;

//Misc.
@synthesize currentPopover = _currentPopover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    self.playerView = [[[PlayerView alloc] initWithFrame:self.view.bounds] autorelease];
    self.playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    [self.playButton sizeToFit];
    self.playButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.playButton setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
    self.playButton.enabled = NO;
    
    self.pauseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    [self.pauseButton sizeToFit];
    self.pauseButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.pauseButton addTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
    
    self.audioSettingsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.audioSettingsButton setTitle:@"\uE03C Settings" forState:UIControlStateNormal];
    [self.audioSettingsButton sizeToFit];
    self.audioSettingsButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.audioSettingsButton addTarget:self action:@selector(adjustAudioSettings:) forControlEvents:UIControlEventTouchUpInside];
    [self.audioSettingsButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.audioSettingsButton setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
    self.audioSettingsButton.enabled = NO;
    
    [self.view addSubview:self.playerView];
    [self.view addSubview:self.playButton];
    [self.view addSubview:self.pauseButton];
    [self.view addSubview:self.audioSettingsButton];
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    [self loadFileFromURL:nil];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.playButton.frame = CGRectMake(0, self.view.frame.size.height - 40, 100, 40);
  self.pauseButton.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame), self.playButton.frame.origin.y, self.playButton.frame.size.width, self.playButton.frame.size.height);
  self.audioSettingsButton.frame = CGRectMake(self.view.frame.size.width - 100, self.view.frame.size.height - 40, 100, 40);
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

#pragma mark - Actions
- (void)loadFileFromURL:(NSString *)url {
  url = url == nil ? kPlayerViewControllerDefaultURL : url;
  AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:url]];
  NSString *tracksKey = @"tracks";
  
  [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:tracksKey] completionHandler:
   ^{     
     // Completion handler block.
     dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = nil;
        AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];
        
        if (status == AVKeyValueStatusLoaded) {
          self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
          [_playerItem addObserver:self forKeyPath:@"status" options:0 context:&ItemStatusAndTracksContext];
          [_playerItem addObserver:self forKeyPath:@"tracks" options:0 context:&ItemStatusAndTracksContext];

          [[NSNotificationCenter defaultCenter] addObserver:self
                                                   selector:@selector(playerItemDidReachEnd:)
                                                       name:AVPlayerItemDidPlayToEndTimeNotification
                                                     object:_playerItem];
          self.player = [AVPlayer playerWithPlayerItem:_playerItem];
          [_playerView setPlayer:_player];
        }
        else {
          // You should deal with the error appropriately.
          NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
        }
      });
   }];
}

- (void)syncUI {
  if ((_player.currentItem != nil) &&
      ([_player.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
    _playButton.enabled = YES;
    _audioSettingsButton.enabled = [_playerItem.tracks count] > 2;
    
  }
  else {
    _audioSettingsButton.enabled = NO;
    _playButton.enabled = NO;
  }
}

- (void)play:(UIButton *)sender {
  [self.player play];
}
- (void)pause:(UIButton *)sender {
  [self.player pause];
}

- (void)adjustAudioSettings:(UIButton *)sender {
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [self.currentPopover dismissPopoverAnimated:YES];
    self.currentPopover = nil;
    self.currentPopover = [AudioTrackSelectorViewController trackSelectorInPopoverWithDelegate:nil player:self.player];
    [self.currentPopover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  } else {
    UINavigationController *nav = [AudioTrackSelectorViewController trackSelectorInNavigationControllerWithDelegate:nil player:self.player];
    [self presentModalViewController:nav animated:YES];
  }
}

#pragma mark - KVO Callback
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if (context == &ItemStatusAndTracksContext) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self syncUI];
    });
    return;
  }
  [super observeValueForKeyPath:keyPath ofObject:object
                         change:change context:context];
  return;
}

#pragma mark - Notification Callbacks
- (void)playerItemDidReachEnd:(NSNotification *)notification {
  [_player seekToTime:kCMTimeZero];
}

- (void)dealloc {
  [_player release];
  [_playButton release];
  [_playerItem release];
  [_playerView release];
  [_pauseButton release];
  [_currentPopover release];
  [super dealloc];
}

@end
