{ extend } = require 'underscore'
metaphysics = require '../../lib/metaphysics'

PendingOrder = require '../../models/pending_order'

query = """
  query artwork($id: String!) {
    artwork(id: $id) {
      ... actions
      ... additional_info
      ... artists
      ... auction
      ... banner
      ... client
      ... commercial
      ... deep_zoom
      ... images
      ... meta
      ... metadata
      ... partner_stub
    }
  }
  #{require './components/actions/query'}
  #{require './components/additional_info/query'}
  #{require './components/artists/query'}
  #{require './components/auction/query'}
  #{require './components/banner/query'}
  #{require './client/query'}
  #{require './components/commercial/query'}
  #{require './components/deep_zoom/query'}
  #{require './components/images/query'}
  #{require './components/meta/query'}
  #{require './components/metadata/query'}
  #{require './components/partner_stub/query'}
"""

helpers = extend [
  {}
  actions: require './components/actions/helpers'
  additional_info: require './components/additional_info/helpers'
  artists: require './components/artists/helpers'
  auction: require './components/auction/helpers'
  banner: require './components/banner/helpers'
  commercial: require './components/commercial/helpers'
  metadata: require './components/metadata/helpers'
  partner: require './components/partner/helpers'
  partner_stub: require './components/partner_stub/helpers'
  related_artworks: require './components/related_artworks/helpers'
]...

bootstrap = ->
  require('./components/actions/bootstrap') arguments...
  require('./components/auction/bootstrap') arguments...
  require('./components/banner/bootstrap') arguments...
  require('./client/bootstrap') arguments...
  require('./components/commercial/bootstrap') arguments...
  require('./components/deep_zoom/bootstrap') arguments...
  require('./components/partner/bootstrap') arguments...
  require('./components/video/bootstrap') arguments...

@index = (req, res, next) ->
  send = method: 'post', query: query, variables: req.params

  return if metaphysics.debug req, res, send

  metaphysics send
    .then (data) ->
      extend res.locals.helpers, helpers
      bootstrap res.locals.sd, data
      res.locals.sd.PARAMS = req.params
      res.render 'index', data

    .catch next

@acquire = (req, res, next) ->
  headers = if req.user?
    'X-ACCESS-TOKEN': req.user.get 'accessToken'
  else
    {}

  order = new PendingOrder
  order
    .save {
      artwork_id: req.body.artwork_id
      edition_set_id: req.body.edition_set_id
      session_id: req.session.id
    }, headers: headers

    .then ->
      res.redirect "/order/#{order.id}/resume?token=#{order.get 'token'}"

    .catch next
