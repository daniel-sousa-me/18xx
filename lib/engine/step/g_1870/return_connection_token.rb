# frozen_string_literal: true

require_relative '../token'

module Engine
  module Step
    module G1870
      class ReturnConnectionToken < Token
        def actions(entity)
          ['choose']
        end

        def description
          'Return Connection Token'
        end

        def override_entities
          @round.connection_runs.keys
        end

        def current_entity
          @round.connection_runs.keys.first
        end

        def context_entities
          @round.entities
        end

        def active_context_entity
          @round.entities[@round.entity_index]
        end

        def active?
          @round.connection_runs.any? && !passed?
        end

        def choice_name
          'Use of destination token'
        end

        def choices
          options = ['Charter']
          options << 'Map' unless @round.connection_runs[current_entity].tile.cities.any? { |c| c.tokened_by?(current_entity) }

          options
        end

        def process_choose(action)
          token = Engine::Token.new(action.entity, price: 100)
          action.entity.tokens << token

          if action.choice == 'Map'
            @round.connection_runs[action.entity].tile.cities.first.place_token(action.entity, token, free: true, outside: true)
          else
            action.entity.remove_ability(action.entity.abilities(:assign_hexes).first)
          end

          @round.connection_steps << self
          pass!
        end
      end
    end
  end
end
