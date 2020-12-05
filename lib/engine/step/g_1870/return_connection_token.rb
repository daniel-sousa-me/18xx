# frozen_string_literal: true

require_relative '../token'

module Engine
  module Step
    module G1870
      class ReturnConnectionToken < Token
        def actions(_entity)
          %w[choose pass]
        end

        def description
          'Return Connection Token'
        end

        def pass_description
          'Connection run not possible'
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
          destination = @round.connection_runs[current_entity]
          return %w[Map Charter] unless destination.tile.cities.any? { |c| c.tokened_by?(current_entity) }

          ['Charter']
        end

        def process_choose(action)
          entity = action.entity
          destination = @round.connection_runs[entity]
          ability = entity.abilities(:assign_hexes).first

          token = Engine::Token.new(action.entity, price: 100)
          entity.tokens << token

          if action.choice == 'Map'
            destination.tile.cities.first.place_token(entity, token, free: true, outside: true)
            ability.description = 'Reached ' + ability.description
          else
            entity.remove_ability(ability)
          end

          destination.remove_assignment!(entity)
          entity.trains.each { |train| train.operated = false }

          @round.connection_steps << self
          pass!
        end

        def process_pass(_action)
          @round.connection_runs.shift
          @round.skip_connection_check = true
        end
      end
    end
  end
end
