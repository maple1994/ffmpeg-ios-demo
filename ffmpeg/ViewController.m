//
//  ViewController.m
//  ffmpeg
//
//  Created by Maple on 2021/9/15.
//

#import "ViewController.h"
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libavfilter/avfilter.h>
#import "ffmpeg.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showInfo:avcodec_configuration()];
}

- (IBAction)showProtocol:(id)sender {
    char info[40000] = {0};
    av_register_all();
    struct URLProtocol *pup = NULL;
    struct URLProtocol **p_temp = &pup;
    // 0 = In 1 = Out
    avio_enum_protocols((void **)p_temp, 0);
    while((*p_temp) != NULL) {
        sprintf(info, "%s[In ][%10s]\n", info, avio_enum_protocols((void **)p_temp, 0));
    }
    [self showInfo:info];
}

- (IBAction)showAvFormat:(id)sender {
    char info[40000] = {0};
    av_register_all();
    AVInputFormat *inFmt = av_iformat_next(NULL);
    AVInputFormat *outFmt = av_iformat_next(NULL);
    
    while(inFmt != NULL) {
        sprintf(info, "%s [In ]%10s\n", info, inFmt->name);
        inFmt = inFmt->next;
    }
    
    while(outFmt != NULL) {
        sprintf(info, "%s [out ]%10s\n", info, outFmt->name);
        outFmt = outFmt->next;
    }
    
    [self showInfo:info];
}

- (IBAction)showAvCodec:(id)sender {
    char info[40000] = {0};
    av_register_all();
    
    AVCodec *c_temp = av_codec_next(NULL);
    while(c_temp != NULL) {
        if(c_temp->decode != NULL) {
            sprintf(info, "%s[Dec]", info);
        }else {
            sprintf(info, "%s[Enc]", info);
        }
        switch (c_temp->type) {
            case AVMEDIA_TYPE_VIDEO:
                sprintf(info, "%s[Video]", info);
                break;
            case AVMEDIA_TYPE_AUDIO:
                sprintf(info, "%s[Audio]", info);
                break;
            default:
                sprintf(info, "%s[Other]", info);
                break;
        }
        sprintf(info, "%s%10s\n", info, c_temp->name);
        c_temp = c_temp->next;
    }
    [self showInfo:info];
}

- (IBAction)showAvFilter:(id)sender {
    char info[40000] = {0};
    avfilter_register_all();
    AVFilter *f_temp = (AVFilter *)avfilter_next(NULL);
    while(f_temp != NULL) {
        sprintf(info, "%s[%10s]\n", info, f_temp->name);
        f_temp = f_temp->next;
    }
    [self showInfo:info];
}

- (IBAction)showConfigure:(id)sender {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"out.mp4" ofType:nil];
    NSString *outPath = @"/Users/maple/Desktop/out.gif";
//    int argc = 4;
//    char **arguments = (char **)calloc(argc, sizeof(char *));
//    if(arguments != NULL) {
//        arguments[0] = "ffmpeg";
//        arguments[1] = "-i";
//        arguments[2] = (char *)[filePath UTF8String];
//        arguments[3] = (char *)[outPath UTF8String];
//    }
    NSString *cmmondStr = [NSString stringWithFormat:@"ffmpeg -i %@ %@", filePath, outPath];
    NSMutableArray *argv_arr = [cmmondStr componentsSeparatedByString:@" "].mutableCopy;
    int argc = (int)argv_arr.count;
    char **arguments = (char **)calloc(argc, sizeof(char *));
    for(int i = 0; i < argc; i++) {
        NSString *str = argv_arr[i];
        arguments[i] = (char *)[str UTF8String];
    }
    ffmpeg_main(argc, arguments);
}

- (void)showInfo:(const char *)chs
{
    self.infoLabel.text = [NSString stringWithFormat:@"%s", chs];
}

@end
