//
//  GameOverScene.h
//  Cocos2DSimpleGame
//
//  Created by Nadeem Khan on 9/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameOverLayer : CCLayerColor {
    CCLabelTTF *_label;
}

@property (nonatomic, retain) CCLabelTTF *label;
@end

@interface GameOverScene : CCScene {
    GameOverLayer *_layer;
}

@property (nonatomic, retain) GameOverLayer *layer;
@end
