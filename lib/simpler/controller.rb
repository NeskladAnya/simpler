require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      set_params
      send(action)
      set_headers
      set_status
      write_response

      @response.finish
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def write_response
      body = render_body

      @response.write(body)
    end

    def render_body
      if @request.env['simpler.template'].is_a?(Hash)
        render_with_format
      else
        View.new(@request.env).render(binding)
      end
    end

    def params
      @request.params
    end

    def set_params
      if @request.env['simpler.action'] == 'show'
        @request.params['id'] = @request.env['REQUEST_PATH'].gsub(/\D+/, '')
      end
    end

    def render(template)
      @request.env['simpler.template'] = template
    end

    def set_headers
      if @request.env['simpler.template'].is_a?(Hash)
        set_response_headers
      else
        set_default_headers
      end
    end

    def set_response_headers
      if @request.env['simpler.template'].keys.include?(:plain)
        @response['Content-Type'] = 'text/plain'
      end
    end

    def set_default_headers
      @response['Content-Type'] = 'text/html'
    end

    def set_status
      if @request.env['simpler.template'].is_a?(Hash) && @request.env['simpler.template'].keys.include?(:status)
        @response.status = @request.env['simpler.template'][:status]
      end
    end

    def render_with_format
      if @request.env['simpler.template'].keys.include?(:plain)
        @request.env['simpler.template'][:plain]
      end
    end
  end
end
