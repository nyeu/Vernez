//
//  VZTData.h
//  VernezTechTest
//
//  Created by Joan on 11/5/15.
//  Copyright (c) 2015 Joan Cardona. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle/Mantle.h>

@interface VZTData : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString * bigImage;
@property (nonatomic, copy, readonly) NSString * smallImage;

@end
