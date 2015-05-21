Q = require 'q'
knox = require 'knox'
request = require 'superagent'
{ S3_KEY, S3_SECRET, APPLICATION_NAME } = require '../../config'

module.exports = class JSONPage
  constructor: ({ @name, @paths }) ->
    throw new Error 'Requires a `name`' unless @name?

  path: ->
    "/json/#{@name}.json"

  client: ->
    @__client__ ?=
      knox.createClient
        key: S3_KEY
        secret: S3_SECRET
        bucket: APPLICATION_NAME

  get: (callback) ->
    Q.promise (resolve, reject) =>
      error = (message) ->
        err = new Error message
        reject err
        callback err

      request
        .get "http://#{APPLICATION_NAME}.s3.amazonaws.com#{@path()}"
        .end (err, res) =>
          if res.ok
            try
              @data = JSON.parse res.text
              resolve @data
              callback null, @data
            catch e
              error e
          else
            error res.error

  set: (data, callback) ->
    buffer = new Buffer JSON.stringify(data)
    headers = 'Content-Type': 'application/json', 'x-amz-acl': 'public-read'
    @client().putBuffer buffer, @path(), headers, callback