//
//  SolarTerminatorOverlayView.m
//  SolarTerminator
//
//  Created by Daniel Brooks on 7/8/13.
//  Copyright (c) 2013 Daniel Brooks. All rights reserved.
//

#import "SolarTerminatorOverlay.h"

@implementation SolarTerminatorOverlay

@synthesize polygon;

-(id)init {
    self = [super init];
    if(self) {
       
        [self setDate:[NSDate date]];
    }

    return self;
}


- (CLLocationCoordinate2D)coordinate{
    return CLLocationCoordinate2DMake(0, 0);
}

-(MKMapRect)boundingMapRect {
    CLLocationCoordinate2D coordinateOrigin = CLLocationCoordinate2DMake(90, -180);
    CLLocationCoordinate2D coordinateMax = CLLocationCoordinate2DMake(-90, 180);
    
    MKMapPoint upperLeft = MKMapPointForCoordinate(coordinateOrigin);
    MKMapPoint lowerRight = MKMapPointForCoordinate(coordinateMax);
    
    MKMapRect mapRect = MKMapRectMake(upperLeft.x,
                                      upperLeft.y,
                                      lowerRight.x - upperLeft.x,
                                      lowerRight.y - upperLeft.y);
    return mapRect;
}

-(void)setDate:(NSDate *)date {
    NSMutableArray * somePoints = [self sunPoints:date];

    CLLocationCoordinate2D points[364];

    for(int i = 0; i < 364; i++) {
        CLLocation *location =  (CLLocation *)[somePoints objectAtIndex:i];
        points[i] = location.coordinate;
    }

    polygon = [MKPolygon polygonWithCoordinates:points count:364];
    polygon.title = @"Sun Position";
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
        
        arctanLat = -arctanLat;
        
        if(i == -180) {
            lat1 = arctanLat;
        }


        CLLocation *location = [[CLLocation alloc] initWithLatitude:arctanLat longitude:i];
        [points addObject:location];
    }
    
    
    
    CLLocation *bottomRight = [[CLLocation alloc] initWithLatitude:-90 longitude:180];
    CLLocation *bottomLeft = [[CLLocation alloc] initWithLatitude:-90 longitude:-180];
    CLLocation *start = [[CLLocation alloc] initWithLatitude:lat1 longitude:-180];

    [points addObject:bottomRight];
    [points addObject:bottomLeft];
    [points addObject:start];

    
    
    return points;
}

@end
