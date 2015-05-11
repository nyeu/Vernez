//
//  VZTAPIClient.m
//  VernezTechTest
//
//  Created by Joan on 11/5/15.
//  Copyright (c) 2015 Joan Cardona. All rights reserved.
//

#import "VZTAPIClient.h"

@implementation VZTAPIClient

+(instancetype) sharedClient{

    static VZTAPIClient * _sharedClient;
    static dispatch_once_t onceToken;
    
    dispatch_once (&onceToken, ^{
        
        _sharedClient = [[VZTAPIClient alloc] initWithBaseURL:[NSURL URLWithString:@""]];
        
    });
    
    
    return _sharedClient;
}

@end
