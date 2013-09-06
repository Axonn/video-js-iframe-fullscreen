video-js-iframe-fullscreen
==========================

A custom fullscreen menu for VideoJS which uses Flash's fullscreen mode, useful for serving video in an iframe. As of the time I'm writing this (September 6, 2013) you should be able to see this in action by visiting any Vidcaster-powered site such as [tv.vidcaster.com](http://tv.vidcaster.com/) with either Firefox or Internet Explorer and pressing the fullscreen button on any video.

We needed this because our videos need to be easily embeddable, so they must be served within iframes. Internet Explorer (all versions, even 10) doesn't support the JavaScript fullscreen API, and you can't use VideoJS's "full window" method in an iframe so we needed another option. This custom menu allows access to Flash's fullscreen mode which does work in Internet Explorer from within an iframe. This also fixes issues we were having in Firefox: we only serve H.264 video, so Firefox runs VideoJS in Flash mode, and we were experiencing a problem where whenever the JavaScript fullscreen API was used, Firefox would re-initialize VideoJS's Flash object and the video would start over. This fullscreen menu fixes that issue too. In more recent versions of Firefox and VideoJS this might not be a problem anymore.

The reason why we need a menu at all versus just going into fullscreen immediately is because Flash doesn't allow you to initiate fullscreen mode from JavaScript. You have to do it by clicking a button in the Flash object itself.

Disclaimers: This code is from December 2012 so it's based on VideoJS 3.2.0 and it's somewhat out-of-date. Also note that this has [our LiveRail integration](https://github.com/vidcaster/video-js-liverail) bundled in to the source, but if you don't need that you should be able to safely ignore it.

Credit for development goes to Tanel Teemusk and Dan Connor. The fullscreen and cancel icons are from the [Iconic](http://somerandomdude.com/iconic/) icon set.