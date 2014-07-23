//
//  ViewController.m
//  MySafari
//
//  Created by Iván Mervich on 7/23/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIWebViewDelegate, UITextFieldDelegate, UIScrollViewDelegate>
@property IBOutlet UIWebView *myWebView;
@property (weak, nonatomic) IBOutlet UITextField *myURLTextField;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *clearURLButton;

@property float lastOffsetY;
@property UIActivityIndicatorView *spinner;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lastOffsetY = 0.0f;
    self.myWebView.scrollView.delegate = self;

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);

//    [self debugMobileMakersURL];
}

- (void)debugMobileMakersURL {

    self.myURLTextField.text = @"mobilemakers.co";
    [self checkForHttpPrefix];

    NSURL *url = [NSURL URLWithString:self.myURLTextField.text];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.myWebView loadRequest:urlRequest];
}

// enter key pressed
- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [self checkForHttpPrefix];

    NSURL *url = [NSURL URLWithString:self.myURLTextField.text];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.myWebView loadRequest:urlRequest];

    [textField resignFirstResponder];

    return YES;
}

// go back in the web view
- (IBAction)onBackButtonPressed:(id)sender {
    [self.myWebView goBack];
}
// go forward in the web view
- (IBAction)onForwardButtonPressed:(id)sender {
    [self.myWebView goForward];
}
// stop loading the web view
- (IBAction)onStopLoadingButtonPressed:(id)sender {
    [self.myWebView stopLoading];
}
// reload the web view
- (IBAction)onReloadButtonPressed:(id)sender {
    [self.myWebView reload];
}
// new tab?
- (IBAction)onPlusButtonPressed:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] init];
    alertView.message = @"Comming soon!";
    [alertView addButtonWithTitle:@"OK"];

    [alertView show];
}
// clear URL
- (IBAction)onClearURLButtonPressed:(id)sender {
    self.myURLTextField.text = nil;
}

// check if back and forward buttons are enabled
- (void)webViewDidFinishLoad:(UIWebView *)webView {

    // set button states
    self.backButton.enabled = self.myWebView.canGoBack;
    self.forwardButton.enabled = self.myWebView.canGoForward;

    // set textfield current url
    self.myURLTextField.text = self.myWebView.request.URL.absoluteString;

    // set the page title on the nav item
    self.navigationItem.title = [self.myWebView stringByEvaluatingJavaScriptFromString:@"document.title"];

    // remove spinner
    [self stopAndRemoveSpinner];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    // show spinner
    [self startAndShowSpinner];
    // show network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // hide spinner
    [self stopAndRemoveSpinner];
    // hide network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"Error";
    alert.message = error.localizedDescription;

    [alert addButtonWithTitle:@"OK"];
    [alert show];
}

- (void)startAndShowSpinner {
    [self.spinner startAnimating];
    [self.navigationController.view addSubview:self.spinner];
}

- (void)stopAndRemoveSpinner {
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
}

// check if the url has the 'http://' prefix
- (void)checkForHttpPrefix {
    // original URL
    NSString *enteredURL = self.myURLTextField.text;

    // check if it's a valid url
    if ([enteredURL length] < 7) {
        self.myURLTextField.text = [NSString stringWithFormat:@"http://%@", enteredURL];
        return;
    }

    // substring where the prefix must go
    NSString *prefix = [enteredURL substringToIndex:7];

    // if there is no http:// prefix, add it
    if (![prefix isEqualToString:@"http://"]) {
        self.myURLTextField.text = [NSString stringWithFormat:@"http://%@", enteredURL];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // save the last y position
    self.lastOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    UITextField *urlTextField = self.myURLTextField;
    UIButton *clearUrlButton = self.clearURLButton;

    // if it's going up show the textfield, otherwise hide it
    if (scrollView.contentOffset.y < self.lastOffsetY) {
        // show textfield
        if (urlTextField.frame.origin.y < 70) {
            urlTextField.frame = CGRectMake(urlTextField.frame.origin.x, urlTextField.frame.origin.y + 4, urlTextField.frame.size.width, urlTextField.frame.size.height);
            clearUrlButton.frame = CGRectMake(clearUrlButton.frame.origin.x, clearUrlButton.frame.origin.y + 4, clearUrlButton.frame.size.width, clearUrlButton.frame.size.height);
        }


    } else {
        // hide textfield
        if (urlTextField.frame.origin.y > 35) {
            urlTextField.frame = CGRectMake(urlTextField.frame.origin.x, urlTextField.frame.origin.y - 4, urlTextField.frame.size.width, urlTextField.frame.size.height);
            clearUrlButton.frame = CGRectMake(clearUrlButton.frame.origin.x, clearUrlButton.frame.origin.y - 4, clearUrlButton.frame.size.width, clearUrlButton.frame.size.height);
        }

    }
}


@end
