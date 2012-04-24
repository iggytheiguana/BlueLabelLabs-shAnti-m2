//
//  MeditationInstance.m
//  shAnti
//
//  Created by Jasjeet Gill on 4/15/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "MeditationInstance.h"
#import "Meditation.h"

@implementation MeditationInstance
@dynamic datecompleted;
@dynamic datescheduled;
@dynamic meditationid;
@dynamic percentcompleted;
@dynamic state;
@dynamic userid;

//creates a Meditation instance
+ (MeditationInstance*)createInstanceOfMeditation:(NSNumber *)meditationID
                                        forUserID:(NSNumber *)userID
                                        withState:(NSNumber *)state
                                withScheduledDate:(NSNumber *)scheduledDate
{
    ResourceContext* resourceContext = [ResourceContext instance];
    MeditationInstance* retVal = (MeditationInstance*) [Resource createInstanceOfType:MEDITATIONINSTANCE withResourceContext:resourceContext];
    
    retVal.meditationid = meditationID;
    retVal.userid = userID;
    retVal.state = state;
    retVal.datescheduled = scheduledDate;
    retVal.datecompleted = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    retVal.percentcompleted = nil;
    
    return  retVal;
}


@end
