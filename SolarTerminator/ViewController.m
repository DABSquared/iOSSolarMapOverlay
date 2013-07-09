//
//  ViewController.m
//  SolarTerminator
//
//  Created by Daniel Brooks on 7/8/13.
//  Copyright (c) 2013 Daniel Brooks. All rights reserved.
//

#import "ViewController.h"

#import "SolarTerminatorOverlay.h"

#import "SunPosition.h"

@interface ViewController ()

@property(nonatomic,strong)IBOutlet MKMapView * mapView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    SolarTerminatorOverlay *polygon = [[SolarTerminatorOverlay alloc] init];


    CLLocationDistance radius = 80000; // Distance is in meters
    MKCircle * circle = [MKCircle circleWithCenterCoordinate:[SunPosition getSunCooridinate:[NSDate date]]
                                                      radius:radius];

    [self.mapView addOverlay:circle];
    [self.mapView addOverlay:polygon];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    NSLog(@"in viewForOverlay!");

    if ([overlay isKindOfClass:[SolarTerminatorOverlay class]]) {
        //get the MKPolygon inside the ParkingRegionOverlay...
        MKPolygon *proPolygon = ((SolarTerminatorOverlay*)overlay).polygon;
        MKPolygonView *aView = [[MKPolygonView alloc] initWithPolygon:proPolygon];
        
        aView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        aView.lineWidth = 3;

        return aView;
    }else if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleView * circleView = [[MKCircleView alloc] initWithCircle:overlay];
        circleView.lineWidth = 2;
        circleView.strokeColor = [UIColor colorWithWhite:.2 alpha:.5];
        circleView.fillColor = [UIColor colorWithWhite:.2 alpha:.3];
        return circleView;
    }
    
    return nil;
}

@end
