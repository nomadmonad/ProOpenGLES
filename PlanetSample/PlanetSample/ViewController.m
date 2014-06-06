//
//  ViewController.m
//  PlanetSample
//
//  Created by tyamamo on 2014/05/29.
//  Copyright (c) 2014年 RICOH IT Solutions, Inc. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLSolarSystemController.h"

@interface ViewController () {
    OpenGLSolarSystemController* m_solarSystem;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    m_solarSystem = [[OpenGLSolarSystemController alloc] init];
    
    [EAGLContext setCurrentContext:self.context];
    [self setClipping];
}

- (void)dealloc
{
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
 
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [m_solarSystem execute];
}

- (void)setClipping
{
    float aspectRatio;
    const float zNear = 2.15;
    const float zFar = 1000;
    const float fieldOfView = 60.0;
    GLfloat size;
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    aspectRatio = (float)frame.size.width/(float)frame.size.height;
    
    // Projecton Matrixを変更可能な状態にする
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    size = zNear * tanf(GLKMathDegreesToRadians(fieldOfView) / 2.0);
    
    glFrustumf(-size, size, -size / aspectRatio, size / aspectRatio, zNear, zFar);
    glViewport(0, 0, frame.size.width, frame.size.height);
    
    // GL_MODELVIEWをデフォルトの状態とする
    glMatrixMode(GL_MODELVIEW);
}


@end
