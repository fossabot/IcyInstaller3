//
//  ViewController.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 2/8/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//
#include <spawn.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <bzlib.h>
#include "NSTask.h"
#import "ViewController.h"

@interface ViewController ()

// The download variables
@property (strong, nonatomic) NSURLConnection *connectionManager;
@property (strong, nonatomic) NSMutableData *downloadedMutableData;
@property (strong, nonatomic) NSURLResponse *urlResponse;
@property (strong, nonatomic) NSString *filename;

// UI
@property (strong, nonatomic) UIButton *aboutButton;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *descLabel;
@property (strong, nonatomic) UIWebView *welcomeWebView;
@property (strong, nonatomic) UIWebView *depictionWebView;
@property (strong, nonatomic) UIView *navigationView;
@property (strong, nonatomic) UIImageView *homeImage;
@property (strong, nonatomic) UIImageView *homeImageSEL;
@property (strong, nonatomic) UIImageView *sourcesImage;
@property (strong, nonatomic) UIImageView *sourcesImageSEL;
@property (strong, nonatomic) UIImageView *manageImage;
@property (strong, nonatomic) UIImageView *manageImageSEL;
@property (strong, nonatomic) UILabel *homeLabel;
@property (strong, nonatomic) UILabel *sourcesLabel;
@property (strong, nonatomic) UILabel *manageLabel;
@property (strong, nonatomic) UITextField *searchField;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UITableView *tableView2;
@property (strong, nonatomic) UIView *loadingView;
@property (strong, nonatomic) UITextView *loadingArea;
@property (strong, nonatomic) UIProgressView *progressView;

// Package management arrays
@property (strong, nonatomic) NSMutableArray *packageIDs;
@property (strong, nonatomic) NSMutableArray *packageNames;
@property (strong, nonatomic) NSMutableArray *packageImages;
@property (strong, nonatomic) NSMutableArray *packageIcons;

// Package search methods
@property (strong, nonatomic) NSMutableArray *searchNames;
@property (strong, nonatomic) NSMutableArray *searchDescs;
@property (strong, nonatomic) NSMutableArray *searchDepictions;
@property (strong, nonatomic) NSMutableArray *searchFilenames;

