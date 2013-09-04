#import "LASIImageView.h"
#import <objc/runtime.h>


@implementation LASIImageView


#pragma mark - init & dealloc


- (id)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}


- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self)
    {
        [self initialize];
    }
    return self;
}


- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}


- (void)initialize
{
    _secondsToCache = 900;
    _timeOutSeconds = 8;
    _cacheDelegate = [ASIDownloadCache sharedCache];
    _cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
    _cachePolicy = ASIDoNotReadFromCacheCachePolicy;
}


- (void)dealloc
{
    [self freeAll];
}


#pragma mark - layoutSubviews


- (void)layoutSubviews
{
    _progressView.frame = CGRectMake(floorf(self.frame.size.width/2 - _progressView.frame.size.width/2), floorf(self.frame.size.height/2 - _progressView.frame.size.height/2), _progressView.frame.size.width, _progressView.frame.size.height);
}


#pragma mark - Progress view


- (void)loadProgressView
{
    [self freeProgressView];
    
    LProgressView *progressView = [[LProgressView alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
    
    if (_progressAppearance)
        progressView.progressAppearance = _progressAppearance;
    
    _progressView = progressView;
    
    [self addSubview:_progressView];
}


#pragma mark - downloadImage


- (void)downloadImage
{
    [self freeAll];
    
    NSURL *imageURL = [NSURL URLWithString:_imageUrl];
    
    if (!imageURL)
    {
        [self requestFailed:nil];
        return;
    }
    
    _request = [ASIHTTPRequest requestWithURL:imageURL usingCache:_cacheDelegate andCachePolicy:_cachePolicy];
    _request.cacheStoragePolicy = _cacheStoragePolicy;
    _request.secondsToCache = _secondsToCache;
    _request.timeOutSeconds = _timeOutSeconds;
    _request.downloadProgressDelegate = self;
    _request.delegate = self;
    
    [self loadProgressView];
    
    [_request startAsynchronous];
}


- (void)cancelImageDownload
{
    [self freeRequest];
    [self freeProgressView];
}


#pragma mark - ASIHTTPRequestDelegate


- (void)requestFinished:(ASIHTTPRequest *)request
{
    UIImage *downloadedImage = [UIImage imageWithData:request.responseData];
    
    if (downloadedImage)
        self.image = downloadedImage;
    else
        [self requestFailed:nil];
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (_downloadFailedImage)
        self.image = _downloadFailedImage;
    else if (_downloadFailedImageName)
        self.image = [UIImage imageNamed:_downloadFailedImageName];
}


#pragma mark - ASIProgressDelegate


- (void)setProgress:(float)newProgress
{
    _progressView.progress = newProgress;
}


#pragma mark - Free


- (void)freeRequest
{
    if (_request)
    {
        [_request clearDelegatesAndCancel];
        _request = nil;
    }
}


- (void)freeProgressView
{
    if (_progressView)
    {
        if (_progressView.superview)
            [_progressView removeFromSuperview];
     
        _progressView = nil;
    }
}


- (void)freeAll
{
    [self freeRequest];
    [self freeProgressView];
}


#pragma mark - Setters


- (void)setImage:(UIImage *)image
{
    [self cancelImageDownload];
    
    [super setImage:image];
}


- (void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;

    self.image = nil;
    
    [self downloadImage];
}


- (void)setProgressAppearance:(LProgressAppearance *)progressAppearance
{
    _progressAppearance = progressAppearance;
    
    if (_progressView)
        _progressView.progressAppearance = _progressAppearance;
}


#pragma mark -


@end


#pragma mark - LRoundProgressView


@implementation LProgressView


#pragma mark - LProgressAppearance


static LProgressAppearance *lProgressAppearance = nil;


+ (LProgressAppearance *)progressAppearance
{
    if (lProgressAppearance)
        return lProgressAppearance;
    
    return lProgressAppearance = [LProgressAppearance new];
}


+ (void)setProgressAppearance:(LProgressAppearance *)progressAppearance
{
    lProgressAppearance = progressAppearance;
}


- (LProgressAppearance *)progressAppearance
{
    if (_progressAppearance)
        return _progressAppearance;
    
    return [LProgressView progressAppearance];
}


- (void)setProgressAppearance:(LProgressAppearance *)progressAppearance
{
    _progressAppearance = progressAppearance;
}


#pragma mark - init & dealloc


- (id)init
{
	return [self initWithFrame:CGRectMake(0.f, 0.f, 37.f, 37.f)];
}


- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
    {
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		_progress = 0.f;
		[self registerForKVO];
	}
	return self;
}


- (void)dealloc
{
	[self unregisterFromKVO];
}


#pragma mark - Drawing


- (void)drawRect:(CGRect)rect
{
	CGRect allRect = self.bounds;
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    LProgressAppearance *appearance = self.progressAppearance;
	
	if (appearance.type == 0)
    {
		// Draw background
		CGFloat lineWidth = 5.f;
		UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
		processBackgroundPath.lineWidth = lineWidth;
		processBackgroundPath.lineCapStyle = kCGLineCapRound;
		CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
		CGFloat radius = (self.bounds.size.width - lineWidth)/2;
		CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
		CGFloat endAngle = (2 * (float)M_PI) + startAngle;
		[processBackgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
		[appearance.backgroundTintColor set];
		[processBackgroundPath stroke];
		// Draw progress
		UIBezierPath *processPath = [UIBezierPath bezierPath];
		processPath.lineCapStyle = kCGLineCapRound;
		processPath.lineWidth = lineWidth;
		endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
		[processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
		[appearance.progressTintColor set];
		[processPath stroke];

        if (appearance.showPercentage)
            [self drawTextInContext:context];
    }
    else if (appearance.type == 1)
    {
        CGColorRef colorBackAlpha = CGColorCreateCopyWithAlpha(appearance.backgroundTintColor. CGColor, 0.05f);
        CGColorRef colorProgressAlpha = CGColorCreateCopyWithAlpha(appearance.progressTintColor. CGColor, 0.2f);
        
        CGRect allRect = rect;
        CGRect circleRect = CGRectMake(allRect.origin.x + 2, allRect.origin.y + 2, allRect.size.width - 4, allRect.size.height - 4);
        float x = allRect.origin.x + (allRect.size.width / 2);
        float y = allRect.origin.y + (allRect.size.height / 2);
        float angle = (_progress) * 360.0f;
        
        CGContextSaveGState(context);
        CGContextSetStrokeColorWithColor(context, colorProgressAlpha);
        CGContextSetFillColorWithColor(context, colorBackAlpha);
        CGContextSetLineWidth(context, 2.0);
        CGContextFillEllipseInRect(context, circleRect);
        CGContextStrokeEllipseInRect(context, circleRect);
        
        CGContextSetRGBFillColor(context, 1.0, 0.0, 1.0, 1.0);
        CGContextMoveToPoint(context, x, y);
        CGContextAddArc(context, x, y, (allRect.size.width + 4) / 2, -M_PI / 2, (angle * M_PI) / 180.0f - M_PI / 2, 0);
        CGContextClip(context);
        
        CGContextSetStrokeColorWithColor(context, appearance.progressTintColor.CGColor);
        CGContextSetFillColorWithColor(context, appearance.backgroundTintColor.CGColor);
        CGContextSetLineWidth(context, 2.0);
        CGContextFillEllipseInRect(context, circleRect);
        CGContextStrokeEllipseInRect(context, circleRect);
        CGContextRestoreGState(context);
        
        if (appearance.showPercentage)
            [self drawTextInContext:context];
	}
    else
    {
        CGRect circleRect = CGRectInset(allRect, 2.0f, 2.0f);

        CGColorRef colorBackAlpha = CGColorCreateCopyWithAlpha(appearance.backgroundTintColor. CGColor, 0.1f);
        
		[appearance.progressTintColor setStroke];
        CGContextSetFillColorWithColor(context, colorBackAlpha);

        // Draw background
		CGContextSetLineWidth(context, 2.0f);
		CGContextFillEllipseInRect(context, circleRect);
		CGContextStrokeEllipseInRect(context, circleRect);
		// Draw progress
		CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
		CGFloat radius = (allRect.size.width - 4) / 2 - 3;
		CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
		CGFloat endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
		[appearance.progressTintColor setFill];
		CGContextMoveToPoint(context, center.x, center.y);
		CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
		CGContextClosePath(context);
		CGContextFillPath(context);
    }
}


- (void)drawTextInContext:(CGContextRef)context
{
    LProgressAppearance *appearance = self.progressAppearance;

    CGRect allRect = self.bounds;

    UIFont *font = appearance.percentageTextFont;
    NSString *text = [NSString stringWithFormat:@"%i%%", (int)(_progress * 100.0f)];
    
    CGSize textSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(30000, 13)];

    float x = floorf(allRect.size.width / 2) + 3 + appearance.percentageTextOffset.x;
    float y = floorf(allRect.size.height / 2) - 6 + appearance.percentageTextOffset.y;
    
    CGContextSetFillColorWithColor(context, appearance.percentageTextColor.CGColor);
    [text drawAtPoint:CGPointMake(x - textSize.width / 2.0, y) withFont:font];
}


#pragma mark - KVO


- (void)registerForKVO
{
	for (NSString *keyPath in [self observableKeypaths])
    {
		[self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
	}
}


- (void)unregisterFromKVO
{
	for (NSString *keyPath in [self observableKeypaths])
    {
		[self removeObserver:self forKeyPath:keyPath];
	}
}


- (NSArray *)observableKeypaths
{
	return [NSArray arrayWithObjects:@"progressAppearance", @"progress", nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self setNeedsDisplay];
}


@end


@implementation LProgressAppearance


- (id)init
{
    self = [super init];
    if (self)
    {
        self.schemeColor = [UIColor whiteColor];
        _percentageTextFont = [UIFont systemFontOfSize:10];
        _percentageTextOffset = CGPointZero;
        _type = 0;
        _showPercentage = YES;
    }
    return self;
}


- (void)setSchemeColor:(UIColor *)schemeColor
{
    _schemeColor = schemeColor;
    
    _progressTintColor = [UIColor colorWithCGColor:CGColorCreateCopyWithAlpha(schemeColor.CGColor, 1)];
    _backgroundTintColor = [UIColor colorWithCGColor:CGColorCreateCopyWithAlpha(schemeColor.CGColor, 0.1)];
    _percentageTextColor = [UIColor colorWithCGColor:CGColorCreateCopyWithAlpha(schemeColor.CGColor, 1)];
}


@end