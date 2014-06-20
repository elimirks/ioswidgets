#import <UIKit/UIKit.h>

@interface NetworkImageView : UIImageView<NSURLConnectionDataDelegate>
/*! \brief Set whether the view should show a loading indicator or not.
 * \param isHidden Whether the view should show the loading indicator or not.
 */
-(void)setLoading:(BOOL)loading animated:(BOOL)animated;

/*! \brief Initialize.
 * \param frameRect The frame to set to the view.
 */
-(instancetype)initWithFrame:(CGRect)frameRect;

/*! \brief Load the image from the specified URL.
 * \param image The URL to the image
 */
-(void)loadFromURL:(NSString*)imageURL;

//! \brief Realigns the spinner
-(void)realignElements;
@end

