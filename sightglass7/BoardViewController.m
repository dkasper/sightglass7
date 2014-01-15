//
//  BoardViewController.m
//  sightglass7
//
//  Created by David Kasper on 11/19/13.
//  Copyright (c) 2013 David Kasper. All rights reserved.
//

#import "BoardViewController.h"
@import Social;
#import "Square.h"

#define GRID_SIZE 4

@interface BoardViewController () {
    BOOL facebookShare, twitterShare;
    double backoff;
}

@property (nonatomic, copy) NSString *winShareText;

@end

@implementation BoardViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        backoff = 1.0;
        self.squares = [[NSMutableArray alloc] initWithCapacity:GRID_SIZE * GRID_SIZE];
        self.title = @"Sightglass Bingo";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New Game" style:UIBarButtonItemStylePlain target:self action:@selector(newGame:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self setupBoard];
    [self loadData];
}

-(void)setupBoard {
    for(int y=0;y<GRID_SIZE;y++) {
        for(int x=0;x<GRID_SIZE;x++) {
            Square *square = [[Square alloc] init];
            square.translatesAutoresizingMaskIntoConstraints = NO;
            square.index = y * GRID_SIZE + x;
            [square addTarget:self action:@selector(squareTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.squares addObject:square];
            [self.view addSubview:square];
        }
    }
    
    for(int y=0;y<GRID_SIZE;y++) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[square1]-5-[square2(==square1)]-5-[square3(==square1)]-5-[square4(==square1)]-5-|" options:NSLayoutFormatAlignAllBaseline metrics:@{@"padding": @"5"} views:@{@"square1": self.squares[y*GRID_SIZE],@"square2": self.squares[y*GRID_SIZE+1], @"square3": self.squares[y*GRID_SIZE+2], @"square4": self.squares[y*GRID_SIZE+3]}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[square1]-5-[square2(==square1)]-5-[square3(==square1)]-5-[square4(==square1)]-5-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:@{@"square1": self.squares[y],@"square2": self.squares[GRID_SIZE + y], @"square3": self.squares[2*GRID_SIZE+y], @"square4": self.squares[3*GRID_SIZE + y]}]];
    }
}

-(void)loadData {
    NSURL *phrasesUrl = [NSURL URLWithString:@"http://davidkasper.net/words.txt"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithURL:phrasesUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(!error) {
            NSString *phraseString = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            self.phrases = [phraseString componentsSeparatedByString:@","];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationItem.rightBarButtonItem.enabled = YES;
                [self newGame:nil];
            });
        } else {
            [self performSelector:@selector(loadData) withObject:nil afterDelay:backoff];
            backoff = MIN(backoff * 2, 16.0);
        }
    }];
    
    [task resume];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    for(Square *s in self.squares) {
        [s resizeTitle];
    }
}

-(IBAction)newGame:(id)sender {
    if(self.phrases.count >= GRID_SIZE * GRID_SIZE) {
        NSMutableArray *random = [[NSMutableArray alloc] initWithArray:self.phrases];
        
        for(int row=0;row<GRID_SIZE * GRID_SIZE;row++) {
            Square *s = self.squares[row];
            s.selected = NO;
            NSUInteger randomIndex = arc4random() % [random count];
            NSString *val = [random objectAtIndex:randomIndex];
            [random removeObjectAtIndex:randomIndex];
            s.phrase = val;
        }
    }
}

-(void)squareTapped:(Square *)sender {
    NSInteger row = sender.index / GRID_SIZE;
    NSInteger col = sender.index % GRID_SIZE;
    sender.selected = !sender.selected;
    [self checkForWinAtIndex:[NSIndexPath indexPathForRow:row inSection:col]];
}

-(void)checkForWinAtIndex:(NSIndexPath *)index {
    int rowCount = 0, colCount=0;
    NSMutableArray *rowValues = [[NSMutableArray alloc] init];
    NSMutableArray *colValues = [[NSMutableArray alloc] init];
    
    for(int i=0;i<GRID_SIZE;i++) {
        // check rows
        BOOL rowSelected = [self.squares[i * GRID_SIZE + index.section] isSelected];
        if(rowSelected) {
            [rowValues addObject:[self.squares[i * GRID_SIZE + index.section] phrase]];
            rowCount++;
        }
        
        // check cols
        BOOL colSelected = [self.squares[index.row * GRID_SIZE + i] isSelected];
        if(colSelected) {
            [colValues addObject:[self.squares[index.row * GRID_SIZE + i] phrase]];
            colCount++;
        }
    }
    
    if(rowCount == GRID_SIZE) {
        facebookShare = NO;
        twitterShare = NO;
        self.winShareText = [rowValues componentsJoinedByString:@", "];
        [self showWinAlertView];
    } else if(colCount == GRID_SIZE) {
        facebookShare = NO;
        twitterShare = NO;
        self.winShareText = [colValues componentsJoinedByString:@", "];
        [self showWinAlertView];
    }
}

-(void)showWinAlertView {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Winner!" message:@"You just won Sightglass Bingo! Share your victory?" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:@"Facebook", @"Twitter", nil];
    [av show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == alertView.cancelButtonIndex) {
        [self newGame:nil];
    } else {
        SLComposeViewController *svc;
        if(buttonIndex == alertView.firstOtherButtonIndex) {
            svc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        } else {
            svc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        }
        [svc setInitialText:[NSString stringWithFormat:@"I just won Sightglass Bingo by spotting %@!", self.winShareText]];
        [svc setCompletionHandler:^(SLComposeViewControllerResult result) {
            if(result != SLComposeViewControllerResultCancelled && facebookShare && twitterShare) {
                [self newGame:nil];
            } else {
                [self showWinAlertView];
            }
        }];
        [self presentViewController:svc animated:YES completion:nil];
    }
}

@end
