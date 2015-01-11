#import "ViewController.h"

static NSInteger const kTagHeaderCell = 999;
static CGFloat const kHeightHeaderCell = 140.0f;

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *placeholderImageView;

@property (nonatomic, assign) CGFloat placeholderMinimumY;
@property (nonatomic, assign) CGPoint lastContentOffset;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.placeholderMinimumY = CGRectGetMinY(self.placeholderImageView.frame);
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = YES;
}

#pragma mark <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.0f;
    }
    
    return 70.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return kHeightHeaderCell;
    }
    
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    return blurView;
    
}

#pragma mark <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
        cell.tag = kTagHeaderCell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell"];
        cell.backgroundColor = indexPath.row % 2 == 0 ? [UIColor colorWithRed:229.0f/255.0f green:241.0f/255.0f blue:1.0f alpha:1.0f] : [UIColor colorWithRed:255.0f/96.0f green:255.0f/110.0f blue:255.0f/127.0f alpha:1.0f];
    }
    
    return cell;
}



#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollDiff = self.lastContentOffset.y - scrollView.contentOffset.y;
    CGFloat originY = CGRectGetMinY(self.placeholderImageView.frame) + scrollDiff;

    BOOL contentMovingOffScreen = scrollView.contentOffset.y > 0.0f;
    
    __block UITableViewCell *headerCell;
    
    [[self.tableView visibleCells] enumerateObjectsUsingBlock:^(UITableViewCell *cell, NSUInteger idx, BOOL *stop) {
        if (cell.tag == kTagHeaderCell) {
            *stop = YES;
            headerCell = cell;
        }
    }];

    if (contentMovingOffScreen) {
        CGFloat alpha = MAX(1 - (scrollView.contentOffset.y / kHeightHeaderCell), 0.0f);
        headerCell.alpha = alpha;

        if (alpha > 0.0f) {
            scrollView.clipsToBounds = NO;
            self.title = nil;
        } else {
            scrollView.clipsToBounds = YES;
            self.title = @"Title";
        }
        
        originY = CGRectGetMinY(self.placeholderImageView.frame);
    } else if (scrollDiff < 0.0f) {
        originY = MAX(originY, self.placeholderMinimumY);
    } else {
        originY = MIN(originY, 0.0f);
        headerCell.alpha = 1.0f;
    }
    
    CGRect newRect = CGRectMake(CGRectGetMinX(self.placeholderImageView.frame),
                                originY,
                                CGRectGetWidth(self.placeholderImageView.frame),
                                CGRectGetHeight(self.placeholderImageView.frame));
    
    self.placeholderImageView.frame = newRect;
    self.lastContentOffset = scrollView.contentOffset;
}

@end
