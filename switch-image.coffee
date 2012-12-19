$ = jQuery
defaults = 
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

namespace = 'switchImage'
$.fn[namespace] =
  defaults: defaults

jQueryWidget = (namespace, defaults, constructor)->
  return (option)->
    args = arguments
    return this.each ->
      $this = $(this)
      data = $this.data(namespace)
      if !data
        options = option if typeof option == 'object'
        if options.animation
          options.animation = $.extend {}, defaults.animation, options.animation
        options = $.extend {}, defaults, options
        $this.data(namespace, data = new constructor(this, options))
      if typeof option == 'string'
        args = Array.prototype.slice.call(arguments, 0)
        args.shift()
        data[option].apply data, args

$.fn[namespace] = new jQueryWidget namespace, defaults,
  class SwitchImage
    constructor: (el, @options)->
      # console.log 'SwitchImage', el, @options
      @$el = $(el)
      events = []
      events.push k for k, v of @options.suffixes
      @$el.find(@options.selector).on events.join(' '), $.proxy @switch, @
      @klass = "#{namespace}-switch"
      @init()
    init: ->
      that = @
      @$el.find(@options.selector).each ->
        $image = $(this).find that.options.targetSelector
        return unless $image.length > 0
        for k, suffix of that.options.suffixes
          if suffix then that.loadSuffix suffix, $image
    loadSuffix: (suffix, $image)->
      src = $image.attr('src').replace(/\./, suffix + ".")
      $image.css('z-index', 100)
      $switch = $("<img src='#{src}' class='#{@klass}'>")
        .css('zIndex', 0)
        .css('position', 'absolute')
        .css('top', 0)
        .css('left', 0)
      if @options.animation
        for k, v of @options.animation.off
          $switch.css(k, v)
      $image.data(namespace, $switch)
      $image.parent()
        .css('position', 'relative')
        .append($switch)
      # console.log 'append'
    switch: (e)->
      suffix = @options.suffixes[e.type]
      $el = $(e.currentTarget)
      if $el.is @options.targetSelector
        $image = $el
      else
        $image = $el.find(@options.targetSelector).not(".#{@klass}")
      return unless $image.length > 0
      # console.log e.type
      if e.type == 'mouseout' # don't switch if the mouse is over the image
        offset = $image.offset()
        offset.right = offset.left + $image.width()
        offset.bottom = offset.top + $image.height()
        if e.pageX >= offset.left && e.pageX <= offset.right && e.pageY >= offset.top && e.pageY <= offset.bottom
          # console.log 'skip'
          return
      $switch = $image.data(namespace)
      if $switch && $image.width() && !$switch.css('width')
        $switch.width($image.width()).height($image.height())
      @doSwitch(suffix, $image, $switch)
    doSwitch: (suffix, $image, $switch)->
      # console.log suffix, $image, $switch
      if suffix
        $on = $switch
        $off = $image
      else
        $on = $image
        $off = $switch
      anim = @options.animation
      # console.log 'animate', suffix
      if anim.duration
        $on.stop()
        $on.animate anim.on, anim.duration, @options.easing.on || @options.easing if $on
        $off.stop()
        $off.animate anim.off, anim.duration, @options.easing.off || @options.easing if $off
      else
        $on.css anim.on if $on
        $off.css anim.off if $off
