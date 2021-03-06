//
//  UILoginView.m
//  Platform
//
//  Created by Bobby Gill on 11/9/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UILoginView.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "Macros.h"
#import "GetAuthenticatorResponse.h"
#import "CallbackResult.h"
#import "NSStringGUIDCategory.h"
#import "ImageManager.h"
#import "AuthenticationManager.h"
#import "BaseViewController.h"
#import "shAntiAppDelegate.h"
#define kMinimumBusyWaitTime    1
#define kMaximumBusyWaitTimePutAuthenticator    30
#define kMaximumBusyWaitTimeFacebookLogin       30
#define kTimeToShowCompleteIndicator 2


@implementation UILoginView
@synthesize parentViewController = m_parentViewController;
@synthesize authenticateWithFacebook = m_authenticateWithFacebook;
@synthesize authenticateWithTwitter = m_authenticateWithTwitter;
@synthesize onFailCallback = m_onFailCallback;
@synthesize fbPictureRequest = m_fbPictureRequest;
@synthesize fbProfileRequest = m_fbProfileRequest;
@synthesize twitterEngine    = __twitterEngine;
@synthesize onSuccessCallback = m_onSuccessCallback;

#pragma mark - Properties
- (SA_OAuthTwitterEngine*) twitterEngine {
    if (__twitterEngine != nil) {
        return __twitterEngine;
    }
    ApplicationSettings* settingsObjects = [[ApplicationSettingsManager instance] settings];
    __twitterEngine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
	__twitterEngine.consumerKey = settingsObjects.twitter_consumerkey;
	__twitterEngine.consumerSecret = settingsObjects.twitter_consumersecret;
    
    return __twitterEngine;
    
}

- (id)initWithFrame:(CGRect)frame withParent:(BaseViewController*)parentViewController
{
    self = [super initWithFrame:frame];
    if (self) {
        self.parentViewController = parentViewController;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    self.parentViewController = nil;
    [super dealloc];
    
}

-(void) beginTwitterAuthentication {
    //we check to see if the user has supplied their Twitter accessToken, if not, then we move to the next page
    //and display a twitter authn screen
    NSString* activityName = @"UILoginView.beginTwitterAuthentication:";
    AuthenticationContext* newContext = [[AuthenticationManager instance]contextForLoggedInUser];
    
    
    if (newContext != nil) 
    {
        NSString* message = [NSString stringWithFormat:@"Beginning twitter authentication"];
        LOG_LOGINVIEWCONTROLLER(0,@"%@%@",activityName,message);
        
        UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: self.twitterEngine delegate: self];
        
        if (controller) 
            //display twitter view controller for authentication
            [self.parentViewController presentModalViewController: controller animated: YES];
        else {
            //user is already authenticated with Twitter
            [self.twitterEngine sendUpdate: [NSString stringWithFormat: @"Already Updated. %@", [NSDate date]]];
            LOG_LOGINVIEWCONTROLLER(0, @"%@ user already logged into twitter, skipping authentication",activityName);
            [self dismissWithResult:YES];
        }
        
    }
    else {
        //error condition
        LOG_LOGINVIEWCONTROLLER(1, @"%@Cannot authenticate to Twitter without being authenticated to Facebook",activityName);
        [self dismissWithResult:NO];
    }
    
    
}


- (void) dismissWithResult:(BOOL)result {
    if (result) {
        //authentication action completed successfully
        if (self.onSuccessCallback != nil) {
            //fire success callback
            Response* response = [[Response alloc]init];
            response.didSucceed = [NSNumber numberWithBool:YES];
            self.onSuccessCallback.fireOnMainThread = YES;
            [self.onSuccessCallback fireWithResponse:response];
            [response release];
        }
    }
    else {
         //authentication action failed
        if (self.onFailCallback != nil) {
            //fire fail callback
            Response* response = [[Response alloc]init];
            response.didSucceed = [NSNumber numberWithBool:NO];
            self.onFailCallback.fireOnMainThread = YES;
            [self.onFailCallback fireWithResponse:response];
            [response release];
        }
       
    }
    
    
    [self removeFromSuperview];
}

