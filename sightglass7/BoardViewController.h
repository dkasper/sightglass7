//
//  BoardViewController.h
//  sightglass7
//
//  Created by David Kasper on 11/19/13.
//  Copyright (c) 2013 David Kasper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoardViewController : UIViewController

@property (nonatomic) NSMutableArray *squares;
@property (nonatomic) NSArray *phrases;

-(IBAction)newGame:(id)sender;

@end
