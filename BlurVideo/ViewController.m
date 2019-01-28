//
//  ViewController.m
//  BlurVideo
//
//  Created by 刘东旭 on 2019/1/27.
//  Copyright © 2019年 刘东旭. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@implementation ViewController {
    NSString *newPath,*p;
    int i;
    BOOL isRePoint;
    NSPoint firstPoint,lastPoint;
    float x,y,w,h;
    NSSize size;
    NSString *fileName;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isRePoint = YES;
    // Do any additional setup after loading the view.
}

- (IBAction)importVideo:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[@"mp4", @"mov", @"flv"]];//可以选择的格式
    [panel setAllowsOtherFileTypes:YES];
    __weak typeof(self)weakSelf = self;
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {//点击确定以后
            NSString *path = [panel.URLs.firstObject path];
            self->fileName = path.lastPathComponent;
            self->newPath = [path stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
            NSLog(@"%@",self->newPath);
            self->p = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/MacOS"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf grabimage:self->newPath forTime:5];
                AVAsset *asset = [AVAsset assetWithURL:panel.URLs.firstObject];
                
                self->size = NSMakeSize(asset.naturalSize.width, asset.naturalSize.height);
                self.imageView.frame = NSMakeRect(0, 0, self->size.width/2, self->size.height);
            });
            
        }
    }];
}

- (void)grabimage:(NSString *)path forTime:(int)time {
    NSString *stringFFmpeg = [NSString stringWithFormat:@"%@/ffmpeg -i %@ -ss 00:00:0%d -t 1 -r 1 imagetmp.png -y",self->p,path,time];
    NSLog(@"%@",stringFFmpeg);
    NSString *cmd = [self executeCommand:stringFFmpeg];
    NSLog(@"cmdResult:%@", cmd);
    NSString *sabox = [NSString stringWithFormat:@"%@/imagetmp.png",NSHomeDirectory()];
    self.imageView.image = [[NSImage alloc] initWithContentsOfFile:sabox];
}

- (NSString *)executeCommand: (NSString *)cmd {
    NSString *output = [NSString string];
    FILE *pipe = popen([cmd cStringUsingEncoding: NSUTF8StringEncoding], "r+");
    if (!pipe)
        return @"";
    
    char buf[1024];
    while(fgets(buf, 1024, pipe)) {
        output = [output stringByAppendingFormat: @"%s", buf];
    }
    
    pclose(pipe);
    return output;
    
}

- (IBAction)test:(id)sender {
    NSLog(@"imageViewSize:%@",NSStringFromSize(self.imageView.frame.size));
    [self caculationPoint];
    NSString *stringFFmpeg = [NSString stringWithFormat:@"%@/ffmpeg -i %@ -vf delogo=x=%d:y=%d:w=%d:h=%d -ss 00:00:05 -t 1 %@ -y",self->p,self->newPath,(int)x,(int)y,(int)w,(int)h,self->fileName];
    NSLog(@"test=====>%@",stringFFmpeg);
    NSString *cmd = [self executeCommand:stringFFmpeg];
    NSLog(@"cmdResult:%@", cmd);
    NSString *sabox = [NSString stringWithFormat:@"%@/%@",NSHomeDirectory(),self->fileName];
    [self grabimage:sabox forTime:0];
}

- (IBAction)repoint:(id)sender {
    isRePoint = YES;
    i = 0;
    x=y=w=h=0;
    [self grabimage:self->newPath forTime:5];
}

- (IBAction)start:(id)sender {
    [self caculationPoint];
    NSString *stringFFmpeg = [NSString stringWithFormat:@"%@/ffmpeg -i %@ -vf delogo=x=%f:y=%f:w=%f:h=%f %@ -y",self->p,self->newPath,x,y,w,h,self->fileName];
    NSLog(@"%@",stringFFmpeg);
    NSString *startBlur = [self executeCommand:stringFFmpeg];
    NSLog(@"cmdResult:%@", startBlur);
    NSString *open = [NSString stringWithFormat:@"open %@",NSHomeDirectory()];
    [self executeCommand:open];
    
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint point = [event locationInWindow];
    if (isRePoint) {
        if (i == 0) {
            point = [self.view convertPoint:NSMakePoint(point.x, point.y) toView:self.imageView];
            NSPoint p = NSMakePoint(point.x, size.height - point.y);
            firstPoint = p;
            NSLog(@"firstPoint===>%@",NSStringFromPoint(firstPoint));
        } else {
            point = [self.view convertPoint:NSMakePoint(point.x, point.y) toView:self.imageView];
            NSPoint p = NSMakePoint(point.x, size.height - point.y);
            lastPoint = p;
            NSLog(@"lastPoint===>%@",NSStringFromPoint(lastPoint));
        }
        i++;
    }
}

- (void)caculationPoint {
    x = firstPoint.x;
    y = firstPoint.y;
    w = (lastPoint.x - firstPoint.x);
    h = (lastPoint.y - firstPoint.y);
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
