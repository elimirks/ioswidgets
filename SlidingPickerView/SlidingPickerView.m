#import "SlidingPickerView.h"

#define ANIMATION_DURATION 0.2
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define IS_IOS_7_OR_LATER (IOS_VERSION >= 7.0)

@implementation SlidingPickerView
+(instancetype)new {
	NSArray* subviewArray = [[NSBundle mainBundle]
		loadNibNamed:@"SlidingPickerView"
		owner:nil
		options:nil];
	SlidingPickerView* picker = (SlidingPickerView*)subviewArray[0];
	[picker setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];

	if (IS_IOS_7_OR_LATER) {
		UIBarButtonItem* rightItem = picker.titleBar.topItem.rightBarButtonItem;
		[rightItem setTintColor:[UIColor whiteColor]];
	}
	return picker;
}

-(IBAction)done:(id)selector {
	[self setHidden:YES animated:YES];
	[[NSNotificationCenter defaultCenter]
		postNotificationName:SlidingPickerViewDidHideNotification
		object:self];
}

-(void)setHidden:(BOOL)hidden {
	[self setHidden:hidden animated:NO];
}

-(void)setHidden:(BOOL)hidden animated:(BOOL)animated {
	if (animated) {
		if (hidden) {
			if (![self isHidden]) {
				[self animateToHide];
			}
		} else {
			if ([self isHidden]) {
				[self animateToShow];
				[[NSNotificationCenter defaultCenter]
					postNotificationName:SlidingPickerViewDidShowNotification
					object:self];
			}
		}
	} else {
		[super setHidden:hidden];
	}
}

-(void)animateToHide {
	[UIView animateWithDuration:ANIMATION_DURATION
		animations:^(void) {
			[self setFrame:[self frameForHidden:YES]];
		}
		completion:^(BOOL finished) {
			// To prevent selections from being made after this view is gone.
			[[self pickerView] setDelegate:nil];
			[super setHidden:YES];
		}
	];
}

-(void)animateToShow {
	[self setFrame:[self frameForHidden:YES]];
	[super setHidden:NO];
	[UIView animateWithDuration:ANIMATION_DURATION
		animations:^(void) {
			[self setFrame:[self frameForHidden:NO]];
		}
		completion:^(BOOL finished) {}
	];
}

-(CGRect)frameForHidden:(BOOL)hidden {
	if (self.superview == nil)
		return CGRectZero;
	
	CGRect parentRect = self.superview.bounds;
	CGRect newViewFrame = self.frame;
	newViewFrame.size.width = parentRect.size.width;
	
	if (hidden) {
		newViewFrame.origin.y = parentRect.origin.y + parentRect.size.height;
	} else {
		newViewFrame.origin.y =
			parentRect.origin.y + parentRect.size.height - newViewFrame.size.height;
	}
	
	return newViewFrame;
}

-(void)setTitle:(NSString*)title {
	[self.titleBar.topItem setTitle:title];
}

-(void)setPickerDelegate:(id<UIPickerViewDelegate>)delegate {
	[self.pickerView setDelegate:delegate];
}

-(void)setBarColor:(UIColor*)color {
	if (IS_IOS_7_OR_LATER) {
		[self.titleBar setBarTintColor:color];
	} else {
		[self.titleBar setTintColor:color];
	}
}
@end

