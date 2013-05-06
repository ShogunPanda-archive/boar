# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Services
    class Generic
      attr_accessor :controller
      attr_accessor :configuration
      attr_accessor :options
      attr_accessor :params

      include Boar::Utils::Basic

      def initialize(controller)
        @controller = controller
        @configuration = Rails.application.config.boar
        @options = @controller.boar_options
        @params = @controller.params

        skip_cache_param = get_option(@options, :skip_cache_param, @configuration.skip_cache_param)
        @skip_cache = skip_cache_param ? @controller.request.params[skip_cache_param].to_boolean : false
      end

      def run(method)
        begin
          self.send(method)
        rescue => e
          e = Boar::Exceptions::UnImplemented.new if !self.respond_to?(method)
          self.handle_error(e)
        end
      end

      def handle_error(exception)
        if exception.is_a?(Lazier::Exceptions::Dump) then
          raise exception
        else
          handler = self.handler_for(:views, @options)

          # Get HTTP code
          code = exception.is_a?(Boar::Exceptions::Error) ? exception.code : 500

          # Basing on the code
          view = case code
            when 403 then handler.call(:error, code: 403)
            when 404 then handler.call(:error, code: 404)
            else
              raise exception if !Boar::Exceptions::Error.must_raise?(exception)
              handler.call(:error, code: 500, exception: exception)
          end

          @controller.render(file: view, status: code, formats: [:html]) if !@controller.performed?
        end
      end

      def handle_authentication(path, options = nil)
        self.handler_for(:authentication, options).call(path)
      end

      def handler_for(scope, options = nil)
        options = ensure_hash(options)
        scope = scope.to_sym

        # Get the handler specified by user
        handlers_options = get_option(@options.merge(options), :handlers, {})

        # Use either the user handler or the system one
        handlers = @configuration.handlers.merge(handlers_options)

        # Instantiate the handler
        @boar_handlers ||= {}
        @boar_handlers[scope] ||= ::Lazier.find_class(handlers[scope]).new(self, options)
      end
    end
  end
end