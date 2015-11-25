require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'
require 'json'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = route_params.merge(req.params)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    !!@already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    if already_built_response?
      raise 'Already rendered'
    else
      @res.status = 302
      @res['location'] = url
      session.store_session(@res)
      @already_built_response = @res
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    if already_built_response?
      raise 'Already rendered'
    else
      @res['Content-Type'] = content_type
      @res.write(content)
      session.store_session(@res)
      @already_built_response = @res
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    # debugger
    folder = "./views/#{self.class.name.tableize.singularize}/"
    file_path = folder + template_name.to_s + ".html.erb"
    # debugger
    content = File.read(file_path)
    template = ERB.new(content)
    result = template.result(binding)
    render_content(result, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @sesson ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(action_name)
    # debugger
    send(action_name)
    render(action_name) unless @already_built_response
  end
end
