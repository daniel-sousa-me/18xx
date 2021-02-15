# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1866
      module Step
        class Dividend < Engine::Step::Dividend
          def corporation_dividends(entity, per_share)
            super + @game.routes_subsidy(@round.routes)
          end
        end
      end
    end
  end
end
