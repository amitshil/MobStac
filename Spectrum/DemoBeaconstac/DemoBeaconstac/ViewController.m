//
//  ViewController.m
//  DemoBeaconstac
//
//  Created by Garima Batra on 8/26/14.
//  Copyright (c) 2014 MobStac Inc. All rights reserved.
//

#import "ViewController.h"
#import "VideoAndAudioViewController.h"
#import "MyTableViewCell.h"


@interface ViewController () <UITableViewDataSource,UITableViewDelegate>
{
    Beaconstac *beaconstac;
    NSString *mediaType;
    NSString *mediaUrl;
    NSArray *productArray;
    NSArray *prodImageArray;
    BOOL isRuleTriggeredForWelcome;
    BOOL isRuleTriggeredForStoreExit;
    BOOL isExitTriggered;
}
@end

@implementation ViewController
@synthesize tblListOfItems;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]]];
    self.title = @"Demo Beaconstac";
    
    [[MSLogger sharedInstance]setLoglevel:MSLogLevelVerbose];
    
    // Setup and initialize the Beaconstac SDK
    BOOL success = [Beaconstac setupOrganizationId:87
                                         userToken:@"43895b574d13f49ba59c84ae7ebb5554dfca2f71"
                                        beaconUUID:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
                                  beaconIdentifier:@"com.groupsave.DemoBeaconstac"];
    // Credentials end
    productArray=[[NSArray alloc] initWithObjects:@"Lakme",@"Garnier",@"Himalyas",@"AXE", nil];
    prodImageArray = [[NSArray alloc]initWithObjects:@"images.jpeg",@"images-3.jpeg", @"images-2.jpeg",@"axe_cropped.png", nil];

    if (success) {
        NSLog(@"DemoApp:Successfully saved credentials.");
    }
    
    beaconstac = [[Beaconstac alloc]init];
    beaconstac.delegate = self;
    isRuleTriggeredForStoreExit = NO;
    isRuleTriggeredForWelcome = NO;
    isExitTriggered = NO;

    // Demonstrates Custom Attributes functionality.
   [self customAttributeDemo];
}

