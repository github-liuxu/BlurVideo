//
//  ViewController.m
//  BlurVideo
//
//  Created by 刘东旭 on 2019/1/27.
//  Copyright © 2019年 刘东旭. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController {
    NSString *newPath,*p;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
//    self.imageView.image = [NSImage imageNamed:@"timg.jpg"];
}

- (IBAction)importVideo:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[@"mp4", @"mov", @"flv"]];//可以选择的格式
    [panel setAllowsOtherFileTypes:YES];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {//点击确定以后
            NSString *path = [panel.URLs.firstObject path];
            self->newPath = [path stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
            NSLog(@"%@",self->newPath);
            self->p = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/MacOS"];
            NSString *stringFFmpeg = [NSString stringWithFormat:@"%@/ffmpeg -i %@ -ss 00:00:02 -t 1 -r 1 imagetmp.png -y",self->p,self->newPath];
            NSLog(@"%@",stringFFmpeg);
            NSLog(@"cmdResult:%@", [self executeCommand:stringFFmpeg]);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.imageView.image = [[NSImage alloc] initWithContentsOfFile:@"/Users/liudongxu/Library/Containers/com.liudongxu.BlurVideo/Data/imagetmp.png"];
            });
        }
    }];
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
    NSString *stringFFmpeg = [NSString stringWithFormat:@"%@/ffmpeg -i %@ -vf delogo=x=1:y=1:w=1:h=1 -ss 00:00:02 -t 1 -test.mp4 -y",self->p,self->newPath];
    NSLog(@"%@",stringFFmpeg);
    NSLog(@"cmdResult:%@", [self executeCommand:stringFFmpeg]);
    [self executeCommand:@"open /Users/liudongxu/Library/Containers/com.liudongxu.BlurVideo/Data/imagetmp.png"];
}

- (IBAction)start:(id)sender {
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
