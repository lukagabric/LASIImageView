#import "ViewController.h"


@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[LASIImageView sharedProgressAppearance] setType:LProgressTypeAnnular];
    [[LASIImageView sharedProgressAppearance] setSchemeColor:[UIColor whiteColor]];
    [[LASIImageView sharedRequestSettings] setSecondsToCache:5];
    
    _imageView.imageUrl = @"http://farm9.staticflickr.com/8190/8148007408_8fbac75988_o.jpg";

    LRequestSettings *reqSettings = [LRequestSettings new];
    reqSettings.secondsToCache = 20;
    
    LProgressAppearance *progressAppearance = [LProgressAppearance new];
    progressAppearance.schemeColor = [UIColor redColor];
    
    _imageView2.requestSettings = reqSettings;
    _imageView2.progressAppearance = progressAppearance;
    _imageView2.imageUrl = @"http://www.fromparis.com/panoramas_quicktime_vr/hand-held_panorama_in_3_mnts/hand-held_panorama_in_3_mnts_5000.jpg";
    
    _imageView3.imageUrl = @"http://www.larkinweb.co.uk/panoramas/lake_placid/Lake_Placid_south_medium_res_panorama.jpg";
}


@end