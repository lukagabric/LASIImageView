#import "ViewController.h"


@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LProgressAppearance *appearance = [LProgressAppearance new];
    appearance.showPercentageInAnnular = NO;
    _imageView.progressViewAppearance = appearance;
    
    _imageView.imageUrl = @"http://images.sodahead.com/slideshows/000003527/polls_toadily_insane_4725_290286_answer_1_xlarge-31143707557_xlarge.jpeg";
}


@end