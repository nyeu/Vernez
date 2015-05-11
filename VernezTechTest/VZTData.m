//
//  VZTData.m
//  VernezTechTest
//
//  Created by Joan on 11/5/15.
//  Copyright (c) 2015 Joan Cardona. All rights reserved.
//

#import "VZTData.h"

@implementation VZTData

+(NSDictionary *)JSONKeyPathsByPropertyKey{
    
    return @{
             @"smallImage":@"images.low_resolution.url",
             @"bigImage":@"images.standard_resolution.url",
             };
    
}

@end