@end
#define coolerBlueColor [UIColor colorWithRed:0.00 green:0.52 blue:1.00 alpha:1.0];
BOOL darkMode = NO;
int packageIndex;
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Get value of darkMode
    darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"];
    // Stuff for downloading with progress
    self.downloadedMutableData = [[NSMutableData alloc] init];
    // The button at the right
    _aboutButton = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 120,33,75,30)];
    _aboutButton.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    if(darkMode) [_aboutButton setTitle:@"Light" forState:UIControlStateNormal];
    else [_aboutButton setTitle:@"Dark" forState:UIControlStateNormal];
    _aboutButton.titleLabel.textColor = coolerBlueColor;
    [_aboutButton addTarget:self action:@selector(about) forControlEvents:UIControlEventTouchUpInside];
    [self makeViewRound:_aboutButton withRadius:5];
    [self.view addSubview:_aboutButton];
    // The top label
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(26,26,[UIScreen mainScreen].bounds.size.width,40)];
    _nameLabel.text = @"Icy Installer";
    [_nameLabel setFont:[UIFont boldSystemFontOfSize:30]];
    [self.view addSubview:_nameLabel];
    // The less top but still top label
    _descLabel = [[UILabel alloc]initWithFrame:CGRectMake(26,76,[UIScreen mainScreen].bounds.size.width,20)];
    _descLabel.text = @"Where the possibilities are endless";
    [_descLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.view addSubview:_descLabel];
    // The homepage website
    _welcomeWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0,120,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 180)];
    [_welcomeWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://artikus.pe.hu/Icy.html"]]];
    [self.view addSubview:_welcomeWebView];
    // The depiction webview
    _depictionWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0,120,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 180)];
    [self.view addSubview:_depictionWebView];
    _depictionWebView.hidden = YES;
    // Change the user agent to a desktop one, so when we view depictions "Open in Cydia" doesn't appear
    NSDictionary *dictionary = @{@"UserAgent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.1 Safari/605.1.15"};
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Navigation, I guess
    _navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 60, [UIScreen mainScreen].bounds.size.width, 60)];
    UIView *border = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _navigationView.frame.size.width, 1)];
    border.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
    [_navigationView addSubview:border];
    [self.view addSubview:_navigationView];
    // The homeImage
    _homeImageSEL = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons/HomeSEL.png"]];
    _homeImageSEL.frame = CGRectMake(30,10,32,32);
    [_navigationView addSubview:_homeImageSEL];
    _homeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons/Home.png"]];
    _homeImage.frame = CGRectMake(30,10,32,32);
    _homeImage.userInteractionEnabled = YES;
    _homeImage.hidden = YES;
    [_navigationView addSubview:_homeImage];
    // The home label
    _homeLabel = [[UILabel alloc] initWithFrame:CGRectMake(27,45,40,10)];
    _homeLabel.textAlignment = NSTextAlignmentCenter;
    _homeLabel.textColor = coolerBlueColor;
    _homeLabel.text = @"Home";
    [_homeLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [_navigationView addSubview:_homeLabel];
    // The sourcesImage
    _sourcesImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons/Sources.png"]];
    _sourcesImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 16, 10, 32, 32);
    _sourcesImage.userInteractionEnabled = YES;
    [_navigationView addSubview:_sourcesImage];
    _sourcesImageSEL = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons/SourcesSEL.png"]];
    _sourcesImageSEL.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 16, 10, 32, 32);
    _sourcesImageSEL.hidden = YES;
    [_navigationView addSubview:_sourcesImageSEL];
    // The sources label
    _sourcesLabel = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 25,45,50,10)];
    _sourcesLabel.textColor = [UIColor grayColor];
    _sourcesLabel.textAlignment = NSTextAlignmentCenter;
    _sourcesLabel.text = @"Sources";
    [_sourcesLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [_navigationView addSubview:_sourcesLabel];
    // The manageImage
    _manageImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons/Installed.png"]];
    _manageImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 62,10,32,32);
    _manageImage.userInteractionEnabled = YES;
    [_navigationView addSubview:_manageImage];
    _manageImageSEL = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons/InstalledSEL.png"]];
    _manageImageSEL.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 62,10,32,32);
    _manageImageSEL.hidden = YES;
    [_navigationView addSubview:_manageImageSEL];
    // The manage label
    _manageLabel = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 70,40,50,20)];
    _manageLabel.textColor = [UIColor grayColor];
    _manageLabel.textAlignment = NSTextAlignmentCenter;
    _manageLabel.text = @"Manage";
    [_manageLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [_navigationView addSubview:_manageLabel];
    // Gesture recognizers
    UITapGestureRecognizer *homeGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(homeAction)];
    [_homeImage addGestureRecognizer:homeGesture];
    UITapGestureRecognizer *sourcesGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sourcesAction)];
    [_sourcesImage addGestureRecognizer:sourcesGesture];
    UITapGestureRecognizer *manageGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(manageAction)];
    [_manageImage addGestureRecognizer:manageGesture];
    // Table views
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(13,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 160) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView2 = [[UITableView alloc] initWithFrame:CGRectMake(13,160,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 220) style:UITableViewStylePlain];
    _tableView2.delegate = self;
    _tableView2.dataSource = self;
    _tableView2.backgroundColor = [UIColor whiteColor];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView2 setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    [self.view addSubview:_tableView2];
    _tableView.hidden = YES;
    _tableView2.hidden = YES;
    // Search texfield
    _searchField = [[UITextField alloc]initWithFrame:CGRectMake(20,120,[UIScreen mainScreen].bounds.size.width - 40,30)];
    _searchField.placeholder = @"Search";
    _searchField.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
    _searchField.textAlignment = NSTextAlignmentCenter;
    _searchField.returnKeyType = UIReturnKeySearch;
    _searchField.delegate = self;
    _searchField.hidden = YES;
    [self makeViewRound:_searchField withRadius:5];
    [self.view addSubview:_searchField];
    // Loading view
    _loadingView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    if(darkMode) _loadingView.backgroundColor = [UIColor blackColor];
    else _loadingView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_loadingView];
    // Gradient
    UIView *gradientView = [[UIView alloc] initWithFrame:CGRectMake(30,[UIScreen mainScreen].bounds.size.height / 2 - 160,[UIScreen mainScreen].bounds.size.width - 60,360)];
    [self makeViewRound:gradientView withRadius:10];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = @[(id)[UIColor colorWithRed:0.16 green:0.81 blue:0.93 alpha:1.0].CGColor, (id)[UIColor colorWithRed:0.15 green:0.48 blue:0.78 alpha:1.0].CGColor];
    gradient.frame = gradientView.bounds;
    if(!darkMode) [gradientView.layer insertSublayer:gradient atIndex:0];
    [_loadingView addSubview:gradientView];
    // Top label
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, 50)];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = @"Icy Installer";
    [loadingLabel setFont:[UIFont boldSystemFontOfSize:30]];
    if(darkMode) loadingLabel.textColor = [UIColor whiteColor];
    else loadingLabel.textColor = [UIColor blackColor];
    [_loadingView addSubview:loadingLabel];
    // Loading textarea
    _loadingArea = [[UITextView alloc] initWithFrame:CGRectMake(0, 50, gradientView.bounds.size.width, 330)];
    _loadingArea.scrollEnabled = NO;
    _loadingArea.textColor = [UIColor whiteColor];
    _loadingArea.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0];
    _loadingArea.textAlignment = NSTextAlignmentCenter;
    [_loadingArea setFont:[UIFont boldSystemFontOfSize:15]];
    _loadingArea.text = @"Welcome to Icy Installer 3.1!\nMade by ArtikusHG.\nLoading packages....";
    [gradientView addSubview:_loadingArea];
    // Progress spinwheel
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.frame = CGRectMake(gradientView.bounds.size.width / 2 - 10,20,20,20);
    [gradientView addSubview:spinner];
    [spinner startAnimating];
    // Progress View
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _progressView.frame = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,10);
    _progressView.progress = 0;
    [self.view addSubview:_progressView];
    if(darkMode) [self switchToDarkMode];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self loadStuff];
        freopen([@"/var/mobile/Media/Icy/log.txt" cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
    });
}

#pragma mark - Loading methods

