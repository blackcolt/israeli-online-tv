//
//  ViewController.m
//  israeli online tv
//
//  Created by idan magled on 8/29/14.
//  Copyright (c) 2014 idan magled. All rights reserved.
//


#import "ViewController.h"



@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *channelsUiPicker;
@end

@implementation ViewController
@synthesize chenelsArray;
@synthesize responseData;
@synthesize FileSize;
@synthesize _totalFileSize;
@synthesize overLayView;
@synthesize currentChannel;
@synthesize player;
@synthesize dbVersion;
@synthesize bannerView;


- (IBAction)buttonTap:(id)sender {
    
    [self dissableAllControls];
    [self getDataAndReturnJsonArrayWithUrl:@"http://black-colt.net/onlineIsraeliTv/api.php?action=getChannels"];
    self.dbVersion = [self getDBVersion];
    self.refreashBtnOutlet.enabled = FALSE;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.chenelsArray = [[NSMutableArray alloc] init];
    self.chenelsArray = [self getChannelsArrayFromUserDefult];
    if ([self.chenelsArray count] == 0) {
        [self getDataAndReturnJsonArrayWithUrl:@"http://black-colt.net/onlineIsraeliTv/api.php?action=getChannels"];
        self.dbVersion = [self getDBVersion];
    }
    else{
        [self checkIfDbUpToDate];
        self.versionOutlet.text = [self getDbVersionFromUserDefult];
        self.currentChannel = [self.chenelsArray objectAtIndex:0];
    }
    [self.channelsUiPicker reloadAllComponents];
    self.overLayView = [[UIView alloc] initWithFrame:self.view.frame];
    self.overLayView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2f];
    
}
-(void)viewDidAppear:(BOOL)animated{
    
    [self getAdmob];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [chenelsArray count];
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return [[chenelsArray objectAtIndex:row] channel_name] ;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    currentChannel = [self.chenelsArray objectAtIndex:row];
}

-(NSMutableArray*)getDataAndReturnJsonArrayWithUrl:(NSString*)ulrString{
    NSMutableArray *jsonArray;
    NSURL *myURL = [NSURL URLWithString:ulrString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL cachePolicy:
                                    NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    
    [request setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    return jsonArray;
    
}

-(NSString*) getDBVersion{
    NSString *version = [[NSString alloc] init];
    [self getDataFrom:@"http://black-colt.net/onlineIsraeliTv/api.php?action=getDbVersion"];
    return version;
}

- (void) getDataFrom:(NSString *)url{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data
                              
                              options:kNilOptions
                              error:&connectionError];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.versionOutlet.text = [NSString stringWithFormat:@"DB:%@",[json objectForKey:@"version"]];
            [self setDbVersionToUserDefult:[NSString stringWithFormat:@"DB:%@",[json objectForKey:@"version"]]];
        });
    }];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    responseData = [[NSMutableData alloc] init];
    [responseData setLength:0];
    FileSize = [NSNumber numberWithLongLong:[response expectedContentLength]];
    NSLog(@"%@",[NSNumber numberWithLongLong:[response expectedContentLength]]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
    NSNumber *resourceLength = [NSNumber numberWithUnsignedInteger:[responseData length]];
    NSLog(@"resourceData length: %d ", [resourceLength intValue]);
    NSNumber *progress = [NSNumber numberWithFloat:([resourceLength floatValue] / [FileSize floatValue])];
    self.progressBar.progress = [progress floatValue];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    NSLog(@"%@",error);
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[responseData
                                                                   length]);
    NSError *error;
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    
    self.chenelsArray =  [self convertJsonToClass:json];
    [self saveChannelsListToUserDefult];
    [self.channelsUiPicker reloadAllComponents];
    
}

-(NSMutableArray*)convertJsonToClass:(NSMutableArray*) jsonArray{
    NSMutableArray *channelsArry = [[NSMutableArray alloc] init];
    channelsArry = [[NSMutableArray alloc] init];
    for (id obj in jsonArray) {
        channel *newChannel = [[channel alloc] initWithChannel_Name:[obj objectForKey:@"channel_name"] Channel_Url:[obj objectForKey:@"channel_url"]];
        [channelsArry addObject:newChannel];
    }
    
    self.currentChannel = [channelsArry objectAtIndex:0];
    [self enableAllControls];
    return channelsArry;
}

