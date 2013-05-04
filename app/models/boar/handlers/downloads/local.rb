# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Handlers
    module Downloads
      class Local < Base
        def initialize(service, options)
          super(service, options)

          # Normalize the root
          @root = self.get_option(options, :directory, Rails.application.config.boar.downloads_directory)
          @root = self.interpolate(@root, {root: Rails.root, request: @service.controller.request, controller: @controller})
        end

        def call(path, entry, _, _)
          # Get the full path
          file = Pathname.new(@root) + path
          raise Boar::Exceptions::NotFound.new(path) if !file.exist?

          # Check MIME and whether the disposition is inline or not
          type = MIME::Types.type_for(file.to_s).first.content_type
          disposition = (entry[:disposition].ensure_string == "inline") ? "inline" : "attachment"

          # Serve the file
          @service.download_file(file, disposition: disposition, type: type)
        end
      end
    end
  end
end