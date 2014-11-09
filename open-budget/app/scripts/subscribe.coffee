class SubscribeModel extends Backbone.Model

  URL = 'http://the.open-budget.org.il/rss/changes/pending'

  defaults:
    state: "unknown"
    key: null
    loginURL: null

  initialize: (options) ->
    @refreshSubscription()

  notLoggedIn: (loginURL) =>
    console.log 'notLoggedIn'#,loginURL
    @set('state',"not-logged-in")
    @set('key',null)
    @set('loginURL',loginURL)

  subscribe: ->
    hn.subscribe( URL, null, null, null, 60,
                  (key) =>
                    console.log 'subscribe',key
                    @set('state',"subscribed")
                    @set('key',key)
                 , @notLoggedIn)
  unsubscribe: ->
    hn.unsubscribe( @get('key'),
                    () =>
                      console.log 'unsubscribe'
                      @set('state',"not-subscribed")
                      @set('key',null)
                   , @notLoggedIn)
  refreshSubscription: ->
    hn.issubscribed( URL, null, null,
                     (subscribed, key) =>
                       console.log 'issubscribed',subscribed,key
                       if subscribed
                         @set('state',"subscribed")
                         @set('key',key)
                       else
                         @set('state',"not-subscribed")
                    , @notLoggedIn)

class SubscribeView extends Backbone.View

  initialize: (options) ->
    @model.on('change:state', => @render())
    @model.on('change:loginURL', => @render())
    @attempting = false
    $(window).focus =>
      if @model.get('state') == 'not-logged-in' and @attempting
        @model.subscribe()

  render: ->
    console.log 'SubscribeModalButtonView:render'
    if @model.get('state') == "not-logged-in"
      @$el.toggleClass('loggedout',true)
      @$el.toggleClass('subscribed',false)
      @$el.toggleClass('notsubscribed',false)
      @renderLogin(@model.get('loginURL'))
    else if @model.get('state') == "not-subscribed"
      @$el.toggleClass('loggedout',false)
      @$el.toggleClass('subscribed',false)
      @$el.toggleClass('notsubscribed',true)
    else if @model.get('state') == "subscribed"
      @$el.toggleClass('loggedout',false)
      @$el.toggleClass('subscribed',true)
      @$el.toggleClass('notsubscribed',false)
    @attempting = false

  renderLogin: (loginUrl) ->

  onClick: ->
    console.log 'onClick'
    if @model.get('state') == "not-logged-in"
      if @model.get('loginURL') != null
          @attempting = true
          return @onLogin()
    else if @model.get('state') == "not-subscribed"
      @model.subscribe()
    else if @model.get('state') == "subscribed"
      @model.unsubscribe()
    false

  events:
    'click': 'onClick'


class SubscribeModalButtonView extends SubscribeView

  initialize: (options) ->
    @modal = options.modal
    super

  renderLogin: (loginUrl) ->
    @$el.attr('href',@model.get('loginURL'))
    @$el.attr('target','_blank')

  onLogin: ->
    @modal.modal('hide')
    window.open(@$el.attr('href'),"_blank")
    false

class SubscribeMainButtonView extends SubscribeView

  initialize: (options) ->
    @modal = options.modal
    @modal.modal({show:false})
    super

  onLogin: ->
    @modal.modal({show:true})
    false

$( ->
  subscribeModel = new SubscribeModel()
  modal = $("#subscribeModal")
  window.subscribeModalButtonView = new SubscribeModalButtonView(model: subscribeModel,el: $("#subscribeModal .btn-primary"), modal: modal)
  window.subscribeMainButtonView = new SubscribeMainButtonView(model: subscribeModel,el: $("#subscribeWidget"), modal: modal)
)
