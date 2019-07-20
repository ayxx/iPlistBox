//
//  ViewController.m
//  CreatePlistFile
//
//  Created by AY on 2019/7/20.
//  Copyright © 2019 ayxx. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak) IBOutlet NSTextField *nameTF;
@property (weak) IBOutlet NSTextField *bundleTF;
@property (weak) IBOutlet NSTextField *ipaTF;
@property (weak) IBOutlet NSTextField *iconTF;
@property (nonatomic, strong) NSProgressIndicator * indicator;
@end

@implementation ViewController

- (NSProgressIndicator *)indicator {
    if (!_indicator) {
        NSProgressIndicator *indicator = [[NSProgressIndicator alloc]init];
        NSRect firstFrame = [[NSApp mainWindow] frame];
        indicator.frame = CGRectMake((firstFrame.size.width - 40)/2, (firstFrame.size.height - 40)/2, 40, 40);
        indicator.style = NSProgressIndicatorSpinningStyle;
        //这种方式只是给背景rect添加了背景色。
        indicator.wantsLayer = YES;
        indicator.layer.backgroundColor = [NSColor cyanColor].CGColor;
        indicator.controlSize = NSControlSizeRegular;
        [indicator sizeToFit];
        self.indicator = indicator;
        [self.view.window.contentView addSubview:indicator];
    }
    return _indicator;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.title = @"";
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)createTap:(id)sender {
    if (self.nameTF.stringValue.length==0) {
        [self showAlert:self.nameTF.placeholderString];
        return;
    }
    if (self.bundleTF.stringValue.length==0) {
        [self showAlert:self.bundleTF.placeholderString];
        return;
    }
    if (self.ipaTF.stringValue.length==0) {
        [self showAlert:self.ipaTF.placeholderString];
        return;
    }
    if (![self.ipaTF.stringValue hasPrefix:@"https://"]) {
        [self showAlert:self.ipaTF.placeholderString];
        return;
    }
    if (self.iconTF.stringValue.length==0) {
        [self showAlert:self.iconTF.placeholderString];
        return;
    }
    if (!([self.iconTF.stringValue hasPrefix:@"https://"] || [self.iconTF.stringValue hasPrefix:@"https//"])) {
        [self showAlert:self.iconTF.placeholderString];
        return;
    }
    // 写入数据
    NSString *plistPath = [self writeData];
    // 导出模板
    [self savePanelWith:plistPath];
}

- (NSString *)writeData {
//    [self.indicator startAnimation:nil];
//    self.indicator.hidden = NO;
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray objectAtIndex:0];
    //获取文件的完整路径
    NSString *plistPath = [path stringByAppendingPathComponent:@"new.plist"];
//    NSLog(@"获取文件的完整路径: %@", plistPath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:plistPath]) {
        // 获取模板
        NSString *dataPath = [[NSBundle mainBundle]pathForResource:@"iOS" ofType:@"plist"];
        NSError *error;
        //拷贝文件到沙盒的document下
        if([fileManager copyItemAtPath:dataPath toPath:plistPath error:&error]) {
            NSLog(@"copy success");
        } else{
            NSLog(@"%@",error);
        }
    }
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
//    NSLog(@"dataDic: %@", dataDic);
    //修改模板
    NSMutableArray *items = dataDic[@"items"];
    NSMutableDictionary *dic = items.firstObject;
    NSMutableArray *assets = dic[@"assets"];
    for (NSMutableDictionary *mdic in assets) {
        if ([mdic[@"kind"] isEqualToString:@"software-package"]) {
            mdic[@"url"] = self.ipaTF.stringValue;
        }
        if ([mdic[@"kind"] isEqualToString:@"display-image"]) {
            mdic[@"url"] = self.iconTF.stringValue;
        }
    }
    NSMutableDictionary *metadata = dic[@"metadata"];
    metadata[@"bundle-identifier"] = self.bundleTF.stringValue;
    metadata[@"title"] = self.nameTF.stringValue;
//    NSLog(@" new dataDic: %@", dataDic);
    // 写入模板
    [dataDic writeToFile:plistPath atomically:YES];
    return plistPath;
}

- (void)showAlert:(NSString*)message {
    NSAlert *alert = [[NSAlert alloc]init];
    [alert addButtonWithTitle:@"好的"];
    [alert setMessageText:@"抱歉!"];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
    }];
}

- (void)savePanelWith:(NSString*)plistPath {
//    [self.indicator stopAnimation:nil];
//    self.indicator.hidden = YES;
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.title = @"保存plist";
    [panel setMessage:@"选择保存的地址"];
    [panel setAllowsOtherFileTypes:YES];
    [panel setAllowedFileTypes:@[@"plist"]];
    [panel setExtensionHidden:NO];
    [panel setCanCreateDirectories:YES];
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSString *path = [[panel URL]path];
            NSData *data = [NSData dataWithContentsOfFile:plistPath];
            [data writeToFile:path atomically:YES];
        }
    }];
}

@end
