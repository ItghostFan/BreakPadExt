//
//  Person+CoreDataProperties.m
//  
//
//  Created by ItghostFan on 2022/3/14.
//
//

#import "Person+CoreDataProperties.h"

@implementation Person (CoreDataProperties)

+ (NSFetchRequest<Person *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Person"];
}

@dynamic user_id;
@dynamic name;
@dynamic age;

@end
