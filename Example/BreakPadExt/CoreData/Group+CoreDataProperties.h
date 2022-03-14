//
//  Group+CoreDataProperties.h
//  
//
//  Created by ItghostFan on 2022/3/14.
//
//

#import "Group+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Group (CoreDataProperties)

+ (NSFetchRequest<Group *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSString *group_id;
@property (nullable, nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
