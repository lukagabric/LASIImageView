#import "ViewController.h"


@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[LProgressView progressAppearance] setType:LProgressTypePie];
    [[LProgressView progressAppearance] setSchemeColor:[UIColor whiteColor]];
    
    _imageView.imageUrl = @"http://farm9.staticflickr.com/8190/8148007408_8fbac75988_o.jpg";
}


@end