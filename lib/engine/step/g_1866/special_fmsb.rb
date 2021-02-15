# frozen_string_literal: true
#
require_relative '../base'
require_relative '../tracker'
require_relative '../tokener'

module Engine
  module Step
    module G1866
      class SpecialFmsb < Base
        include Tracker
        include Tokener

        TRACK_ACTIONS = %w[lay_tile].freeze
        PLACE_TOKEN_ACTIONS = %w[place_token pass].freeze
        PASS_ACTION = %w[pass].freeze

        def actions(entity)
          case @state
          when nil
            return [] unless ability(entity)
            TRACK_ACTIONS
          when :token
            return [] unless entity == @entity.owner
            return [] unless @destination.tile.cities.any? { |c| c.tokenable?(@entity.owner, free: true) }
            PLACE_TOKEN_ACTIONS
          end
        end

        def pass!
          super
          @state = nil
        end

        def description
          case @state
          when nil
            'FMSB: Upgrade Tile'
          when :token
            'FMSB: Place Token'
          end
        end

        def pass_description
          'FMSB: Pass (Token)'
        end

        def active_entities
          return [@company] if @company
          [@entity.owner]
        end

        def blocks?
          @state
        end

        def process_lay_tile(action)
          @entity = action.entity
          @destination = action.hex

          lay_tile(action, entity: action.entity)
          @state = :token
        end

        def process_place_token(action)
          place_token(
            @entity.owner,
            action.city,
            available_tokens(@entity)[0],
            connected: false,
            extra: true
          )

          ability(@entity).use!
          @entity = nil
          @state = nil
        end

        def process_pass(action)
          entity = action.entity
          ability = abilities(entity)
          raise GameError, "Not #{entity.name}'s turn: #{action.to_h}" unless entity == @entity.owner

          entity.remove_ability(ability)
          @log << "#{entity.owner.name} passes placing token with #{entity.name}"
          @entity = nil
          @state = nil
        end

        def skip!
          if @entity
            ability = abilities(@entity)
            @entity.remove_ability(ability)
            @log << "#{@entity.owner.name} skips placing token with #{@entity.name}"
            @entity = nil
            @state = nil
          end

          super
        end

        def available_tokens(entity)
          [@entity.owner.next_token]
        end

      def available_hex(entity, hex)
        case @state
        when nil
          hex_neighbors(entity, hex)
        when :token
          hex == @destination
        end
      end

      def hex_neighbors(entity, hex)
        return unless (ability = abilities(entity))
        return if !ability.hexes&.empty? && !ability.hexes&.include?(hex.id)

        operator = entity.owner.corporation? ? entity.owner : @game.current_entity
        return if ability.type == :tile_lay && ability.reachable && !@game.graph.connected_hexes(operator)[hex]

        @game.hex_by_id(hex.id).neighbors.keys
      end

      def potential_tiles(entity, hex)
        return [] unless (tile_ability = abilities(entity))

        tiles = tile_ability.tiles.map { |name| @game.tiles.find { |t| t.name == name } }
        tiles = @game.tiles.uniq(&:name) if tile_ability.tiles.empty?

        special = tile_ability.special if tile_ability.type == :tile_lay
        tiles
          .compact
          .select { |t| @game.phase.tiles.include?(t.color) && @game.upgrades_to?(hex.tile, t, special) }
      end

        def ability(entity)
          return unless entity.company?
          @game.abilities(entity, :tile_lay)
        end
      end
    end
  end
end