- (void) checkStatusAndDismiss {
    //called when authentication is complete
    
    NSString* activityName = @"UILoginView.checkStatusAndDismiss:";
    BOOL result = YES;
   
    shAntiAppDelegate* appDelegate = (shAntiAppDelegate*) [[UIApplication sharedApplication]delegate];
    Facebook* facebook = appDelegate.facebook;
    
    if (self.authenticateWithFacebook) {
        
        if (![facebook isSessionValid]) {
            //we need to dismiss with failure since we were unable to login into facebok
            LOG_LOGINVIEWCONTROLLER(1, @"%@Login with Facebook failed.",activityName);
            result = NO;
        }
    }
    AuthenticationContext* userContext = [[AuthenticationManager instance]contextForLoggedInUser];
    if (self.authenticateWithTwitter && ![userContext hasTwitter]) {
        //twitter authentication failed or hasnt happened, we begin twitter auth
        [self performSelectorOnMainThread:@selector(beginTwitterAuthentication) withObject:nil waitUntilDone:NO];
        
        
    }
    else {
        [self dismissWithResult:result];
    }
    
}
-(void) beginFacebookAuthentication {
  //  NSString* activityName = @"UILoginView.beginFacebookAuthentication:";
    //now we need to grab their facebook authentication data, and then log them into our app    
    NSArray *permissions = [NSArray arrayWithObjects:@"offline_access",@"email", @"publish_actions",@"publish_stream",@"user_about_me", nil];
    shAntiAppDelegate* appDelegate = (shAntiAppDelegate*)[[UIApplication sharedApplication]delegate];
    Facebook* facebook = appDelegate.facebook;
    
    [facebook authorize:permissions delegate:self];
    
}

#pragma mark - instance methods
- (void) authenticate:(BOOL)facebook 
          withTwitter:(BOOL)twitter 
     onSuccessCallback:(Callback *)onSuccessCallback 
    onFailCallback:(Callback *)onFailCallback 
{
    NSString* activityName = @"UILoginView:authenticate:";
    //we start with facebook authentication
    AuthenticationManager* authnManager = [AuthenticationManager instance];
    self.authenticateWithTwitter = twitter;
    self.authenticateWithFacebook = facebook;
    self.onFailCallback = onFailCallback;
    self.onSuccessCallback = onSuccessCallback;
    
    if (self.authenticateWithFacebook) {
        //authenticate with facebook
        
        if (![authnManager isUserAuthenticated]) {
            //authenticate with facebook
            [self beginFacebookAuthentication];
        }
        else {
            LOG_LOGINVIEWCONTROLLER(0, @"%@User is already authenticated with Facebook",activityName);
            [self checkStatusAndDismiss];
        }

    }
    
    else if (self.authenticateWithTwitter) {
        if (![authnManager isUserAuthenticated]) {
            //user is not authenticated in our app, cannot proceed with twitter auth
            LOG_LOGINVIEWCONTROLLER(1,@"%@must first login with Facebook",activityName);
            self.authenticateWithFacebook = YES;
            [self beginFacebookAuthentication];
           
        }
        else {
            //user is authenticated, we can proceed with authentication
                //authenticate with twitter 
            [self beginTwitterAuthentication];
           
       
            
        }
    }
}

