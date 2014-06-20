ioswidgets
==========

A collection of several iOS widgets.

SlidingPickerView
-----------------

Used to provide a UIPickerView that will slide up from the bottom of the screen.

Usage:

```
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

```
	// ...
	NetworkImageView* image =
		[[NetworkImage alloc] initWithFrame:frame];
	[image loadFromURL:@"http://example.com/foobar.png"];
	[someView addSubView:image];
	// ...
```