- (void)loadStuff {
    // Initialize arrays
    _searchNames = [[NSMutableArray alloc] init];
    _searchDescs = [[NSMutableArray alloc] init];
    _searchDepictions = [[NSMutableArray alloc] init];
    _searchFilenames = [[NSMutableArray alloc] init];
    _packageIcons = [[NSMutableArray alloc] init];
    BOOL isDirectory;
    // Check for needed directories
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy" isDirectory:&isDirectory]) [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Media/Icy" withIntermediateDirectories:NO attributes:nil error:nil];
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/Repos" isDirectory:&isDirectory]) [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Media/Icy/Repos" withIntermediateDirectories:NO attributes:nil error:nil];
    // Get package list and put to table view
    _packageNames = [[NSMutableArray alloc] init];
    _packageIDs = [[NSMutableArray alloc] init];
    FILE *file = fopen("/var/lib/dpkg/status", "r");
    char str[999];
    NSString *icon = nil;
    NSString *lastID = nil;
    while(fgets(str, 999, file) != NULL) {
        if(strstr(str, "Package:"))  [_packageIDs addObject:[[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Package: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
        if(strstr(str, "Name:")) [_packageNames addObject:[[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Name: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
        if(strstr(str, "Section:")) {
            icon = [NSString stringWithFormat:@"/Applications/IcyInstaller3.app/icons/%@.png",[[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Section: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
            if([icon rangeOfString:@" "].location != NSNotFound) icon = [NSString stringWithFormat:@"%@.png",[icon substringToIndex:[icon rangeOfString:@" "].location]];
            if(![[NSFileManager defaultManager] fileExistsAtPath:icon]) icon = @"/Applications/IcyInstaller3.app/icons/Home.png";
        }
        if(strstr(str, "Icon:")) icon = [[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Icon: file://" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if(strlen(str) < 2) {
            lastID = [_packageIDs lastObject];
            if(_packageIDs.count > _packageNames.count) [_packageNames addObject:lastID];
            NSString *lastObject = [_packageNames lastObject];
            [_packageNames sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            [_packageIDs removeLastObject];
            [_packageIDs insertObject:lastID atIndex:[_packageNames indexOfObject:lastObject]];
            [_packageIcons insertObject:icon atIndex:[_packageNames indexOfObject:lastObject]];
        }
    }
    fclose(file);
    _loadingArea.text = [_loadingArea.text stringByAppendingString:@"Finished loading packages.\nLaunching Icy..."];
    [_tableView reloadData];
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _loadingView.frame  = CGRectMake(0,-[UIScreen mainScreen].bounds.size.height - 20,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    } completion:^(BOOL finished) {
        if(darkMode) [_welcomeWebView stringByEvaluatingJavaScriptFromString:@"document.body.style.background = 'black'; var p = document.getElementsByTagName('p'); for (var i = 0; i < p.length; i++) { p[i].style.color = 'white'; }"];
        }];
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    if(theTableView == _tableView) {
        return _packageNames.count;
    } else if(theTableView == _tableView2) {
        return _searchNames.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = (UITableViewCell *)[theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    if(theTableView == _tableView) {
        cell.textLabel.text = [_packageNames objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [_packageIDs objectAtIndex:indexPath.row];
        UIImage *icon = [UIImage imageWithContentsOfFile:[_packageIcons objectAtIndex:indexPath.row]];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(40,40), NO, [UIScreen mainScreen].scale);
        [icon drawInRect:CGRectMake(0,0,40,40)];
        icon = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self makeViewRound:cell.imageView withRadius:10];
        cell.imageView.image = icon;
    } else if(theTableView == _tableView2) {
        cell.textLabel.text = [_searchNames objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [_searchDescs objectAtIndex:indexPath.row];
    } else cell.textLabel.text = @"Some stupid error happened";
    return cell;
}

NSString *packageName;
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(theTableView == _tableView) [self packageInfoWithIndexPath:indexPath];
        else if(theTableView == _tableView2) [self showDepictionForPackageWithIndexPath:indexPath];
        else [self messageWithTitle:@"Error" message:@"Literally an error. Go report this to @ArtikusHG."];
}

#pragma mark - Package management methods

UIView *infoView;
UITextView *infoText;
- (void)packageInfoWithIndexPath:(NSIndexPath *)indexPath {
    _nameLabel.text = @"Info";
    _descLabel.text = [NSString stringWithFormat:@"%@",[_packageIDs objectAtIndex:indexPath.row]];
    _descLabel.text = [_descLabel.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *searchString = [NSString stringWithFormat:@"Package: %@",_descLabel.text];
    NSString *info = @"";
    FILE *file = fopen("/var/lib/dpkg/status", "r");
    char str[999];
    int shouldWrite = 0;
    const char *search = [searchString UTF8String];
    while(fgets(str, 999, file) != NULL) {
        if(strstr(str, search)) {
            shouldWrite = 1;
        }
        if(strlen(str) < 2 && shouldWrite == 1) {
            break;
        }
        if(shouldWrite == 1 && !strstr(str, "Priority:") && !strstr(str, "Status:") && !strstr(str, "Installed-Size:") && !strstr(str, "Maintainer:") && !strstr(str, "Architecture:") && !strstr(str, "Replaces:") && !strstr(str, "Provides:") && !strstr(str, "Homepage:") && !strstr(str, "Depiction:") && !strstr(str, "Depiction:") && !strstr(str, "Sponsor:") && !strstr(str, "dev:") && !strstr(str, "Tag:") && !strstr(str, "Icon:") && !strstr(str, "Website:")) {
            info = [NSString stringWithFormat:@"%@%@",info,[NSString stringWithCString:str encoding:NSASCIIStringEncoding]];
        }
    }
    fclose(file);
    UIView *infoTextView = [[UIView alloc] initWithFrame:CGRectMake(20,10,[UIScreen mainScreen].bounds.size.width - 40,[UIScreen mainScreen].bounds.size.height / 2 - 20)];
    [self makeViewRound:infoTextView withRadius:10];
    infoView = [[UIView alloc] initWithFrame:CGRectMake(0,-[UIScreen mainScreen].bounds.size.height - 160,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 160)];
    [infoView addSubview:infoTextView];
    [self.view addSubview:infoView];
    infoText = [[UITextView alloc] initWithFrame:infoTextView.bounds];
    infoText.editable = NO;
    infoText.scrollEnabled = YES;
    infoText.text = info;
    infoText.textColor = [UIColor whiteColor];
    infoText.backgroundColor = [UIColor clearColor];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = @[(id)[UIColor colorWithRed:0.16 green:0.81 blue:0.93 alpha:1.0].CGColor, (id)[UIColor colorWithRed:0.15 green:0.48 blue:0.78 alpha:1.0].CGColor];
    gradient.frame = infoTextView.bounds;
    if(darkMode) {
        infoView.backgroundColor = [UIColor blackColor];
        infoText.backgroundColor = [UIColor blackColor];
    } else {
        infoView.backgroundColor = [UIColor whiteColor];
        [infoTextView.layer insertSublayer:gradient atIndex:0];
    }
    [infoText setFont:[UIFont boldSystemFontOfSize:15]];
    [self makeViewRound:infoText withRadius:10];
    [infoTextView addSubview:infoText];
    UIButton *dismiss = [[UIButton alloc] initWithFrame:CGRectMake(20,infoView.bounds.size.height - 50,[UIScreen mainScreen].bounds.size.width - 40,40)];
    dismiss.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    [dismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
    dismiss.layer.masksToBounds = YES;
    dismiss.layer.cornerRadius = 10;
    [dismiss.titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
    dismiss.titleLabel.textColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    [dismiss addTarget:self action:@selector(dismissInfo) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:dismiss];
    UIButton *remove = [[UIButton alloc] initWithFrame:CGRectMake(20,infoView.bounds.size.height - 100,[UIScreen mainScreen].bounds.size.width - 40,40)];
    remove.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.1];
    [remove setTitle:@"Remove" forState:UIControlStateNormal];
    remove.layer.masksToBounds = YES;
    remove.layer.cornerRadius = 10;
    [remove.titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
    remove.titleLabel.textColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    [remove addTarget:self action:@selector(removePackageButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:remove];
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        infoView.frame  = CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 160);
    } completion:nil];
}

- (void)dismissInfo {
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        infoView.frame  = CGRectMake(0,-[UIScreen mainScreen].bounds.size.height - 100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 160);
    } completion:nil];
    [self manageAction];
}

- (void)removePackageButtonAction {
    [self removePackageWithBundleID:_descLabel.text];
}

UIView *dependencyView;
NSMutableArray *dependencies;
- (void)removePackageWithBundleID:(NSString *)bundleID {
    //[self reloadWithMessage:[self runCommandWithOutput:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/freeze"] withArguments:@[@"-r", _descLabel.text] errors:NO]];
    NSString *output = [self runCommandWithOutput:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/freeze"] withArguments:@[@"-r", bundleID] errors:YES];
    if([output rangeOfString:@"dpkg: dependency problems prevent removal"].location != NSNotFound) {
        output = [output stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"dpkg: dependency problems prevent removal of %@:\n",_descLabel.text] withString:@""];
        dependencies = [[[NSMutableArray alloc] init] autorelease];
        NSMutableArray *dependencyNames = [[[NSMutableArray alloc] init] autorelease];
        for (id object in [output componentsSeparatedByString:@"\n"]) if([object rangeOfString:@"depends"].location != NSNotFound) [dependencies addObject:[[object substringToIndex:[[object substringFromIndex:1] rangeOfString:@" "].location + 1] stringByReplacingOccurrencesOfString:@" " withString:@""]];
        dependencies = [[[NSOrderedSet orderedSetWithArray:dependencies] array] mutableCopy];
        for (id object in dependencies) [dependencyNames addObject:[self packageNameForBundleID:object]];
        dependencyView = [[UIView alloc] initWithFrame:CGRectMake(20,-[UIScreen mainScreen].bounds.size.height - 180,[UIScreen mainScreen].bounds.size.width - 40,[UIScreen mainScreen].bounds.size.height - 180)];
        if(darkMode) dependencyView.backgroundColor = [UIColor blackColor];
        else dependencyView.backgroundColor = [UIColor whiteColor];
        [self makeViewRound:dependencyView withRadius:10];
        [self.view addSubview:dependencyView];
        UITextView *dependencyText = [[UITextView alloc] initWithFrame:CGRectMake(0,2,dependencyView.bounds.size.width,dependencyView.bounds.size.height - 70)];
        dependencyText.text = [NSString stringWithFormat:@"You're trying to remove the package %@, however, the following packages depend on this package:\n",_descLabel.text];
        for(id object in dependencyNames) dependencyText.text = [dependencyText.text stringByAppendingString:[NSString stringWithFormat:@"- %@\n",object]];
        dependencyText.text = [dependencyText.text stringByAppendingString:@"Would you still like to remove the package? All of its dependencies are also going to be removed."];
        if(darkMode) dependencyText.textColor = [UIColor whiteColor];
        dependencyText.backgroundColor = [UIColor clearColor];
        dependencyText.font = [UIFont boldSystemFontOfSize:15];
        [dependencyView addSubview:dependencyText];
        UIButton *noButton = [[UIButton alloc] initWithFrame:CGRectMake(10,dependencyView.bounds.size.height - 40,dependencyView.bounds.size.width / 2 - 20,30)];
        noButton.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
        [noButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [noButton setTitle:@"No" forState:UIControlStateNormal];
        noButton.titleLabel.textColor = coolerBlueColor;
        [self makeViewRound:noButton withRadius:10];
        [noButton addTarget:self action:@selector(dismissDependencyWarning) forControlEvents:UIControlEventTouchUpInside];
        [dependencyView addSubview:noButton];
        UIButton *yesButton = [[UIButton alloc] initWithFrame:CGRectMake(dependencyView.bounds.size.width - dependencyView.bounds.size.width / 2 + 5,dependencyView.bounds.size.height - 40,dependencyView.bounds.size.width / 2 - 20,30)];
        yesButton.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
        [yesButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [yesButton setTitle:@"Yes" forState:UIControlStateNormal];
        yesButton.titleLabel.textColor = coolerBlueColor;
        [self makeViewRound:yesButton withRadius:10];
        [yesButton addTarget:self action:@selector(removeAllPackages) forControlEvents:UIControlEventTouchUpInside];
        [dependencyView addSubview:yesButton];
        darkenView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        darkenView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        [self.view addSubview:darkenView];
        [self.view bringSubviewToFront:dependencyView];
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            dependencyView.frame = CGRectMake(20,100,[UIScreen mainScreen].bounds.size.width - 40,[UIScreen mainScreen].bounds.size.height - 180);
        } completion:nil];
    }
}

- (void)dismissDependencyWarning {
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        dependencyView.frame = CGRectMake(20,-[UIScreen mainScreen].bounds.size.height - 180,[UIScreen mainScreen].bounds.size.width - 40,[UIScreen mainScreen].bounds.size.height - 180);
    } completion:nil];
    darkenView.hidden = YES;
    darkenView.alpha = 0;
}

- (void)removeAllPackages {
    for (id object in dependencies) [self removePackageWithBundleID:object];
}

- (NSString *)packageNameForBundleID:(NSString *)bundleID {
    FILE *file = fopen("/var/lib/dpkg/status", "r");
    char str[999];
    char search[999];
    snprintf(search, sizeof(search), "Package: %s", [bundleID UTF8String]);
    BOOL shouldReturn = NO;
    while (fgets(str, 999, file) != NULL) {
        if(strstr(str, search)) shouldReturn = YES;
        if(strstr(str, "Name:") && shouldReturn) break;
    }
    fclose(file);
    return [[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] substringFromIndex:6] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

#pragma mark - Reload methods
UIView *reloadView;
- (void)reloadWithMessage:(NSString *)message {
    reloadView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width,0,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
    if(darkMode) reloadView.backgroundColor = [UIColor blackColor];
    else reloadView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:reloadView];
    UITextView *messageView = [[UITextView alloc] initWithFrame:CGRectMake(20,0,[UIScreen mainScreen].bounds.size.width - 40,[UIScreen mainScreen].bounds.size.height - 235)];
    messageView.font = [UIFont boldSystemFontOfSize:15];
    messageView.text = message;
    messageView.editable = NO;
    [reloadView addSubview:messageView];
    UIButton *respring = [[UIButton alloc] initWithFrame:CGRectMake(20, reloadView.bounds.size.height - 210, reloadView.bounds.size.width - 40, 50)];
    [self makeViewRound:respring withRadius:10];
    respring.backgroundColor = [UIColor colorWithRed:0.10 green:0.74 blue:0.61 alpha:1];
    [respring setTitle:@"Respring" forState:UIControlStateNormal];
    [respring setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [respring.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [respring addTarget:self action:@selector(respring) forControlEvents:UIControlEventTouchUpInside];
    [reloadView addSubview:respring];
    UIButton *uicache = [[UIButton alloc] initWithFrame:CGRectMake(20, reloadView.bounds.size.height - 140, reloadView.bounds.size.width - 40, 50)];
    [self makeViewRound:uicache withRadius:10];
    uicache.backgroundColor = [UIColor colorWithRed:0.50 green:0.55 blue:0.55 alpha:1];
    [uicache setTitle:@"Reload cache" forState:UIControlStateNormal];
    [uicache setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [uicache.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [uicache addTarget:self action:@selector(uicache) forControlEvents:UIControlEventTouchUpInside];
    [reloadView addSubview:uicache];
    UIButton *dismiss = [[UIButton alloc] initWithFrame:CGRectMake(20, reloadView.bounds.size.height - 70, reloadView.bounds.size.width - 40, 50)];
    [self makeViewRound:dismiss withRadius:10];
    dismiss.backgroundColor = [UIColor colorWithRed:0.90 green:0.49 blue:0.13 alpha:1];
    [dismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
    [dismiss setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [dismiss.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [dismiss addTarget:self action:@selector(dismissReload) forControlEvents:UIControlEventTouchUpInside];
    [reloadView addSubview:dismiss];
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        reloadView.frame = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    } completion:nil];
}

- (void)uicache {
    pid_t pid;
    int status;
    const char *argv[] = {"uicache", NULL};
    posix_spawn(&pid, "/usr/bin/uicache", NULL, NULL, (char* const*)argv, NULL);
    waitpid(pid, &status, 0);
}

- (void)respring {
    pid_t pid;
    int status;
    const char *argv[] = {"killall", "-9", "SpringBoard", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)argv, NULL);
    waitpid(pid, &status, 0);
}

- (void)dismissReload {
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        reloadView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width,0,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
        } completion:nil];
}

#pragma mark - Manage methods

UIView *manageView;
UIView *darkenView;
- (void)manage {
    darkenView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    darkenView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:darkenView];
    manageView = [[UIView alloc] initWithFrame:CGRectMake(30,-230,[UIScreen mainScreen].bounds.size.width - 60,230)];
    if(darkMode) manageView.backgroundColor = [UIColor blackColor];
    else manageView.backgroundColor = [UIColor whiteColor];
    [self makeViewRound:manageView withRadius:10];
    [self.view addSubview:manageView];
    UIButton *refresh = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, manageView.bounds.size.width - 40, 50)];
    [self makeViewRound:refresh withRadius:10];
    refresh.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.1];
    [refresh setTitle:@"Refresh sources" forState:UIControlStateNormal];
    [refresh setTitleColor:[[UIColor greenColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
    [refresh.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [refresh addTarget:self action:@selector(refreshSources) forControlEvents:UIControlEventTouchUpInside];
    [manageView addSubview:refresh];
    UIButton *update = [[UIButton alloc] initWithFrame:CGRectMake(20, 90, manageView.bounds.size.width - 40, 50)];
    [self makeViewRound:update withRadius:10];
    update.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    [update setTitle:@"Scan updates" forState:UIControlStateNormal];
    [update setTitleColor:[[UIColor blueColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
    [update.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [update addTarget:self action:@selector(updatePackages) forControlEvents:UIControlEventTouchUpInside];
    [manageView addSubview:update];
    UIButton *dismiss = [[UIButton alloc] initWithFrame:CGRectMake(20, 160, manageView.bounds.size.width - 40, 50)];
    [self makeViewRound:dismiss withRadius:10];
    dismiss.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.1];
    [dismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
    [dismiss setTitleColor:[[UIColor redColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
    [dismiss.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [dismiss addTarget:self action:@selector(dismissManage) forControlEvents:UIControlEventTouchUpInside];
    [manageView addSubview:dismiss];
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        manageView.frame = CGRectMake(30,[UIScreen mainScreen].bounds.size.height / 2 - 115,[UIScreen mainScreen].bounds.size.width - 60,230);
    } completion:nil];
}

- (void)dismissManage {
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        manageView.frame = CGRectMake(30,-230,[UIScreen mainScreen].bounds.size.width - 60,230);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3 animations:^ {
            [darkenView setAlpha:0];
        }];
    }];
}

- (void)refreshSources {
    // BigBoss
    NSString *bigboss = @"http://apt.thebigboss.org/repofiles/cydia/dists/stable/main/binary-iphoneos-arm/Packages.bz2";
     NSURL *bigbossURL = [NSURL URLWithString:bigboss];
     NSData *bigbossURLData = [NSData dataWithContentsOfURL:bigbossURL];
     if (bigbossURLData) [bigbossURLData writeToFile:@"/var/mobile/Media/Icy/Repos/BigBoss.bz2" atomically:YES];
     // ModMyi
     NSString *modmyi = @"http://apt.modmyi.com/dists/stable/main/binary-iphoneos-arm/Packages.bz2";
     NSURL *modmyiURL = [NSURL URLWithString:modmyi];
     NSData *modmyiURLData = [NSData dataWithContentsOfURL:modmyiURL];
     if (modmyiURLData) {
     [modmyiURLData writeToFile:@"/var/mobile/Media/Icy/Repos/ModMyi.bz2" atomically:YES];
     }
     // Zodttd and MacCiti
     NSString *zodttd = @"http://zodttd.saurik.com/repo/cydia/dists/stable/main/binary-iphoneos-arm/Packages.bz2";
     NSURL *zodttdURL = [NSURL URLWithString:zodttd];
     NSData *zodttdURLData = [NSData dataWithContentsOfURL:zodttdURL];
     if (zodttdURLData) {
     [zodttdURLData writeToFile:@"/var/mobile/Media/Icy/Repos/Zodttd.bz2" atomically:YES];
     }
     // Saurik's repo
     NSString *saurik = @"http://apt.saurik.com/cydia/Packages.bz2";
     NSURL *saurikURL = [NSURL URLWithString:saurik];
     NSData *saurikURLData = [NSData dataWithContentsOfURL:saurikURL];
     if (saurikURLData) [saurikURLData writeToFile:@"/var/mobile/Media/Icy/Repos/Saurik.bz2" atomically:YES];
    // Unpack the files
    bunzip_one("/var/mobile/Media/Icy/Repos/BigBoss.bz2", "/var/mobile/Media/Icy/Repos/BigBoss");
    bunzip_one("/var/mobile/Media/Icy/Repos/Zodttd.bz2", "/var/mobile/Media/Icy/Repos/Zodttd");
    bunzip_one("/var/mobile/Media/Icy/Repos/ModMyi.bz2", "/var/mobile/Media/Icy/Repos/ModMyi");
    bunzip_one("/var/mobile/Media/Icy/Repos/Saurik.bz2", "/var/mobile/Media/Icy/Repos/Saurik");
}

int bunzip_one(const char file[999], const char output[999]) {
    FILE *f = fopen(file, "r+b");
    FILE *outfile = fopen(output, "w");
    fprintf(outfile, "");
    outfile = fopen(output, "a");
    int bzError;
    BZFILE *bzf;
    char buf[4096];
    
    bzf = BZ2_bzReadOpen(&bzError, f, 0, 0, NULL, 0);
    if (bzError != BZ_OK) {
        fprintf(stderr, "E: BZ2_bzReadOpen: %d\n", bzError);
        return -1;
    }
    
    while (bzError == BZ_OK) {
        int nread = BZ2_bzRead(&bzError, bzf, buf, sizeof buf);
        if (bzError == BZ_OK || bzError == BZ_STREAM_END) {
            size_t nwritten = fwrite(buf, 1, nread, stdout);
            fprintf(outfile, "%s", buf);
            if (nwritten != (size_t) nread) {
                fprintf(stderr, "E: short write\n");
                return -1;
            }
        }
    }
    
    if (bzError != BZ_STREAM_END) {
        fprintf(stderr, "E: bzip error after read: %d\n", bzError);
        return -1;
    }
    
    BZ2_bzReadClose(&bzError, bzf);
    unlink(file);
    fclose(outfile);
    fclose(f);
    return 0;
}

- (void)updatePackages {
    
}

- (void)about {
    if([_aboutButton.currentTitle isEqualToString:@"Dark"]) {
        [_aboutButton setTitle:@"Light" forState:UIControlStateNormal];
        [self switchToDarkMode];
    } else if([_aboutButton.currentTitle isEqualToString:@"Light"]) {
        [_aboutButton setTitle:@"Dark" forState:UIControlStateNormal];
        [self switchToLightMode];
    } else if([_aboutButton.currentTitle isEqualToString:@"Install"] && _depictionWebView.hidden) {
        [self messageWithTitle:@"Error" message:@"You need to search for a package first."];
    } else if([_aboutButton.currentTitle isEqualToString:@"Install"] && !_depictionWebView.hidden) {
        _nameLabel.text = @"Getting...";
        _descLabel.text = @"Downloading and installing...";
        [self downloadWithProgressAndURLString:[_searchFilenames objectAtIndex:packageIndex] saveFilename:@"downloaded.deb"];
    } else if([_aboutButton.currentTitle isEqualToString:@"Backup"]){
        if([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Backup.txt"]) {
            [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Backup.txt" error:nil];
        }
        FILE *file = fopen("/var/lib/dpkg/status", "r");
        char str[999];
        while(fgets(str, 999, file) != NULL) {
            if(strstr(str, "Name:")) {
                memmove(str, str+6, strlen(str));
                [[NSString stringWithFormat:@"%@%@", [NSString stringWithContentsOfFile:@"/var/mobile/Backup.txt" encoding:NSUTF8StringEncoding error:nil], [NSString stringWithCString:str encoding:NSASCIIStringEncoding]] writeToFile:@"/var/mobile/Backup.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
        }
        fclose(file);
        [self messageWithTitle:@"Done" message:@"The package backup was saved to /var/mobile/Backup.txt"];
    } else if([_aboutButton.currentTitle isEqualToString:@"Manage"]) [self manage];
    else [self messageWithTitle:@"Some random shit happened" message:@"Literally the title."];
}

#pragma mark - Dark/light modes

- (void)switchToDarkMode {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"darkMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    darkMode = YES;
    _navigationView.backgroundColor = [UIColor blackColor];
    _nameLabel.textColor = [UIColor whiteColor];
    _descLabel.textColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor blackColor];
    _tableView.backgroundColor = [UIColor blackColor];
    _tableView2.backgroundColor = [UIColor blackColor];
    _searchField.backgroundColor = [UIColor grayColor];
    _searchField.textColor = [UIColor whiteColor];
    infoView.backgroundColor = [UIColor blackColor];
    [_welcomeWebView stringByEvaluatingJavaScriptFromString:@"document.body.style.background = 'black'; var p = document.getElementsByTagName('p'); for (var i = 0; i < p.length; i++) { p[i].style.color = 'white'; }"];
    _searchField.keyboardAppearance = UIKeyboardAppearanceDark;
}

- (void)switchToLightMode {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"darkMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    darkMode = NO;
    _navigationView.backgroundColor = [UIColor whiteColor];
    _nameLabel.textColor = [UIColor blackColor];
    _descLabel.textColor = [UIColor blackColor];
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView2.backgroundColor = [UIColor whiteColor];
    _searchField.backgroundColor = [UIColor whiteColor];
    _searchField.textColor = [UIColor blackColor];
    infoView.backgroundColor = [UIColor whiteColor];
    [_welcomeWebView reload];
    _searchField.keyboardAppearance = UIKeyboardAppearanceLight;
}

#pragma mark - Navigation methods

- (void)homeAction {
    _nameLabel.text = @"Icy Installer";
    _descLabel.text = @"Where the possibilities are endless";
    [UIView performWithoutAnimation:^{
        if(darkMode) {
            [_aboutButton setTitle:@"Light" forState:UIControlStateNormal];
        } else {
            [_aboutButton setTitle:@"Dark" forState:UIControlStateNormal];
        }
        [_aboutButton layoutIfNeeded];
    }];
    _aboutButton.titleLabel.textColor = coolerBlueColor;
    _welcomeWebView.hidden = NO;
    _depictionWebView.hidden = YES;
    _homeImage.hidden = YES;
    _homeImageSEL.hidden = NO;
    _homeLabel.textColor = coolerBlueColor;
    _sourcesImageSEL.hidden = YES;
    _sourcesImage.hidden = NO;
    _sourcesLabel.textColor = [UIColor grayColor];
    _manageImageSEL.hidden = YES;
    _manageImage.hidden = NO;
    _manageLabel.textColor = [UIColor grayColor];
    _tableView.hidden = YES;
    _tableView2.hidden = YES;
    _searchField.hidden = YES;
}
- (void)sourcesAction {
    _nameLabel.text = @"Sources";
    _descLabel.text = @"Search Cydia package sources";
    [UIView performWithoutAnimation:^{
        [_aboutButton setTitle:@"Manage" forState:UIControlStateNormal];
        [_aboutButton layoutIfNeeded];
    }];
    _aboutButton.titleLabel.textColor = coolerBlueColor;
    _welcomeWebView.hidden = YES;
    _depictionWebView.hidden = YES;
    _homeImageSEL.hidden = YES;
    _homeImage.hidden = NO;
    _homeLabel.textColor = [UIColor grayColor];
    _sourcesImageSEL.hidden = NO;
    _sourcesImage.hidden = YES;
    _sourcesLabel.textColor = coolerBlueColor;
    _manageImageSEL.hidden = YES;
    _manageImage.hidden = NO;
    _manageLabel.textColor = [UIColor grayColor];
    _tableView.hidden = YES;
    _tableView2.hidden = NO;
    _searchField.hidden = NO;
    _searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSForegroundColorAttributeName: [UIColor lightTextColor]}];
}
- (void)manageAction {
    _nameLabel.text = @"Manage";
    _descLabel.text = @"Manage already installed packages";
    [UIView performWithoutAnimation:^{
        [_aboutButton setTitle:@"Backup" forState:UIControlStateNormal];
        [_aboutButton layoutIfNeeded];
    }];
    _aboutButton.titleLabel.textColor = coolerBlueColor;
    _welcomeWebView.hidden = YES;
    _depictionWebView.hidden = YES;
    _homeImageSEL.hidden = YES;
    _homeImage.hidden = NO;
    _homeLabel.textColor = [UIColor grayColor];
    _sourcesImageSEL.hidden = YES;
    _sourcesImage.hidden = NO;
    _sourcesLabel.textColor = [UIColor grayColor];
    _manageImageSEL.hidden = NO;
    _manageImage.hidden = YES;
    _manageLabel.textColor = coolerBlueColor;
    _tableView.hidden = NO;
    _tableView2.hidden = YES;
    _searchField.hidden = YES;
}

#pragma mark - Small but useful bits of code

- (void)messageWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    [alert release];
    _aboutButton.titleLabel.textColor = coolerBlueColor;
}

- (void)makeViewRound:(UIView *)view withRadius:(int)radius {
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = radius;
}

#pragma mark - Search methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.text.length < 4) {
        [self.view endEditing:YES];
        [self messageWithTitle:@"Sorry" message:@"This is too short for Icy to search. Please enter three or more symbols."];
        return YES;
    }
    NSArray *repos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Media/Icy/Repos" error:NULL];
    for (id repo in repos) {
        NSString *fullURL = nil;
        if([repo isEqualToString:@"ModMyi"]) fullURL = @"http://modmyi.saurik.com/";
        else if ([repo isEqualToString:@"Zodttd"]) fullURL = @"http://cydia.zodttd.com/repo/cydia/";
        else if([repo isEqualToString:@"Saurik"]) fullURL = @"http://apt.saurik.com/";
        else if([repo isEqualToString:@"BigBoss"]) fullURL = @"http://apt.thebigboss.org/repofiles/cydia/";
        [self searchForPackage:_searchField.text inRepo:[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@",repo] withFullURLString:fullURL];
    }
    [_tableView2 reloadData];
    [self.view endEditing:YES];
    return YES;
}

- (void)searchForPackage:(NSString *)package inRepo:(NSString *)repo withFullURLString:(NSString *)fullURL {
    char str[999];
    const char *filename = [repo UTF8String];
    FILE *file = fopen(filename, "r");
    BOOL shouldAdd = NO;
    NSString *lastDesc = nil;
    NSString *lastDepiction = nil;
    NSString *lastFilename = nil;
    NSString *lastName = nil;
    while(fgets(str, 999, file) != NULL) {
        if(strstr(str, [package UTF8String]) && strstr(str, "Name:")) shouldAdd = YES;
        if(strstr(str, "Description:")) lastDesc = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Description: " withString:@""];
        if(strstr(str, "Depiction:")) lastDepiction = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Depiction: " withString:@""];
        if(strstr(str, "Filename:")) lastFilename = [NSString stringWithFormat:@"%@%@",fullURL,[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Filename: " withString:@""]];
        if(strstr(str, "Name:")) lastName = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Name: " withString:@""];
        if(strlen(str) < 2 && shouldAdd) {
            [_searchNames addObject:lastName];
            [_searchDescs addObject:lastDesc];
            [_searchDepictions addObject:lastDepiction];
            lastFilename = [lastFilename stringByReplacingOccurrencesOfString:@" " withString:@""];
            lastFilename = [lastFilename stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [_searchFilenames addObject:lastFilename];
            shouldAdd = NO;
        }
    }
    fclose(file);
}

- (void)showDepictionForPackageWithIndexPath:(NSIndexPath *)indexPath {
    packageIndex = (int)indexPath.row;
    [_aboutButton setTitle:@"Install" forState:UIControlStateNormal];
    NSString *depictionString = [_searchDepictions objectAtIndex:indexPath.row];
    depictionString = [depictionString stringByReplacingOccurrencesOfString:@" " withString:@""];
    depictionString = [depictionString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [_depictionWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:depictionString]]];
    _depictionWebView.hidden = NO;
    [self.view bringSubviewToFront:_depictionWebView];
}

#pragma mark - UI Orientation methods

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        [self changeToPortrait];
    }
    else if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        [self changeToLandscape];
    }
}

- (void)changeToPortrait {
    _aboutButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 120,33,75,30);
    _nameLabel.frame = CGRectMake(26,26,[UIScreen mainScreen].bounds.size.width,40);
    _descLabel.frame = CGRectMake(26,76,[UIScreen mainScreen].bounds.size.width,20);
    _welcomeWebView.frame = CGRectMake(0,120,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 200);
    _navigationView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 75, [UIScreen mainScreen].bounds.size.width, 75);
    _homeImage.frame = CGRectMake(30,10,32,32);
    _homeLabel.frame = CGRectMake(27,45,40,10);
    _sourcesImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 16, 10, 32, 32);
    _sourcesLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 25,45,50,10);
    _manageImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 62,10,32,32);
    _manageLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 70,40,50,20);
    _tableView.frame = CGRectMake(13,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 200);
    _tableView2.frame = CGRectMake(13,140,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 220);
    _searchField.frame = CGRectMake(20,120,[UIScreen mainScreen].bounds.size.width - 40,20);
}

- (void)changeToLandscape {
    _aboutButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.height - 120,33,75,30);
    _nameLabel.frame = CGRectMake(26,26,[UIScreen mainScreen].bounds.size.height,40);
    _descLabel.frame = CGRectMake(26,76,[UIScreen mainScreen].bounds.size.height,20);
    _welcomeWebView.frame = CGRectMake(0,120,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 200);
    _navigationView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.width - 75, [UIScreen mainScreen].bounds.size.height, 75);
    _homeImage.frame = CGRectMake(30,10,32,32);
    _homeLabel.frame = CGRectMake(27,45,40,10);
    _sourcesImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.height / 2 - 16, 10, 32, 32);
    _sourcesLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.height / 2 - 25,45,50,10);
    _manageImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.height - 62,10,32,32);
    _manageLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.height - 70,40,50,20);
    _tableView.frame = CGRectMake(13,100,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 200);
    _tableView2.frame = CGRectMake(13,140,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 220);
    _searchField.frame = CGRectMake(20,120,[UIScreen mainScreen].bounds.size.height - 40,20);
}

