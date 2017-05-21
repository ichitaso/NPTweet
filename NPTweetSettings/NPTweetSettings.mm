#import <UIKit/UIKit.h>
#import <Preferences/PSControlTableCell.h>
#import <Preferences/PSListController.h>

@interface PSListController (NPTweet)
- (void)loadView;
- (void)_returnKeyPressed:(id)arg1;
@end

@interface PSTableCell (NPTweet)
@property(readonly, assign, nonatomic) UILabel *textLabel;
@end

static CGFloat const kHBFPHeaderTopInset = 64.f;
static CGFloat const kHBFPHeaderHeight = 160.f;

@interface NPTweetListController : PSListController <UIActionSheetDelegate>
{
    CGRect topFrame;
    UILabel *bannerTitle;
    UILabel *footerLabel;
    UILabel *titleLabel;
}
- (NSArray *)specifiers;

@property(retain) UIView *bannerView;
@end

@implementation NPTweetListController

- (NSArray *)specifiers
{
    if (_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"NPTweetSettings" target:self] retain];
    }
    return _specifiers;
}

// Header Label
- (void)loadView
{
    [super loadView];
    
    UINavigationItem *navigationItem = self.navigationItem;
    
    CGFloat headerHeight = 0 + kHBFPHeaderHeight;
    CGRect selfFrame = [self.view frame];
    
    _bannerView = [[UIView alloc] init];
    _bannerView.frame = CGRectMake(0, -kHBFPHeaderHeight, selfFrame.size.width, headerHeight);
    _bannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.table addSubview:_bannerView];
    [self.table sendSubviewToBack:_bannerView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,40)];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
    [titleLabel setText:@""];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    navigationItem.titleView = titleLabel;
    titleLabel.textColor = [UIColor colorWithRed:0.06 green:0.13 blue:0.25 alpha:0.6];
    [titleLabel setAlpha:0];
    
    topFrame = CGRectMake(0, -kHBFPHeaderHeight, 414, kHBFPHeaderHeight);
    
    bannerTitle = [[UILabel alloc] init];
    bannerTitle.text = @"NPTweet";
    [bannerTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Ultralight" size:36]];
    bannerTitle.textColor = [UIColor blackColor];
    
    [_bannerView addSubview:bannerTitle];
    
    [bannerTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_bannerView addConstraint:[NSLayoutConstraint constraintWithItem:bannerTitle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_bannerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0f]];
    [_bannerView addConstraint:[NSLayoutConstraint constraintWithItem:bannerTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bannerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:20.0f]];
    bannerTitle.textAlignment = NSTextAlignmentCenter;//NSTextAlignmentRight;
    
    footerLabel = [[UILabel alloc] init];
    footerLabel.text = @"Quickly tweet the song♪";
    [footerLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
    footerLabel.textColor = [UIColor grayColor];
    footerLabel.alpha = 1.0;
    
    [_bannerView addSubview:footerLabel];
    
    [footerLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_bannerView addConstraint:[NSLayoutConstraint constraintWithItem:footerLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_bannerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0f]];
    [_bannerView addConstraint:[NSLayoutConstraint constraintWithItem:footerLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bannerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:60.0f]];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.table setContentInset:UIEdgeInsetsMake(kHBFPHeaderHeight-kHBFPHeaderTopInset,0,0,0)];
    [self.table setContentOffset:CGPointMake(0, -kHBFPHeaderHeight+kHBFPHeaderTopInset)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollOffset = scrollView.contentOffset.y;
    topFrame = CGRectMake(0, scrollOffset, 414, -scrollOffset);
    
    if (scrollOffset > -167 && scrollOffset < -60 && scrollOffset != -150) {
        [titleLabel setText:@"NPTweet"];
        float alphaDegree = -60 - scrollOffset;
        [titleLabel setAlpha:1/alphaDegree];
    } else if (scrollOffset >= -60) {
        [titleLabel setAlpha:1];
   	} else if (scrollOffset < -167) {
        [titleLabel setAlpha:0];
    }
}

- (void)openTwitter:(id)specifier
{
    NSMutableArray *items = [NSMutableArray array];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) {
        [items addObject:@"Open in Tweetbot"];
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
        [items addObject:@"Open in Twitter"];
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"theworld:"]]) {
        [items addObject:@"Open in TheWolrd"];
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetlogix:"]]) {
        [items addObject:@"Open in TweetLogix"];
    }
    
    [items addObject:@"Open in Safari"];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Follow @ichitaso"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    
    for (NSString *buttonTitle in items) {
        [sheet addButtonWithTitle:buttonTitle];
    }
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
    [sheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([option isEqualToString:@"Open in Tweetbot"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/ichitaso"]];
    } else if ([option isEqualToString:@"Open in TheWolrd"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"theworld://scheme/user/?screen_name=ichitaso"]];
    } else if ([option isEqualToString:@"Open in TweetLogix"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetlogix:///home?username=ichitaso"]];
    } else if ([option isEqualToString:@"Open in Twitter"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=ichitaso"]];
    } else if ([option isEqualToString:@"Open in Safari"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/ichitaso/"]];
    }
}

- (void)copyFormat
{
    NSString *str = @"#NowPlaying _SONG_ - _ALBUM_ by _ARTIST_ on _APP_";
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    [pboard setValue:str forPasteboardType:@"public.utf8-plain-text"];
}

// PSEDitCell Return to dismiss
- (void)_returnKeyPressed:(NSNotification *)notification
{
    [self.view endEditing:YES];
    [super _returnKeyPressed:notification];
}

@end

static NSString * const InitialURL = @"http://willfeeltips.appspot.com/depiction/donate.html";

@interface WFTWebBrowserViewController : UIViewController
{
    UIWebView *webView;
}
@property (nonatomic, retain) UIWebView *webView;

@end

@implementation WFTWebBrowserViewController

@synthesize webView;

- (void)dealloc
{
    [webView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    CGRect webFrame = [[UIScreen mainScreen] applicationFrame];
    
    self.webView = [[[UIWebView alloc] initWithFrame:webFrame] autorelease];
    self.webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [self.view addSubview:self.webView];
    
    NSURL *url = [NSURL URLWithString:InitialURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
}

- (void)btnBackPress
{
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
}

- (void)btnNextPress
{
    if (self.webView.canGoForward) {
        [self.webView goForward];
    }
}

@end

@interface WFTWebView : PSViewController
{
    WFTWebBrowserViewController *_viewController;
    UIView *view;
}
@end

@implementation WFTWebView

- (id)initForContentSize:(CGSize)size
{
    CGRect r = [[UIScreen mainScreen] bounds];
    CGFloat w = r.size.width;
    CGFloat h = r.size.height;
    
    if ([[PSViewController class] instancesRespondToSelector:@selector(initForContentSize:)]) {
        self = [super initForContentSize:size];
    } else {
        self = [super init];
    }
    if (self) {
        CGRect frame =  CGRectMake(0, 0, w, h);
        view = [[UIView alloc] initWithFrame:frame];
        _viewController = [[WFTWebBrowserViewController alloc] init];
        _viewController.view.frame = CGRectMake(_viewController.view.frame.origin.x, _viewController.view.frame.origin.y + 44, _viewController.view.frame.size.width, _viewController.view.frame.size.height - 44);
        [view addSubview:_viewController.view];
        
        if ([self respondsToSelector:@selector(navigationItem)]) {
            //Set Back Button
            UIBarButtonItem *rightButton =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                          target:self
                                                          action:@selector(btnBackPress)];
            
            [[self navigationItem] setRightBarButtonItem:rightButton];
            [rightButton release];
        }
    }
    return self;
}

- (UIView *)view
{
    return view;
}

- (CGSize)contentSize
{
    return [view frame].size;
}

- (void)dealloc
{
    [_viewController release];
    [view release];
    [super dealloc];
}

- (void)btnBackPress
{
    [_viewController btnBackPress];
}

@end