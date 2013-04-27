# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  class ApplicationController < ActionController::Base
    attr_reader :boar_options
    before_filter :setup_boar_options

    def setup_boar_options
      @boar_options ||= params.delete(:boar_options)
    end
  end
end
