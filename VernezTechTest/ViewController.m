//
//  ViewController.m
//  VernezTechTest
//
//  Created by Joan on 11/5/15.
//  Copyright (c) 2015 Joan Cardona. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    NSString * nextURL;
    NSMutableArray * dataArray;
    NSInteger kLoadingCellTag;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    kLoadingCellTag = 1;
    dataArray = [[NSMutableArray alloc] init];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPressGesture];
    
    nextURL = @"https://api.instagram.com/v1/tags/selfie/media/recent?client_id=bfbb83b81f7d4dfa9212027dfb8b47fb";
    [self fetchImages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) fetchImages{
    
    [[VZTAPIClient sharedClient] GET:nextURL parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        nextURL = [[responseObject objectForKey:@"pagination"] objectForKey:@"next_url"];
        NSError * error;
        [dataArray addObjectsFromArray:[MTLJSONAdapter modelsOfClass:VZTData.class fromJSONArray:[responseObject objectForKey:@"data"] error:&error]];
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
      
        UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error getting the feed, try again please" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [errorAlert show];
        
    }];
}

#pragma mark - Table View Data Source


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < dataArray.count) {
        
        if (indexPath.row % 3) {
            return 188;
        }
        
        return 388;
    }
    
    return 50;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == kLoadingCellTag && dataArray.count > 0) {
        [self fetchImages];
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < dataArray.count) {
        
        if (indexPath.row % 3) {
            return [self smallCellAtIndexPath:indexPath];
        }
        return [self bigCellAtIndexPath:indexPath];
    }
    
    return [self loadingCellAtIndexPath:indexPath];
}

-(UITableViewCell*) bigCellAtIndexPath:(NSIndexPath*) indexPath{
    
    static NSString * cellIdentifier = @"bigCell";
    VZTImagesTableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[VZTImagesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    VZTData * imageFeed = [dataArray objectAtIndex:indexPath.row];
    [cell.imageCell sd_setImageWithURL:[NSURL URLWithString:imageFeed.bigImage]];
    
    return cell;

}

-(UITableViewCell*) smallCellAtIndexPath:(NSIndexPath*) indexPath{
    
    static NSString * cellIdentifier = @"smallCell";
    VZTImagesTableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[VZTImagesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    VZTData * imageFeed = [dataArray objectAtIndex:indexPath.row];
    [cell.imageCell sd_setImageWithURL:[NSURL URLWithString:imageFeed.smallImage]];
    
    return cell;
}

-(UITableViewCell*) loadingCellAtIndexPath:(NSIndexPath*) indexPath{
    
    static NSString * cellIdentifier = @"loadingCell";
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.tag = kLoadingCellTag;
    return cell;
    
}

#pragma mark - Drag and Drop

- (IBAction)longPressGestureRecognized:(id)sender {

    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView * snapshot = nil;
    static NSIndexPath  * sourceIndexPath = nil;
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                snapshot = [self customSnapshotFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    
                    // Fade out.
                    cell.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    
                    cell.hidden = YES;
                    
                }];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                [dataArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                sourceIndexPath = indexPath;
            }
            break;
        }
            
        default: {
            // Clean up.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                
                // Undo fade out.
                cell.alpha = 1.0;
                
                [cell setNeedsLayout]; // re-layout
                [cell setNeedsDisplay];
                [cell.contentView setNeedsLayout]; // re-layout
                [cell.contentView setNeedsDisplay];
                
                [self.tableView reloadData];
                
            } completion:^(BOOL finished) {
                
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                
            }];
            break;
        }
    }
}

- (UIView *)customSnapshotFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

@end
