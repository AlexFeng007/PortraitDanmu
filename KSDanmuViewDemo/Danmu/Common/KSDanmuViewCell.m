//
//  KSDanmuViewCell.m
//  KSDanmuViewDemo
//
//  Created by YaphetS on 2020/8/24.
//  Copyright © 2020 sapphire. All rights reserved.
//

#import "KSDanmuViewCell.h"
#import "KSDanMuModel.h"
#import "UIColor+Utils.h"
#import "Masonry.h"

@interface KSDanmuViewCell()
@property (nonatomic, strong) UILabel *danmuContent;
@end

@implementation KSDanmuViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)configWithModel:(KSDanMuModel *)model
{
    NSString *danmuString = [NSString stringWithFormat:@"%@:%@",model.nickname,model.content];
    CGSize danmuContentSize = [self labelAutoCalculateRectWith:danmuString FontSize:13.f MaxSize:CGSizeMake(375, 180)];
    self.danmuContent.frame = CGRectMake(5, 5, danmuContentSize.width, danmuContentSize.height);
    [self.contentView addSubview:self.danmuContent];
    [self.danmuContent sizeToFit];
    self.danmuContent.text = danmuString;
    [self.danmuContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(self.contentView.mas_left).offset(5.f);
        make.height.mas_equalTo(danmuContentSize.height);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-5.f);
    }];
}

- (void)setupUI
{
    self.contentView.backgroundColor = [UIColor clearColor];
}

#pragma mark: lazy
- (UILabel *)danmuContent
{
    if (!_danmuContent) {
        _danmuContent = [[UILabel alloc] initWithFrame:CGRectZero];
        _danmuContent.textAlignment = NSTextAlignmentLeft;
        _danmuContent.font = [UIFont systemFontOfSize:13.f];
        _danmuContent.textColor = [UIColor colorFromHexRGB:@"ffffff"];
        _danmuContent.numberOfLines = 0;
    }
    return _danmuContent;
}

#pragma mark: 状态管理
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark: Tools
- (CGSize)labelAutoCalculateRectWith:(NSString*)text FontSize:(CGFloat)fontSize MaxSize:(CGSize)maxSize
{
   NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc]init];
   paragraphStyle.lineBreakMode=NSLineBreakByWordWrapping;
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

+ (NSString *)cellIdentifier
{
    return @"KSDanmuViewCell";
}

@end
