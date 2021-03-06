//
//  HelloWorldLayer.m
//  Cocos2DSimpleGame
//
//  Created by Nadeem Khan on 9/12/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

NSMutableArray *_targets;
NSMutableArray *_projectiles;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) addTarget
{
    CCSprite *target = [CCSprite spriteWithFile:@"Target.png" rect:CGRectMake(0,0,27,40)];
    
    target.tag = 1;
    [_targets addObject:target];
    
    // Determine where to spawnt the target along the Y axis
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minY = target.contentSize.height/2;
    int maxY = winSize.height - target.contentSize.height/2;
    int rangeY = maxY - minY;
    
    // Y Position somewhere along on the screen on the y axis
    int actualY = (arc4random() % rangeY) + minY;
    
    // X Position somwehere off the right edge.
    target.position = ccp(winSize.width + (target.contentSize.width / 2), actualY);
    
    [self addChild:target];
    
    // Determine the speed of the target
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int durationRange = maxDuration - minDuration;
    
    int actualDuration = (arc4random() % durationRange) + minDuration;
    
    // Create the actions
    id actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(-target.contentSize.width/2, actualY)];
    
    id actionMoveDone = [CCCallFuncN actionWithTarget:self 
                                             selector:@selector(spriteMoveFinished:)];
    [target runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];    
    
    
}

-(void) spriteMoveFinished:(id)sender {
    CCSprite *sprite = (CCSprite *) sender;
    if(sprite.tag == 1) // target
    {
        [_targets removeObject:sprite];
        
        GameOverScene *gameOverScene = [GameOverScene node];
        
        [gameOverScene.layer.label setString:@"You lose :["];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];
        
    } else if(sprite.tag == 2)
    {
        [_projectiles removeObject:sprite];
    }
    
    [self removeChild:sprite  cleanup:YES];
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(255, 255, 255, 255) ])) {
        
        _targets = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];
        
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        _player = [[CCSprite spriteWithFile:@"Player2.jpeg"] retain];
        _player.position = ccp(_player.contentSize.width/2, winSize.height/2);
        [self addChild:_player];
        
		
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];

		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label];
	}
    
    self.isTouchEnabled = YES;
    
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
    
    [self schedule:@selector(update:)];
    
    [self schedule:@selector(gameLogic:) interval:1.0];
	return self;
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_nextProjectile != nil) return;
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    // Set up initial location of the projectile
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    _nextProjectile = [[CCSprite spriteWithFile:@"Projectile2.jpeg"] retain];
    _nextProjectile.position = ccp(20, winSize.height/2);
    
    
    // Determine offset of location to projectile
    int offX = location.x - _nextProjectile.position.x;
    int offY = location.y - _nextProjectile.position.y;
    
    // Bail out of we are shooting down or backwards
    if (offX <= 0) return;
    
    
    // Determine where we wish to shoot the projectile to
    int realX = winSize.width + (_nextProjectile.contentSize.width/2);
    float ratio = (float) offY / (float) offX;
    
    int realY = (realX * ratio) + _nextProjectile.position.y;
    CGPoint realDest = ccp(realX, realY);
    
    // Determine the length of how far we're shooting
    int offRealX = realX - _nextProjectile.position.x;
    int offRealY = realY - _nextProjectile.position.y;
    
    float length = sqrtf((offRealX*offRealX) + (offRealY*offRealY));
    float velocity = 480/1; //480 px per sec
    
    float realMoveDuration = length / velocity;
    
    // Determine the angle of the face.
    float angleRadians = atanf((float) offRealY / (float) offRealX);
    float angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
    float cocosAngle = -1 * angleDegrees;
    
    float rotateSpeed = 0.5 / M_PI;
    float rotateDuration = fabs(angleRadians * rotateSpeed);
    [_player runAction:[CCSequence actions:
                        [CCRotateTo actionWithDuration:rotateDuration angle:cocosAngle],
                        [CCCallFunc actionWithTarget:self selector:@selector(finishShoot)],
                        nil]];
    
    
    
    // Move projectile to actual endpoint
    
    [_nextProjectile runAction:[CCSequence actions:
                           [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
                           [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                           nil]];
    
    
    // Add to projectiles array
    _nextProjectile.tag = 2;
    
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
}

-(void) finishShoot
{
    // Ok to add now - we've finished rotation!
    [self addChild:_nextProjectile];
    [_projectiles addObject:_nextProjectile];
    
    // Release
    [_nextProjectile release];
    _nextProjectile = nil;
    
}

-(void)update:(ccTime)dt
{
    NSMutableArray *projectileToDelete = [[NSMutableArray alloc] init];
    
    for(CCSprite *projectile in _projectiles)
    {
        CGRect projectileRect = CGRectMake(
                                           projectile.position.x - (projectile.contentSize.width/2),
                                           projectile.position.y - (projectile.contentSize.height/2),
                                           projectile.contentSize.width,
     
                                           projectile.contentSize.height);
        NSMutableArray *targetsToDelete = [[NSMutableArray alloc]init];
        
        for(CCSprite *target in _targets)
        {
            CGRect targetRect = CGRectMake(
                                           target.position.x - (target.contentSize.width/2), 
                                           target.position.y - (target.contentSize.height/2), 
                                           target.contentSize.width, 
                                           target.contentSize.height);
            
            if(CGRectIntersectsRect(projectileRect, targetRect))
            {
                [targetsToDelete addObject:target];
            }
        }
        
        for(CCSprite *target in targetsToDelete)
        {
            [_targets removeObject:target];
            [self removeChild:target cleanup:YES];
            _projectileDestroyed++;
            
            if(_projectileDestroyed > 30)
            {
                GameOverScene *gameOverScene = [GameOverScene node];
                _projectileDestroyed = 0;
                [gameOverScene.layer.label setString:@"You Win!"];
                [[CCDirector sharedDirector] replaceScene:gameOverScene];
            }
        }
        
        if(targetsToDelete.count > 0) 
        {
            [projectileToDelete addObject:projectile];
        }
        
        [targetsToDelete release];
    }
    
    for(CCSprite *projectile in projectileToDelete)
    {
        [_projectiles removeObject:projectile];
        [self removeChild:projectile cleanup:YES];
    }
    
    [projectileToDelete release];
}

-(void) gameLogic :(ccTime) dt
{
    [self addTarget];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
    [_targets release];
    _targets = nil;
    [_projectiles release];
    _projectiles = nil;
    
    [_player release];
    _player = nil;
    
}
@end
