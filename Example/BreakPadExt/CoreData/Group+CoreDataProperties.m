//
//  Group+CoreDataProperties.m
//  
//
//  Created by ItghostFan on 2022/3/14.
//
//

#import "Group+CoreDataProperties.h"

@implementation Group (CoreDataProperties)

+ (NSFetchRequest<Group *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Group"];
}

@dynamic group_id;
@dynamic name;

@end
