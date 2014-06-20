#import <UIKit/UIKit.h>

#define SlidingPickerViewDidHideNotification \
	@"SlidingPickerViewDidHideNotification"
#define SlidingPickerViewDidShowNotification \
	@"SlidingPickerViewDidShowNotification"

@interface SlidingPickerView : UIView
@property (retain, nonatomic) IBOutlet UIPickerView* pickerView;
@property (retain, nonatomic) IBOutlet UINavigationBar* titleBar;
+(instancetype)new;
-(IBAction)done:(id)selector;
-(void)setHidden:(BOOL)hidden;
-(void)setHidden:(BOOL)hidden animated:(BOOL)animated;
-(void)setTitle:(NSString*)title;
-(void)setPickerDelegate:(id<UIPickerViewDelegate>)delegate;
-(void)setBarColor:(UIColor*)color;
@end

