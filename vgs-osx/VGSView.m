#import <Foundation/NSURL.h>
#import "VGSView.h"

static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now, const CVTimeStamp *outputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *context);

@implementation VGSView

+ (Class)layerClass
{
    return [VGSLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"frame: %@,%@ - %@x%@", @(frame.origin.x), @(frame.origin.y), @(frame.size.width), @(frame.size.height));
    if ((self = [super initWithFrame:frame]) != nil) {
        NSLog(@"set layer");
        [self setWantsLayer:YES];
        self.vgsLayer = [VGSLayer layer];
        [self setLayer:self.vgsLayer];
        //[self.vgsLayer setDelegate:self];
        //[self.vgsLayer setNeedsDisplay];
        CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
        CVDisplayLinkSetOutputCallback(_displayLink, MyDisplayLinkCallback, (__bridge void *)self);
        CVDisplayLinkStart(_displayLink);
    }
    return self;
}

- (void)releaseDisplayLink
{
    NSLog(@"release vsync listener");
    if (_displayLink) {
        CVDisplayLinkStop(_displayLink);
        CVDisplayLinkRelease(_displayLink);
        _displayLink = nil;
    }
}

- (void)vsync
{
    [self.vgsLayer setNeedsDisplay];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)keyDown:(NSEvent *)event
{
}

- (void)keyUp:(NSEvent *)event
{
}

static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now, const CVTimeStamp *outputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *context)
{
    //[(__bridge VGSLayer *)context performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
    [(__bridge VGSLayer *)context performSelectorOnMainThread:@selector(vsync) withObject:nil waitUntilDone:NO];
    return kCVReturnSuccess;
}

@end
