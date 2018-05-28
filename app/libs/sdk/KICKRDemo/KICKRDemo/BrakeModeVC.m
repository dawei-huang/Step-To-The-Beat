//
//  BrakeModeVC.m
//  KICKRDemo
//
//  Created by Michael Moore on 8/18/12.
//  Copyright (c) 2012 Wahoo Fitness. All rights reserved.
//

#import "BrakeModeVC.h"

@interface BrakeModeVC ()

@end

@implementation BrakeModeVC

@synthesize pwmModeLevelField;

@synthesize powerLabel;
@synthesize speedLabel;


#pragma mark -
#pragma mark UIViewController Implementation

//--------------------------------------------------------------------------------
- (void)dealloc
{
    [pwmModeLevelField release];
    
    [powerLabel release];
    [speedLabel release];
    
    [super dealloc];
}

//--------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        applicableNetworks = WF_NETWORKTYPE_BTLE | WF_NETWORKTYPE_ANTPLUS;
    }
    return self;
}

//--------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sensorType = WF_SENSORTYPE_BIKE_POWER;
    self.navigationItem.title = @"PWM (Brake) Mode";
}

//--------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//--------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    WFBikePowerConnection* bpc = self.bikePowerConnection;
    if ( bpc )
    {
        bpc.btDelegate = self;
    }
}

//--------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    WFBikePowerConnection* bpc = self.bikePowerConnection;
    if ( bpc )
    {
        bpc.btDelegate = nil;
    }
}

//--------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark WFBikeTrainerDelegate Implementation

//--------------------------------------------------------------------------------
- (void)cpmConnection:(WFBikePowerConnection*)cpmConn didSetTrainerMode:(WFBikeTrainerMode_t)eMode status:(UCHAR)ucStatus
{
    NSString* msg = [NSString stringWithFormat:@"Mode: %d\nSuccess: %@", eMode, (ucStatus==0)?@"TRUE":@"FALSE"];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"SET TRAINER MODE" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

#pragma mark -
#pragma mark WFSensorCommonViewController Implementation

//--------------------------------------------------------------------------------
- (void)onSensorConnected:(WFSensorConnection*)connectionInfo
{
    WFBikePowerConnection* bpc = self.bikePowerConnection;
    if ( bpc )
    {
        bpc.btDelegate = self;
    }
}

//--------------------------------------------------------------------------------
- (void)resetDisplay
{
    [super resetDisplay];
    
	powerLabel.text = @"n/a";
	speedLabel.text = @"n/a";
}

//--------------------------------------------------------------------------------
- (void)updateData
{
    [super updateData];
    
    WFBikePowerData* btleData = [self.bikePowerConnection getBikePowerData];
	if (btleData)
    {
        speedLabel.text = [btleData formattedSpeed:TRUE];
        if ( [hardwareConnector.settings.staleDataString isEqualToString:speedLabel.text] )
        {
            powerLabel.text = hardwareConnector.settings.staleDataString;
        }
        else
        {
            powerLabel.text = [NSString stringWithFormat:@"%d W", btleData.instantPower];
        }
    }
	else
	{
		[self resetDisplay];
	}
}



#pragma mark -
#pragma mark BrakeModeVC Implementation

#pragma mark Properties

//--------------------------------------------------------------------------------
- (WFBikePowerConnection*)bikePowerConnection
{
	WFBikePowerConnection* retVal = nil;
	if ( [self.sensorConnection isKindOfClass:[WFBikePowerConnection class]] )
	{
		retVal = (WFBikePowerConnection*)self.sensorConnection;
	}
	
	return retVal;
}

#pragma mark Event Handlers

//--------------------------------------------------------------------------------
- (IBAction)setPWMModeClicked:(id)sender
{
    
    // the trainerSetResistanceMode takes a floating point scale value between
    // zero and one.  convert the entered percentage to zero to one scale.
    // the integer PWM scale value to floating point.
    [self.pwmModeLevelField resignFirstResponder];
    float fpScale = [pwmModeLevelField.text floatValue] / 100.0;
    [self.bikePowerConnection trainerSetResistanceMode:fpScale];
    
}

//--------------------------------------------------------------------------------
- (IBAction)textFieldDoneEditing:(id)sender
{
	[sender resignFirstResponder];
    [self setPWMModeClicked:sender];
}

@end
