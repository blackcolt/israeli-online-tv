//
//  ViewController.h
//  israeli online tv
//
//  Created by idan magled on 8/29/14.
//  Copyright (c) 2014 idan magled. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "channel.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "GADBannerView.h"


@interface ViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate,UIWebViewDelegate,GADBannerViewDelegate>{
    GADBannerView *bannerView_;
}

@property (nonatomic,retain)GADBannerView *bannerView;

@property (nonatomic,retain) NSMutableArray *chenelsArray;
@property (weak, nonatomic) IBOutlet UIWebView *playerWebView;

@property (nonatomic,retain) NSMutableData *responseData;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorViewOutlet;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (nonatomic) float _totalFileSize;
@property (nonatomic,retain) NSNumber *FileSize;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorOutlet;
@property (nonatomic,retain) UIView *overLayView;
@property (weak, nonatomic) IBOutlet UIButton *refreashBtnOutlet;
@property (nonatomic,retain) channel *currentChannel;
- (IBAction)viewBtnTap:(id)sender;
@property (nonatomic, strong) MPMoviePlayerController *player;
@property (weak, nonatomic) IBOutlet UILabel *versionOutlet;
@property (nonatomic,retain) NSString *dbVersion;

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
@end

