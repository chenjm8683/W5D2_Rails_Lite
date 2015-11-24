require 'rack'
require_relative '../lib/controller_base'
require 'byebug'

class MyController < ControllerBase
  attr_accessor :req, :res, :already_built_response

  def initialize(req, res)
    @req = req
    @res = Rack::Response.new
    @already_built_response = nil
  end

  def go
    # debugger
    if @req.path == "/cats"
      render_content("hello cats!", "text/html")
    else
      redirect_to("/cats")
    end
  end

  def render_content(content, content_type)
    # if @already_built_response.nil?
    #   # debugger
    #   @already_built_response = Rack::Response.new
    #   @already_built_response['Content-Type'] = 'text/html'
    #   @already_built_response.write(content)
    # end
    # # ['200', {}, ['Hello']]
    # @res = @already_built_response
    # if @already_built_response.nil?
      @res['Content-Type'] = content_type
      @res.write(content)
      @already_built_response = @res
    # else
      # @res = @already_built_response
    # end
  end

  def redirect_to(url)
    @res = ['302', {'location' => url}, []]
  end
end
app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  MyController.new(req, res).go
  res.finish
end

Rack::Server.start(
  app: app,
  Port: 3000
)
