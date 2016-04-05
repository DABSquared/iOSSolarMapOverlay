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

    CLLocationCoordinate2D points[361];

    for(int i = 0; i < 361; i++) {
        CLLocation *location =  (CLLocation *)[somePoints objectAtIndex:i];
        points[i] = location.coordinate;
    }
    
    polygon = [[MKPolylineRenderer alloc] initWithPolyline:[MKPolyline polylineWithCoordinates:points count:361]];
    polygon.polyline.title = @"Sun Position";
}

-(NSMutableArray *)sunPoints:(NSDate *)date  {
    CLLocationCoordinate2D brightPoint = [SunPosition getSunCooridinate:date];
    
    double K = (M_PI/180.0);
    double lat1 = 0;
 
    NSMutableArray * points = [[NSMutableArray alloc] init];

    double longitudeStart = 0;
    double longitude = 0;

    CLLocation * location = [[CLLocation alloc] init];
   // Headers for use with excel!
  //  NSLog(@"BrightPoint Long:%f", brightPoint.longitude);
  //  NSLog(@"BrightPoint Lat:%f", brightPoint.latitude);
    
    longitudeStart = brightPoint.longitude;

    if (brightPoint.longitude < -180)
       longitudeStart = brightPoint.longitude+360;
    else if (brightPoint.longitude > 180)
       longitudeStart = brightPoint.longitude-360;
    
    longitudeStart = -longitudeStart;  // Invert start point
  
   // NSLog(@"Updated BrightPoint:%f",longitudeStart);
   // NSLog(@"Index, Lat, Long"); // For point dump header
 
    for (int i=-180; i<=180; i++) {
       
        longitude= longitudeStart + i;

        if (longitude < -180)
        {
            longitudeStart =  longitudeStart+360;
            longitude = longitudeStart + i;
        }
        else if (longitude > 180)
        {
            longitudeStart =  longitudeStart-360;
             longitude = longitudeStart + i;
         }
         double tanLat = -(cos(longitude*K)/tan(brightPoint.latitude*K));
       
        double arctanLat = atan(tanLat)/K;
        if (i == -180)
          lat1 = arctanLat;
      
   //     NSLog(@"%d ,%f, %f ,%f, %f", i, tanLat, arctanLat, longitude, lat1);
        location = [[CLLocation alloc] initWithLatitude:arctanLat longitude:i];
        [points addObject:location];
    }
    
//    CLLocation *bottomRight = [[CLLocation alloc] initWithLatitude:-90 longitude:180];
//    CLLocation *bottomLeft = [[CLLocation alloc] initWithLatitude:-90 longitude:-180];
//    CLLocation *start = [[CLLocation alloc] initWithLatitude:lat1 longitude:-180];
//  //  NSLog(@"Start %@", start);
//  
//    [points addObject:bottomRight];
//    [points addObject:bottomLeft];
//    [points addObject:start];
    
    return points;
}

@end
