# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Handlers
    module Downloads
      class Dropbox < Base
        def initialize(service, options)
          super(service, options)

          @session = ::DropboxSession.deserialize(credentials[:session])
          @root = @provider_options.fetch(:root, "dropbox").to_sym
          @client = ::DropboxClient.new(@session, @root)
        end

        def call(path, entry, regexp, match_data)
          # Get the final path
          final_path = entry[:path].gsub(/\\(\d+)/) { |m| match_data[$1.to_i] }

          # Read the URL from Redis
          key = @configuration.backend_key("downloads:dropbox[#{final_path}]", self, @service.controller.request)
          url = @configuration.backend.get(key)

          if true || url.blank? then
            begin
              inline = entry[:disposition] == "inline"
              share =  inline ? @client.shares(final_path) : self.direct_shares(final_path)

              url = share["url"] + (!inline ? "?dl=1" : "")
              expire = DateTime.parse(share["expires"], "%a, %d %b %Y %T %Z")

              # Save the URL
              @configuration.backend.set(key, url)
              @configuration.backend.expire(key, expire.to_i)
            rescue => e
              if e.message =~ /Path .+ not found/ then
                raise Boar::Exceptions::NotFound.new(path)
              else
                raise e
                raise Boar::Exceptions::ServerError.new("[#{e.class}] #{e.message}")
              end
            end
          end

          # Redirect to the final URL
          @service.controller.redirect_to(url)
        end

        def direct_shares(path)
          # Get the public URL - We don't use Dropbox shares method directly because we have to pass a parameter
          response = @session.do_get@client.build_url("/shares/#{@root}#{@client.format_path(path)}?short_url=false")
          @client.parse_response(response)
        end
      end
    end
  end
end