#pragma mark - Random backend methods
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.urlResponse = response;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.downloadedMutableData appendData:data];
    _progressView.progress = ((100.0/self.urlResponse.expectedContentLength)*self.downloadedMutableData.length)/100;
    if (_progressView.progress == 1) {
        _progressView.hidden = YES;
    } else {
        _progressView.hidden = NO;
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.downloadedMutableData writeToFile:[NSString stringWithFormat:@"/var/mobile/Media/%@",_filename] atomically:YES];
    if([_filename isEqualToString:@"downloaded.deb"]) {
        /*pid_t pid1;
        int status1;
        const char *argv1[] = {"freeze", "-i", "--force-depends", "/var/mobile/Media/downloaded.deb", NULL};
        const char *path[] = {"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games", NULL};
        posix_spawn(&pid1, "/usr/bin/freeze NO PLZ NO", NULL, NULL, (char**)argv1, (char**)path);
        waitpid(pid1, &status1, 0);*/
        [self reloadWithMessage:[self runCommandWithOutput:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/freeze"] withArguments:@[@"-i", @"/var/mobile/Media/downloaded.deb"] errors:NO]];
        [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Media/downloaded.deb" error:nil];
        _nameLabel.text = @"Done";
        _descLabel.text = @"The package was installed";
    }
}

- (void)downloadWithProgressAndURLString:(NSString *)urlString saveFilename:(NSString *)filename1 {
    _filename = filename1;
    self.connectionManager = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: 60.0] delegate:self];
}

