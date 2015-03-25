//
//  UMComAddedImageCellView.m
//  UMCommunity
//
//  Created by luyiyuan on 14/9/17.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComAddedImageCellView.h"
#import "UMComActionDeleteView.h"

#define IMAGE_WIDTH 73.75

#define YPAD 5

#define TAG_PAD 99


static inline CGRect getRectForIndex(NSUInteger index, float cellPad)
{
    return CGRectMake((cellPad+IMAGE_WIDTH)*(index%4)+cellPad, (YPAD+IMAGE_WIDTH)*(index/4)+YPAD, IMAGE_WIDTH, IMAGE_WIDTH);
}


@interface UMComAddedImageCellView()
@property (nonatomic,strong) UMComActionDeleteView *deleteView;
@end

@implementation UMComAddedImageCellView


- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    
    if(self)
    {
        self.userInteractionEnabled = YES;
    }
    
    return self;
}


- (void)setIndex:(NSUInteger)index cellPad:(float)cellPad
{
    self.curIndex = index;
    
    [self setFrame:getRectForIndex(index,cellPad)];
    [self setTag:index + TAG_PAD];
    
    if(!self.deleteView)
    {
        self.deleteView = [[UMComActionDeleteView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 24, 0, 24, 24)];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteAction:)];
        [self.deleteView addGestureRecognizer:tapGesture];
        [self addSubview:self.deleteView];
    }

}

//- (void)setFrame:(CGRect)frame
//{
//    [super setFrame:frame];
//    
//    
//}


- (void)deleteAction:(UITapGestureRecognizer *)tapGesture
{   
    if(self.handle)
    {
        self.handle(self);
    }
}

@end
