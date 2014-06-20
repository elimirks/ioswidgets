#import "DynamicScrollView.h"

#define PAGECONTROL_SIDE_PADDING 8

@interface DynamicScrollView() {
	UIPageControl* pageControl;
	
	// A little transparent-round background for the pageControl.
	UIView* pageControlContainer;
}
@property (nonatomic) NSMutableDictionary* accessedViews;
@end

@implementation DynamicScrollView
-(instancetype)initWithFrame:(CGRect)frame viewLoadDelegate:(id)del {
	if ((self = [super initWithFrame:frame])) {
		[self setupViewLoadDelegate:del];
		[self setAccessedViews:[NSMutableDictionary dictionary]];
	}
	return self;
}
-(void)setupViewLoadDelegate:(id)del {
	// Prepare the view.
	[self setBackgroundColor:[UIColor blackColor]];
	self.scrollsToTop = NO;
	self.showsVerticalScrollIndicator = NO;
	self.showsHorizontalScrollIndicator = NO;
	self.bounces = YES;
	self.delegate = self;
	self.viewLoadDelegate = del;
	self.pagingEnabled = YES;
	
	pageControl = [[UIPageControl alloc] init];
	// The frame will be set in the addStaticsToView method.
	pageControlContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
	[pageControlContainer setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.15]];
	
	[self reloadData];
	
	UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doDoubleTap)];
	doubleTap.numberOfTapsRequired = 2; 
	[self addGestureRecognizer:doubleTap];
}

-(void)doDoubleTap {
	int index = self.contentOffset.x / self.frame.size.width;
	UIScrollView* view = [self.accessedViews objectForKey:@(index)];
	
	if (view.zoomScale > 1.0f) {
		[view setZoomScale:1.0f animated:YES];
	} else {
		[view setZoomScale:2.0f animated:YES];
	}
}

