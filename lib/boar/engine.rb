# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  class Engine < ::Rails::Engine
    isolate_namespace Boar
    mattr_accessor :backend

    initializer "boar.configuration" do |app|
      app.config.boar = Boar::Configuration.new(app)
    end
  end
end
