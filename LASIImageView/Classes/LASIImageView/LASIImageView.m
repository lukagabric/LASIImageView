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
    self = [super initWithImage:image highlightedImage:highlightedImage];
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
    
    _request = [ASIHTTPRequest requestWithURL:imageURL usingCache:self.requestSettings.cacheDelegate andCachePolicy:self.requestSettings.cachePolicy];
    _request.cacheStoragePolicy = self.requestSettings.cacheStoragePolicy;
    _request.secondsToCache = self.requestSettings.secondsToCache;
    _request.timeOutSeconds = self.requestSettings.timeOutSeconds;
    _request.downloadProgressDelegate = self;

    __weak typeof(self) weakSelf = self;
    __weak ASIHTTPRequest *weakReq = _request;
    
    [_request setCompletionBlock:^{
        [weakSelf requestFinished:weakReq];
    }];
    
    [_request setFailedBlock:^{
        [weakSelf requestFailed:weakReq];
    }];
    
    if ([[ASIDownloadCache sharedCache] isCachedDataCurrentForRequest:_request])
    {
        [self loadCachedImage];
    }
    else
    {
        [self loadProgressView];
        [_request startAsynchronous];
    }
}


- (void)loadCachedImage
{
    NSString *filePath = [[ASIDownloadCache sharedCache] pathToStoreCachedResponseDataForRequest:_request];
    
	if (filePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        UIImage *cachedImage = [UIImage imageWithContentsOfFile:filePath];
        
        if (cachedImage)
            super.image = cachedImage;
    }
}


- (void)loadPlaceholderImage
{
    if (!self.image)
    {
        if (self.asiImageViewAppearance.placeholderImage)
            self.image = self.asiImageViewAppearance.placeholderImage;
        else if (self.asiImageViewAppearance.placeholderImageName)
            self.image = [UIImage imageNamed:self.asiImageViewAppearance.placeholderImageName];
    }
}


- (void)loadDownloadFailedImage
{
    [self loadCachedImage];
    
    if (!self.image)
    {
        if (self.asiImageViewAppearance.downloadFailedImage)
            self.image = self.asiImageViewAppearance.downloadFailedImage;
        else if (self.asiImageViewAppearance.downloadFailedImageName)
            self.image = [UIImage imageNamed:self.asiImageViewAppearance.downloadFailedImageName];
    }
}


- (void)cancelImageDownload
{
    [self freeAll];
}


#pragma mark - ASIHTTPRequestDelegate


- (void)requestFinished:(ASIHTTPRequest *)request
{
    UIImage *downloadedImage = [UIImage imageWithData:request.responseData];
    
    if (downloadedImage)
    {
        self.image = downloadedImage;
        [self freeAll];
        
        if (_finishedBlock)
            _finishedBlock(self, request);
    }
    else
    {
        [self requestFailed:nil];
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self loadDownloadFailedImage];
    [self freeAll];
    
    if (_failedBlock)
        _failedBlock(self, request);
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


#pragma mark - Getters


- (LProgressAppearance *)progressAppearance
{
    @synchronized(self)
    {
        if (_progressAppearance)
            return _progressAppearance;
        
        return [LProgressAppearance sharedProgressAppearance];
    }
}


- (LRequestSettings *)requestSettings
{
    @synchronized(self)
    {
        if (_requestSettings)
            return _requestSettings;
        
        return [LRequestSettings sharedRequestSettings];
    }
}


- (LASIImageViewAppearance *)asiImageViewAppearance
{
    @synchronized(self)
    {
        if (_asiImageViewAppearance)
            return _asiImageViewAppearance;
        
        return [LASIImageViewAppearance sharedASIImageViewAppearance];
    }
}


+ (LProgressAppearance *)sharedProgressAppearance
{
    return [LProgressAppearance sharedProgressAppearance];
}


+ (LRequestSettings *)sharedRequestSettings
{
    return [LRequestSettings sharedRequestSettings];
}


+ (LASIImageViewAppearance *)sharedASIImageViewAppearance
{
    return [LASIImageViewAppearance sharedASIImageViewAppearance];
}


#pragma mark -


@end


#pragma mark - LRoundProgressView


@implementation LProgressView


- (LProgressAppearance *)progressAppearance
{
    @synchronized(self)
    {
        if (_progressAppearance)
            return _progressAppearance;
        
        return [LProgressAppearance sharedProgressAppearance];
    }
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
	
	if (appearance.type == LProgressTypeAnnular)
    {
		CGFloat lineWidth = 5.f;
		UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
		processBackgroundPath.lineWidth = lineWidth;
		processBackgroundPath.lineCapStyle = kCGLineCapRound;
		CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
		CGFloat radius = (self.bounds.size.width - lineWidth)/2;
		CGFloat startAngle = - ((float)M_PI / 2);
		CGFloat endAngle = (2 * (float)M_PI) + startAngle;
		[processBackgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
		[appearance.backgroundTintColor set];
		[processBackgroundPath stroke];

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
    else if (appearance.type == LProgressTypeCircle)
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

		CGContextSetLineWidth(context, 2.0f);
		CGContextFillEllipseInRect(context, circleRect);
		CGContextStrokeEllipseInRect(context, circleRect);

		CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
		CGFloat radius = (allRect.size.width - 4) / 2 - 3;
		CGFloat startAngle = - ((float)M_PI / 2);
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


#pragma mark -


@end


@implementation LProgressAppearance


static LProgressAppearance *sharedProgressAppearanceInstance = nil;


+ (LProgressAppearance *)sharedProgressAppearance
{
    @synchronized(self)
    {
        if (sharedProgressAppearanceInstance)
            return sharedProgressAppearanceInstance;
        
        return sharedProgressAppearanceInstance = [LProgressAppearance new];
    }
}


#pragma mark - init


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


#pragma mark - Setters


- (void)setSchemeColor:(UIColor *)schemeColor
{
    _schemeColor = schemeColor;
    
    _progressTintColor = [UIColor colorWithCGColor:CGColorCreateCopyWithAlpha(schemeColor.CGColor, 1)];
    _backgroundTintColor = [UIColor colorWithCGColor:CGColorCreateCopyWithAlpha(schemeColor.CGColor, 0.1)];
    _percentageTextColor = [UIColor colorWithCGColor:CGColorCreateCopyWithAlpha(schemeColor.CGColor, 1)];
}


#pragma mark -


@end


@implementation LRequestSettings


#pragma mark - LRequestSettings


static LRequestSettings *sharedRequestSettingsInstance = nil;


+ (LRequestSettings *)sharedRequestSettings
{
    @synchronized(self)
    {
        if (sharedRequestSettingsInstance)
            return sharedRequestSettingsInstance;
        
        return sharedRequestSettingsInstance = [LRequestSettings new];
    }
}


- (id)init
{
    self = [super init];
    if (self)
    {
        _secondsToCache = 900;
        _timeOutSeconds = 8;
        _cacheDelegate = [ASIDownloadCache sharedCache];
        _cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
        _cachePolicy = ASIAskServerIfModifiedWhenStaleCachePolicy;
    }
    return self;
}


@end


@implementation LASIImageViewAppearance


#pragma mark - LASIImageViewAppearance


static LASIImageViewAppearance *sharedImageViewAppearanceInstance = nil;


+ (LASIImageViewAppearance *)sharedASIImageViewAppearance
{
    @synchronized(self)
    {
        if (sharedImageViewAppearanceInstance)
            return sharedImageViewAppearanceInstance;
        
        return sharedImageViewAppearanceInstance = [LASIImageViewAppearance new];
    }
}


@end