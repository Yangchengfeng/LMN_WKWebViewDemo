# 仿微信小功能之“投诉”

####**功能选择列表(粗略写)**
1、添加UITableView

```
@property (weak, nonatomic) IBOutlet UITableView *chatDetailView;
```

2、添加数据

```
@property (strong, nonatomic) NSArray *dataArr;

_dataArr = @[@"聊天置顶", @"新消息免打扰", @"聊天室档案", @"设定当前聊天背景", @"查找聊天内容", @"删除聊天记录", @"投诉"];
```

3、设置代理(没有设置代理运行后只能看到一片灰色)
添加: ``` <UITableViewDelegate, UITableViewDataSource> ```


```
_chatDetailView.delegate = self;
_chatDetailView.dataSource = self; // 这个也可以通过连线
```
4、实现代理方法

```
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
if(section == 0 || section == 2) {
return 2;
}
return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
static int staticRow = 0;
UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
if(cell == nil) {
cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
}
cell.textLabel.text = _dataArr[staticRow++];
return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
[tableView deselectRowAtIndexPath:indexPath animated:YES];
if(indexPath.section == 4) {
CFComplaintViewController *complaintVC = [[CFComplaintViewController alloc] init];
[complaintVC loadWebviewWithURL:@"http://www.baidu.com"]; // 这里先用这个url，待更新
UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:complaintVC];
[self presentViewController:naviVC animated:YES completion:nil];
}
}
```

这里要拉取出网页，还得在info.plist添加：

```
<key>NSAppTransportSecurity</key>
<dict>
<key>NSAllowsArbitraryLoads</key>
<true/>
</dict>
```

运行效果：

![这里写图片描述](http://img.blog.csdn.net/20170212233527339?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQveWFuZ19jaGVuZ2Zlbmc=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)


####**进入到投诉界面**
背景：点击“投诉”，跳转到投诉界面

- 加载网页
+ 这里选择用**WKWebView**

1、导入头文件


```
#import <WebKit/WebKit.h>
```
2、添加WKWebview

```
@property (nonatomic, strong) WKWebView *complaintWebview;
```
3、添加获取网页的方法

```

- (void)loadWebviewWithURL:(NSString *)url;
```

```
- (void)loadWebviewWithURL:(NSString *)url {
_complaintWebview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
// 添加进度条(下面会提到)
[_complaintWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
[self.view addSubview:_complaintWebview];
// 添加代理方法(下面会提到)
}

```

- 添加进度条

1、添加进度条

```
@property (nonatomic, strong) UIProgressView *loadProgressView;
@property (nonatomic, assign) NSInteger loadCount; // 用于确认是否完全加载:0表示未加载或者加载失败，1表示加载完成
```

```
// 添加进度条
_loadProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 5)];
_loadProgressView.trackTintColor = [UIColor blackColor];
_loadProgressView.progressTintColor = [UIColor greenColor];
[_complaintWebview addSubview:_loadProgressView];

```

```
// 添加代理方法
[self.complaintWebview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
```

```
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

// 取消监听
- (void)dealloc { 
[_complaintWebview removeObserver:self forKeyPath:@"estimatedProgress"];
}

```

####**与h5进行交互**
背景：当投诉界面是h5写的，如何在用户点击“提交投诉”按钮时返回上个界面

---
####WKWebview(该部分待“与h5进行交互”功能添加再更新详细内容)
####KVO用法
1、添加观察者
2、在观察者中实现监听方法

```
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {}
```

3、移除观察者



[与h5进行交互，待下次更新]