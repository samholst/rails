module ActionController #:nodoc:
  # TODO: Cookies and session variables set in render_component that happens inside a view should be copied over.
  module Components #:nodoc:
    def self.append_features(base)
      super
      base.helper do
        def render_component(options) 
          @controller.logger.info("Start rendering component (#{options.inspect}): ")
          result = @controller.send(:component_response, options).body
          @controller.logger.info("\n\nEnd of component rendering")
          return result
        end
      end
    end

    protected
      def render_component(options = {}) #:doc:
        response = component_response(options, true)
        logger.info "Start rendering component (#{options.inspect}): "
        result = render_text(response.body, response.headers["Status"])
        logger.info("\n\nEnd of component rendering")
        return result
      end
  
    private
      def component_response(options, reuse_response = false)
        component_class(options).process(request_for_component(options), reuse_response ? @response : response_for_component)
      end
    
      def component_class(options)
        options[:controller] ? (options[:controller].camelize + "Controller").constantize : self.class
      end
      
      def request_for_component(options)
        request_for_component = Marshal::load(Marshal::dump(@request))
        request_for_component.send(
          :instance_variable_set, :@parameters, 
          (options[:params] || {}).merge({ "controller" => options[:controller], "action" => options[:action] })
        )
        return request_for_component
      end
      
      def response_for_component
        Marshal::load(Marshal::dump(@response))
      end
  end
end
