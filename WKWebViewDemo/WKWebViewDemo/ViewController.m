//
//  ViewController.m
//  WKWebViewDemo
//
//  Created by feiyanghe on 2019/6/19.
//  Copyright © 2019 feiyanghe. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
@interface ViewController ()<WKScriptMessageHandler, WKNavigationDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,assign) CGFloat webCellHeight;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.webCellHeight = 0.0;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://azwap.ysh250.com/html/goodsXqImg.html?GoodsId=3521"]]];
}

#pragma mark - tableView delegate and dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger num;
    num = 1;
    return num;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num;
    num = 1;
    return num;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height;
    height = 0.0000000001;
    return height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    height = self.webCellHeight;
    return height;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"cell";
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell==nil)
    {
        cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [cell.contentView addSubview:self.webView];
    return cell;
}

#pragma mark ----------------- WKNavigationDelegate
//开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"加载中。。。");
}

//加载错误时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"加载失败");
}

//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"加载完成");
    NSString *js1 = @"function getImagesHeight(screenWidth){var imagesHeight = 0;for(i=0;i <document.images.length;i++){var image = document.images[i];var imgW = image.width;var imgH = image.height;var realImgH = screenWidth*imgH/imgW;imagesHeight += realImgH;} window.webkit.messageHandlers.getWebHeight.postMessage(imagesHeight)}";
    NSString *js2 = [NSString stringWithFormat:@"getImagesHeight(%f)",[UIScreen mainScreen].bounds.size.width];
    [self.webView evaluateJavaScript:js1 completionHandler:^(id item, NSError * _Nullable error) {
        // Block中处理是否执行JS错误的代码
    }];
    
    [self.webView evaluateJavaScript:js2 completionHandler:^(id item, NSError * _Nullable error) {
        // Block中处理是否执行JS错误的代码
    }];
}
#pragma mark ----------------- WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"%@",message.body);
    NSLog(@"%@",message.name);
    if ([message.name isEqualToString:@"getWebHeight"]) {
        NSString *body = [NSString stringWithFormat:@"%@",message.body];
        CGFloat webH = body.floatValue;
        self.webCellHeight = webH;
        self.webView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.webCellHeight);
        [self.tableView reloadData];
    }
    
}
#pragma mark ----------------- Custom Methods

#pragma mark ----------------- Lazy loading
- (WKWebView *)webView{
    if (_webView == nil) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) configuration:config];
        _webView.scrollView.scrollEnabled = NO;
        _webView.navigationDelegate = self;
        WKUserContentController *userCC = config.userContentController;
        //意思是网页中需要传递的参数是通过这个JS中的showMessage方法来传递的
        [userCC addScriptMessageHandler:self name:@"getWebHeight"];
    }
    return _webView;
}

@end
