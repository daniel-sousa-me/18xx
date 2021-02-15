# frozen_string_literal: true

require_relative '../dividend'

module Engine
  module Step
    module G1866
      class Dividend < Dividend
        def corporation_dividends(entity, per_share)
          super + @game.routes_subsidy(@round.routes)
        end
      end
    end
  end
end
