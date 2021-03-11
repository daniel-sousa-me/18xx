# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1866
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def process_par(action)
            if action.corporation.id == 'TBF'
              share_price = action.share_price
              corporation = action.corporation
              parrer = action.entity

              raise GameError, "#{corporation} cannot be parred" unless @game.can_par?(corporation, parrer)

              tmb_cities = @game.tmb_corporation.tokens.map(&:city)
              raise GameError, 'TMB and BFF are not connected' unless @game.bff_corporation.tokens.any? do |token|
                @game.hexes_connected?(token.city, tmb_cities) if token.city
              end

              @game.stock_market.set_par(corporation, share_price)
              share = corporation.shares.first
              bundle = share.to_bundle
              @game.share_pool.buy_shares(action.entity,
                                          bundle,
                                          exchange: corporation.par_via_exchange,
                                          exchange_price: 2 * bundle.price_per_share)

              # TBF chooses home token now.
              @game.place_home_token(corporation)
              corporation.par_via_exchange.close!

              @current_actions << action
            else
              super
            end

            @game.check_crisis!
          end

          def process_buy_shares(action)
            super

            @game.check_crisis!
          end
        end
      end
    end
  end
end