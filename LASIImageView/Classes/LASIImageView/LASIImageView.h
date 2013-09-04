#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "ASICacheDelegate.h"


@class LRoundProgressView, LProgressAppearance;


@interface LASIImageView : UIImageView <ASIHTTPRequestDelegate, ASIProgressDelegate>
{
    ASIHTTPRequest *_request;
    __weak LRoundProgressView *_progressView;
}


@property (strong, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) UIImage *placeholderImage;
@property (strong, nonatomic) NSString *placeholderImageName;
@property (strong, nonatomic) UIImage *downloadFailedImage;
@property (strong, nonatomic) NSString *downloadFailedImageName;

@property (strong, nonatomic) LProgressAppearance *progressAppearance;

@property (assign, nonatomic) ASICachePolicy cachePolicy;
@property (assign, nonatomic) ASICacheStoragePolicy cacheStoragePolicy;
@property (weak, nonatomic) id <ASICacheDelegate> cacheDelegate;
@property (assign, nonatomic) NSUInteger secondsToCache;
@property (assign, nonatomic) NSUInteger timeOutSeconds;


@end


@interface LRoundProgressView : UIView


@property (assign, nonatomic) float progress;
@property (strong, nonatomic) LProgressAppearance *progressAppearance;


@end


@interface LProgressAppearance : NSObject


//setting schemeColor will set progressTintColor, backgroundTintColor and percentageTextColor
@property (strong, nonatomic) UIColor *schemeColor;
@property (strong, nonatomic) UIColor *progressTintColor;
@property (strong, nonatomic) UIColor *backgroundTintColor;
@property (strong, nonatomic) UIColor *percentageTextColor;

@property (strong, nonatomic) UIFont *percentageTextFont;
@property (assign, nonatomic) CGPoint percentageTextOffset;
@property (assign, nonatomic) int type;
@property (assign, nonatomic) BOOL showPercentage;


@end