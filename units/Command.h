//
//  Command.h
//  openHAB
//
//  Created by XMYY-25 on 2017/10/19.
//  Copyright © 2017年 openHAB e.V. All rights reserved.
//

#ifndef Command_h
#define Command_h

//重新定义NSLog
#ifdef DEBUG
#define PMLog(...) NSLog(__VA_ARGS__)
#else
#define PMLog(...)
#endif


#ifdef DEBUG
#define NSLog(...) \
do {\
NSDateFormatter *dateFormatter = [NSDateFormatter new];\
[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];\
[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];\
NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];\
printf("%s [%s:%ld]🐞: %s\n",dateString.UTF8String,strrchr(__FILE__,'/')+1,[[NSNumber numberWithInt:__LINE__] integerValue],[[NSString stringWithFormat:__VA_ARGS__]UTF8String]);\
} while(0)

#endif

#define SB(block,args...)  block?block(args):nil

#define SBR(block,args...)  ({BOOL result=NO; if (block) {block(args); result= YES;} result;})
#define SBR_OBJ(block,args...)  ({ block?block(args):nil;})

#define PMString(format,args...)    [NSString stringWithFormat:format,##args]

#endif /* Command_h */