#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSString* activityName = @"UILoginView.storeCachedTwitterOAuthData:";
    NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
    
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
    
    //now we need to update the user's object and twitter information
    
    ResourceContext* resourceContext = [ResourceContext instance];
    
    NSArray* components = [data componentsSeparatedByString:@"&"];
    if ([components count] == 4) {
        
        NSString* oAuthToken = [[[components objectAtIndex:0]componentsSeparatedByString:@"="]objectAtIndex:1];
        NSString* oAuthTokenSecret = [[[components objectAtIndex:1]componentsSeparatedByString:@"="]objectAtIndex:1];
        NSString* twitterUserName = [[[components objectAtIndex:3]componentsSeparatedByString:@"="]objectAtIndex:1];
        
        //need to dismiss the Twitter view controller here
        [self.parentViewController dismissModalViewControllerAnimated:YES];
        
        //display progress indicator
        [self.parentViewController showProgressBar:@"Communicating with Twitter..." withCustomView:nil withMaximumDisplayTime:[NSNumber numberWithInt:kMaximumBusyWaitTimePutAuthenticator]];
        
        Callback* callback = [[Callback alloc] initWithTarget:self withSelector:@selector(onUpdateAuthenticatorCompleted:)];
        
        [resourceContext updateAuthenticatorWithTwitter:twitterUserName 
                                        withAccessToken:oAuthToken 
                                  withAccessTokenSecret:oAuthTokenSecret 
                                         withExpiryDate:@"" 
                                         onFinishNotify:callback];
        [callback release];
    }
    else {
        //error condition
        //need to dismiss the Twitter view controller here
        LOG_LOGINVIEWCONTROLLER(1, @"%@Twitter login view controller returned the wrong number of result components: %d",activityName,[components count]);
        [self.parentViewController dismissModalViewControllerAnimated:YES];
        [self dismissWithResult:NO];
    }
    
    
    
    
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
    NSString* activityName = @"UILoginView.cachedTwitterOAuthDataForUsername:";
    LOG_LOGINVIEWCONTROLLER(0, @"%@ called for username %@",activityName,username);
    return nil;
}
- (void) twitterOAuthConnectionFailedWithData: (NSData *) data 
{
    NSString* activityName = @"UILoginView.twitterOAuthConnectionFailedWithData:";
    LOG_LOGINVIEWCONTROLLER(1,@"%@Twitter connection failed",activityName);
                            
}

#pragma mark - FBRequestDelegate
- (void) request:(FBRequest *)request didLoad:(id)result {
    NSString* activityName = @"LoginViewController.request:didLoad:";
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    
    shAntiAppDelegate* appDelegate = (shAntiAppDelegate*)[[UIApplication sharedApplication]delegate];
    Facebook* facebook = appDelegate.facebook;
    ResourceContext* resourceContext = [ResourceContext instance];
    
    if (request == self.fbProfileRequest) {
        LOG_LOGINVIEWCONTROLLER(0, @"%@%@",activityName,@"Facebook profile downloaded for logged in user");
        NSString* facebookIDString = [result valueForKey:ID];
        NSNumber* facebookID = [facebookIDString numberValue];
        NSString* displayName = [result valueForKey:NAME];
        NSString* email = [result valueForKey:EMAIL];
        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onGetAuthenticationContextDownloaded:)];
        
        
        LOG_LOGINVIEWCONTROLLER(0, @"%@:Requesting new authenticator from service withName:%@, withEmail:%@, withFacebookAccessToken:%@",activityName,displayName,email,facebook.accessToken);
        [resourceContext getAuthenticatorToken:facebookID withName:displayName withEmail:email withFacebookAccessToken:facebook.accessToken withFacebookTokenExpiry:facebook.expirationDate withDeviceToken:appDelegate.deviceToken onFinishNotify:callback];
        [callback release];
        
    }
    else if (request == self.fbPictureRequest) {
//        User* userObject = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID];
//        
//        AuthenticationContext* currentContext = [authenticationManager contextForLoggedInUser];
//        
//        if (userObject != nil && currentContext != nil) {
//            UIImage* image = [UIImage imageWithData:result];
//            LOG_LOGINVIEWCONTROLLER(0,@"%@Download of Facebook profile complete, saving photo to phone",activityName);
//            //we need to save this image to the local file system
//            ImageManager* imageManager = [ImageManager instance];
//            NSString* path = [imageManager saveImage:image withFileName:currentContext.facebookuserid];
//            
//            //save the path on the user object and commit            
//            userObject.thumbnailurl = path;
//            [resourceContext save:YES onFinishCallback:nil trackProgressWith:nil];
//        }
    }
}

- (void) request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSString* activityName = @"UILoginView.fbRequestDidFailWithError:";
    LOG_SECURITY(0, @"%@ facebook request failed with error:%@",activityName,[error localizedDescription]);
}

