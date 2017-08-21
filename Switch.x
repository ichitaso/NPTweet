#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"
#import <Social/Social.h>
#import <firmware.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import "MediaRemote.h"

@interface SBMainSwitcherViewController
+ (id)sharedInstance;
- (BOOL)isVisible;
- (BOOL)dismissSwitcherNoninteractively;
@end

@interface SBControlCenterController
+ (id)sharedInstance;
- (BOOL)isVisible;
- (void)dismissAnimated:(BOOL)arg1;
@end

@interface SBMediaController
+ (id)sharedInstance;
- (id)nowPlayingAlbum;
- (id)nowPlayingTitle;
- (id)nowPlayingArtist;
- (id)nowPlayingApplication;
- (id)_nowPlayingInfo;
- (BOOL)isPlaying;
@end

@interface SBApplication
- (id)displayName;
@end

@interface SBLockScreenManager
+ (SBLockScreenManager *)sharedInstance;
- (BOOL)isUILocked;
@end

@interface MPUNowPlayingController
@property BOOL isPlaying;
@property (nonatomic,readonly) NSString * nowPlayingAppDisplayID;
@property (nonatomic,readonly) UIImage * currentNowPlayingArtwork;
@property (nonatomic,readonly) NSDictionary * currentNowPlayingInfo;
@end

static UIWindow *window = nil;
static BOOL isPlaying;
static NSString *title;
static NSString *artist;
static NSString *album;
static NSString *appName;
static UIImage *artwork;

static NSString *format;
static NSString *tweetText;
static NSString * const kArtist = @"_ARTIST_";
static NSString * const kSong = @"_SONG_";
static NSString * const kAlbum = @"_ALBUM_";
static NSString * const kApplication = @"_APP_";

extern NSString * SBSCopyLocalizedApplicationNameForDisplayIdentifier(NSString *identifier);

#define PREF_PATH @"/var/mobile/Library/Preferences/com.ichitaso.nptweet.plist"

static void loadSettings()
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
    
    format = [dict objectForKey:@"format"] ? [[dict objectForKey:@"format"] copy] : @"#NowPlaying _SONG_ - _ALBUM_ by _ARTIST_ on _APP_";
}

static void openSettings()
{
    NSString *PO2_PATH = @"/var/mobile/Library/Preferences/net.angelxwind.preferenceorganizer2.plist";
    
    BOOL Tweaks = [[NSDictionary dictionaryWithContentsOfFile:PO2_PATH] objectForKey:@"TweaksName"] != nil;
    BOOL Tweaks1 = [[[NSDictionary dictionaryWithContentsOfFile:PO2_PATH] valueForKey:@"ShowTweaks"] boolValue];
    BOOL Tweaks2 = [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/PreferenceOrganizer2.dylib"];
    BOOL Tweaks3 = [[NSFileManager defaultManager] fileExistsAtPath:PO2_PATH];
    BOOL Tweaks4 = [[NSDictionary dictionaryWithContentsOfFile:PO2_PATH] objectForKey:@"ShowTweaks"] != nil;
    
    NSString *po2Str = @"";
    NSString *po2Url = @"";
    
    if (Tweaks) {
        po2Str = [[[NSDictionary dictionaryWithContentsOfFile:PO2_PATH] objectForKey:@"TweaksName"] copy];
        if (![po2Str isEqualToString:@""]) {
            CFStringRef originalString = (__bridge CFStringRef)po2Str;
            
            CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(
                                                                                kCFAllocatorDefault,
                                                                                originalString,
                                                                                NULL,
                                                                                CFSTR(":/?#[]@!$&'()*+,;="),
                                                                                kCFStringEncodingUTF8);
            
            po2Url = [NSString stringWithFormat:@"prefs:root=%@&path=NPTweet",encodedString];
        } else {
            po2Url = @"prefs:root=Tweaks&path=NPTweet";
        }
    }
    
    if (Tweaks && Tweaks2 && !Tweaks4) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:po2Url]];
    } else if (Tweaks && !Tweaks1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=NPTweet"]];
    } else if (Tweaks && Tweaks1 && Tweaks2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:po2Url]];
    } else if (Tweaks1 && Tweaks2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Tweaks&path=NPTweet"]];
    } else if (Tweaks2 && !Tweaks3) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Tweaks&path=NPTweet"]];
    } else if (Tweaks2 && !Tweaks4) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Tweaks&path=NPTweet"]];
    } else if (Tweaks2 && !Tweaks1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=NPTweet"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=NPTweet"]];
    }
}

