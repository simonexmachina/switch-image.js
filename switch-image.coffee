namespace = 'switchImage'
$ = jQuery
defaults = 
  selector: 'img'
  targetSelector: 'img'
  defaultState: 'mouseout'
  events:
    mouseover: 'on'
    mouseout: 'off'
    'switchImage:on': 'on'
    'switchImage:off': 'off'
  suffixes:
    on: '-on'
    off: ''
  classes:
    on: "#{namespace}-on"
    off: null
  suffixSelectors: {}
    # mouseover: '.hover'
  animation:
    on: opacity: 1
    off: opacity: 0
    duration: 600
  easing:
    on: 'easeOutQuad'
    off: 'easeInQuad'
  # switchOthersTo: 'off'

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
      events.push k for k, v of @options.events
      @$el.find(@options.selector).on events.join(' '), $.proxy @switchEvent, @
      @klass = "#{namespace}-switch"
      @init()
    init: ->
      that = @
      @$el.find(@options.selector).each ->
        $image = $(this).find that.options.targetSelector
        return unless $image.length > 0
        for k, state of that.options.events
          suffix = that.options.suffixes[state]
          if suffix then that.loadSuffix suffix, $image
      @refresh(this)
    loadSuffix: (suffix, $image)->
      src = $image.attr('src').replace(/(@2x)?\./, "#{suffix}$1.")
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
    refresh: ()->
      that = this
      @$el.find(@options.selector).each ->
        switched = false
        for state, selector of that.options.suffixSelectors
          if $(this).is(selector)
            switched = true
            that.switchEvent type: state, currentTarget: this
        if !switched
          that.switchEvent type: that.options.defaultState, currentTarget: this
    switchEvent: (ev)->
      state = @options.events[ev.type]
      @switch(ev.currentTarget, state, ev)
    switch: (el, state, ev = null, skipOthers = null)->
      suffix = @options.suffixes[state]
      $el = $(el)
      if $el.is @options.targetSelector
        $image = $el
      else
        $image = $el.find(@options.targetSelector).not(".#{@klass}")
      return unless $image.length > 0
      # console.log e.type
      if ev and (ev.type == 'mouseout') # don't switch if the mouse is over the image
        offset = $image.offset()
        offset.right = offset.left + $image.width()
        offset.bottom = offset.top + $image.height()
        if ev.pageX >= offset.left && ev.pageX <= offset.right && ev.pageY >= offset.top && ev.pageY <= offset.bottom
          # console.log 'skip'
          return
      $switch = $image.data(namespace)
      if $switch && $image.width() && !$switch.css('width')
        $switch.width($image.width()).height($image.height())
      # if @options.switchOthersTo and not skipOthers
      #   @$el.find(@options.targetSelector)
      #     .filter(@options.classes[state]).each =>
      #       @switch(this, @options.switchOthersTo, null, true)
      @doSwitch(suffix, $image, $switch)
    doSwitch: (suffix, $image, $switch)->
      # console.log suffix, $image, $switch
      if suffix
        $on = $switch
        $off = $image
        addClass = @options.classes.on
        removeClass = @options.classes.off
      else
        $on = $image
        $off = $switch
        addClass = @options.classes.off
        removeClass = @options.classes.on
      $el = $image.closest(@options.selector)
      $el.addClass addClass if addClass
      $el.removeClass removeClass if removeClass
      anim = @options.animation
      # console.log 'animate', suffix
      if anim.duration
        if $on
          $on.stop()
          $on.animate anim.on, anim.duration, @options.easing.on || @options.easing
        if $off
          $off.stop()
          $off.animate anim.off, anim.duration, @options.easing.off || @options.easing
      else
        $on.css anim.on if $on
        $off.css anim.off if $off
