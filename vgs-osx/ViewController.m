#import "VGSView.h"
#import "ViewController.h"

int vgsint_init(const char *bin);

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // self.view.frame = [NSScreen mainScreen].frame;
    CALayer *layer = [CALayer layer];
    [layer setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0)];
    [self.view setWantsLayer:YES];
    [self.view setLayer:layer];
    
    // initialize VGS system
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *docs_dir = [paths objectAtIndex:0];
    BOOL isDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:docs_dir isDirectory:&isDir]) {
        if (![fileManager createDirectoryAtPath:docs_dir withIntermediateDirectories:YES attributes:nil error:NULL]) {
            NSLog(@"Error: Create folder failed: %@", docs_dir);
        }
    }
    
    /* TODO: load Rom data
    vgsint_setdir([docs_dir UTF8String]);
    NSString *fullPath;
    fullPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"romdata.bin"];
    if (vgsint_init([fullPath UTF8String])) {
        _exit(-1);
    }
     */
    
    // initialize BG view
    self.bg = [[NSImageView alloc] initWithFrame:[self calcVramRect]];
    [self.bg setImage:[NSImage imageNamed:@"background.png"]];
    [self.bg setImageScaling:NSImageScaleAxesIndependently];
    [self.view addSubview:self.bg];
    
    // initialize VGS view
    self.vram = [[VGSView alloc] initWithFrame:[self calcVramRect]];
    [self.view addSubview:self.vram];
    
    // setup input
    [self.view addTrackingRect:self.view.frame owner:[self.view window] userData:nil assumeInside:NO];
    self.view.window.title = @"SUZUKI PLAN - Video Game System";
    [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidResizeNotification
                                                      object:self.view.window
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notif) {
                                                      self.bg.frame = self.view.window.contentView.frame;
                                                      self.vram.frame = [self calcVramRect];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:NSViewFrameDidChangeNotification
                                                      object:self.view
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      self.bg.frame = self.view.window.contentView.frame;
                                                      self.vram.frame = [self calcVramRect];
                                                  }];
}

- (NSRect)calcVramRect
{
    if (self.view.window.contentView.frame.size.width) {
        self.view.frame = self.view.window.contentView.frame;
    } else {
        self.view.frame = CGRectMake(0, 0, 512, 480);
    }
    if (self.view.frame.size.height < self.view.frame.size.width) {
        CGFloat height = self.view.frame.size.height;
        CGFloat width = height / 15 * 16;
        CGFloat x = (self.view.frame.size.width - width) / 2;
        return NSRectFromCGRect(CGRectMake(x, 0, width, height));
    } else {
        CGFloat width = self.view.frame.size.width;
        CGFloat height = width / 16 * 15;
        CGFloat y = (self.view.frame.size.height - height) / 2;
        return NSRectFromCGRect(CGRectMake(0, y, width, height));
    }
}

- (void)viewWillAppear
{
    [self.view.window setBackgroundColor:[NSColor blackColor]];
    [self.view.window toggleFullScreen:self.view.window.screen];
    [self disableMouse];
    
    [self.view.window makeFirstResponder:self.vram];
    
    //[self.view.window setTitleVisibility:NSWindowTitleHidden];
    // self.view.window.level = NSScreenSaverWindowLevel;
    
    //[self.view.window.contentView enterFullScreenMode:self.view.window.screen withOptions:nil];
    //[self.view.window makeFirstResponder:self.vram];
    //[NSCursor hide];
}

- (void)disableMouse
{
    CGPoint centerPoint = CGPointMake(self.view.window.screen.frame.size.width / 2, self.view.window.screen.frame.size.height / 2);
    CGWarpMouseCursorPosition(centerPoint);
    CGAssociateMouseAndMouseCursorPosition(FALSE);
    CGDisplayHideCursor(kCGDirectMainDisplay);
}

- (void)viewDidAppear
{
    self.view.window.title = @"SUZUKI PLAN - Video Game System";
}

- (void)viewWillDisappear
{
    [self.vram releaseDisplayLink];
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

@end

