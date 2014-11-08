//
//  MyTableViewCell.h
//  DemoBeaconstac
//
//  Created by Manigandan Parthasarathi on 08/11/14.
//  Copyright (c) 2014 Mobstac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *prodName;

@property (strong, nonatomic) IBOutlet UIImageView *prodImage;
@property (strong, nonatomic) IBOutlet UILabel *lblCount;

@end
