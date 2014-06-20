#import <UIKit/UIKit.h>

@protocol DynamicScrollViewDelegate;

//! \brief Neat little lazy load scrolling widget.
@interface DynamicScrollView : UIScrollView<UIScrollViewDelegate>
@property(assign, nonatomic) id <DynamicScrollViewDelegate> viewLoadDelegate;

-(DynamicScrollView*)initWithFrame:(CGRect)frame viewLoadDelegate:(id)del;
//! \brief There are some objects that shouldn't scroll.
-(void)addStaticsToView:(UIView*)drawView;
//! \brief Refreshes the view and it's contents, but keeps the current photo alive.
-(void)reloadDataAndKeepPosition;
//! \brief Refreshes the view and it's contents..
-(void)reloadData;
@end

@protocol DynamicScrollViewDelegate<NSObject>
//! \brief Returns the amount of views.
-(NSInteger)countOfViewsFor:(DynamicScrollView*)dynamic;

//! \brief Returns the view at the specified index.
-(UIView*)viewFor:(DynamicScrollView*)dynamic atIndex:(NSInteger)index;
@end

