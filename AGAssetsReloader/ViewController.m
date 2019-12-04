//
//  ViewController.m
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/8/4.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "ViewController.h"
#import "AGMainTableViewController.h"
#import "AGMainImageCell.h"
#import "AGMainMessageCell.h"
#import "AGAssetsModuleA.h"
#import "AGThemePackCollectionViewController.h"
#import "AGLanguageCollectionViewController.h"

@interface ViewController ()
<UITableViewDataSource, UITableViewDelegate>

/** table view */
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:AGMainImageCell.class forCellReuseIdentifier:NSStringFromClass(AGMainImageCell.class)];
    [self.tableView registerClass:AGMainMessageCell.class forCellReuseIdentifier:NSStringFromClass(AGMainMessageCell.class)];
    
    
    [self setup];
    
}

- (void)setup
{
    self.title = @"首页";
    
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *themeItem = [[UIBarButtonItem alloc] initWithTitle:@"主题" style:UIBarButtonItemStyleDone target:self action:@selector(themeItemClick:)];
    UIBarButtonItem *languageItem = [[UIBarButtonItem alloc] initWithTitle:@"语言" style:UIBarButtonItemStyleDone target:self action:@selector(languageItemClick:)];
    self.navigationItem.rightBarButtonItems = @[themeItem, languageItem];
    
    // 添加主题、语言更换的响应
    [AGAssetsModuleA ag_addLanguageReloadResponder:self];
    [AGAssetsModuleA ag_addThemeReloadResponder:self];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    
    [self.tableView reloadData];
}

#pragma mark - ----------- Event Methods -----------
- (void)themeItemClick:(UIBarButtonItem *)item
{
    AGThemePackCollectionViewController *vc = [AGThemePackCollectionViewController themePackCollectionViewController];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)languageItemClick:(UIBarButtonItem *)item
{
    AGLanguageCollectionViewController *vc = [AGLanguageCollectionViewController languageCollectionViewController];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 24;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AGMainImageCell *cell;
    if ( indexPath.row % 2 == 0 ) {
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(AGMainImageCell.class)];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(AGMainMessageCell.class)];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AGMainTableViewController *vc = [[AGMainTableViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - ----------- Getter Methods -----------
- (UITableView *)tableView
{
    if ( nil == _tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
