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

    
}

@end
