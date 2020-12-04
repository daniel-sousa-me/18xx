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
      needs :app_route, default: nil, store: true

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

        # divs << link_container('')
        route = Lib::Params.add(@app_route, 'action')

        divs << link_container('⟲', [h('a#hist_ctrl+z', {
                                         attrs: {
                                           href: route,
                                           onclick: 'return false',
                                           title: 'Undo – shortcut: ctrl+z',
                                         },
                                         on: {
                                           click: lambda do
                                             process_action(Engine::Action::Undo.new(@game.current_entity,
                                                                                     action_id: cursor))
                                             store(:app_route, route, skip: true) if cursor
                                           end,
                                         },
                                         style: {
                                           color: 'currentColor',
                                           textDecoration: 'none',
                                         },
                                       }, '⟲')], !@game.undo_possible, true)

        divs << link_container('⟳', [h('a#hist_ctrl+y', {
                                         attrs: {
                                           href: '#',
                                           onclick: 'return false',
                                           title: 'Redo – shortcut: ctrl+y',
                                         },
                                         on: {
                                           click: -> { process_action(Engine::Action::Redo.new(@game.current_entity)) },
                                         },
                                         style: {
                                           color: 'currentColor',
                                           textDecoration: 'none',
                                         },
                                       }, '⟳')], !@game.redo_possible, true)

        # divs << link_container('')

        if cursor && !@game.exception
          store(:round_history, @game.round_history, skip: true) unless @round_history
          next_round = @round_history[@game.round_history.size]
        end

        divs << link('>', 'Next Action', cursor && cursor + 1 < @num_actions ? cursor + 1 : nil, !cursor, 'ArrowDown')
        divs << link('>>', 'Next Round', next_round, !next_round, 'PageDown')
        divs << link('>|', 'Current', nil, !cursor, 'End')

        h(:div, { style: { margin: '0.5rem', textAlign: 'center', display: 'flex' } }, divs)
      end

      def link_container(text, elm, disabled = false, bigger = false)
        props = { style: { margin: 'auto 1rem' } }
        props[:style][:opacity] = 0.4 if disabled
        props[:style][:fontSize] = '1.4em' if bigger

        h(:span, props, disabled ? text : elm)
      end

      def link(text, title, action_id, disabled, hotkey)
        link_container(text, [history_link(text, title, action_id, hotkey)], disabled)
      end
    end
  end
end
