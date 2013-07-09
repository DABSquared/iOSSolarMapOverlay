//
//  SunPosition.m
//  SolarTerminator
//
//  Created by Daniel Brooks on 7/8/13.
//  Copyright (c) 2013 Daniel Brooks. All rights reserved.
//

#import "SunPosition.h"

#import <math.h>
#import <tgmath.h>

@implementation SunPosition


/** Epoch Julian Date. */
#define EPOCH_JULIAN_DATE 2447891.5
/** Epoch start time in seconds. */
#define EPOCH_TIME_SECS 631065600

#define TWO_PI M_PI * 2


/**
 * Constant denoting the number of radians an object would travel if it
 * orbited around the earth in a day.
 */
#define ORBIT_RADS_PER_DAY (M_PI *2) / 365.242191

/**
 * Ecliptic Longitude of earth at 1990 January epoch. From Duffett-Smith,
 * chapter 46, table 6. (279.403303 degrees converted to radians).
 */
#define ECLIPTIC_LONGITUDE_EPOCH 4.87650757893409
/**
 * Variable notation of ECLIPTIC_LONGITUDE_EPOCH from Duffett-Smith.
 */
#define epsilon_g ECLIPTIC_LONGITUDE_EPOCH

/**
 * Ecliptic Longitude of of perigee. From Duffett-Smith, chapter 46, table
 * 6. (282.768422 degrees converted to radians).
 */
#define ECLIPTIC_LONGITUDE_PERIGEE 4.935239985213178
/**
 * Variable notation of ECLIPTIC_LONGITUDE_PERIGEE from Duffett-Smith.
 */
#define omega_bar_g ECLIPTIC_LONGITUDE_PERIGEE

/**
 * Eccentricity of orbit, from Duffett-Smith, chapter 46, table 6.
 */
#define ECCENTRICITY 0.016713

/**
 * MEAN_OBLIQUITY_OF_EPOCH gives the mean obliquity of the ecliptic, which
 * is the angle between the planes of the equator and the ecliptic. Using
 * the algorithm described in Duffett-Smith, chapter 27, this is calculated
 * for the 1990 January epoch to be .4091155 radians (23.440592 degrees).
 */
#define MEAN_OBLIQUITY_OF_EPOCH .4091155

// These parameters are used in the Moon position calculations.

/**
 * Moon parameter, from Duffett-Smith, chapter 65, table 10. In radians.
 */
#define MOON_EPOCH_MEAN_LONGITUDE 318.351648 * M_PI / 180.0
/**
 * The algorithm representation for the moon MOON_EPOCH_MEAN_LONGITUDE, "l".
 */
#define el0 MOON_EPOCH_MEAN_LONGITUDE;

/**
 * Moon parameter, from Duffett-Smith, chapter 65, table 10. In radians.
 */
#define PERIGEE_EPOCH_MEAN_LONGITUDE 36.340410 * M_PI / 180.0
/**
 * The algorithm representation for the moon PERIGEE_EPOCH_MEAN_LONGITUDE.
 */
#define P0 PERIGEE_EPOCH_MEAN_LONGITUDE;

/**
 * Moon parameter, from Duffett-Smith, chapter 65, table 10. In radians.
 */
#define NODE_EPOCH_MEAN_LONGITUDE  318.510107 * M_PI / 180.0
/**
 * The algorithm representation for the moon NODE_EPOCH_MEAN_LONGITUDE.
 */
#define N0 NODE_EPOCH_MEAN_LONGITUDE

/**
 * Moon parameter, from Duffett-Smith, chapter 65, table 10. In radians.
 */
#define MOON_ORBIT_INCLINATION 5.145396 * M_PI / 180.0
/**
 * The algorithm representation for the moon MOON_ORBIT_INCLINATION, "i".
 */
#define eye MOON_ORBIT_INCLINATION

