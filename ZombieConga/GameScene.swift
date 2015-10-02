//
//  GameScene.swift
//  ZombieConga
//
//  Created by Steve Clement on 24/09/15.
//  Copyright (c) 2015 Steve Clement. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

  // Variables exposed to all the functions (or properties to some)
  let zombie = SKSpriteNode(imageNamed: "zombie1")
  var lastUpdateTime: NSTimeInterval = 0
  var dt: NSTimeInterval = 0
  let zombieMovePointPerSec: CGFloat = 480.0
  var velocity = CGPointZero
  let playableRect: CGRect
  var lastTouchLocation: CGPoint?
  let zombieRotateRadiansPerSec:CGFloat = 4.0 * π

  let debug = true


  // Overrides
  override init(size: CGSize) {
    let maxAspectRatio:CGFloat = 16.0/9.0
    let playableHeight = size.width / maxAspectRatio
    let playableMargin = (size.height-playableHeight)/2
    playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
    super.init(size: size)
  }
  required init(coder aDecode: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func didMoveToView(view: SKView) {
    backgroundColor = SKColor.whiteColor()
    let background = SKSpriteNode(imageNamed: "background1")
    //background.position = CGPoint(x: size.width/2, y: size.height/2)
    background.anchorPoint = CGPointZero
    background.position = CGPointZero
    background.zPosition = -1
    
    zombie.position = CGPoint(x: 400.0, y: 400.0)
    //zombie.xScale = 2.0
    //zombie.yScale = 2.0
    //zombie.setScale(2.0)
    addChild(background)
    addChild(zombie)
    spawnEnemy()
    debugDrawPlayableArea()
  }
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let touch = touches.first as UITouch!
    let touchLocation = touch.locationInNode(self)
    sceneTouched(touchLocation)
  }
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let touch = touches.first as UITouch!
    let touchLocation = touch.locationInNode(self)
    sceneTouched(touchLocation)
  }
  override func update(currentTime: CFTimeInterval) {
    if lastUpdateTime > 0 {
      dt = currentTime - lastUpdateTime
    } else {
      dt = 0
    }
    lastUpdateTime = currentTime
    println("\(dt*1000) ms since last update")

    if let lastTouch = lastTouchLocation {
      let diff = lastTouch - zombie.position
      if (diff.length() <= zombieMovePointPerSec * CGFloat(dt)) {
        zombie.position = lastTouchLocation!
        velocity = CGPointZero
      } else {
        moveSprite(zombie, velocity: velocity)
        rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
      }
    }

    boundsCheckZombie()
  }

  // User Functions
  func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
    let amountToMove = velocity * CGFloat(dt)
    println("Amount to move: \(amountToMove)")
    sprite.position += amountToMove
  }
  func moveZombieToward(location: CGPoint) {
    let offset = location - zombie.position
    let direction = offset.normalized()
    velocity = direction * zombieMovePointPerSec
  }
  func sceneTouched(touchLocation: CGPoint) {
    lastTouchLocation = touchLocation
    moveZombieToward(touchLocation)
  }
  func boundsCheckZombie() {
    let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
    let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))

    if zombie.position.x <= bottomLeft.x {
      zombie.position.x = bottomLeft.x
      velocity.x = -velocity.x
    }
    if zombie.position.x >= topRight.x {
      zombie.position.x = topRight.x
      velocity.x = -velocity.x
    }
    if zombie.position.y <= bottomLeft.y {
      zombie.position.y = bottomLeft.y
      velocity.y = -velocity.y
    }
    if zombie.position.y >= topRight.y {
      zombie.position.y = topRight.y
      velocity.y = -velocity.y
    }
  }
  func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
    let shortest = shortestAngleBetween(sprite.zRotation, angle2: velocity.angle)
    let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
    sprite.zRotation += shortest.sign() * amountToRotate

  }
  func distanceCheckZombie(lastTouchLocation: CGPoint, touchLocation: CGPoint) {
    print("Last: \(lastTouchLocation) \nCurrent: \(touchLocation)")
  }
  func spawnEnemy() {
    let enemy = SKSpriteNode(imageNamed: "enemy")
    enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: size.height/2)
    addChild(enemy)
//    let actionMidMove = SKAction.moveTo(CGPoint(x: size.width/2, y:CGRectGetMinY(playableRect) + enemy.size.height/2), duration: 1.0)
//    let actionMove = SKAction.moveTo(CGPoint(x: -enemy.size.width/2, y:enemy.position.y), duration: 1.0)
    let actionMidMove = SKAction.moveByX(-size.width/2 - enemy.size.width/2, y: -CGRectGetHeight(playableRect)/2 + enemy.size.height/2, duration: 1.0)
    let actionMove = SKAction.moveByX(-size.width/2-enemy.size.width/2, y: CGRectGetHeight(playableRect)/2 - enemy.size.height/2, duration: 1.0)
    let wait = SKAction.waitForDuration(0.25)
    let logMessage = SKAction.runBlock() {
      self.println("Reached bottom!")
    }
    let halfSequence = SKAction.sequence([actionMidMove, logMessage, wait, actionMove])
    let sequence = SKAction.sequence([halfSequence, halfSequence.reversedAction()])

    enemy.runAction(sequence)
  }

  // Debug helpers
  func println(content: NSString) {
    if debug {
      print("\(content)")
    }
  }
  func debugDrawPlayableArea() {
    if !debug {
      return
    }
    print("\(size)")
    let shape = SKShapeNode()
    let path = CGPathCreateMutable()
    CGPathAddRect(path, nil, playableRect)
    shape.path = path
    shape.strokeColor = SKColor.redColor()
    shape.lineWidth = 12.0
    addChild(shape)
  }
}