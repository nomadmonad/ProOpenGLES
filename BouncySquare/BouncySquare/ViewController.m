//
//  ViewController.m
//  BouncySquare
//
//  Created by tyamamo on 2014/05/29.
//  Copyright (c) 2014年 RICOH IT Solutions, Inc. All rights reserved.
//

#import "ViewController.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface ViewController ()
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
    
    //[self setupGL];
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

#pragma mark - GLKView and GLKViewController delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    static int counter = 0;
    
    static const GLfloat cubeVertices[] = {
        -0.5,  0.5,  0.5,   // vertex 0
         0.5,  0.5,  0.5,   // v1
         0.5, -0.5,  0.5,   // v2
        -0.5, -0.5,  0.5,   // v3
        
        -0.5,  0.5, -0.5,   // v4
         0.5,  0.5, -0.5,   // v5
         0.5, -0.5, -0.5,   // v6
        -0.5, -0.5, -0.5,   // v7
    };
    
    static const GLubyte cubeColors[] = {
        255, 255,   0, 255,
          0, 255, 255, 255,
          0,   0,   0,   0,
        255,   0, 255, 255,
        
        255, 255,   0, 255,
          0, 255, 255, 255,
          0,   0,   0,   0,
        255,   0, 255, 255,
    };
    
    static const GLubyte tfan1[6 * 3] = {
        1, 0, 3,
        1, 3, 2,
        1, 2, 6,
        1, 6, 5,
        1, 5, 4,
        1, 4, 0,
    };
    
    static const GLubyte tfan2[6 * 3] = {
        7, 4, 5,
        7, 5, 6,
        7, 6, 2,
        7, 2, 3,
        7, 3, 0,
        7, 0, 4,
    };
    
    static GLfloat transY = 0.0;
    static GLfloat z = -2.0;
    static GLfloat spinX = 0.0;
    static GLfloat spinY = 0.0;
    
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glMatrixMode(GL_CULL_FACE);
    glCullFace(GL_BACK);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glTranslatef(0.0, (GLfloat)(sinf(transY)/2.0), z);
    
    glRotatef(spinY, 0.0, 1.0, 0.0);
    glRotatef(spinX, 1.0, 0.0, 0.0);
    glScalef(1, 2, 1);

    transY += 0.075f;
    
    glVertexPointer(3, GL_FLOAT, 0, cubeVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, cubeColors);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glDrawElements(GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, tfan1);
    glDrawElements(GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, tfan2);
    
    if (!(counter % 100)) {
        NSLog(@"FPS: %d\n", self.framesPerSecond);
    }
    counter++;
    
    spinX += 0.25;
    spinY += 0.25;
}

- (void)setClipping
{
    float aspectRatio;
    const float zNear = 0.1;
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
