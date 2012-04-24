//
//  Meditation.h
//  shAnti
//
//  Created by Jasjeet Gill on 4/15/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Resource.h"

@interface Meditation : Resource

@property (nonatomic,retain) NSNumber* numtimescompleted;
@property (nonatomic,retain) NSNumber* numtimesstarted;
@property (nonatomic,retain) NSNumber* position;
@property (nonatomic,retain) NSString* audiourl;
@property (nonatomic,retain) NSString* title;
@property (nonatomic,retain) NSString* desc;
@property (nonatomic,retain) NSString* imageurl;





@end
