#import <pthread.h>
#import "VGSLayer.h"

#define INTERLACE

extern int g_request;
static unsigned short imgbuf[2][256 * 240 * 2];
static CGContextRef img[2];
static pthread_t tid = 0;
static volatile int bno;
static volatile bool event_flag = false;
static volatile bool alive_flag = true;
static volatile bool end_flag = false;

@implementation VGSLayer

// Main loop
static void *GameLoop(void *args)
{
    /*
    int i;
    unsigned short *buf;
    unsigned char *bg;
    unsigned char *sp;
     */

    while (alive_flag) {
        while (event_flag) {
            usleep(100);
        }
        // TODO: call AP procedure
        /*
        if (_pause) {
            vgs2_pause();
        } else {
            if (vgs2_loop()) {
                dispatch_async(dispatch_get_main_queue(), ^{
                  [VGSLayer onExit];
                });
            }
        }
        */

        // TODO: VRAM to CG image buffer
        /*
        buf = (unsigned short *)imgbuf[bno];
        bg = _vram.bg;
        sp = _vram.sp;
        for (i = 0; i < 61440; i++) {
            if (*sp) {
                *buf = ADPAL[*sp];
                *sp = 0;
            } else {
                *buf = ADPAL[*bg];
            }
            bg++;
            sp++;
            buf++;
        }
        */
        event_flag = true;
    }
    end_flag = true;
    return NULL;
}

+ (id)defaultActionForKey:(NSString *)key
{
    return nil;
}

- (id)init
{
    if (self = [super init]) {
        self.opaque = NO;
        img[0] = nil;
        img[1] = nil;
        // create image buffer
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        for (int i = 0; i < 2; i++) {
            img[i] = CGBitmapContextCreate(imgbuf[i], 256, 240, 5, 2 * 256, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder16Little);
        }
        CFRelease(colorSpace);
        // start buffering thread
        pthread_create(&tid, NULL, GameLoop, NULL);
        struct sched_param param;
        memset(&param, 0, sizeof(param));
        param.sched_priority = 46;
        pthread_setschedparam(tid, SCHED_OTHER, &param);
    }
    return self;
}

- (void)display
{
    bno = 1 - bno;       // flip to another vram
    event_flag = false;  // start another buffering
    // visible the previous buffer
    CGImageRef cgImage = CGBitmapContextCreateImage(img[1 - bno]);
    self.contents = (__bridge id)cgImage;
    CFRelease(cgImage);
}

+ (void)onExit
{
    NSLog(@"exit app");
    [NSApp terminate:self];
}

- (void)dealloc
{
    alive_flag = false;
    while (!end_flag)
        usleep(1000);
    for (int i = 0; i < 2; i++) {
        if (img[i] != nil) {
            CFRelease(img[i]);
            img[i] = nil;
        }
    }
}
@end
