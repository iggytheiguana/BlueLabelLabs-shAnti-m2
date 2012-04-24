//
//  MeditationInstance.h
//  shAnti
//
//  Created by Jasjeet Gill on 4/15/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Resource.h"

@interface MeditationInstance : Resource

@property (nonatomic,retain) NSNumber* datecompleted;
@property (nonatomic,retain) NSNumber* datescheduled;
@property (nonatomic,retain) NSNumber* meditationid; //reference to a Meditation object id
@property (nonatomic,retain) NSNumber* percentcompleted;
@property (nonatomic,retain) NSNumber* state; //enumerated constant of type MeditationState (SCHEDULED,INPROGRESS,COMPLETED)
@property (nonatomic,retain) NSNumber* userid;

+ (MeditationInstance*)createInstanceOfMeditation:(NSNumber *)meditationID
                                        forUserID:(NSNumber *)userID
                                        withState:(NSNumber *)state
                                withScheduledDate:(NSNumber *)scheduledDate;

@end
