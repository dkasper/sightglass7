//
//  Square.h
//  sightglass7
//
//  Created by David Kasper on 12/11/13.
//  Copyright (c) 2013 David Kasper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Square : UIControl

-(void)resizeTitle;

@property (nonatomic, copy) NSString *phrase;
@property (nonatomic, assign) int index;

@end
