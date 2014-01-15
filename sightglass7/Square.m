//
//  Square.m
//  sightglass7
//
//  Created by David Kasper on 12/11/13.
//  Copyright (c) 2013 David Kasper. All rights reserved.
//

#import "Square.h"

@interface Square ()

@property (nonatomic) UILabel *titleLabel;

@end

@implementation Square

@synthesize selected = _selected;

-(id)init {
    if(self = [super init]) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor blackColor];

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:self.titleLabel];
        
        NSDictionary *dict = NSDictionaryOfVariableBindings(_titleLabel);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-2-[_titleLabel]-2-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:dict]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    }
    return self;
}

-(void)setPhrase:(NSString *)phrase {
    _phrase = [phrase copy];
    self.titleLabel.text = _phrase;
    [self resizeTitle];
}

-(void)setSelected:(BOOL)selected {
    _selected = selected;
    if(selected) {
        self.backgroundColor = [UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:1.0];
    } else {
        self.backgroundColor = [UIColor blackColor];
    }
}

-(void)resizeTitle {
    NSString *longestWord = nil;
    CGRect largestWordRect = CGRectZero;
    for(NSString *word in [self.titleLabel.text componentsSeparatedByString:@" "]) {
        CGRect wordRect = [word boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.titleLabel.font} context:nil];
        if(wordRect.size.width > largestWordRect.size.width) {
            largestWordRect = wordRect;
            longestWord = word;
        }
    }
    
    CGFloat fontSize = 18;
    while (largestWordRect.size.width > self.bounds.size.width - 4) {
        UIFont *font = [UIFont fontWithName:self.titleLabel.font.fontName size:fontSize];
        largestWordRect = [longestWord boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
        fontSize -= 0.5;
    }
    self.titleLabel.font = [UIFont fontWithName:self.titleLabel.font.fontName size:fontSize];
}

@end
