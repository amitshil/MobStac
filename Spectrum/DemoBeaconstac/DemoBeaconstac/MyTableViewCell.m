//
//  MyTableViewCell.m
//  DemoBeaconstac
//
//  Created by Manigandan Parthasarathi on 08/11/14.
//  Copyright (c) 2014 Mobstac. All rights reserved.
//

#import "MyTableViewCell.h"

@implementation MyTableViewCell

@synthesize prodName,prodImage,lblCount;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
