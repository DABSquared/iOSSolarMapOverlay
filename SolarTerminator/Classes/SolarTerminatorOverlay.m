//
//  SolarTerminatorOverlayView.m
//  SolarTerminator
//
//  Created by Daniel Brooks on 7/8/13.
//  Copyright (c) 2013 Daniel Brooks. All rights reserved.
//

#import "SolarTerminatorOverlay.h"
#import "SunPosition.h"

@implementation SolarTerminatorOverlay

@synthesize polygon;

-(id)init {
    self = [super init];
    if(self) {

        [self setDate:[NSDate date]];
        
        NSLog(@"%f %f",[SunPosition getSunCooridinate:[NSDate date]].latitude, [SunPosition getSunCooridinate:[NSDate date]].longitude);

    }

    return self;
}

- (MKMapRect)boundingMapRect{


    MKMapRect bounds =MKMapRectMake(-180, -180, 360, 360);


    return bounds;
}

- (CLLocationCoordinate2D)coordinate{
    return CLLocationCoordinate2DMake(0, 0);
}

-(void)setDate:(NSDate *)date {
    NSMutableArray * somePoints = [self sunPoints:date];

    CLLocationCoordinate2D points[360];

    for(int i = 0; i < 360; i++) {
        CLLocation *location =  (CLLocation *)[somePoints objectAtIndex:i];
        points[i] = location.coordinate;
    }

    polygon = [MKPolygon polygonWithCoordinates:points count:360];
    polygon.title = @"Some Polygon";
}

-(NSMutableArray *)sunPoints:(NSDate *)date  {
    CLLocationCoordinate2D brightPoint = [SunPosition getSunCooridinate:date];
    
    double K = M_PI/180.0;

    NSMutableArray * points = [[NSMutableArray alloc] init];

    double lat1 = 0;
    double longitude;

    for (int i=-180; i<=180; i++) {
        longitude=i+brightPoint.longitude;
        double tanLat = - cos(longitude*K)/tan(brightPoint.latitude*K);
        double arctanLat = atan(tanLat)/K;
        if(i == -180) {
            lat1 = arctanLat;
        }

        NSLog(@"%f %f", longitude, arctanLat);

        CLLocation *location = [[CLLocation alloc] initWithLatitude:arctanLat longitude:i];
        [points addObject:location];
    }
    
    return points;
}

@end
