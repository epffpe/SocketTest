//
//  ViewController.h
//  SocketTest
//
//  Created by manolya atalay on 6/3/15.
//  Copyright (c) 2015 RNR Associates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSStreamDelegate>
@property (weak, nonatomic) IBOutlet UITextField *inputNameField;
@property (weak, nonatomic) IBOutlet UIView *joinView;
- (IBAction)joinChat:(id)sender;

@end

NSInputStream *inputStream;
NSOutputStream *outputStream;
NSMutableArray * messages;