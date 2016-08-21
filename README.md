#CoreFlightAnimation

[![Cocoapods Compatible](https://img.shields.io/badge/pod-v0.9.1-blue.svg)]()
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)]()
[![Platform](https://img.shields.io/badge/platform-ios | tvos-lightgrey.svg)]()
[![License](https://img.shields.io/badge/license-MIT-343434.svg)](/LICENSE.md)

![alt tag](/Documentation/FlightBanner.png?raw=true)

##Introduction

CoreFlightAnimation is a naturally built on top of CoreAnimation APIs. Featuring seamless intergration into existing animations in existing projects, `CABasicAnimation`, and `CAAnimationGroup` are enhanced 46+ parametric easings, animation caching, and sequencing with other animations. 

Under the hood, CoreFlightAnimation uses `CAKeyframeAnimation` to dynamically interpolate based on the presentation layer's values when the animation is applied. Unique to CoreFlightAnimation is that you can define prowperty animations with different easing curves, group them together, and watch the group synchronize them dynamically from the current state, even in mid-flight. 
<br>

##Features

- [x] Seamless integration with existing CoreAnimation APIs
- [x] [46+ Parametric Curves, Decay, and Springs](/Documentation/parametric_easings.md) 
- [x] Chain Animations:
	* Synchronously 
	* Relative to Time Progress
	* Relative to Value Progress
- [x] Reverse Animations / AnimationGroups
	* Once, Mutiple Times, or Indefinitely 
	* Delay Revese
	* Invert Easing Curves
- [x] Apply Unique Easing per Property Animation
- [x] Advanced Multi-Curve Group Synchronization
- [x] Define, Cache, and Reuse Animations
    
##Installation

* [Installation Documentation](/Documentation/installation.md)

##Basic Use 

Since the framework was built mimicking CoreAnimation APIs it is very simple integration wherever `CABasicAnimation`, and `CAAnimationGroup` are used as the follow nearly identical syntax. Before diving into some more advanced features, take a quick look at how the `CoreAnimation` compares to the `CoreFlightAnimation`. 

##### CoreAnimation vs. CoreFlightAnimation

```swift
let positionAnimation 					= CABasicAnimation(keyPath: "position")
positionAnimation.duration 				= 0.5
positionAnimation.toValue 				= NSValue(CGPoint : toCenterPoint)
positionAnimation.fromValue 			= NSValue(CGPoint : view.layer.position)
positionAnimation.fillMode              = kCAFillModeForwards
positionAnimation.timingFunction        = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)

let boundsAnimation 					= CABasicAnimation(keyPath: "bounds")
boundsAnimation.duration 				= 0.5
boundsAnimation.toValue 				= NSValue(CGRect : toBounds)
boundsAnimation.fromValue 				= NSValue(CGRect : view.layer.bounds)
boundsAnimation.fillMode              	= kCAFillModeForwards
boundsAnimation.timingFunction        	= CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)

let animationGroup 						= CAAnimationGroup()
animationGroup.duration 				= 0.5
animationGroup.removedOnCompletion   	= false
animationGroup.animations 				= [positionAnimation, boundsAnimation]

view.layer.addAnimation(animationGroup, forKey: "PositionAnimationKey")
view.frame = toFrame
```
Below is the equivalent in `CoreFlightAnimation`.

```swift
let positionAnimation 					= FABasicAnimation(keyPath: "position")
positionAnimation.duration 				= 0.5
positionAnimation.toValue 				= NSValue(CGPoint : toCenterPoint)
positionAnimation.easingFuntion         = .OutCubic

let boundsAnimation 					= FABasicAnimation(keyPath: "bounds")
boundsAnimation.duration 				= 0.5
boundsAnimation.toValue 				= NSValue(CGRect : toBounds)
boundsAnimation.easingFuntion          = .OutCubic
    
let animationGroup = FABasicAnimationGroup()
animationGroup.animations = [positionAnimation, boundsAnimation]

view.layer.addAnimation(animationGroup, forKey: "PositionAnimationKey")
view.frame = toFrame
```

Follow the following 4 steps to integrate `CoreFlightAnimation` into existing projects:

1. Change `CABasicAnimation` to `FABasicAnimation`, technically the letter **C** to **F**
2. Change `CAAnimationGroup` to `FABasicAnimationGroup`, same as previous :)
3. Use defaults values the following properties, which are now configured by CoreFlightAnimation:
	- *removedOnCompletion*
	- *fillMode*
	- *fromValue* 
4. Change `timingFunction` property to `easingFuntion`, and use one of 46+ enumerated options :)

Simple as that!

###Caching Animations

The cool thing about this framework is that you can register animations for a specific key, and trigger them as needed based on the Animation Key it registered against. By defining multiple states up front, we can toggle them when needed, and it will synchronize / interpolate all the values accordingly when applied.

####Register Animation

FABasicAnimation allows for caching animations, and reusing them at a later point. for the purpose of this example lets first create an animation key to register a position animation against

```swift
struct AnimationKeys {
    static let PositionAnimation  = "PositionAnimation"
}
```

Now that the key is defined, create lets create an animation.

```swift
let positionAnimation 					= FABasicAnimation(keyPath: "position")
positionAnimation.toValue 				= NSValue(CGPoint : toCenterPoint)
positionAnimation.duration 				= 0.5
positionAnimation.easingFuntion         = .EaseOutCubic
``` 

Once the animation is created, we then need to register it with to the view with out defined animation key.

```swift
// Register Animation Groups
view.registerAnimation(positionAnimation, forKey: AnimationKeys.PositionAnimation)
```

**Note**: Registering an FABasicAnimationGroup works the exact same way as the registering an FABasicAnimation documented above. Technically, when registering a simple FABasicAnimation, the framework wraps the animation in an FABasicAnimationGroup anyways for syncronization purposes.

####Applying Registered Animations

To apply the animation state, all we have to do is call the following. This will synchronize the current presentations values with a prior animation, apply the relative remaining time of travel, and will apply the animation to the final destination.

```swift
view.applyAnimation(forKey: AnimationKeys.PositionAnimation)
```

If you want to just apply the final values of a registered animation without actually performing the animation, just call the following

```swift
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