#import "ViewController.h"


@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[LASIImageView sharedProgressAppearance] setType:LProgressTypeAnnular];
    [[LASIImageView sharedProgressAppearance] setSchemeColor:[UIColor whiteColor]];
    [[LASIImageView sharedRequestSettings] setSecondsToCache:5];
    
    _imageView.imageUrl = @"http://farm9.staticflickr.com/8190/8148007408_8fbac75988_o.jpg";
}


@end