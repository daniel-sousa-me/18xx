# frozen_string_literal: true

module Engine
  module Game
    module G1866
      module Step
        class Teleport < Engine::Step::Base
          def actions(entity)
            return [] unless entity == current_entity

            @fmsb = entity.companies.find { |c| c.id == 'FMSB' }
            return [] unless @fmsb

            @passed ? [] : ['choose']
          end

          def description
            'FMSB Teleport'
          end

          def active?
            !current_actions.empty?
          end

          def choice_available?(entity)
            entity == current_entity && entity.companies.find { |c| c.id == 'FMSB' }
          end

          def can_sell?
            false
          end

          def ipo_type(_entity)
            nil
          end

          def swap_sell(_player, _corporation, _bundle, _pool_share); end

          def choices
            ['Close FMSB', 'Pass']
          end

          def choice_name
            'Close FMSB to upgrade and place a token on any city'
          end

          def process_choose(action)
            corp = action.entity

            if action.choice == 'Close FMSB'
              @log << "#{corp.id} closes FMSB"
              @fmsb.close!
            end
            @passed = true
          end
        end
      end
    end
  end
end
