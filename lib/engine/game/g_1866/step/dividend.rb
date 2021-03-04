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

          def process_dividend(action)
            bonus = @game.routes_president_bonus(@round.routes)
            receiver = action.entity.owner

            super

            return unless bonus.positive?

            @log << "#{receiver.name} receives a bonus of #{@game.format_currency(bonus)}"
            @game.bank.spend(bonus, receiver, check_positive: false)
          end
        end
      end
    end
  end
end
