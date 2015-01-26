//
//  MBCategoryProperties.h
//  kitchensink-app
//
//  Created by Emiel Bon on 16-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//
//  http://ios-blog.co.uk/tutorials/cleaner-properties-implementation-in-categories/
//
// <Incantation>
//  Take heed, ye who entereth here.
//  Turn back while thou still canst,
//  if thou holdst thine sanity dear.
// </Incantation>

#import "GTMObjC2Runtime.h"

#define JESynthesize(ownership, type, getter, setter) \
    static const void *_JESynthesizeKey_##getter = &_JESynthesizeKey_##getter; \
    - (type)getter \
    { \
        return _JESynthesize_get_##ownership(type, getter); \
    } \
    - (void)setter:(type)getter \
    { \
        _JESynthesize_set_##ownership(type, getter); \
    }

#define _JESynthesize_get_assign(type, getter) \
    ({ \
        typeof(type) _je_value[1] = {}; \
        [(NSValue *)objc_getAssociatedObject(self, _JESynthesizeKey_##getter) getValue:_je_value]; \
        _je_value[0]; \
    })

#define _JESynthesize_get_unsafe_unretained(type, getter) \
    objc_getAssociatedObject(self, _JESynthesizeKey_##getter);

#define _JESynthesize_get_strong    _JESynthesize_get_unsafe_unretained

#define _JESynthesize_get_retain    _JESynthesize_get_unsafe_unretained

#define _JESynthesize_get_copy      _JESynthesize_get_unsafe_unretained

#define _JESynthesize_get_weak(type, getter) \
    ((_JEAssociatedObjectsWeakWrapper *)objc_getAssociatedObject(self, _JESynthesizeKey_##getter)).weakObject

#define _JESynthesize_set_assign(type, getter) \
    objc_setAssociatedObject(self, \
    _JESynthesizeKey_##getter, \
    [[NSValue alloc] initWithBytes:&getter objCType:@encode(type)], \
    OBJC_ASSOCIATION_RETAIN_NONATOMIC);

#define _JESynthesize_set_unsafe_unretained(type, getter) \
    objc_setAssociatedObject(self, \
    _JESynthesizeKey_##getter, \
    getter, \
    OBJC_ASSOCIATION_ASSIGN);

#define _JESynthesize_set_strong(type, getter) \
    objc_setAssociatedObject(self, \
    _JESynthesizeKey_##getter, \
    getter, \
    OBJC_ASSOCIATION_RETAIN_NONATOMIC);

#define _JESynthesize_set_retain _JESynthesize_set_strong

#define _JESynthesize_set_copy(type, getter) \
    objc_setAssociatedObject(self, \
    _JESynthesizeKey_##getter, \
    getter, \
    OBJC_ASSOCIATION_COPY_NONATOMIC);

#define _JESynthesize_set_weak(type, getter) \
    objc_setAssociatedObject(self, \
    _JESynthesizeKey_##getter, \
    [[_JEAssociatedObjectsWeakWrapper alloc] initWithWeakObject:getter], \
    OBJC_ASSOCIATION_RETAIN_NONATOMIC);