# frozen_string_literal: true

require_relative '../base'
require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1870
      class PriceProtection < Base
        def actions(entity)
          return [] if !entity.player? || entity != current_entity

          actions = []
          actions << 'buy_shares' if can_buy?(president, price_protection)
          actions << 'pass' if actions.any?
          actions
        end

        def setup
          while price_protection && !can_buy?(president, price_protection)
            process_pass(nil, true)
          end
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

        def price_protection
          @round.sell_queue.dig(0, 'bundle')
        end

        def president
          @round.sell_queue.dig(0, 'president')
        end

        def can_sell?
          false
        end

        def can_buy?(entity, bundle)
          return unless bundle&.buyable
          return unless bundle == price_protection

          entity.cash >= bundle.price &&
            !@round.players_sold[entity][bundle.corporation] &&
            entity == president &&
            @game.num_certs(entity) + bundle.num_shares <= @game.cert_limit
        end

        def shift
          @round.sell_queue.shift.values_at('bundle', 'president')
        end

        def process_buy_shares(action)
          return unless price_protection
          bundle, player = shift
          price = bundle.price

          @game.share_pool.transfer_shares(
            bundle,
            player,
            spender: player,
            receiver: @bank,
            price: price
          )

          @round.pass_order.delete(player)
          player.unpass!

          @round.goto_entity!(player)

          num_presentation = @game.share_pool.num_presentation(bundle)
          @log << "#{player.name} price protects #{num_presentation} "\
                  "#{bundle.corporation.name} for #{@game.format_currency(price)}"
        end

        def process_pass(_action, forced = false)
          return unless price_protection
          bundle, player = shift

          corporation = bundle.corporation
          price = corporation.share_price.price

          previous_ignore = corporation.share_price.type == :ignore_one_sale
          bundle.num_shares.times do
            previous_ignore = corporation.share_price.type == :ignore_one_sale
            @game.stock_market.move_down(corporation)
          end
          current_ignore = corporation.share_price.type == :ignore_one_sale

          verb = forced ? 'can\'t' : 'doesn\'t'
          num_presentation = @game.share_pool.num_presentation(bundle)
          @log << "#{player.name} #{verb} price protect #{num_presentation} #{corporation.name}"

          if current_ignore && !previous_ignore
            @log << "#{corporation.name} hits the ledge"
            @game.stock_market.move_up(corporation) if current_ignore && !previous_ignore
          end

          @game.log_share_price(corporation, price)
        end

        def active_entities
          @round.sell_queue.map { |q| q['president'] }
        end
      end
    end
  end
end
