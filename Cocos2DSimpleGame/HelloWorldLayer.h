//
//  HelloWorldLayer.h
//  Cocos2DSimpleGame
//
//  Created by Nadeem Khan on 9/12/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "GameOverScene.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayerColor
{
    int _projectileDestroyed;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
