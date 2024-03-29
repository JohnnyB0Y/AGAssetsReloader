//
//  AGMainCollectionViewController.m
//  
//
//  Created by JohnnyB0Y on 2019/8/4.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGMainCollectionViewController.h"
#import "AGThemePackCollectionViewController.h"
#import "AGMainCollectionViewCell.h"
#import "AGAssetsModuleB.h"

@interface AGMainCollectionViewController ()

@end

@implementation AGMainCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[AGMainCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self setup];
}

- (void)setup
{
    self.title = @"详情";
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"更换主题" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [AGAssetsModuleB ag_addThemeReloadResponder:self];
    [AGAssetsModuleB ag_addLanguageReloadResponder:self];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    [self.collectionView reloadData];
}

#pragma mark - ----------- Event Methods -----------
- (void)rightItemClick:(UIBarButtonItem *)item
{
    AGThemePackCollectionViewController *vc = [AGThemePackCollectionViewController themePackCollectionViewController];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 124;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *fl = [[UICollectionViewFlowLayout alloc] init];
    fl.itemSize = CGSizeMake(40, 40);
    AGMainCollectionViewController *vc = [[AGMainCollectionViewController alloc] initWithCollectionViewLayout:fl];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark <UICollectionViewDelegate>


@end