-(NSArray *)outputOfCommand:(NSString *)command withArguments:(NSArray *)args {
    NSArray *array = [[NSArray alloc] init];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:command];
    [task setCurrentDirectoryPath:@"/"];
    [task setArguments:args];
    NSPipe *out = [NSPipe pipe];
    NSPipe *err = [NSPipe pipe];
    [task setStandardOutput:out];
    [task setStandardError:err];
    [task launch];
    [task waitUntilExit];
    [task release];
    [array setValue:[[[NSString alloc] initWithData:[[out fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding] autorelease] forKey:@"out"];
    [array setValue:[[[NSString alloc] initWithData:[[err fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding] autorelease] forKey:@"err"];
    [array setValue:[NSString stringWithFormat:@"%d",task.terminationStatus] forKey:@"return"];
    return array;
}
- (NSString *)runCommandWithOutput:(NSString *)command withArguments:(NSArray *)args errors:(BOOL)errors {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:command];
    [task setCurrentDirectoryPath:@"/"];
    [task setArguments:args];
    NSPipe *out = [NSPipe pipe];
    NSPipe *err = [NSPipe pipe];
    [task setStandardOutput:out];
    [task setStandardError:err];
    [task launch];
    [task waitUntilExit];
    [task release];
    if(errors) return [[[NSString alloc] initWithData:[[err fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding] autorelease];
    else return [[[NSString alloc] initWithData:[[out fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding] autorelease];
}

#pragma mark - Random methods
- (void)dealloc {
    [super dealloc];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
