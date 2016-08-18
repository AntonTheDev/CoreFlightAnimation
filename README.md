# CoreFlightAnimation

[![Cocoapods Compatible](https://img.shields.io/badge/pod-v0.1.0Beta-blue.svg)]()
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)]()
[![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)]()
[![License](https://img.shields.io/badge/license-MIT-343434.svg)]()

![alt tag](/Documentation/FlightBanner.jpg?raw=true)

##Introduction

***Currently found on dev branch until documentation is complete***

CoreFlightAnimation is a naturally built on top of CoreAnimation APIs. Featuring seamless intergration into existing animations in existing projects, `CABasicAnimation`, and `CAAnimationGroup` are enhanced 46+ parametric easings, animation caching, and sequencing with other animations. 

Under the hood, CoreFlightAnimation uses `CAKeyframeAnimation` to dynamically interpolate based on the presentation layer's values when the animation is applied. Unique to CoreFlightAnimation is that you can define prowperty animations with different easing curves, group them together, and watch the group synchronize them dynamically from the current state, even in mid-flight. 
<br>

##Features

- [x] Seamless integration with CoreAnimation APIs
- [x] [46+ Parametric Curves, Decay, and Springs](/Documentation/parametric_easings.md) 
- [x] Chain Animations:
	* Synchronously 
	* Relative to Time Progress
	* Relative to Value Progress
- [x] Apply Unique Easing per Property Animation
- [x] Advanced Multi-Curve Group Synchronization
- [x] Define, Cache, and Reuse Animations
    
##Installation

* [Installation Documentation](/Documentation/installation.md)

##Integration into Existing Projects

Follow the following 4 steps, and be on your way:

1. Change `CABasicAnimation` to `FABasicAnimation`, technically the letter **C** to **F**
2. Change `CAAnimationGroup` to `FABasicAnimationGroup`, same as previous :)
3. Use defaults values the following properties, which are now configured by CoreFlightAnimation:
	- *removedOnCompletion*, 
	- *fillMode*, 
	- *fromValue* 
4. Change `timingFunction` property to `easingFuntion`, and use one of 46+ enumerated options :)

Simple as that!

##Basic Use 

Since the framework was built mimicking CoreAnimation APIs it is very simple integration wherever `CABasicAnimations`, and `CAAnimationGroups` are used as the follow nearly identical sytax other the property name change for the `timingFunction` to the newly enhanced `easingFuntion` with many more options.

##### CABasicAnimation vs. FABasicAnimation

Using a CABasicAnimation, it can get lengthy to write an animation. Even after creating some sort of helper mechanism, CABasicAnimations have their limitations, especially the lack of timingFunctions. Let's observe the following CABasicAnimation. 

```
	let toCenterPoint = CGPointMake(100,100)

    let positionAnimation 					= CABasicAnimation(keyPath: "position")
    positionAnimation.duration 				= 0.5
    positionAnimation.toValue 				= NSValue(CGPoint : toCenterPoint)
    positionAnimation.fromValue 			= NSValue(CGPoint : view.layer.position)
    positionAnimation.fillMode              = kCAFillModeForwards
    positionAnimation.removedOnCompletion   = false
    positionAnimation.timingFunction        = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)

    view.layer.addAnimation(positionAnimation, forKey: "PositionAnimationKey")
    view.center = toCenterPoint
```
Below is the equvalent using FABasicAnimation.

```
	let toCenterPoint = CGPointMake(100,100)
	
    let positionAnimation 					= FABasicAnimation(keyPath: "position")
    positionAnimation.toValue 				= NSValue(CGPoint : toCenterPoint)
    positionAnimation.duration 				= 0.5
	positionAnimation.easingFuntion         = .OutSine
    
    view.layer.addAnimation(positionAnimation, forKey: "PositionAnimationKey")
    view.center = toCenterPoint
```

The key differences you will notice:

1. `CABasicAnimation` becomes an instance of `FABasicAnimation`
2. The **removedOnCompletion**, **fillMode**, and **fromValue** are now set automatically by the framework
3. The **timingFunction** becomes the **easingFuntion**, with 35 enumerated options4. 


##### CAAnimationGroup vs. FABasicAnimationGroup

As easy it is to conver a CABasicAnimation to an FABasicAnimation, and before diving into some more advanced topics, lets now take a quick look at how the CAAnimationGroup compares to the FABasicAnimationGroup. 

First lets created an two animations to animate the frame of our view. Observe how we create a following CAAnimationGroup, with two animations, one for bounds, and the other for position.

