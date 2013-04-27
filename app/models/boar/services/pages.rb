# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Services
    class Pages < Boar::Services::Generic
      def main
        # Get the path
        path = @controller.params[:path]

        # Handle ACL for the path
        self.handle_authentication(path, @options)

        @controller.render(file: search_page(path)) if !@controller.performed?
      end

      private
        def search_page(path, partial = false, options = nil)
          # Setup path and options
          path = "index" if path.blank?
          options ||= @options

          # Get the template file
          template = (self.handler_for(:root, options).call + path).to_s

          begin
            perform_search(template, partial, options)

            # We return the template if search didn't fail, which means that the #render method will success.
            template
          rescue ActionView::MissingTemplate
            raise Boar::Exceptions::NotFound.new(template)
          end
        end

        def perform_search(template, partial, options)
          # Get the context
          context = @controller.view_renderer.lookup_context

          # Setup the locale
          context.locale = options[:add_locale] ? current_locale(options) : nil

          # Perform the search
          context.with_fallbacks { context.find_template(template, nil, partial, [], {}) }
        end

        def current_root(options = nil)
          self.handler_for(:root, options).call
        end

        def current_locale(options = nil)
          self.handler_for(:locale, options).call
        end
    end
  end
end