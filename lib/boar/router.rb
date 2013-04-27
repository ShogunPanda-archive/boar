# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module ActionDispatch::Routing
  class Mapper
    def boar_mount_pages(*args)
      Boar::Router.mount_pages(self, *args)
    end

    def boar_mount_downloads(*args)
      Boar::Router.mount_downloads(self, *args)
    end
  end
end

module Boar
  class Router
    def self.mount_pages(router, *args)
      options = args.extract_options!
      config = Rails.application.config.boar

      root = get_option(options, :root, config.pages_root)
      root += "/" if root.present? && root !~ /\/$/
      locale_param = get_option(options, :locale_param, config.locale_param).to_sym
      default_locale = get_option(options, :default_locale, config.default_locale).to_sym
      locale_regexp = get_option(options, :locale_regexp, config.locale_regexp)
      route_options = get_option(options, :route_options, {}).deep_symbolize_keys

      router.scope(module: :boar) do
        router.scope("(#{locale_param.inspect})", defaults: {locale_param => default_locale}, constraints: {locale_param => locale_regexp}) do
          yield(router, options) if block_given?
          router.match("#{root}(*path)", route_controller(options, "pages#main").merge({via: :get, boar_options: options}).merge(route_options))
        end
      end
    end

    def self.mount_downloads(router, *args)
      options = args.extract_options!
      config = Rails.application.config.boar

      root = get_option(options, :root, config.downloads_root)
      root += "/" if root.present? && root !~ /\/$/
      route_options = get_option(options, :route_options, {}).deep_symbolize_keys

      router.scope(module: :boar) do
        yield(router, options) if block_given?
        router.match("#{root}", {controller: options.fetch(:controller, "downloads"), action: :update, via: :put, boar_options: options}.merge(route_options))
        router.match("#{root}(*path)", route_controller(options, "downloads#main").merge({via: :get, boar_options: options}).merge(route_options))
      end
    end

    private
      def self.route_controller(options, default)
        options[:controller] ? {controller: options[:controller], action: options[:action].ensure_string || :index} : {to: default}
      end

      def self.get_option(options, key, default = nil)
        begin
          options.symbolize_keys.fetch(key.to_sym)
        rescue Exception => _
          block_given? ? yield(key) : default
        end
      end
  end
end
