//
//  AGLanguageCollectionViewController.m
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/12/2.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGLanguageCollectionViewController.h"
#import "AGThemePackCollectionViewCell.h"
#import <AGViewModel/AGVMKit.h>
#import "AGAssetsModuleA.h"
#import <AGCategories.h>

@interface AGLanguageCollectionViewController ()

/** 语言包s */
@property (nonatomic, copy) AGVMSection *languageVMS;

@end

@implementation AGLanguageCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

static NSString * const kAGLanguageName = @"kAGLanguageName";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[AGThemePackCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self setup];
}

- (void)setup
{
    self.title = @"语言包";
    self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

+ (instancetype)languageCollectionViewController
{
    UICollectionViewFlowLayout *fl = [[UICollectionViewFlowLayout alloc] init];
    
    fl.itemSize = CGSizeMake(120, 140);
    
    AGLanguageCollectionViewController *vc = [[AGLanguageCollectionViewController alloc] initWithCollectionViewLayout:fl];
    
    return vc;
}

#pragma mark - ----------- Event Methods -----------
- (void)rightItemClick:(UIBarButtonItem *)item
{
    
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.languageVMS.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AGThemePackCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    AGViewModel *vm = self.languageVMS[indexPath.item];
    
    vm.setIndexPath(indexPath).setBindingView(cell);
    
    cell.viewModel = vm;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AGViewModel *vm = self.languageVMS[indexPath.item];
    NSString *languageName = vm[kAGLanguageName];
    [AGAssetsModuleA reloadLanguageAssetsForPackName:languageName];
    [self.navigationController popViewControllerAnimated:YES];
}

- (AGVMSection *)languageVMS
{
    if ( nil == _languageVMS ) {
        _languageVMS = [AGVMSection newWithItemCapacity:12];
        
        [_languageVMS ag_packageItemData:^(AGViewModel * _Nonnull package) {
            package[kAGVMTitleText] = @"跟随系统";
            package[kAGVMTitleColor] = [UIColor blackColor];
            UIImage *image = [UIImage ag_imageWithColor:[UIColor yellowColor] size:CGSizeMake(4, 4)];
            package[kAGVMImage] = image;
        }];
        
        [_languageVMS ag_packageItemData:^(AGViewModel * _Nonnull package) {
            package[kAGVMTitleText] = @"英语";
            package[kAGVMTitleColor] = [UIColor orangeColor];
            package[kAGVMImage] = [UIImage ag_imageWithColor:[UIColor orangeColor] size:CGSizeMake(4, 4)];
            package[kAGLanguageName] = @"LocalizationEnglish";
        }];
        
        [_languageVMS ag_packageItemData:^(AGViewModel * _Nonnull package) {
            package[kAGVMTitleText] = @"中文";
            package[kAGVMTitleColor] = [UIColor blueColor];
            package[kAGVMImage] = [UIImage ag_imageWithColor:[UIColor blueColor] size:CGSizeMake(4, 4)];
            package[kAGLanguageName] = @"LocalizationChinese";
        }];
        
        [_languageVMS ag_packageItemData:^(AGViewModel * _Nonnull package) {
            package[kAGVMTitleText] = @"粤语";
            package[kAGVMTitleColor] = [UIColor purpleColor];
            package[kAGVMImage] = [UIImage ag_imageWithColor:[UIColor purpleColor] size:CGSizeMake(4, 4)];
            package[kAGLanguageName] = @"LocalizationCantonese";
        }];
    }
    return _languageVMS;
}
@end
