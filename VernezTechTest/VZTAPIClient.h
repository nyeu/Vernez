//
//  VZTAPIClient.h
//  VernezTechTest
//
//  Created by Joan on 11/5/15.
//  Copyright (c) 2015 Joan Cardona. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface VZTAPIClient : AFHTTPSessionManager

+(instancetype) sharedClient;

@end
