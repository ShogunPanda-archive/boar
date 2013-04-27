# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  class Configuration
    def initialize(app)
      @data = {
        app: app,
        backend: Redis.new,
        handlers: {
          root: Boar::Handlers::Root,
          authentication: Boar::Handlers::Authentication,
          locale: Boar::Handlers::Locale,
          views: Boar::Handlers::Views
        }
      }

      initialize_pages()
      initialize_downloads()
    end

    def backend_key(key, _, request)
      "boar[#{request.domain}:#{request.port}]:#{key}"
    end

    def method_missing(method, *args, &block)
      key = method.to_sym

      if @data.has_key?(key) then
        rv = @data[key]
        rv = HashWithIndifferentAccess.new(rv) if rv.is_a?(Hash)
        rv
      else
        super
      end
    end

    private
      def initialize_pages
        @data.merge!({
          pages_root: "",
          pages_directory: "{{root}}/app/pages",
          locale_param: :locale,
          add_locale: true,
          default_locale: @data[:app].config.i18n.default_locale || "en",
          locale_regexp: /[a-z]{2}((_([a-zA-Z]{2}))?)/,
          views: {
            authentication: "authentication",
            error: "errors/{{code}}"
          }
        })
      end

      def initialize_downloads
        @data.merge!({
          downloads_root: "downloads",
          downloads_directory: "{{root}}/files",
          config_file: "{{root}}/config/downloads.yml",
          default_provider: :local
        })
      end
  end
end
