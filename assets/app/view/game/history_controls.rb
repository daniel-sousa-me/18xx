# frozen_string_literal: true

require 'lib/params'
require 'view/link'
require 'view/game/actionable'

module View
  module Game
    class HistoryControls < Snabberb::Component
      include Actionable
      needs :num_actions, default: 0
      needs :game, store: true
      needs :round_history, default: nil, store: true

      def render
        return h(:div) if @num_actions.zero?

        divs = [h('b.margined', 'History')]
        cursor = Lib::Params['action']&.to_i

        unless cursor&.zero?
          divs << link('|<', 'Start', 0)

          last_round =
            if cursor == @game.raw_actions.size
              @game.round_history[-2]
            else
              @game.round_history[-1]
            end
          divs << link('<<', 'Previous Round', last_round) if last_round

          prev_action =
            if @game.exception
              @game.last_processed_action
            elsif cursor
              cursor - 1
            else
              @num_actions - 1
            end
          divs << link('<', 'Previous Action', prev_action)
        end

        if cursor && !@game.exception
          divs << link('>', 'Next Action', cursor + 1 < @num_actions ? cursor + 1 : nil)
          store(:round_history, @game.round_history, skip: true) unless @round_history
          next_round = @round_history[@game.round_history.size]
          divs << link('>>', 'Next Round', next_round) if next_round
          divs << link('>|', 'Current', nil)
        end

        h(:div, divs)
      end

      def link(text, title, action_id)
        h(:span, { style: { marginRight: '2rem' } }, [history_link(text, title, action_id)])
      end
    end
  end
end
