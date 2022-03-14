//
//  GroupMembers+CoreDataProperties.h
//  
//
//  Created by ItghostFan on 2022/3/14.
//
//

#import "GroupMembers+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface GroupMembers (CoreDataProperties)

+ (NSFetchRequest<GroupMembers *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSString *group_id;
@property (nullable, nonatomic, copy) NSString *user_id;
@property (nullable, nonatomic, retain) Group *group_connect;
@property (nullable, nonatomic, retain) Person *persion_connect;

@end

NS_ASSUME_NONNULL_END
