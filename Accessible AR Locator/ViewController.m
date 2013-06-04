//
//  ViewController.m
//  Accessible AR Locator
//
//  Created by Pavel Belevtsev on 03.06.13.
//  Copyright (c) 2013 Injoit. All rights reserved.
//

#import "ViewController.h"
#import "MapARViewController.h"
#import "FBNavigationBar.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(IS_HEIGHT_GTE_568){
        [self.backgroundImage setImage:[UIImage imageNamed:@"Default-568h@2x.png"]];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self createSessionWithDelegate:self];
    
}

- (void)createSessionWithDelegate:(id)delegate{
  	
    // Create extended application authorization request (for push notifications)
	QBASessionCreationRequest *extendedAuthRequest = [[QBASessionCreationRequest alloc] init];
	
    extendedAuthRequest.userLogin = @"superuser";
    extendedAuthRequest.userPassword = @"superpass";
    
 	// QuickBlox application authorization
	[QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:delegate];
	
	[extendedAuthRequest release];
}

#pragma mark -
#pragma mark QB QBActionStatusDelegate

// QuickBlox API queries delegate
-(void)completedWithResult:(Result *)result{
    
    // QuickBlox Application authorization result

    MapARViewController *mapARViewController = [[MapARViewController alloc] initWithNibName:@"MapARViewController" bundle:nil];
	
    UINavigationController *mapARNavigationController = [[UINavigationController alloc] initWithRootViewController:mapARViewController];
	
    [mapARViewController.navigationController setValue:[[[FBNavigationBar alloc]init] autorelease] forKeyPath:@"navigationBar"];
    
    [mapARViewController release];
    
    [self presentModalViewController:mapARNavigationController animated:YES];
    
    [mapARNavigationController release];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
