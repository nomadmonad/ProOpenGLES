//
//  OpenGLSolarSystemController.m
//  PlanetSample
//
//  Created by tyamamo on 2014/05/29.
//  Copyright (c) 2014年 RICOH IT Solutions, Inc. All rights reserved.
//

#import "OpenGLSolarSystemController.h"
#import "Planet.h"
#import "OpenGLSolarSystem.h"

@implementation OpenGLSolarSystemController{
    Planet* m_earth;
}

- (id)init
{
    [self initGeometry];
    return self;
}

- (void)initGeometry
{
    m_earth = [[Planet alloc] init:10 slices:10 radius:1.0 squash:1.0];
}

- (void)execute
{
    static GLfloat angle = 0;
    glLoadIdentity();
    glTranslatef(0.0, -0.0, -3.0);
    glRotatef(angle, 0.0, 1.0, 0.0);
    
    [m_earth execute];
    angle += 0.5;
}

- (void)initLighting
{
    GLfloat diffuse[] = {0.0, 1.0, 0.0, 1.0};
    GLfloat pos[] = {0.0, 10.0, 0.0, 1.0};
    
    glLightfv(SS_SUNLIGHT, GL_POSITION, pos);
    glLightfv(SS_SUNLIGHT, GL_DIFFUSE, diffuse);
    
    glShadeModel(GL_SMOOTH);
    
    glEnable(GL_LIGHTING);
    glEnable(SS_SUNLIGHT);
}

@end
