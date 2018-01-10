#import <Foundation/Foundation.h>
#import <pthread.h>
#import "VGSLayer.h"

@interface VGSView : NSView
@property (atomic, readwrite) VGSLayer *vgsLayer;
@property (atomic, readwrite) BOOL isFullScreen;
@property CVDisplayLinkRef displayLink;
- (id)initWithFrame:(CGRect)frame;
- (void)releaseDisplayLink;
@end
