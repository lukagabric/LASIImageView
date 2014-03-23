LASIImageView
=============

iOS UIImageView subclass - download image with different progress indicators

Screenshots
-----------
[![](http://lukagabric.com/wp-content/uploads/2013/09/LASIImageViewSample.png)](http://lukagabric.com/wp-content/uploads/2013/09/LASIImageViewSample.png)

How to use
----------

Just add LASIImageView class files to the project and set the imageUrl property to download and display the image.

Progress indicator types
------------------------

Three types of progress indicators are available (as in the screenshot above):

* LProgressTypeAnnular
* LProgressTypeCircle
* LProgressTypePie

Appearance
----------

It is possible to set shared appearance. Setting appearance for particular LASIImageView instance will override global appearance.

    [[LASIImageView sharedProgressAppearance] setSchemeColor:[UIColor whiteColor]];
    [[LASIImageView sharedASIImageViewAppearance] setDownloadFailedImageName:@"downloadFailed.png"];

Request settings
----------------

    @property (assign, nonatomic) ASICachePolicy cachePolicy;
    @property (assign, nonatomic) ASICacheStoragePolicy cacheStoragePolicy;
    @property (weak, nonatomic) id <ASICacheDelegate> cacheDelegate;
    @property (assign, nonatomic) NSUInteger secondsToCache;
    @property (assign, nonatomic) NSUInteger timeOutSeconds;

Blocks
------

On request finished - success or fail blocks are called (LASIImageViewDownloadFinishedBlock or LASIImageViewDownloadFailedBlock)
