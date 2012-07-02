# DMScrollingTicker

DMScrollingTicker is an advanced horizontal scroll ticker class made in Objective-C for iOS.
It doesn't use standard NSTimer to perform animations but instead Quartz Layers / CoreGraphics.
It allows to load any set of UIView subclasses and add to the scrolling queue with a simple call.

Daniele Margutti, <http://www.danielem.org>

![DMScrollingTicker Example Project](http://danielemargutti.com/wp-content/uploads/2012/06/DMScrollingTicker.png)

## How to get started

You can pick between two modes:
* standard mode: you will pass your list of UIViews and begin animation (all views will be adjusted and loaded at startup time)
* lazy mode: you will pass only UIView's CGSizes array and a datasource blocks handler and DMScrollingView will load each view only when needed (and remove them when not used). It may be useful when you have lots of ticker elements (here called subviews) and you pay attention to the memory usage

It's compatible with iOS 4.x+ or later (it uses blocks).

## Change log

### May 31, 2012

* First version

## Donations

If you found this project useful, please donate.
There’s no expected amount and I don’t require you to.

<a href='https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=GS3DBQ69ZBKWJ">CLICK THIS LINK TO DONATE USING PAYPAL</a>

## License (MIT)

Copyright (c) 2012 Daniele Margutti

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