- (void)viewDidAppear:(BOOL)animated {
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return productArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
   
    if (cell == nil) {
       
        
        cell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"myCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
   
   // cell.textLabel.text=[productArray objectAtIndex: indexPath.row];
  
    cell.prodName.text=[productArray objectAtIndex:indexPath.row];

    cell.imageView.image = [UIImage imageNamed:[prodImageArray objectAtIndex:indexPath.row]];
    NSString *strCount=[self getValueForLocalStorageVarKey:[productArray objectAtIndex:indexPath.row]];
    cell.lblCount.text=strCount;
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Row %ld is selected", (long)indexPath.row);
    
    NSString *str =  [self getValueForLocalStorageVarKey:[productArray objectAtIndex:indexPath.row]];
    if ([str intValue]>0) {
        int temp = [str intValue]+1;
        if (temp > 4) {
            NSString *strDiscount = [NSString stringWithFormat:@"You have got Discount on %@ item for max no. of purchases",[productArray objectAtIndex:indexPath.row]];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Congrats!!!" message:strDiscount delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [self setValueForLocalStorageVar:[NSString stringWithFormat:@"%d", 0] withKey:[productArray objectAtIndex:indexPath.row]];
        }
        else {
            [self setValueForLocalStorageVar:[NSString stringWithFormat:@"%d", temp] withKey:[productArray objectAtIndex:indexPath.row]];
        }
    }
    else {
        [self setValueForLocalStorageVar:[NSString stringWithFormat:@"%d", 1] withKey:[productArray objectAtIndex:indexPath.row]];
    }
    [tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)customAttributeDemo
{
    [beaconstac updateFact:@"female" forKey:@"Gender"];
}

-(void)customAttributeSelected: (NSString *)prodName {
    [beaconstac updateFact:prodName forKey:@"Product"];
    
}

#pragma mark - Beaconstac delegate
// Tells the delegate a list of beacons in range.
- (void)beaconsRanged:(NSDictionary *)beaconsDictionary
{
    
    
}

// Tells the delegate about the camped on beacon among available beacons.
- (void)campedOnBeacon:(id)beacon amongstAvailableBeacons:(NSDictionary *)beaconsDictionary
{
    NSLog(@"DemoApp:Entered campedOnBeacon");
    NSLog(@"DemoApp:campedOnBeacon: %@, %@", beacon, beaconsDictionary);
    NSLog(@"DemoApp:facts Dict: %@", beaconstac.factsDictionary);
}

// Tells the delegate when the device exits from the camped on beacon range.
- (void)exitedBeacon:(id)beacon
{
    NSLog(@"DemoApp:Entered exitedBeacon");
    NSLog(@"DemoApp:exitedBeacon: %@", beacon);
    
}

// Tells the delegate that a rule is triggered with corresponding list of actions. 
- (void)ruleTriggeredWithRuleName:(NSString *)ruleName actionArray:(NSArray *)actionArray
{
     NSLog(@"DemoApp:Action Array: %@", actionArray);
    //
    // actionArray contains the list of actions to trigger for the rule that matched.
    //
    for (NSDictionary *actionDict in actionArray) {
        //
        // meta.action_type can be "popup", "webpage", "media", or "custom"
        //
        if ([[[actionDict objectForKey:@"meta"]objectForKey:@"action_type"]  isEqual: @"popup"]) {
            //
            // Show an alert
            //
            NSLog(@"DemoApp:Text Alert action type");
        
            if ([ruleName isEqualToString:@"Welcome"]&& !isRuleTriggeredForWelcome) {
                NSLog(@"DemoApp:Text Alert action type");
                NSString *message = [[[actionDict objectForKey:@"meta"]objectForKey:@"params"]objectForKey:@"text"];
                [[[UIAlertView alloc] initWithTitle:ruleName message:[NSString stringWithFormat:@"%@",message] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                isRuleTriggeredForWelcome = YES;
            }
            else if ([ruleName isEqualToString:@"Store Exit"]&& !isRuleTriggeredForStoreExit) {
                NSLog(@"DemoApp:Text Alert action type");
                NSString *message = [[[actionDict objectForKey:@"meta"]objectForKey:@"params"]objectForKey:@"text"];
                [[[UIAlertView alloc] initWithTitle:ruleName message:[NSString stringWithFormat:@"%@",message] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                isRuleTriggeredForStoreExit = YES;
                // isExitTriggered = NO;
            }
            
            //else if([ruleName isEqualToString:])
                
            
        } else if ([[[actionDict objectForKey:@"meta"]objectForKey:@"action_type"]  isEqual: @"webpage"]) {
            //
            // Handle webpage by popping up a WebView
            //
            NSLog(@"DemoApp:Webpage action type");
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            UIWebView *webview=[[UIWebView alloc]initWithFrame:screenRect];
            NSString *url=[[[actionDict objectForKey:@"meta"]objectForKey:@"params"]objectForKey:@"url"];
            NSURL *nsurl=[NSURL URLWithString:url];
            NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
            [webview loadRequest:nsrequest];
            
            [self.view addSubview:webview];
            
            // Setting title of the current View Controller
            self.title = @"Webpage action";
            
        } else if ([[[actionDict objectForKey:@"meta"]objectForKey:@"action_type"]  isEqual: @"video"]) {
            //
            // Media type - video
            //
            NSLog(@"DemoApp:Media action type video");
            mediaType = @"video";
            mediaUrl = [[[actionDict objectForKey:@"meta"]objectForKey:@"params"]objectForKey:@"url"];
            [self performSegueWithIdentifier:@"AudioAndVideoSegue" sender:self];
            
        } else if ([[[actionDict objectForKey:@"meta"]objectForKey:@"action_type"]  isEqual: @"audio"]) {
            //
            // Media type - audio
            //
            NSLog(@"DemoApp:Media action type audio");
            mediaType = @"audio";
            mediaUrl = [[[actionDict objectForKey:@"meta"]objectForKey:@"params"]objectForKey:@"url"];
            
            [self performSegueWithIdentifier:@"AudioAndVideoSegue" sender:self];
            
        } else if ([[[actionDict objectForKey:@"meta"]objectForKey:@"action_type"]  isEqual: @"custom"]) {
            //
            // Custom JSON converted to NSDictionary - it's up to you how you want to handle it
            //
            NSDictionary *params = [[actionDict objectForKey:@"meta"]objectForKey:@"params"];
            NSLog(@"DemoApp:Received custom action_type: %@", params);
            
        }
    }
}

// Notifies the view controller that a segue is about to be performed.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Pass media url and media type to the VideoAndAudioViewController.
    if ([segue.identifier isEqualToString:@"AudioAndVideoSegue"]) {
        VideoAndAudioViewController *videoAndAudioVC = segue.destinationViewController;
        videoAndAudioVC.title = [NSString stringWithFormat:@"%@ action", mediaType];
        videoAndAudioVC.mediaUrl = mediaUrl;
        videoAndAudioVC.mediaType = mediaType;
    }
}

#pragma mark — set local storage (NSUserDefaults) methods

- (BOOL)isLocalStorageOn:(NSString *)keyForCheck
{
    @try {
        NSUserDefaults *InsallationShown = [NSUserDefaults standardUserDefaults];
        return [InsallationShown boolForKey:keyForCheck];
        
    }
    @catch (NSException *exception) {
        return 0;
    }
}

- (void)setLocalStorageBit:(BOOL)flag withKey:(NSString *)keyForSet
{
    NSUserDefaults *InsallationShown = [NSUserDefaults standardUserDefaults];
    [InsallationShown setBool:flag forKey:keyForSet];
    [InsallationShown synchronize];
    
}

- (void)setValueForLocalStorageVar:(NSString *)value withKey:(NSString *)key
{
    NSUserDefaults *Installation = [NSUserDefaults standardUserDefaults];
    [Installation setObject:value forKey:key];
    [Installation synchronize];
}

-(NSString *)getValueForLocalStorageVarKey:(NSString *)key
{
    NSUserDefaults *Installation = [NSUserDefaults standardUserDefaults];
    return [Installation valueForKey:key];
}


@end
