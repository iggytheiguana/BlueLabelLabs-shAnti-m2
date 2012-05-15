//
//  Meditation.m
//  shAnti
//
//  Created by Jasjeet Gill on 4/15/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Meditation.h"
#import "MeditationType.h"
#import "DateTimeHelper.h"

@implementation Meditation

@dynamic title;
@dynamic desc;
@dynamic position;
@dynamic audiourl;
@dynamic imageurl;
@dynamic numtimesstarted;
@dynamic numtimescompleted;


#pragma mark - Static Initializers
//creates a Meditation object
+ (Meditation*)createMeditationWithTitle:(NSString *)title
                         withDescription:(NSString *)description
                            withPosition:(NSNumber *)position
                            withAudioURL:(NSString *)audioURL
                            withImageURL:(NSString *)imageURL

{
    ResourceContext* resourceContext = [ResourceContext instance];
    Meditation* retVal = (Meditation*) [Resource createInstanceOfType:MEDITATION withResourceContext:resourceContext];
    
    retVal.title = title;
    retVal.desc = description;
    retVal.position = position;
    retVal.audiourl = audioURL;
    retVal.imageurl = imageURL;
    retVal.numtimesstarted = [NSNumber numberWithInt:0];
    retVal.numtimescompleted = [NSNumber numberWithInt:0];
    
    return  retVal;
}

//Loads the default meditations for table views
+ (NSArray*)loadDefaultMeditations
{
    NSMutableArray *retVal = [[[NSMutableArray alloc]init]autorelease];
    
    NSArray *titlesArray = [NSArray arrayWithObjects:@"Just breathe", @"Feel your body", @"A mindful walk", @"A mindful gaze", @"Mindful eating", nil];
    
    NSString *audioURL1 = [[NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                  pathForResource:@"MindfulBreathing"
                                                  ofType:@"mp3"]] absoluteString];
    
    NSString *audioURL2 = [[NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                   pathForResource:@"BodyScan"
                                                   ofType:@"mp3"]] absoluteString];
    
    NSString *audioURL3 = [[NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                   pathForResource:@"MindfulWalking"
                                                   ofType:@"mp3"]] absoluteString];
    
    NSString *audioURL4 = [[NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                   pathForResource:@"MindfulSeeing"
                                                   ofType:@"mp3"]] absoluteString];
    
    NSString *audioURL5 = [[NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                   pathForResource:@"MindfulEating"
                                                   ofType:@"mp3"]] absoluteString];
    
    NSArray *audioArray = [NSArray arrayWithObjects:audioURL1, audioURL2, audioURL3, audioURL4, audioURL5, nil];
    
    NSString *imageURL = @"flower_background--shadowed.png";
    
    for (int i = 0; i < 5; i++) {
        Meditation *meditation = [Meditation createMeditationWithTitle:[titlesArray objectAtIndex:i] withDescription:nil withPosition:[NSNumber numberWithInt:i] withAudioURL:[audioArray objectAtIndex:i] withImageURL:imageURL];
        //we set the object id here
        meditation.objectid = [NSNumber numberWithInt:((i+1)*1000)];
        [retVal addObject:meditation];
        [meditation release];
    }
    
    return  retVal;
}

@end