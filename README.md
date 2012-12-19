# switch-image.js

A simple jQuery plugin to switch images in response to events, such as hover (mouseover and mouseout), with support for animated transitions.

That's all for now.

# Usage

```coffee
    $('.switch-image').switchImage()
```

Defaults:

```coffee
  $.fn.switchImage.defaults = 
    selector: 'img'
    targetSelector: 'img'
    suffixes:
      mouseover: '-on'
      mouseout: ''
    animation:
      on: {opacity: 1}
      off: {opacity: 0}
      duration: 600
    easing:
      on: 'easeOutQuad'
      off: 'easeInQuad'
```