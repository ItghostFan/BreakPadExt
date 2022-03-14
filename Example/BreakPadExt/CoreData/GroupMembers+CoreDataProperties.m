//
//  GroupMembers+CoreDataProperties.m
//  
//
//  Created by ItghostFan on 2022/3/14.
//
//

#import "GroupMembers+CoreDataProperties.h"

@implementation GroupMembers (CoreDataProperties)

+ (NSFetchRequest<GroupMembers *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"GroupMembers"];
}

@dynamic group_id;
@dynamic user_id;
@dynamic group_connect;
@dynamic persion_connect;

@end
