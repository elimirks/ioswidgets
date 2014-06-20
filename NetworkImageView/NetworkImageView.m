#import "NetworkImageView.h"

static NSCache* imageDataCache = nil;

@interface NetworkImageView()
@property (nonatomic) NSString* imageUrl;
// Shaded to have a nice animation when setting the image.
@property (nonatomic, retain) UIView* shadeView;
@property (nonatomic, retain) UIActivityIndicatorView* indicator;
@end

@implementation NetworkImageView
-(void)setLoading:(BOOL)loading animated:(BOOL)animated {
	if (loading) {
		[self realignElements];
		[_shadeView setAlpha:1.0];
		[_shadeView setHidden:NO];
		[_indicator startAnimating];
	} else {
		if (animated) {
			[UIView animateWithDuration:0.5
				animations:^(void) {
					[_shadeView setAlpha:0.0];
				}
				completion:^(BOOL finished) {
					[_shadeView setHidden:YES];
					[_indicator stopAnimating];
				}
			];
		} else {
			[_shadeView setHidden:YES];
			[_indicator stopAnimating];
		}
	}
}

-(instancetype)setup {
	if (imageDataCache == nil) imageDataCache = [[NSCache alloc] init];
	
	_indicator = [[UIActivityIndicatorView alloc]
		initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	_shadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
	
	[self addSubview:_shadeView];
	[_shadeView addSubview:_indicator];
	[_shadeView setBackgroundColor:[UIColor blackColor]];
	[self setLoading:YES animated:NO];
	[self setBackgroundColor:[UIColor blackColor]];
	
	// Don't stretch the ratio.
	[self setContentMode:UIViewContentModeScaleAspectFit];
	
	return self;
}

-(instancetype)initWithCoder:(NSCoder*)coder {
	self = [super initWithCoder:coder];
	[self setup];
	return self;
}

-(instancetype)initWithFrame:(CGRect)frameRect {
	self = [super initWithFrame:frameRect];
	[self setup];
	return self;
}

-(void)loadFromURL:(NSString*)imageUrl {
	[self setImage:nil];
	[self setImageUrl:imageUrl];
	
	if ([self cacheContains:imageUrl]) {
		[self loadFromCache:imageUrl];
		return;
	}
	
	[self setLoading:YES animated:NO];
	
	NSURL* url = [NSURL URLWithString:imageUrl];
	NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url];
	[req setTimeoutInterval:60];

	// URL to compare to ensure that the requested URL is still valid.
	NSString* connectionUrl = [imageUrl copy];
	[NSURLConnection
		sendAsynchronousRequest:req
		queue:[NSOperationQueue mainQueue]
		completionHandler:^(NSURLResponse* res, NSData* data, NSError* error) {
			/*
			 * We don't handle errors with data,
			 * Shouldn't really ever happen unless there is a connection cut anyways.
			 */
			if (error != nil) {
				//[self failedToLoad];
			} else if ([data length] > 0) {
				[self saveImageData:data forUrl:connectionUrl];

				if ([self.imageUrl isEqualToString:connectionUrl]) {
					[self loadWithImageData:data];
				}
			} else {
				//[self failedToLoad];
			}
		}
	];
}

-(void)saveImageData:(NSData*)data forUrl:(NSString*)forUrl {
	if ([imageDataCache objectForKey:forUrl] == nil) {
		[imageDataCache setObject:data forKey:forUrl];
	}
}

-(BOOL)cacheContains:(NSString*)url {
	return [imageDataCache objectForKey:url] != nil;
}

-(void)loadFromCache:(NSString*)url {
	[self setLoading:NO animated:NO];
	NSData* imageData = [imageDataCache objectForKey:url];
	[self loadWithImageData:imageData];
}

-(void)loadWithImageData:(NSData*)data {
	[self setImage:[[UIImage alloc] initWithData:data]];
	[self setLoading:NO animated:YES];
}

-(void)realignElements {
	CGSize size = self.frame.size;
	[_indicator setCenter:CGPointMake(size.width / 2, size.height / 2)];
	[_shadeView setFrame:CGRectMake(0, 0, size.width, size.height)];
}

-(void)layoutSubviews {
	[self realignElements];
	[super layoutSubviews];
}
@end

