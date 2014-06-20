ioswidgets
==========

A collection of several iOS widgets.

SlidingPickerView
-----------------

Used to provide a UIPickerView that will slide up from the bottom of the screen.

Usage:

```objective-c
// ...
[self.slidingPickerView setBarColor:[UIColor blueColor]];

[self addSubview:self.slidingPickerView];
[self.slidingPickerView setHidden:YES animated:NO];

[self.slidingPickerView setTitle:@"Title!"];
[self.slidingPickerView setPickerDelegate:pickerWrapper];
// ...

// When you want to show the picker view:
// This will make it appear with a nice slide up animation.
[self.slidingPickerView setHidden:NO animated:YES];

// To hide: (Sliding down)
[self.slidingPickerView setHidden:YES animated:YES];
```

NetworkImageView
----------------

Used to display a loading spinner/indicator while an image is being loaded from the network.
The images are cached using NSCache.

Usage:

```objective-c
// ...
NetworkImageView* image =
	[[NetworkImage alloc] initWithFrame:frame];
[image loadFromURL:@"http://example.com/foobar.png"];
[someView addSubView:image];
// ...
```

DynamicScrollView
-----------------

A UIScrollView that lazy-loads the sub views. The initial intention was for lazy loading UIImageViews.
Includes a page indicator that parallax scrolls if it doesn't have enough space to fit.

Note: This widget is probably due for a refactor :)

Usage:
```objective-c
DynamicScrollView* dynamic = [[DynamicScrollView alloc] initWithFrame:frame viewLoadDelegate:self];
[dynamic reloadDataAndKeepPosition];
// Ads some HUD stuff to to the super view
[dynamic addStaticsToView:self];

// ...

// DynamicScrollViewDelegate

-(NSInteger)countOfViewsFor:(DynamicScrollView*)dynamic {
	return 5;
}

-(UIView*)viewFor:(DynamicScrollView*)dynamic atIndex:(NSInteger)index {
	NSString* imageUrl = @"http://example.com/foo.png";
	
	NetworkImage* image =
		[[NetworkImage alloc] initWithFrame:dynamic.frame];
	[image loadFromURL:imageUrl];
	return image;
}
```

