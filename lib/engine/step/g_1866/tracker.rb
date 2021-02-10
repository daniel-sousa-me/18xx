# frozen_string_literal: true

module Engine
  module Step
    module G1866
      module Tracker
        def migrate_reservations(tile)
          return unless tile.cities.one?

          tile.reservations.dup.each do |corp|
            city = tile.cities.first
            slot = city.get_slot(corp)

            break unless slot

            tile.reservations.delete(corp)
            city.add_reservation!(corp, slot)
          end
        end
      end
    end
  end
end
