require 'json'
require 'byebug'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    # debugger
    cookie = req.cookies['_rails_lite_app']
    @cookie = cookie ? JSON.parse(cookie) : {}
    @path = "/" + req.path
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    @cookie['path'] = @path
    res.set_cookie('_rails_lite_app', @cookie.to_json)
  end
end
