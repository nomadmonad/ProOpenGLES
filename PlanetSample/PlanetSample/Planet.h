//
//  Planet.h
//  PlanetSample
//
//  Created by tyamamo on 2014/05/29.
//  Copyright (c) 2014年 RICOH IT Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>

@interface Planet : NSObject
- (BOOL) execute;
- (id) init:(GLint)stacks slices:(GLint)slices radius:(GLfloat)radius squash:(GLfloat)squash;
@end
