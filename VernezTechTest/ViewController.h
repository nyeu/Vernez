//
//  ViewController.h
//  VernezTechTest
//
//  Created by Joan on 11/5/15.
//  Copyright (c) 2015 Joan Cardona. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VZTAPIClient.h"
#import "VZTImagesTableViewCell.h"
#import "VZTData.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

