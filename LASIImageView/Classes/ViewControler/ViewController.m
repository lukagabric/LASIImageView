#import "ViewController.h"


@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LProgressAppearance *appearance = [LProgressAppearance new];
    appearance.type = 1;
    [appearance setColorSchemeWithColor:[UIColor redColor]];
    _imageView.progressAppearance = appearance;
    _imageView.imageUrl = @"http://farm9.staticflickr.com/8190/8148007408_8fbac75988_o.jpg";
}


@end