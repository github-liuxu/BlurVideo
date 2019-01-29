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
    NSString *seekTime;
    __weak IBOutlet NSTextField *label;
    float scale;
    __weak IBOutlet NSLayoutConstraint *imageViewWidth;
    __weak IBOutlet NSLayoutConstraint *imageViewHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    scale = 1;
    isRePoint = YES;
    seekTime = @"00:00:05";
    label.stringValue = seekTime;
}

- (IBAction)importVideo:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
//    [panel setAllowedFileTypes:@[@"mp4", @"mov", @"flv"]];//可以选择的格式
    [panel setAllowsOtherFileTypes:YES];
    __weak typeof(self)weakSelf = self;
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {//点击确定以后
            NSString *path = [panel.URLs.firstObject path];
            NSString *p = [path stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
            p = [p stringByReplacingOccurrencesOfString:@"(" withString:@"\\("];
            p = [p stringByReplacingOccurrencesOfString:@")" withString:@"\\)"];
            p = [p stringByReplacingOccurrencesOfString:@"[" withString:@"\\["];
            p = [p stringByReplacingOccurrencesOfString:@"]" withString:@"\\]"];
            p = [p stringByReplacingOccurrencesOfString:@"!" withString:@"\\!"];
            self->newPath = p;
            self->fileName = p.lastPathComponent;
            NSLog(@"%@",self->newPath);
            self->p = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/MacOS"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf grabimage:self->newPath forTime:self->seekTime];
//                AVAsset *asset = [AVAsset assetWithURL:panel.URLs.firstObject];
//                self->size = NSMakeSize(asset.naturalSize.width, asset.naturalSize.height);
                self->size = NSMakeSize(self.imageView.image.size.width, self.imageView.image.size.height);
                if (self->size.width > 1280 && self->size.height > 720) {
                    self->imageViewWidth.constant = self->size.width/2;
                    self->imageViewHeight.constant = self->size.height/2;
                    self->scale = 2;
                } else {
                    self->imageViewWidth.constant = self->size.width;
                    self->imageViewHeight.constant = self->size.height;
                    self->scale = 1;
                }
            });
            
        }
    }];
}

- (void)grabimage:(NSString *)path forTime:(NSString *)time {
    NSString *stringFFmpeg = [NSString stringWithFormat:@"%@/ffmpeg -i %@ -ss %@ -t 1 -r 1 imagetmp.png -y",self->p,path,time];
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
    NSString *stringFFmpeg = [NSString stringWithFormat:@"%@/ffmpeg -i %@ -vf delogo=x=%d:y=%d:w=%d:h=%d -ss %@ -t 1 %@ -y",self->p,self->newPath,(int)x,(int)y,(int)w,(int)h,seekTime,self->fileName];
    NSLog(@"test=====>%@",stringFFmpeg);
    NSString *cmd = [self executeCommand:stringFFmpeg];
    NSLog(@"cmdResult:%@", cmd);
    NSString *sabox = [NSString stringWithFormat:@"%@/%@",NSHomeDirectory(),self->fileName];
    [self grabimage:sabox forTime:@"00:00:00"];
}

- (IBAction)repoint:(id)sender {
    isRePoint = YES;
    i = 0;
    x=y=w=h=0;
    [self grabimage:self->newPath forTime:seekTime];
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
            NSPoint p = NSMakePoint(point.x*scale, (size.height - point.y*scale));
            firstPoint = p;
            NSLog(@"firstPoint===>%@",NSStringFromPoint(firstPoint));
        } else {
            point = [self.view convertPoint:NSMakePoint(point.x, point.y) toView:self.imageView];
            NSPoint p = NSMakePoint(point.x*scale, (size.height - point.y*scale));
            lastPoint = p;
            NSLog(@"lastPoint===>%@",NSStringFromPoint(lastPoint));
        }
        i++;
    }
}
- (IBAction)textChanged:(NSTextField *)sender {
    seekTime = sender.stringValue;
    [self grabimage:self->newPath forTime:seekTime];
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
