require 'filum'

module Inventory
  module Server
    module InventoryLogger

    def self.setup(*args)
      Filum.setup(*args)
    end

    def self.logger
      Filum.logger
    end
    end
  end
end