-(void)enableAllControls{
    [self.view setUserInteractionEnabled:YES];
    [self.activityIndicatorOutlet stopAnimating];
    [self.channelsUiPicker setUserInteractionEnabled:YES];
    [overLayView removeFromSuperview];
    [self.refreashBtnOutlet setUserInteractionEnabled:YES];
    
}
-(void)dissableAllControls{
    [self.view setUserInteractionEnabled:NO];
    [self.activityIndicatorOutlet startAnimating];
    [self.channelsUiPicker setUserInteractionEnabled:NO];
    self.progressBar.progress = 0.009;
    [self.view addSubview:self.overLayView];
    [self.refreashBtnOutlet setUserInteractionEnabled:NO];
}

-(void)saveChannelsListToUserDefult{
    
    NSMutableArray *channelsArrayToUserDefult = [[NSMutableArray alloc] init];
    for (channel *channel in self.chenelsArray) {
        NSMutableArray *channelArr = [[NSMutableArray alloc] init];
        [channelArr addObject:[channel channel_name]];
        [channelArr addObject:[channel channel_url]];
        [channelsArrayToUserDefult addObject:channelArr];
    }
    [[NSUserDefaults standardUserDefaults] setValue:channelsArrayToUserDefult forKey:@"channels"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSMutableArray *)getChannelsArrayFromUserDefult{
    NSLog(@"getChannelsArrayFromUserDefult");
    NSMutableArray *channelsArrayFromUserDefultRew = [[NSUserDefaults standardUserDefaults] objectForKey:@"channels"];
    NSMutableArray *channelsArrayFromUserDefult = [[NSMutableArray alloc] init];
    
    for (NSMutableArray *channelArr in channelsArrayFromUserDefultRew) {
        channel *chan = [[channel alloc] initWithChannel_Name:[channelArr objectAtIndex:0]  Channel_Url:[channelArr objectAtIndex:1]];
        [channelsArrayFromUserDefult addObject:chan];
    }
    
    return channelsArrayFromUserDefult;
}

-(void)setDbVersionToUserDefult:(NSString *)Version{
    [[NSUserDefaults standardUserDefaults] setValue:Version forKey:@"dbVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(NSString*)getDbVersionFromUserDefult{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"dbVersion"];
    
}

- (IBAction)viewBtnTap:(id)sender {
    NSString *url = [NSString stringWithFormat:@"%@",[self.currentChannel channel_url]];
    NSLog(@"%@",url);
    [self.playerWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    
    //    NSString *str = [NSString stringWithFormat:@"%@",[currentChannel channel_url]];
    //
    //    MPMoviePlayerViewController *movieViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:str]];
    //
    //    movieViewController.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    //
    //    // Self is the UIViewController you are presenting the movie player from.
    //    [self presentMoviePlayerViewControllerAnimated:movieViewController];
    //    NSLog(@"%@",[currentChannel channel_name]);
}
-(void)checkIfDbUpToDate{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:@"http://black-colt.net/onlineIsraeliTv/api.php?action=getDbVersion"]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data
                              
                              options:kNilOptions
                              error:&connectionError];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *currentVersion = [self getDbVersionFromUserDefult];
            NSString *DbVersion = [[NSString alloc] init];
            
            DbVersion = [NSString stringWithFormat:@"DB:%@",[json objectForKey:@"version"]];
            
            if ([currentVersion isEqualToString:DbVersion]) {
                self.refreashBtnOutlet.enabled = FALSE;
                NSLog(@"uptodate");
            }else{
                self.refreashBtnOutlet.enabled = TRUE;
                NSLog(@"NOT uptodate");
            }
        });
    }];
    
    
    
}

-(void)getAdmob{
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        self.bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0,self.view.frame.size.height,                                                GAD_SIZE_728x90.width,GAD_SIZE_728x90.height)];
        
    }else{
        self.bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0,self.view.frame.size.height,                                                GAD_SIZE_320x50.width,GAD_SIZE_320x50.height)];
        
    }
    
    self.bannerView.adUnitID = @"ca-app-pub-2245492387833435/6085580102";
    self.bannerView.delegate = self;
    [self.bannerView setRootViewController:self];
    [self.view addSubview:self.bannerView];
    [self.bannerView loadRequest:[self createRequest]];
    
}

- (GADRequest *)createRequest {
    GADRequest *request = [GADRequest request];
    return request;
}
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    
    [UIView animateWithDuration:1.0 animations:^ {
        self.bannerView.alpha = 1;
        adView.frame = CGRectMake(0.0,self.view.frame.size.height -
                                  adView.frame.size.height,
                                  adView.frame.size.width,
                                  adView.frame.size.height);
    }];
}




@end