/** Moon parameter, from Duffett-Smith, chapter 65, table 10. */
#define MOON_ECCENTRICITY .054900
/** Moon parameter, from Duffett-Smith, chapter 65, table 10. */
#define MAJOR_AXIS_MOON_ORBIT 384401 // km
/**
 * Moon parameter, from Duffett-Smith, chapter 65, table 10. In radians.
 */
#define MOON_ANGULAR_SIZE .5181 * M_PI / 180.0
/**
 * Moon parameter, from Duffett-Smith, chapter 65, table 10. In radians.
 */
#define MOON_PARALLAX .9507 * M_PI / 180.0

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

+ (SunPosition *)getSingleton
{
    static SunPosition *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SunPosition alloc] init];

    });
    return sharedInstance;
}




+(CLLocationCoordinate2D)getSunCooridinate:(NSDate *)date {
    return [[SunPosition getSingleton] getSunCooridinate:date];
}


-(CLLocationCoordinate2D)getSunCooridinate:(NSDate *)date {

    double mssue = [date timeIntervalSince1970]*1000;

   return [self sunPosition:mssue];
}





#pragma mark - Java Methods

/**
 * Use Kepllers's equation to find the eccentric anomaly. From
 * Duffett-Smith, chapter 47.
 *
 * @param M the angle that the Sun has moved since it passed through
 *        perigee.
 */

-(double)eccentricAnomaly:(double)M {
    double delta;
    double E = M;
    while (true) {
        delta = E - (ECCENTRICITY * sin(E)) - M;

        if (abs(delta) <= 1E-10)
            break;
        E -= (delta / (1.0 - (ECCENTRICITY * cos(E))));
    }
    return E;
}


/**
 * Calculate the mean anomaly of sun, in radians. From Duffett-Smith,
 * chapter 47.
 *
 * @param daysSinceEpoch number of days since 1990 January epoch.
 */
-(double)sunMeanAnomaly:(double)daysSinceEpoch {

    double N = ORBIT_RADS_PER_DAY * daysSinceEpoch;
    N = (double)((int) N % ((int)M_PI * 2));
    if (N < 0)
        N += TWO_PI;

    double M0 = N + epsilon_g - omega_bar_g;
    if (M0 < 0)
        M0 += TWO_PI;
    return M0;
}


/**
 * Calculate the ecliptic longitude of sun, in radians. From Duffett-Smith,
 * chapter 47.
 *
 * @param M0 sun's mean anomaly, calculated for the requested time relative
 *        to the 1990 epoch.s
 */
-(double)sunEclipticLongitude:(double)M0 {
    double E = [self eccentricAnomaly:M0];
    double v = 2 * atan(sqrt((1 + ECCENTRICITY) / (1 - ECCENTRICITY)) * tan(E / 2.0));
    double ret = v + omega_bar_g;
    ret = [self adjustWithin2PI:ret];
    return ret;
}

/**
 * Conversion from ecliptic to equatorial coordinates for ascension. From
 * Duffett-Smith, chapter 27.
 *
 * @param lambda ecliptic longitude
 * @param beta ecliptic latitude
 */
-(double)eclipticToEquatorialAscension:(double)lambda :(double)beta {
    double sin_e = sin(MEAN_OBLIQUITY_OF_EPOCH);
    double cos_e = cos(MEAN_OBLIQUITY_OF_EPOCH);

    return atan2(sin(lambda) * cos_e - tan(beta) * sin_e, cos(lambda));
}


/**
 * Conversion from ecliptic to equatorial coordinates for declination. From
 * Duffett-Smith, chapter 27.
 *
 * @param lambda ecliptic longitude
 * @param beta ecliptic latitude
 */
-(double)eclipticToEquatorialDeclination:(double)lambda :(double)beta {
    double sin_e = sin(MEAN_OBLIQUITY_OF_EPOCH);
    double cos_e = cos(MEAN_OBLIQUITY_OF_EPOCH);

    return asin(sin(beta) * cos_e + cos(beta) * sin_e * sin(lambda));
}


