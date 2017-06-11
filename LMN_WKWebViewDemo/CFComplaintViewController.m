//
//  CFComplaintViewController.m
//  LMN_WKWebViewDemo
//
//  Created by 阳丞枫 on 17/2/12.
//  Copyright © 2017年 chengfengYang. All rights reserved.
//

#import "CFComplaintViewController.h"
#import <WebKit/WebKit.h>

@interface CFComplaintViewController () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *complaintWebview;
@property (nonatomic, strong) UIProgressView *loadProgressView;
@property (nonatomic, assign) NSInteger loadCount;

@end

@implementation CFComplaintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)loadWebviewWithURL:(NSString *)url {
    _complaintWebview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _loadProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 5)];
    _loadProgressView.trackTintColor = [UIColor blackColor];
    _loadProgressView.progressTintColor = [UIColor greenColor];
    [_complaintWebview addSubview:_loadProgressView];
    [_complaintWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    _complaintWebview.navigationDelegate = self;
    [self.view addSubview:_complaintWebview];
    [self.complaintWebview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    WKWebView *webview = (WKWebView *)object;
    if (webview == self.complaintWebview && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            self.loadProgressView.hidden = YES;
            [self.loadProgressView setProgress:0 animated:NO];
        }else {
            self.loadProgressView.hidden = NO;
            [self.loadProgressView setProgress:newprogress animated:YES];
        }
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if([navigationAction.request.URL.query isEqual:@"complaintpage"]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
}

- (void)setLoadCount:(NSInteger)loadCount {
    _loadCount = loadCount;
    
    if (loadCount == 0) {
        self.loadProgressView.hidden = YES;
        [self.loadProgressView setProgress:0 animated:NO];
    }else {
        self.loadProgressView.hidden = NO;
        CGFloat oldP = self.loadProgressView.progress;
        CGFloat newP = (1.0 - oldP) / (loadCount + 1) + oldP;
        if (newP > 0.95) {
            newP = 0.95;
        }
        [self.loadProgressView setProgress:newP animated:YES];
        
    }
}
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.loadCount ++;
}
// 内容返回时
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    self.loadCount --;
}
// 加载失败
- (void)webView:(WKWebView *)webView didFailNavigation: (null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    self.loadCount --;
    NSLog(@"%@",error);
}

- (void)dealloc {
    [_complaintWebview removeObserver:self forKeyPath:@"estimatedProgress"];
}

@end