%hook MPUNowPlayingController
- (void)_updateCurrentNowPlaying
{
    %orig;
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        title = [self.currentNowPlayingInfo[@"kMRMediaRemoteNowPlayingInfoTitle"] copy];
        if (!title) title = @"";
        
        artist = [self.currentNowPlayingInfo[@"kMRMediaRemoteNowPlayingInfoArtist"] copy];
        if (!artist) artist = @"";
        
        if ([self.currentNowPlayingInfo[@"kMRMediaRemoteNowPlayingInfoAlbum"] length] > 1) {
            album = [self.currentNowPlayingInfo[@"kMRMediaRemoteNowPlayingInfoAlbum"] copy];
        } else {
            album = @"";
        }
        // It does not work on iOS 9.3
        //if (self.currentNowPlayingArtwork != nil) {
        //    artwork = self.currentNowPlayingArtwork;
        //} else {
        //    artwork = nil;
        //}
        
        NSString *appID = [NSString stringWithFormat:@"%@", self.nowPlayingAppDisplayID];
        appName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(appID);
        if ([appName isEqualToString:@"ミュージック"]) appName = @"Music";
        if (!appName) appName = @"iOS";
    });
}

- (BOOL)isPlaying
{
    isPlaying = %orig;
    return isPlaying;
}
%end

@interface NPTweetSwitch : NSObject <FSSwitchDataSource>
@end

@implementation NPTweetSwitch

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
	return @"NPTweet";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
	return FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
    
    loadSettings();
    
    if (window != nil) {
        window.hidden = YES;
        window = nil;
    }
    // Close AppSwitcher
    if ([[%c(SBMainSwitcherViewController) sharedInstance] isVisible]) {
        [[%c(SBMainSwitcherViewController) sharedInstance] dismissSwitcherNoninteractively];
    }
    // Close ControlCenter
    if ([[%c(SBControlCenterController) sharedInstance] isVisible]) {
        [[%c(SBControlCenterController) sharedInstance] dismissAnimated:YES];
    }    
    
    NSString *cStr = [format stringByReplacingOccurrencesOfString:kArtist withString:[NSString stringWithFormat:@"%@", artist]];
    cStr = [cStr stringByReplacingOccurrencesOfString:kSong withString:[NSString stringWithFormat:@"%@", title]];
    cStr = [cStr stringByReplacingOccurrencesOfString:kAlbum withString:[NSString stringWithFormat:@"%@", album]];
    cStr = [cStr stringByReplacingOccurrencesOfString:kApplication withString:appName];
    
    if (isPlaying) {
        tweetText = cStr;
    } else {
        tweetText = @"";
    }
    
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *twitterComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        if (isPlaying) {
            MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
                NSDictionary *dict = (__bridge NSDictionary *)(information);
                if ([dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle] != nil) {
                    NSData *artworkData = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];
                    artwork = [UIImage imageWithData:artworkData];
                    if (artwork) {
                        [twitterComposer addImage:artwork];
                    }
                }
            });
        }
        
        [twitterComposer setInitialText:tweetText];
        [twitterComposer setCompletionHandler:^(SLComposeViewControllerResult result) {
            //[self.parentController dismissModalViewControllerAnimated:YES completion:nil];
        }];
        
        CGRect screenSize = [[UIScreen mainScreen] bounds];
        
        window = [[UIWindow alloc] initWithFrame:screenSize];
        window.windowLevel = UIWindowLevelAlert;
        
        UIView *uv = [[UIView alloc] initWithFrame:screenSize];
        
        [window addSubview:uv];
        
        UIViewController *vc = [[UIViewController alloc] init];
        
        vc.view.frame = [UIScreen mainScreen].applicationFrame;
        
        window.rootViewController = vc;
        [window makeKeyAndVisible];
        
        [vc presentViewController:twitterComposer animated:YES completion:^{
            if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_9_0) {
                [window release];
                window = nil;
            }
        }];
    }
    // Support Polus's bottom shelf
    [[FSSwitchPanel sharedPanel] stateDidChangeForSwitchIdentifier:@"com.ichitaso.nptweet"];
}

- (void)applyAlternateActionForSwitchIdentifier:(NSString *)switchIdentifier
{
    openSettings();
}

@end

%ctor
{
    @autoreleasepool {
        %init;
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        (CFNotificationCallback)loadSettings,
                                        CFSTR("com.ichitaso.nptweet.settingschanged"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorCoalesce);
        
        loadSettings();
    }
}