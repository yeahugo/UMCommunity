//
//  UMComUserRecommendViewController.m
//  UMCommunity
//
//  Created by umeng on 15-3-31.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComUserRecommendViewController.h"
#import "UMComUser.h"
#import "UMComAction.h"
#import "UMComBarButtonItem.h"
#import "UMComShowToast.h"
#import "UIViewController+UMComAddition.h"

@interface UMComUserRecommendViewController ()<UMComClickActionDelegate>

@property (nonatomic, strong) UMComPullRequest *fetchRequest;

@property (nonatomic, strong) UILabel *noRecommendTip;

@property (nonatomic, strong) UIActivityIndicatorView *refreshIndicatorView;


@end

@implementation UMComUserRecommendViewController

- (id)initWithCompletion:(LoadDataCompletion)completion
{
    self = [super init];
    if (self) {
        self.completion = completion;
        
        UMComBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithTitle:UMComLocalizedString(@"FinishStep",@"完成") target:self action:@selector(onClickNext)];
        [self.navigationItem setRightBarButtonItem:rightButtonItem];

    }
    return self;
}

- (void)onClickNext
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.completion) {
            self.completion(nil,nil);
        }        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UMComUserRecommendCell" bundle:nil] forCellReuseIdentifier:@"UserRecommendCell"];
    self.tableView.rowHeight = 60.0f;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    if (self.userDataSourceType == UMComSearchUser) {
        [self setBackButtonWithImage];
        [self setTitleViewWithTitle:UMComLocalizedString(@"user_search", @"搜索用户")];
        [self.indicatorView removeFromSuperview];
        [self.tableView reloadData];
 
    }else if (self.userDataSourceType == UMComLikeUser){
        [self setBackButtonWithImage];
        [self setTitleViewWithTitle:UMComLocalizedString(@"like_user", @"喜欢用户")];
        [self.indicatorView removeFromSuperview];
        [self.tableView reloadData];
    }else{
        self.refreshIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.refreshIndicatorView.frame = CGRectMake(self.view.frame.size.width/2-20, -40, 40, 40);
        [self.tableView addSubview:self.refreshIndicatorView];
        [self refreshAllData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)refreshAllData
{
    [self.indicatorView startAnimating];
    if (self.userDataSourceType == UMComReccommentUser) {
        self.fetchRequest = [[UMComRecommendUsersRequest alloc]initWithCount:BatchSize];
        [self requestRecommendUsers];
        [self setBackButtonWithImage];
        [self setTitleViewWithTitle: UMComLocalizedString(@"user_recommend", @"用户推荐")];
        
    }else if(self.userDataSourceType == UMComTopicHotUser){
        self.fetchRequest = [[UMComRecommendTopicUsersRequest alloc]initWithTopicId:self.topicId count:BatchSize];
        [self requestRecommendUsers];
    }
}

- (void)setUserDataSourceType:(UMComUserType)userDataSourceType
{
    _userDataSourceType = userDataSourceType;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"UserRecommendCell";
    UMComUserRecommendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.delegate = self;
    UMComUser *user = self.userList[indexPath.row];
    [cell displayWithUser:user userType:self.userDataSourceType];
    __weak UMComUserRecommendViewController *weakSelf = self;
    cell.onClickAtCellViewAction = ^(UMComUser *user){
        [weakSelf didSelectUser:user];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMComUser *user = self.userList[indexPath.row];
    UIViewController *paramViewController = self;
    if (self.viewController) {
        paramViewController = self.viewController;
    }
    [[UMComUserCenterAction action] performActionAfterLogin:user viewController:paramViewController completion:nil];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.userDataSourceType != UMComSearchUser) {
        if (scrollView.contentOffset.y < -65) {
            self.refreshIndicatorView.center = CGPointMake(scrollView.frame.size.width/2, -40);
            [self.refreshIndicatorView startAnimating];
            [self refreshAllData];
        }
    }

}

#pragma mark - private method
- (void)didSelectUser:(UMComUser *)user
{
    UIViewController *paramViewController = self;
    if (self.viewController) {
        paramViewController = self.viewController;
    }
    [[UMComUserCenterAction action] performActionAfterLogin:user viewController:paramViewController completion:nil];
}


- (void)requestRecommendUsers
{
    __weak UMComUserRecommendViewController *weakSelf = self;
    [self.fetchRequest fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [weakSelf.refreshIndicatorView stopAnimating];
        [weakSelf.indicatorView stopAnimating];
        if (data.count > 0) {
            if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
                weakSelf.footView.backgroundColor = TableViewSeparatorRGBColor;
            }
            weakSelf.userList = data;
            weakSelf.noRecommendTip.hidden = YES;
        }else{
            if (error) {
                weakSelf.noRecommendTip.hidden = YES;
            }else{
                if (weakSelf.noRecommendTip == nil) {
                    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, weakSelf.view.frame.size.height/2-80, weakSelf.view.frame.size.width, 40)];
                    label.backgroundColor = [UIColor clearColor];
                    label.text = UMComLocalizedString(@"Tehre is no recommend user", @"暂时没有推荐用户咯");
                    label.textAlignment = NSTextAlignmentCenter;
                    weakSelf.noRecommendTip = label;
                    [weakSelf.tableView addSubview:label];
                } else {
                    weakSelf.noRecommendTip.hidden = NO;
                }
            }
            [UMComShowToast fetchRecommendUserFail:error];
        }
        [weakSelf.tableView reloadData];
    }];
}



#pragma mark - UMComClickActionDelegate
- (void)customObj:(UMComUserRecommendCell *)cell clickOnFollowUser:(UMComUser *)user
{
    UIViewController *paramViewController = self;
    if (self.viewController) {
        paramViewController = self.viewController;
    }
    [[UMComAction action] performActionAfterLogin:nil viewController:paramViewController completion:^(NSArray *data, NSError *error) {
        [cell focusUserAfterLoginSucceed];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
