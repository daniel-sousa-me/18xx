# frozen_string_literal: true

require_relative '../assign'

module Engine
  module Step
    module G1870
      class Assign < Assign
        def available_hex(entity, hex)
          if entity == @game.port_company
            return [hex.id] if hex.assigned?(entity.id)
            return
          end

          super
        end

        def process_assign(action)
          entity = action.entity
          hex = action.target

          if hex.assigned?(entity.id) && entity == @game.port_company
            hex.remove_assignment!('GSC')
            hex.assign!('GSC closed', entity.owner)
            entity.close!

            @log << 'The port is now closed'
          else
            super
            @log << 'The port is open. To close the port use the ability again' if entity == @game.port_company
          end
        end
      end
    end
  end
end