/**
 * Given a date from a gregorian calendar, give back a julian date. From
 * Duffett-Smith, chapter 4.
 *
 * @param cal Gregorian calendar for requested date.
 * @return julian date of request.
 */
-(double)calculateJulianDate:(NSDate *)date {
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;

    NSDateComponents * dateComponents = [[NSCalendar currentCalendar] components:unitFlags fromDate:date];

    int year = [dateComponents year];
    int month = [dateComponents month];
    int day = [dateComponents day];


    if ((month == 1) || (month == 2)) {
        year -= 1;
        month += 12;
    }

    int A = year / 100;
    int B = (int) (2 - A + (A / 4));
    int C = (int) (365.25 * (float) year);
    int D = (int) (30.6001 * (float) (month + 1));

    double julianDate = (double) (B + C + D + day) + 1720994.5;

    return julianDate;
}


/**
 * Calculate the greenwich sidereal time (GST). From Duffett-Smith, chapter
 * 12.
 *
 * @param julianDate julian date of request
 * @param time calendar reflecting local time zone change to greenwich
 * @return GST relative to unix epoch.
 */
-(double)greenwichSiderealTime:(double)julianDate :(NSDate *)time {

    unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit;

    NSDateComponents * dateComponents = [[NSCalendar currentCalendar] components:unitFlags fromDate:time];

    double T = (julianDate - 2451545.0) / 36525.0;
    double T0 = 6.697374558 + (T * (2400.051336 + (T + 2.5862E-5)));

    T0 = (double)((int)T0 % 24);
    if (T0 < 0) {
        T0 += 24.0;
    }

    double UT = [dateComponents hour] + ([dateComponents minute] + [dateComponents second] / 60.0) / 60.0;

    T0 += UT * 1.002737909;

    T0 = (double)((int)T0 % 24);
    if (T0 < 0) {
        T0 += 24.0;
    }

    return T0;
}


/**
 * Given the number of milliseconds since the unix epoch, compute position
 * on the earth (lat, lon) such that sun is directly overhead. From
 * Duffett-Smith, chapter 46-47.
 *
 * @param mssue milliseconds since unix epoch
 * @return LatLonPoint of the point on the earth that is closest.
 */
-(CLLocationCoordinate2D)sunPosition:(double)mssue {

    unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit | NSTimeZoneCalendarUnit;


    // Set the date and clock, based on the millisecond count:
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:(mssue/1000)];

    NSCalendar * calendar =  [NSCalendar currentCalendar];
    
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];

    double julianDate = [self calculateJulianDate:date];

    // Need to correct time to GMT
    long gmtOffset = [[comps  timeZone] secondsFromGMT] * 1000;
    // thanks to Erhard...
    NSTimeZone *DST = [[NSTimeZone alloc] init];
    long dstOffset = [DST daylightSavingTimeOffsetForDate:date] * 1000; // ins.
    // 12.04.99

    date = [NSDate dateWithTimeIntervalSince1970:((mssue - (gmtOffset + dstOffset))/1000)];

    // 12.04.99

    double numDaysSinceEpoch = ((mssue / 1000) - EPOCH_TIME_SECS) / (24.0f * 3600.0f);

    // M0 - mean anomaly of the sun
    double M0 = [self sunMeanAnomaly:numDaysSinceEpoch];
    // lambda
    double sunLongitude = [self sunEclipticLongitude:M0];
    // alpha
    double sunAscension = [self eclipticToEquatorialAscension:sunLongitude :0.0];
    // delta
    double sunDeclination = [self eclipticToEquatorialDeclination:sunLongitude :0.0];

    double tmpAscension = sunAscension - (TWO_PI / 24) * [self greenwichSiderealTime:julianDate :date];

    return CLLocationCoordinate2DMake(RADIANS_TO_DEGREES(sunDeclination), RADIANS_TO_DEGREES(tmpAscension));
}


