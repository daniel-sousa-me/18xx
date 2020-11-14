# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G1870
      class PriceProtection < Base
        def actions(entity)
          return [] if !entity.player? || entity != current_entity

          actions = []
          actions << 'protect' if can_buy?(entity, protecting_bundle)
          actions << 'pass' if actions.any?
          actions
        end

        def description
          'Price protect shares'
        end

        def round_state
          { sell_queue: [] }
        end

        def purchasable_companies(_entity = nil)
          []
        end

        def protecting_bundle
          @round.sell_queue.dig(0)
        end

        def can_sell?
          false
        end

        # TODO: Can we reuse the function from BuySellParShares?
        def can_buy?(entity, bundle)
          return unless bundle
          return unless bundle.buyable

          entity.cash >= bundle.price &&
            # !@players_sold[entity][corporation] &&
            @game.num_certs(entity) + bundle.num_shares <= @game.cert_limit
        end

        def process_protect(action)
          bundle = @round.sell_queue.shift

          player = action.entity
          price = bundle.price

          @game.share_pool.transfer_shares(
            bundle,
            player,
            spender: player,
            receiver: @bank,
            price: price
          )

          @round.goto_entity!(player)

          @log << "#{player.name} price protects #{bundle.corporation.name} "\
                  "for #{@game.format_currency(price)}"
        end

        def skip!(action)
          return process_pass(action, true) if protecting_bundle

          super
        end

        def process_pass(_action, forced = false)
          bundle = @round.sell_queue.shift

          corporation = bundle.corporation
          player = bundle.president
          price = corporation.share_price.price

          num_shares = bundle.num_shares
          previous_ignore = corporation.share_price.type == :ignore_one_sale
          num_shares.times do
            previous_ignore = corporation.share_price.type == :ignore_one_sale
            @game.stock_market.move_down(corporation)
          end
          current_ignore = corporation.share_price.type == :ignore_one_sale

          @log << if forced
                    "#{player.name} can't price protect #{corporation.name}"
                  else
                    "#{player.name} doesn't price protect #{corporation.name}"
                  end
          if current_ignore && !previous_ignore
            @log << "#{corporation.name} hits the ledge"
            @game.stock_market.move_up(corporation) if current_ignore && !previous_ignore
          end

          @game.log_share_price(corporation, price)
        end

        def active_entities
          return [] unless @round.sell_queue.any?

          @round.sell_queue.map(&:president)
        end
      end
    end
  end
end
