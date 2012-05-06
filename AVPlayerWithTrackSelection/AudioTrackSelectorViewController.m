//
//  AudioTrackSelectorViewController.m
//  AVPlayerWithTrackSelection
//
//  Created by Brian Michel on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioTrackSelectorViewController.h"

@interface AudioTrackSelectorViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) NSDictionary *trackInformation;
@property (nonatomic, retain) AVPlayer *player;

@end

@implementation AudioTrackSelectorViewController

@synthesize table = _table;
@synthesize trackInformation = _trackInformation;
@synthesize delegate = _delegate;
@synthesize player = _player;

+ (UIPopoverController *)trackSelectorInPopoverWithDelegate:(id<AudioTrackSelectorDelegate>)delegate player:(AVPlayer *)player {
  AudioTrackSelectorViewController *trackSelector = [[[AudioTrackSelectorViewController alloc] init] autorelease];
  trackSelector.delegate = delegate;
  trackSelector.player = player;
  trackSelector.contentSizeForViewInPopover = CGSizeMake(300, 200);
  UIPopoverController *popover = [[[UIPopoverController alloc] initWithContentViewController:trackSelector] autorelease];
  return popover;
}

+ (UINavigationController *)trackSelectorInNavigationControllerWithDelegate:(id<AudioTrackSelectorDelegate>)delegate player:(AVPlayer *)player {
  AudioTrackSelectorViewController *trackSelector = [[[AudioTrackSelectorViewController alloc] init] autorelease];
  trackSelector.delegate = delegate;
  trackSelector.player = player;
  UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:trackSelector] autorelease];
  return nav;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = NSLocalizedString(@"Audio & Subtitles", nil);
    
    self.table = [[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped] autorelease];
    self.table.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.table.dataSource = self;
    self.table.delegate = self;
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
    
    [self.view addSubview:self.table];
  }
  return self;
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;
  
  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)setPlayer:(AVPlayer *)player {
  if (_player) {
    [_player release];
    _player = nil;
  }
  _player = [player retain];
  
  AVMediaSelectionGroup * legibleGroup = [_player.currentItem.asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicLegible];
  AVMediaSelectionGroup * audioGroup = [_player.currentItem.asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicAudible];
  AVMediaSelectionGroup * visualGroup = [_player.currentItem.asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicVisual];  
  
  self.trackInformation = [NSDictionary dictionaryWithObjectsAndKeys:audioGroup, AVMediaCharacteristicAudible, legibleGroup, AVMediaCharacteristicLegible, visualGroup, AVMediaCharacteristicVisual, nil];
  [self.table reloadData];
}

- (AVPlayer *)player {
  return _player;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
  NSArray *keys = [self.trackInformation allKeys];
  if (section == [keys indexOfObject:[keys lastObject]]) {
   return @"These settings will only affect your current playback session.";
  }
  return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  NSArray *keys = [self.trackInformation allKeys];
  NSString *key = [keys objectAtIndex:section];
  if ([key isEqualToString:AVMediaCharacteristicAudible]) {
    return NSLocalizedString(@"Language", nil);
  } else if ([key isEqualToString:AVMediaCharacteristicLegible]) {
    return NSLocalizedString(@"Subtitle", nil);
  } else if ([key isEqualToString:AVMediaCharacteristicVisual]) {
    return NSLocalizedString(@"Video", nil);
  }
  return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return [[self.trackInformation allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  NSArray *keys = [self.trackInformation allKeys];
  AVMediaSelectionGroup *group = [self.trackInformation objectForKey:[keys objectAtIndex:section]];
  return [group.options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  // Configure the cell...
  if (!cell) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
  }
  NSArray *keys = [self.trackInformation allKeys];
  AVMediaSelectionGroup *group = [self.trackInformation objectForKey:[keys objectAtIndex:indexPath.section]];
  AVMediaSelectionOption *option = [group.options objectAtIndex:indexPath.row];
  cell.textLabel.text = [option.locale displayNameForKey:NSLocaleLanguageCode value:option.locale.localeIdentifier];
  
  AVMediaSelectionOption *currentOptionInGroup = [self.player.currentItem selectedMediaOptionInMediaSelectionGroup:group];
  
  cell.accessoryType = [currentOptionInGroup isEqual:option] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
  
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self.table deselectRowAtIndexPath:indexPath animated:YES];
  NSArray *keys = [self.trackInformation allKeys];

  AVMediaSelectionGroup *group = [self.trackInformation objectForKey:[keys objectAtIndex:indexPath.section]];
  AVMediaSelectionOption *option = [group.options objectAtIndex:indexPath.row];
    
  [self.player.currentItem selectMediaOption:option inMediaSelectionGroup:group];
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(trackSelector:selectedMediaOption:inGroup:)]) {
    [self.delegate trackSelector:self selectedMediaOption:option inGroup:group];
  }

  [self.table reloadData];
}

#pragma mark - Actions
- (void)done:(id)sender {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
  [_table release];
  [_trackInformation release];
  [_player release];
  _delegate = nil;
  [super dealloc];
}

@end
