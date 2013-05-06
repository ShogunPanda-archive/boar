# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Handlers
    module Downloads
      #noinspection RubyClassModuleNamingConvention
      class S3 < Base
        def initialize(service, options)
          super(service, options)

          configuration = self.credentials
          @s3_configuration = {access_key_id: configuration[:access_key], secret_access_key: configuration[:access_secret], region: configuration[:region]}
        end

        def call(path, entry, skip_cache, _, _)
          # Read the URL from Redis
          key = @configuration.backend_key("downloads:s3[#{path}]", self, @service.controller.request)
          url = @configuration.backend.get(key)

          if skip_cache || url.blank? then
            begin
              @s3_configuration[:region] = entry[:region] if entry[:region].present?

              client = AWS::S3.new(@s3_configuration)
              object = client.buckets[entry[:bucket]].objects[entry[:key]]
              raise ArgumentError if !object.exists?

              expire = 1.week
              url = object.url_for(:read, response_content_disposition: entry[:disposition], expire: expire).to_s

              # Save the URL
              if url.present? then
                @configuration.backend.set(key, url)
                @configuration.backend.expire(key, expire)
              end
            rescue => e
              raise Boar::Exceptions::ServerError.new("[#{e.class}] #{e.message}")
            end
          end

          # Redirect to the final URL
          @service.controller.redirect_to(url)
        end
      end
    end
  end
end