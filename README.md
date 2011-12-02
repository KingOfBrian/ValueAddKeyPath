#Value Add Key Path


Value Add Key Path is a key path grammar taken to it's Cocoa Extreme.   It 
allows creation of keypaths with custom collection operations and collection 
filtering with NSPredicate.  It is a goal to allow the lookup of any object
in your application with a single string.

  Using this in Application code is probably a bad idea.
  Using this in Test Code, is very nice.

This was written to give Frank users a Cocoa option for looking up objects
using frank.  It allows the tester to work with non-UIView objects as well as use 
a grammar Cocoa developers are used to.  It is very wordy, but clear and easily 
extensible.  Think of it as an alternative to UISpec rather than an advanced keypath.

In addition to custom Key Paths, there is also a category to simplify object 
lookup and a SelectorEngine for use inside Frank. 

##Basics

* Objects can be filtered by adding a NSPredicate defined by a '[[.*]]' block
 - Only NSArray and NSSet object supported by default
 - Any object can add filtering support by implementing _filteredValueAddUsingPredicate:_
* Execute a method on an object by preceding the key path with a @
 - Arguments are not currently supported.   Grammar suggestions are desired!
 - Regular key path collection operations may not be supported without additional categories


##Examples


Assume the following wrapper for the examples below.

    [[UIApplication sharedApplication] valueAddKeyPath:$EXAMPLE]

To obtain a list of all subviews:

    windows.@flattenBy.subviews

To obtain a specific type of view:

    windows.@flattenBy.subviews[[class.description='UILabel']]

To obtain the view's grand parent:

    windows.@flattenBy.subviews[[class.description='UILabel']].superview.superview

To Ensure that the specified view is not moving

    windows.@flattenBy.subviews[[class.description='UILabel' AND tag=1000 AND isHidden=NO AND isOnScreen=YES]].@flattenBy.superview[[isAnimating = 0]]


Yes, it's a bit excessive, but it makes easy to bridge into scripting languages.