// This should only be called on the sub-scroll views - so we don't have to worry about the subview index.
-(UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView {
	return [scrollView.subviews objectAtIndex:0];
}
-(void)addStaticsToView:(UIView*)drawView {
	CGFloat pageControlWidth = [pageControl sizeForNumberOfPages:pageControl.numberOfPages].width;
	
	[pageControlContainer.layer setCornerRadius:8];
	[pageControlContainer setFrame:CGRectMake(0, 0, pageControlWidth + 16, 16)];
	[pageControlContainer setCenter:CGPointMake(
		self.frame.origin.x + (self.frame.size.width / 2),
		self.frame.origin.y + (self.frame.size.height - 15)
	)];
	
	// Set the inital position.
	[self positionPageControl];
	
	[drawView addSubview:pageControlContainer];
	[drawView addSubview:pageControl];
}

-(void)drawViewAtIndex:(NSInteger)index {
	// We don't want to add the same subview twice.
	if ([self.accessedViews.allKeys containsObject:@(index)])
		return;
	
	// We have a scroll view for each sub view to allow zooming on the views.
	UIScrollView* sv = [[UIScrollView alloc] initWithFrame:CGRectMake(
		index * self.frame.size.width, 0,
		self.frame.size.width, self.frame.size.height
	)];
	[sv setScrollsToTop:NO];
	[sv setMaximumZoomScale:2.0f];
	[sv setDelegate:self];
	[sv setShowsVerticalScrollIndicator:NO];
	[sv setShowsHorizontalScrollIndicator:NO];
	
	UIView* view = [self.viewLoadDelegate viewFor:self atIndex:index];
	
	[view setFrame:CGRectMake(
		0, 0,
		self.frame.size.width, self.frame.size.height
	)];
	
	[sv addSubview:view];
	[self addSubview:sv];
	
	[self.accessedViews setObject:sv forKey:@(index)];
}
// Add the next sub view if it is needed
-(void)scrollViewDidScroll:(UIScrollView*)scrollView {
	// Make sure the scrollView isn't a sub scrollview
	if (scrollView == self) {
		// Round down the leftSideX to find the index. Round up the right to find the index as well.

		CGFloat viewWidth = self.frame.size.width;

		int leftVisibleIndex = self.contentOffset.x / viewWidth;
		int rightVisibleIndex = (self.contentOffset.x + viewWidth) / viewWidth;

		// We don't want the index to be beyond the scrollview.
		if (rightVisibleIndex >= (self.contentSize.width / viewWidth)) {
			rightVisibleIndex = leftVisibleIndex;
			// We don't have to check the left index because it should never be below 0.
		}

		// Set the page control current page to whichever page is more exposed.
		if ((int)self.contentOffset.x % (int)viewWidth > viewWidth / 2) {
			pageControl.currentPage = rightVisibleIndex;
		} else {
			pageControl.currentPage = leftVisibleIndex;
		}

		// The drawViewAtIndex method handles if the view exists or not.
		[self drawViewAtIndex:leftVisibleIndex];
		[self drawViewAtIndex:rightVisibleIndex];

		[self positionPageControl];
	}
}
// Tries to un-zoom the given index. Only unzooms if the view exists (has been accessed).
-(void)tryToUnZoomIndex:(NSInteger)index {
	if ([self.accessedViews.allKeys containsObject:@(index)]) {
		[[self.accessedViews objectForKey:@(index)] setZoomScale:1.0f animated:NO];
	}
}
-(void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView {
	if (scrollView == self) {
		int index = self.contentOffset.x / self.frame.size.width;
		
		// Unzoom the surrounding views.
		[self tryToUnZoomIndex:index - 1];
		[self tryToUnZoomIndex:index + 1];
	}
}

-(void)positionPageControl {
	// Only dynamically position if it needs to scroll.
	if (pageControlContainer.bounds.size.width < self.frame.size.width - PAGECONTROL_SIDE_PADDING * 2 == false) {
		CGFloat pageControlWidth = pageControlContainer.bounds.size.width + PAGECONTROL_SIDE_PADDING * 2;
		CGFloat viewWidth = self.frame.size.width;
		
		// Matt haz teh maths.
		CGFloat leftEdge = (- self.contentOffset.x / viewWidth) * ((float)(pageControlWidth - viewWidth) / pageControl.numberOfPages);
		
		// Issue with 5.0 where this throws an exception. It is a nice feature, but not vital.
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
			[pageControlContainer setCenter:CGPointMake(leftEdge + (pageControlWidth - PAGECONTROL_SIDE_PADDING) / 2, pageControlContainer.center.y)];
		}
	}
	[pageControl setCenter:pageControlContainer.center];
}

-(void)setFrame:(CGRect)frame {
	CGRect oldFrame = self.frame;
	// Current image index
	int currentImageIndex = self.contentOffset.x / oldFrame.size.width;
	//frame.size.height = frame.size.width * 0.75;
	[super setFrame:frame];
	
	// Shouldn't actually be chencking this, because the frame >shouldn't< ever be set to the same size.
	//if (oldFrame.size.width != self.frame.size.width);
	
	CGFloat desiredOffset = currentImageIndex * self.frame.size.width;
	
	[self setContentSize:CGSizeMake([self.viewLoadDelegate countOfViewsFor:self] * self.frame.size.width, self.frame.size.height)];
	[self setContentOffset:CGPointMake(desiredOffset, 0) animated:NO];
}

-(void)reloadDataAndKeepPosition {
	[self.accessedViews removeAllObjects];
	
	// Remove all of the old views.
	for (UIScrollView* i in self.subviews) {
		
		// If the view is visible, don't remove it, just resize it.
		if (i.frame.origin.x + i.frame.size.width >= self.contentOffset.x && i.frame.origin.x <= self.contentOffset.x + self.frame.size.width) {
			// Divide by the frame width instead of the screen width in case the screen size has changed.
			int index = i.frame.origin.x / i.frame.size.width;
			[self.accessedViews setObject:i forKey:@(index)];
			
			[i setZoomScale:1.0f animated:NO];
			// Resize the view in case the screen size has changed.
			[[i.subviews objectAtIndex:0] setFrame:CGRectMake(
				0, 0,
				self.frame.size.width, self.frame.size.height
			)];
			[i setContentSize:((UIView*)[i.subviews objectAtIndex:0]).frame.size];
			[i setFrame:CGRectMake(
				index * self.frame.size.width, 0,
				self.frame.size.width, self.frame.size.height
			)];
		} else {
			[i removeFromSuperview];
		}
	}
	
	// NOTE As it adds sub views, they will stay.
	// That way it will only keep the views that the user has view already.
	
	NSInteger viewCount = [self.viewLoadDelegate countOfViewsFor:self];
	
	[self setContentSize:CGSizeMake(viewCount * self.frame.size.width, self.frame.size.height)];
	
	pageControl.numberOfPages = viewCount;
	
	int currentIndex = self.contentOffset.x / self.frame.size.width;
	if (currentIndex < viewCount) {
		[self drawViewAtIndex:currentIndex];
	}
}

-(void)reloadData {
	// Remove all of the old views.
	for (UIView* i in self.subviews) {
		[i removeFromSuperview];
	}
	
	[self setContentOffset:CGPointMake(0, 0) animated:NO];
	
	[self.accessedViews removeAllObjects];
	
	// NOTE As it adds sub views, they will stay.
	// That way it will only keep the views that the user has view already.
	
	NSInteger viewCount = [self.viewLoadDelegate countOfViewsFor:self];
	
	self.contentSize = CGSizeMake(viewCount * self.frame.size.width, self.frame.size.height);
	
	pageControl.numberOfPages = viewCount;
	
	if (viewCount > 0) {
		// Show the initial view.
		[self drawViewAtIndex:0];
	}
}
@end