/**
 * Given the number of milliseconds since the unix epoch, compute position
 * on the earth (lat, lon) such that moon is directly overhead. From
 * Duffett-Smith, chapter 65. Note: This is acting like it works, but I
 * don't have anything to test it against. No promises.
 *
 * @param mssue milliseconds since unix epoch
 * @return LatLonPoint of the point on the earth that is closest.
 */
-(CLLocationCoordinate2D)moonPosition:(double)mssue {

    // Set the date and clock, based on the millisecond count:
    unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit | NSTimeZoneCalendarUnit;


    // Set the date and clock, based on the millisecond count:
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:(mssue/1000)];

    NSCalendar * calendar =  [NSCalendar currentCalendar];

    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];

    double julianDate = [self calculateJulianDate:date];

    // Need to correct time to GMT
    long gmtOffset = [[comps  timeZone] secondsFromGMT] * 1000;

    date = [NSDate dateWithTimeIntervalSince1970:((mssue - gmtOffset)/1000)];

    // Step 1,2
    double numDaysSinceEpoch = ((mssue / 1000) - EPOCH_TIME_SECS) / (24.0f * 3600.0f);
    // Step 3
    // M0 - mean anomaly of the sun
    double M0 = [self sunMeanAnomaly:numDaysSinceEpoch];
    // lambda
    double sunLongitude = [self sunEclipticLongitude:M0];
    // Step 4
    double el = (13.1763966 * numDaysSinceEpoch * M_PI / 180) + el0;
    el = [self adjustWithin2PI:el];
    // Step 5
    double Mm = el - (.1114041 * numDaysSinceEpoch * M_PI / 180) - P0;
    Mm = [self adjustWithin2PI:Mm];
    // Step 6
    double N = N0 - (.0529539 * numDaysSinceEpoch * M_PI / 180);
    N = [self adjustWithin2PI:N];
    // Step 7
    double C = el - sunLongitude;
    double Ev = 1.2739 * sin(2 * C - Mm);
    // Step 8
    double Ae = .1858 * sin(M0);
    double A3 = .37 * sin(M0);
    // Step 9
    double Mmp = Mm + Ev - Ae - A3;
    // Step 10
    double Ec = 6.2886 * sin(Mmp);
    // Step 11
    double A4 = 0.214 * sin(2 * Mmp);
    // Step 12
    double elp = el + Ev + Ec - Ae + A4;
    // Step 13
    double V = .6583 * sin(2 * (elp - sunLongitude));
    // Step 14
    double elpp = elp + V;
    // Step 15
    double Np = N - (.16 * sin(M0));
    // Step 16
    double y = sin(elpp - Np) * cos(eye);
    // Step 17
    double x = cos(elpp - Np);
    // Step 18
    double amb = atan2(y, x);
    // Step 19
    double lambda_m = amb + Np;
    // Step 20
    double beta_m = asin(sin(elpp - Np) * sin(eye));
    // Step 21
    // alpha
    double moonAscension = [self eclipticToEquatorialAscension:lambda_m :beta_m ];
    // delta
    double moonDeclination = [self eclipticToEquatorialDeclination:lambda_m :beta_m];

    double tmpAscension = moonAscension - (TWO_PI / 24) * [self greenwichSiderealTime:julianDate :date];

    return CLLocationCoordinate2DMake(RADIANS_TO_DEGREES(moonDeclination), RADIANS_TO_DEGREES(tmpAscension));
}

/**
 * Little function that resets the input to be within 0 - 2*PI, by adding or
 * subtracting 2PI as needed.
 *
 * @param num The number to be modified, if needed.
 */
-(double)adjustWithin2PI:(double)num {
    if (num < 0) {
        do
            num += TWO_PI;
        while (num < 0);
    } else if (num > TWO_PI) {
        do
            num -= TWO_PI;
        while (num > TWO_PI);
    }
    return num;
}

@end
