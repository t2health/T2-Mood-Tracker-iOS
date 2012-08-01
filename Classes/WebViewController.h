//
//  WebViewControllerViewController.h
//  VAS002
//
//  Created by Roger Reeder on 7/31/12.
//  Copyright (c) 2012 GDIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate> {
    IBOutlet UIWebView *webView;
    
    //NSString *url;
    //NSString *baseUrl;
}
@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (void)loadPDFFile;
@end
