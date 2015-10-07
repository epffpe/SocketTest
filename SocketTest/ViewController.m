//
//  ViewController.m
//  SocketTest
//
//  Created by manolya atalay on 6/3/15.
//  Copyright (c) 2015 RNR Associates. All rights reserved.
//

#import "ViewController.h"
#import <CFNetwork/CFNetwork.h>
#import "AsyncUdpSocket.h"

typedef struct {
    uint32_t kind;
    uint32_t addr;
    uint32_t var0;
}udpPacket_t;

@interface ViewController () <AsyncUdpSocketDelegate>
@property (strong,nonatomic) AsyncUdpSocket *listenSocket;
@end

@implementation ViewController

@synthesize inputNameField;
@synthesize joinView;



-(AsyncUdpSocket *)listenSocket
{
    if(!_listenSocket){
        _listenSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    }
    return _listenSocket;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initNetworkCommunication];
    messages = [[NSMutableArray alloc] init];
}

- (void)viewDidUnload
{
    [self setInputNameField:nil];
    [self setJoinView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
- (IBAction)UDP:(id)sender
{
    NSError *error = nil;
    
    if (![self.listenSocket bindToPort:5001 error:&error]) {
        NSLog(@"Server error");
        return;
    }
    [self.listenSocket receiveWithTimeout:-1 tag:0];
}

-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data
           withTag:(long)tag
          fromHost:(NSString *)host
              port:(UInt16)port
{
    udpPacket_t *udpPacket = (udpPacket_t *)[data bytes];
    NSLog(@"tag:%ld, kind:%u, addr:%u, var0:%u",tag, udpPacket->kind, udpPacket->addr, udpPacket->var0);
    [self.listenSocket receiveWithTimeout:-1 tag:0];
//    [data bytes];
//    uint8_t txDataBytes[10];
//    txDataBytes[0] = 0;
//    NSData *txData = [NSData dataWithBytes:txDataBytes length:10];
//    [self.listenSocket sendData:txData toHost:host port:1234 withTimeout:2.0 tag:0];
    return YES;
}

- (IBAction)joinChat:(id)sender {
    //GET /index.htm HTTP/1.1
//    NSString *response  = [NSString stringWithFormat:@"logon,%@", inputNameField.text];
    NSString *response  = @"GET /index.htm HTTP/1.1\n\n\n\n";
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
    
}

- (void)initNetworkCommunication {
    
    uint portNo = 80;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"www.google.com", portNo, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
}

/*
 - (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
 NSLog(@"stream event %i", streamEvent);
 }
 */
//-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
//    typedef enum {
//        NSStreamEventNone = 0,
//        NSStreamEventOpenCompleted = 1 << 0,
//        NSStreamEventHasBytesAvailable = 1 << 1,
//        NSStreamEventHasSpaceAvailable = 1 << 2,
//        NSStreamEventErrorOccurred = 1 << 3,
//        NSStreamEventEndEncountered = 1 << 4
//    };
    uint8_t buffer[1024];
    NSInteger len;
    
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened now");
            break;
        case NSStreamEventHasBytesAvailable:
            NSLog(@"has bytes");
            if (theStream == inputStream) {
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
//                            NSLog(@"server said: %@", output);
                            NSLog(@"server said: xxx");
                        }
                    }
                }
            } else {
                NSLog(@"it is NOT theStream == inputStream");
            }
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Stream has space available now");
            break;
            
            
        case NSStreamEventErrorOccurred:
            NSLog(@"Can not connect to the host!");
            break;
            
            
        case NSStreamEventEndEncountered:
            NSLog(@"Stream Closed now");
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            
            break;
            
        default:
            NSLog(@"Unknown event %lu", streamEvent);
    }
    
}
/*
 - (void) messageReceived:(NSString *)message {
 
 [messages addObject:message];
 [self.tView reloadData];
 
 }
 */

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view, typically from a nib.
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

////UDP Server
//- (void)startServer {
//    NSLog(@"UDP Server started...");
//    int sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
//    struct sockaddr_in sa;
//    char buffer[1024];
//    size_t fromlen, recsize;
//    
//    memset(&sa, 0, sizeof(sa));
//    sa.sin_family = AF_INET;
//    sa.sin_addr.s_addr = INADDR_ANY;
//    sa.sin_port = htons(5009);
//    
//    // bind the socket to our address
//    if (-1 == bind(sock,(struct sockaddr *)&sa, sizeof(struct sockaddr)))
//    {
//        perror("error bind failed");
//        close(sock);
//        exit(EXIT_FAILURE);
//    }
//    
//    for (;;)
//    {
//        recsize = recvfrom(sock,
//                           (void *)buffer,
//                           1024,
//                           0,
//                           (struct sockaddr *)&sa,
//                           &fromlen);
//        
//        if (recsize < 0)
//            fprintf(stderr, "%s\n", strerror(errno));
//        
//        NSLog([NSString stringWithFormat:@"<- Rx: %s",buffer]);
//        [self parseRX:msg];
//    }
//    [pool release];
//}
//
//-(void)parseRX:(NSString*) msg {
//    NSLog([NSString stringWithFormat:@"Parsing: %@",msg]);
//    // Code to parse your received data goes here...
//}
//
//- (BOOL)application:(UIApplication *)application
//didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    
//    [NSThread detachNewThreadSelector:@selector(startServer)
//                             toTarget:self
//                           withObject:nil];
//}


@end
