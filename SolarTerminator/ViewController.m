//
//  ViewController.m
//  SolarTerminator
//
//  Created by Daniel Brooks on 7/8/13.
//  Copyright (c) 2013 Daniel Brooks. All rights reserved.
//

#import "ViewController.h"

#import "SolarTerminatorOverlay.h"
#import "SolarTerminatorOverlayFill.h"
#import "SunPosition.h"

@interface ViewController ()

@property(nonatomic,strong)IBOutlet MKMapView * mapView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    SolarTerminatorOverlayFill *polygonFill = [[SolarTerminatorOverlayFill alloc] init];


    CLLocationDistance radius = 80000; // Distance is in meters
    MKCircle * circle = [MKCircle circleWithCenterCoordinate:[SunPosition getSunCooridinate:[NSDate date]]
                                                      radius:radius];

    [self.mapView addOverlay:circle];
    //[self.mapView addOverlay:polygon];
    [self.mapView addOverlay:polygonFill];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    NSLog(@"in viewForOverlay!");

    if ([overlay isKindOfClass:[SolarTerminatorOverlay class]]) {
        //get the MKPolygon inside the ParkingRegionOverlay...
        MKPolylineRenderer *proPolygon = ((SolarTerminatorOverlay*)overlay).polygon;
        proPolygon.strokeColor = [UIColor colorWithWhite:.2 alpha:.5];
        //aView.fillColor = [UIColor colorWithWhite:.2 alpha:.3];
        proPolygon.lineWidth = 5;

        return proPolygon;
    }else  if ([overlay isKindOfClass:[SolarTerminatorOverlayFill class]]) {
        //get the MKPolygon inside the ParkingRegionOverlay...
        MKPolylineRenderer *proPolygon = ((SolarTerminatorOverlayFill*)overlay).polygon;
        proPolygon.strokeColor = [UIColor redColor];
        proPolygon.fillColor = [UIColor colorWithWhite:.2 alpha:.3];
        proPolygon.lineWidth = 5;
        
        return proPolygon;
    }else if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer * circleView = [[MKCircleRenderer alloc] initWithCircle:overlay];
        circleView.lineWidth = 2;
        circleView.strokeColor = [UIColor colorWithWhite:.2 alpha:.5];
        circleView.fillColor = [UIColor colorWithWhite:.2 alpha:.3];
        return circleView;
    }else if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *aView = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        aView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        aView.strokeColor = [UIColor blackColor];
        aView.lineWidth = 5;
        return aView;
    }
    
    return nil;
}

@end
