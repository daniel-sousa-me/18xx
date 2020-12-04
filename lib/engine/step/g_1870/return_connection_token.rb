# frozen_string_literal: true

require_relative '../token'

module Engine
  module Step
    module G1870
      class ReturnConnectionToken < Token
        def actions(_entity)
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
          unless @round.connection_runs[current_entity].tile.cities.any? { |c| c.tokened_by?(current_entity) }
            options << 'Map'
          end

          options
        end

        def process_choose(action)
          entity = action.entity

          token = Engine::Token.new(action.entity, price: 100)
          entity.tokens << token

          if action.choice == 'Map'
            @round.connection_runs[entity].tile.cities.first.place_token(entity, token, free: true, outside: true)
          else
            entity.remove_ability(entity.abilities(:assign_hexes).first)
          end

          @round.connection_steps << self
          pass!
        end
      end
    end
  end
end
