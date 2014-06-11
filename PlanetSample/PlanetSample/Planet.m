//
//  Planet.m
//  PlanetSample
//
//  Created by tyamamo on 2014/05/29.
//  Copyright (c) 2014年 RICOH IT Solutions, Inc. All rights reserved.
//

#import "Planet.h"


@implementation Planet
{
    GLfloat* m_VertexData;
    GLubyte* m_ColorData;
    GLfloat* m_NormalData;
    GLint m_Stacks, m_slices;
    GLfloat m_Scale;
    GLfloat m_Squash;
}

// stack: 球を緯度方向に分割する数（球を経度の方向（横方向で輪切りにする）で、何個に分割するかを定義）
// slice: 球を経度方向に分割する数（球を緯度の方向（縦方向にくし切りにする）で、何個に分割するかを定義）
// radius: 半径
// squash: 扁平率
- (id)init:(GLint)stacks slices:(GLint)slices radius:(GLfloat)radius squash:(GLfloat)squash
{
    unsigned int colorIncrement = 0;
    unsigned int blue = 0;
    unsigned int red = 255;
    int numVertices = 0;
    
    m_Scale = radius;
    m_Squash = squash;
    
    colorIncrement = 255 / stacks;
    
    if (self = [super init]) {
        m_Stacks = stacks;
        m_slices = slices;
        m_VertexData = nil;
        
        // Vertices
        // 頂点データを格納するため、格納する領域を以下の計算式で求める
        //   格納する領域のサイズ = GLFloatのサイズ * 三角形の頂点の数 * （（（経度方向の分割数 + 1） * 2） * 緯度方向の分割数）
        //   * 経度方向はくし切りにするため、分割線が10本引かれた場合、必要な矩形の数は 10 + 1 個となる
        GLfloat* vPtr = m_VertexData = (GLfloat *)malloc(sizeof(GLfloat) * 3 * (((m_slices + 1) * 2) * m_Stacks));
        // 頂点データのColor
        // 格納する領域を以下の計算式で求める
        //   格納する領域のサイズ = GLFloatのサイズ * RGBAの4要素 * （（（経度方向の分割数 + 1） * 2） * 緯度方向の分割数）
        GLubyte* cPtr = m_ColorData = (GLubyte *)malloc(sizeof(GLubyte) * 4 * (((m_slices + 1) * 2) * m_Stacks));
        
        // 法線ベクトル用のデータを格納する 光源の反射方向
        GLfloat* nPtr = m_NormalData = (GLfloat *)malloc(sizeof(GLfloat) * 3 + (((m_slices + 1) * 2) * m_Stacks));
        
        unsigned int phiIdx, thetaIdx;
        
        // latitude
        // 北極から南極方向に処理を実行するループ
        for (phiIdx = 0; phiIdx < m_Stacks; phiIdx++) {
            // starts ad -1.57 goes up to +1.57 radians.
            
            // stackのループの最初で、最初の2点の位置を決めて
            // sliceのループの中でその2点の位置を元に頂点を求めていく。
            
            // the first circle
            // オイラー角の座標系についての知識が必要そう…
            // phi: 座角（方位角）
            // theta: 天頂角
            
            // phiIdxが0の場合、phi0は-90度（-1.57）になってほしい
            float phi0 = M_PI * ((float)(phiIdx + 0) * (1.0 / (float)m_Stacks) - 0.5);
            
            // the next, or second one
            float phi1 = M_PI * ((float)(phiIdx + 1) * (1.0 / (float)m_Stacks) - 0.5);
            float cosPhi0 = cos(phi0);
            float sinPhi0 = sin(phi0);
            float cosPhi1 = cos(phi1);
            float sinPhi1 = sin(phi1);
            
            float cosTheta, sinTheta;
            
            for (thetaIdx = 0; thetaIdx < m_slices; thetaIdx++) {
                // sliceごとに、経度方向のVerrtexを生成していく
                float theta = 2.0 * M_PI * (float) thetaIdx * (1.0 / (float)(m_slices - 1));
                cosTheta = cos(theta);
                sinTheta = sin(theta);
                
                // TRIANGLE_STRIPで描画できるように、stripの頂点座標を計算していく
                // TRIANGLE_STRIPは、4点の頂点を使って2つの三角形を描画する。
                // 最初の三角はv0-v1-v2、次の三角はv2-v1-v3で構成される
                vPtr[0] = m_Scale * cosPhi0 * cosTheta;
                vPtr[1] = m_Scale * sinPhi0 * m_Squash;
                vPtr[2] = m_Scale * cosPhi0 * sinTheta;
                
                vPtr[3] = m_Scale * cosPhi1 * cosTheta;
                vPtr[4] = m_Scale * sinPhi1 * m_Squash;
                vPtr[5] = m_Scale * cosPhi1 * sinTheta;
                
                nPtr[0] = cosPhi0 * cosTheta;
                nPtr[1] = sinPhi0;
                nPtr[2] = cosPhi0 * sinTheta;
                
                nPtr[3] = cosPhi1 * cosTheta;
                nPtr[4] = sinPhi1;
                nPtr[5] = cosPhi1 * sinTheta;
                
                cPtr[0] = red;
                cPtr[1] = 0;
                cPtr[2] = blue;
                cPtr[4] = red;
                cPtr[5] = 0;
                cPtr[6] = blue;
                cPtr[3] = cPtr[7] = 255;
                
                cPtr += 2 * 4;
                vPtr += 2 * 3;
                nPtr += 2 * 3;
            }
            blue += colorIncrement;
            red -= colorIncrement;
        }
        // 頂点の数を求める（処理が終わった後のvPtrのアドレスと先頭位置のアドレスと引いて、6で割ると頂点座標の数を求められる）
        numVertices = (vPtr-m_VertexData) / 6;
    }
    return self;
}

- (BOOL)execute
{
    glMatrixMode(GL_MODELVIEW);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glVertexPointer(3, GL_FLOAT, 0, m_VertexData);
    glNormalPointer(GL_FLOAT, 0, m_NormalData);
    
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_ColorData);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (m_slices + 1) * 2 * (m_Stacks - 1) + 2);
    
    return true;
}
@end
