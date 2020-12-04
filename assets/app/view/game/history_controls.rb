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
        divs = []
        cursor = Lib::Params['action']&.to_i

        unless cursor&.zero?
          prev_round =
            if cursor == @game.raw_actions.size
              @game.round_history[-2]
            else
              @game.round_history[-1]
            end

          prev_action =
            if @game.exception
              @game.last_processed_action
            elsif cursor
              cursor - 1
            else
              @num_actions - 1
            end
        end

        divs << link('|<', 'Start', 0, cursor&.zero?, 'Home')
        divs << link('<<', 'Previous Round', prev_round, !prev_round, 'PageUp')
        divs << link('<', 'Previous Action', prev_action, cursor&.zero?, 'ArrowUp')

        divs << link_container('')

        if cursor && !@game.exception
          store(:round_history, @game.round_history, skip: true) unless @round_history
          next_round = @round_history[@game.round_history.size]
        end

        divs << link('>', 'Next Action', cursor && cursor + 1 < @num_actions ? cursor + 1 : nil, !cursor, 'ArrowDown')
        divs << link('>>', 'Next Round', next_round, !next_round, 'PageDown')
        divs << link('>|', 'Current', nil, !cursor, 'End')

        h(:div, { style: { margin: '0.5rem', textAlign: 'center' } }, divs)
      end

      def link_container(content, disabled = false)
        props = { style: { margin: '0 1rem' } }
        props[:style][:opacity] = 0.4 if disabled

        h(:span, props, content)
      end

      def link(text, title, action_id, disabled, hotkey)
        content = disabled ? text : [history_link(text, title, action_id, hotkey)]
        link_container(content, disabled)
      end
    end
  end
end
