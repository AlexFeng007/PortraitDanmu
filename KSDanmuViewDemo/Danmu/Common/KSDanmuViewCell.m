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
@property (nonatomic, strong) UIView *BgView;
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
    NSString *danmuString = [NSString stringWithFormat:@"%@: %@",model.nickname,model.content];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:danmuString];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorFromHexRGB:@"3263FF"] range:NSMakeRange(0, model.nickname.length+1)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorFromHexRGB:@"ffffff"] range:NSMakeRange(model.nickname.length+2, model.content.length)];
    
    
    [self.contentView addSubview:self.danmuContent];
    self.danmuContent.attributedText = attrStr;
    self.danmuContent.lineBreakMode = NSLineBreakByCharWrapping;
    self.danmuContent.numberOfLines = 0;
    [self.danmuContent sizeToFit];
    [self.danmuContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(5.f);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-5.f);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
    
//    self.contentView.backgroundColor = [UIColor colorFromHexRGB:@"000000"];
//    self.contentView.alpha = 0.3;
//    self.contentView.layer.cornerRadius = 3.f;
//    self.contentView.clipsToBounds = YES;
}
- (void)setupUI
{
    //self.contentView.backgroundColor = [UIColor clearColor];
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

- (UIView *)BgView
{
    if (!_BgView) {
        _BgView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        _BgView.backgroundColor = [UIColor colorFromHexRGB:@"000000"];
        _BgView.alpha = 0.3;
    }
    return _BgView;
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
