#import <Cocoa/Cocoa.h>

@class VGSView;

@interface ViewController : NSViewController
@property (atomic, nonnull) NSImageView *bg;
@property (atomic, nonnull) VGSView *vram;
@end