#pragma mark - FBSessionDelegate
- (void) fbDidLogin {
    NSString* activityName = @"UILoginView.fbDidLogin:";
    shAntiAppDelegate* appDelegate = (shAntiAppDelegate*)[[UIApplication sharedApplication]delegate];
    Facebook* facebook = appDelegate.facebook;
    
    //this method is called upon the completion of the authorize operation
    NSString* message = [NSString stringWithFormat:@"Facebook login successful, accessToken:%@, expiryDate:%@",facebook.accessToken,facebook.expirationDate];    
    LOG_LOGINVIEWCONTROLLER(0,@"%@%@",activityName,message);
    
    //show the progress bar
    [self.parentViewController showProgressBar:@"Logging in..." withCustomView:nil withMaximumDisplayTime:[NSNumber numberWithInt:kMaximumBusyWaitTimeFacebookLogin]];
    
    //the user has authorized our app, now we get his user object to complete authentication
    self.fbProfileRequest = [facebook requestWithGraphPath:@"me" andDelegate:self];
    

    LOG_LOGINVIEWCONTROLLER(0,@"%@%@",activityName,@"requesting user profile details from Facebook");
    
    
}

- (void) fbDidNotLogin:(BOOL)cancelled {
    //authenticate with facebook failed
    NSString* activityName = @"UILoginView.fbDidNotLogin:";
    LOG_SECURITY(0, @"%@user did not complete facebook authentication page",activityName);
    [self dismissWithResult:NO];
    
}

#pragma mark - Async Event Handlers
- (void) saveAuthenticatorResponse:(GetAuthenticatorResponse*)response {
    NSString* activityName = @"UILoginView.saveAuthenticatorResponse:";
    ResourceContext* resourceContext = [ResourceContext instance];
    if (response.didSucceed) {
        AuthenticationManager* authenticationManager = [AuthenticationManager instance];
        
        AuthenticationContext* newContext = response.authenticationcontext;
        User* returnedUser = response.user;
        
        Resource* existingUser = [resourceContext resourceWithType:USER withID:returnedUser.objectid];
        
        //save the user object that is returned to us in the database
        if (existingUser != nil) {
            [existingUser refreshWith:returnedUser];
        }
        else {
            //need to insert the new user into the resource context
            [resourceContext insert:returnedUser];
        }
        [resourceContext save:YES onFinishCallback:nil trackProgressWith:nil];
        
        BOOL contextSavedToKeyChain = [authenticationManager saveAuthenticationContextToKeychainForUser:newContext.userid withAuthenticationContext:newContext];
        
        
        
        if (contextSavedToKeyChain) {
            [authenticationManager loginUser:newContext.userid withAuthenticationContext:newContext isSavedLogin:NO];
            [self checkStatusAndDismiss];
        }
        else {
            //unable to login user due to inability to save the credential to key chain
            //raise global error
            LOG_LOGINVIEWCONTROLLER(1,@"%@Unable to save user credential to key chain, login failure",activityName);
            [self dismissWithResult:NO];
        }
    }
    else {
        LOG_LOGINVIEWCONTROLLER(1,@"%@Login with Bahndr servers failed",activityName);
        [self dismissWithResult:NO];
    }

}
- (void) onUpdateAuthenticatorCompleted:(CallbackResult*)result {
    //we process this response on a background thread to prevent it from interfering with
    //the progress indicator
    [self.parentViewController hideProgressBar];
    GetAuthenticatorResponse* response = result.response;
    [self saveAuthenticatorResponse:response];
    [self dismissWithResult:[response.didSucceed boolValue]];
}

- (void) onGetAuthenticationContextDownloaded:(CallbackResult*)result 
{
   // NSString* activityName = @"UILoginView.onGetAuthenticationContextDownloaded:";
    GetAuthenticatorResponse* response = (GetAuthenticatorResponse*)result.response;
    
    //dismiss the progress bar
    [self.parentViewController hideProgressBar];
    [self saveAuthenticatorResponse:response];

}



@end