```
	let toFrame  		= CGRectMake(100,100,100,100)
	let toCenter 		= CGPointMake(toFrame.midX, toFrame.midY)
	let toBounds 		= CGCGRectMake(0, 0, toFrame.width, toFrame.height)

    let positionAnimation 					= CABasicAnimation(keyPath: "position")
    positionAnimation.duration 				= 0.5
    positionAnimation.toValue 				= NSValue(CGPoint : toCenterPoint)
    positionAnimation.fromValue 			= NSValue(CGPoint : view.layer.position)
    positionAnimation.fillMode              = kCAFillModeForwards
    positionAnimation.removedOnCompletion   = false
    positionAnimation.timingFunction        = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)

    let boundsAnimation 					= CABasicAnimation(keyPath: "bounds")
    boundsAnimation.duration 				= 0.5
    boundsAnimation.toValue 				= NSValue(CGRect : toBounds)
    boundsAnimation.fromValue 				= NSValue(CGRect : view.layer.bounds)
    boundsAnimation.fillMode              	= kCAFillModeForwards
    boundsAnimation.removedOnCompletion   	= false
    boundsAnimation.timingFunction        	= CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)

	let animationGroup = CAAnimationGroup()
	animationGroup.timingFunction = kCAMediaTimingFunctionEaseInEaseOut
	animationGroup.duration = 0.5
	animationGroup.animations = [positionAnimation, boundsAnimation]

    view.layer.addAnimation(animationGroup, forKey: "PositionAnimationKey")
    view.frame = toFrame
```

Now let's look at how he would implement this using FABasicAnimationGroup

```
	let toFrame  		= CGRectMake(100,100,100,100)
	let toCenter 		= CGPointMake(toFrame.midX, toFrame.midY)
	let toBounds 		= CGRectMake(0, 0, toFrame.width, toFrame.height)

    let positionAnimation 					= FABasicAnimation(keyPath: "position")
    positionAnimation.duration 				= 0.5
    positionAnimation.toValue 				= NSValue(CGPoint : toCenterPoint)
    positionAnimation.easingFuntion         = .EaseOutCubic

    let boundsAnimation 					= FABasicAnimation(keyPath: "bounds")
    boundsAnimation.duration 				= 0.5
    boundsAnimation.toValue 				= NSValue(CGRect : toBounds)
    boundsAnimation.easingFuntion          = .EaseOutCubic
    
	let animationGroup = FABasicAnimationGroup()
	animationGroup.animations = [positionAnimation, boundsAnimation]

    view.layer.addAnimation(animationGroup, forKey: "PositionAnimationKey")
    view.frame = toFrame
```
1. `CABasicAnimation` becomes `FABasicAnimation`
2. `CAAnimationGroup` becomes `FABasicAnimationGroup`
3. The **removedOnCompletion**, **fillMode**, and **fromValue** are now defined by the framework
4. The **timingFunction** becomes the **easingFuntion**, with 46+ enumerated options

###Caching Animations

The cool thing about this framework is that you can register animations for a specific key, and trigger them as needed based on the Animation Key it registered against. By defining multiple states up front, we can toggle them when needed, and it will synchronize / interpolate all the values accordingly when applied.

####Register Animation

FABasicAnimation allows for caching animations, and reusing them at a later point. for the purpose of this example lets first create an animation key to register a position animation against

```
	struct AnimationKeys {
    	static let PositionAnimation  = "PositionAnimation"
	}
```

Now that the key is defined, create lets create an animation.

```
    let positionAnimation 					= FABasicAnimation(keyPath: "position")
    positionAnimation.toValue 				= NSValue(CGPoint : toCenterPoint)
    positionAnimation.duration 				= 0.5
	positionAnimation.easingFuntion         = .EaseOutCubic
``` 

Once the animation is created, we then need to register it with to the view with out defined animation key.

```
	// Register Animation Groups
	view.registerAnimation(positionAnimation, forKey: AnimationKeys.PositionAnimation)
```

**Note**: Registering an FABasicAnimationGroup works the exact same way as the registering an FABasicAnimation documented above. Technically, when registering a simple FABasicAnimation, the framework wraps the animation in an FABasicAnimationGroup anyways for syncronization purposes.

####Applying Registered Animations

To apply the animation state, all we have to do is call the following. This will synchronize the current presentations values with a prior animation, apply the relative remaining time of travel, and will apply the animation to the final destination.

```
	 view.applyAnimation(forKey: AnimationKeys.PositionAnimation)
```

If you want to just apply the final values of a registered animation without actually performing the animation, just call the following

```
	 view.applyAnimation(forKey: AnimationKeys.PositionAnimation, animated : false)
```

## License
<br>

     The MIT License (MIT)  
      
     Copyright (c) 2016 Anton Doudarev  
      
     Permission is hereby granted, free of charge, to any person obtaining a copy
     of this software and associated documentation files (the "Software"), to deal
     in the Software without restriction, including without limitation the rights
     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
     copies of the Software, and to permit persons to whom the Software is
     furnished to do so, subject to the following conditions:  
     
     The above copyright notice and this permission notice shall be included in all
     copies or substantial portions of the Software.  
      
     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
     SOFTWARE.  