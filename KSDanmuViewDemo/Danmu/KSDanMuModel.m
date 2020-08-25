//
//  KSDanMuModel.m
//  KSDanmuViewDemo
//
//  Created by YaphetS on 2020/8/24.
//  Copyright © 2020 sapphire. All rights reserved.
//

#import "KSDanMuModel.h"
#import "MJExtension.h"

@implementation KSDanMuModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
        @"nickname":@"nickname",
        @"content":@"content",
    };
}
- (CGFloat)danmuRowHeight
{
    if (!_danmuRowHeight) {
        CGSize labelSize = [self labelAutoCalculateRectWith:[NSString stringWithFormat:@"%@:%@",self.nickname,self.content] FontSize:13.f MaxSize:CGSizeMake(375, 180)];
        _danmuRowHeight = ceil(labelSize.height);
    }
    return _danmuRowHeight;
}

#pragma mark: Tools
- (CGSize)labelAutoCalculateRectWith:(NSString*)text FontSize:(CGFloat)fontSize MaxSize:(CGSize)maxSize
{
   NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc]init];
   paragraphStyle.lineBreakMode=NSLineBreakByCharWrapping;
   NSDictionary* attributes =@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSParagraphStyleAttributeName:paragraphStyle.copy};

   CGSize labelSize;
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        labelSize = [text boundingRectWithSize: maxSize
                                              options: NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine
                                           attributes:attributes
                                              context:nil].size;
    }
    labelSize.height = ceil(labelSize.height);
    labelSize.width = ceil(labelSize.width);
    return labelSize;
}
@end
