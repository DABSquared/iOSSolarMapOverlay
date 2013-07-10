//
//  SunPosition.h
//  SolarTerminator
//
//  Created by Daniel Brooks on 7/8/13.
//  Copyright (c) 2013 Daniel Brooks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(degrees) ((degrees) * (M_PI/180))


@interface SunPosition : NSObject

+(CLLocationCoordinate2D)getSunCooridinate:(NSDate *)date;


@end
