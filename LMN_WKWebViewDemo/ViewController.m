//
//  ViewController.m
//  LMN_WKWebViewDemo
//
//  Created by 阳丞枫 on 17/2/12.
//  Copyright © 2017年 chengfengYang. All rights reserved.
//

#import "ViewController.h"
#import "CFComplaintViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *chatDetailView;
@property (strong, nonatomic) NSArray *dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _dataArr = @[@"聊天置顶", @"新消息免打扰", @"聊天室档案", @"设定当前聊天背景", @"查找聊天内容", @"删除聊天记录", @"投诉"];
    _chatDetailView.delegate = self;
    _chatDetailView.dataSource = self;
}

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
        [complaintVC loadWebviewWithURL:@"https://yangchengfeng.github.io/LMN_Project/LMN_ComplaintPage/CFComplaintPage.html?complaintpage"];
        UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:complaintVC];
        [self presentViewController:naviVC animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
