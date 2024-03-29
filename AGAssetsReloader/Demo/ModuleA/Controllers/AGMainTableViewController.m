//
//  AGMainTableViewController.m
//  
//
//  Created by JohnnyB0Y on 2019/8/4.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGMainTableViewController.h"
#import "AGMainImageCell.h"
#import "AGMainMessageCell.h"
#import "AGAssetsModuleA.h"
#import "AGMainCollectionViewController.h"
#import "AGThemePackCollectionViewController.h"

@interface AGMainTableViewController ()

@end

@implementation AGMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:AGMainImageCell.class forCellReuseIdentifier:NSStringFromClass(AGMainImageCell.class)];
    [self.tableView registerClass:AGMainMessageCell.class forCellReuseIdentifier:NSStringFromClass(AGMainMessageCell.class)];
    
    [self setup];
}

- (void)setup
{
    self.title = @"列表";
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"更换主题" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    // 添加主题、语言更换的响应
    [AGAssetsModuleA ag_addLanguageReloadResponder:self];
    [AGAssetsModuleA ag_addThemeReloadResponder:self];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    [self.tableView reloadData];
}

#pragma mark - ----------- Event Methods -----------
- (void)rightItemClick:(UIBarButtonItem *)item
{
    AGThemePackCollectionViewController *vc = [AGThemePackCollectionViewController themePackCollectionViewController];
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
    if ( indexPath.row % 2 != 0 ) {
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
    
    UICollectionViewFlowLayout *fl = [[UICollectionViewFlowLayout alloc] init];
    fl.itemSize = CGSizeMake(120, 120);
    AGMainCollectionViewController *vc = [[AGMainCollectionViewController alloc] initWithCollectionViewLayout:fl];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
