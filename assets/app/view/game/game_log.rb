# frozen_string_literal: true

require 'view/game/actionable'
require 'view/log'

module View
  module Game
    class GameLog < Snabberb::Component
      include Actionable

      needs :user, default: nil
      needs :chat_input, default: ''
      needs :show_chat, default: true, store: true
      needs :log_level, default: 2, store: true

      LOG_LEVEL_TEXT = {
        2 => 'Hide actions',
        1 => 'Show effects',
        0 => 'Show actions',
      }.freeze

      def render
        children = [
          h(Log, log: @game.log, negative_pad: true),
        ]

        @player = @game.player_by_id(@user['id']) if @user

        key_event = lambda do |event|
          event = Native(event)
          key = event['key']

          case key
          when 'Enter'
            message = event['target']['value']
            if message.strip != ''
              event['target']['value'] = ''
              sender = @player || Engine::Player.new(@game_data['user']['id'], @game_data['user']['name'])
              process_action(Engine::Action::Message.new(sender, message: message))
            end
          when 'Escape'
            `document.getElementById('game').focus()`
          end
        end

        if participant?
          chat_line = [
            h(:span, {
                style: {
                  fontWeight: 'bold',
                  margin: 'auto 0',
                },
              }, [@user['name'] + ':']),
            h('input#chatbar', {
                attrs: {
                 autocomplete: 'off',
                 title: 'hotkey: c – esc to leave',
                 type: 'text',
                 value: @chat_input,
                },
                style: {
                  marginLeft: '0.5rem',
                  height: '1.25rem',
                  flex: '1',
                },
                on: { keyup: key_event },
              }),
            h(:button, {
                style: { height: '100%' },
                on: { click: -> { store(:show_chat, !@show_chat) } },
              },
              @show_chat ? 'Hide messages' : 'Show chat'),
            h(:button, {
                style: { height: '100%' },
                on: { click: -> { store(:log_level, (@log_level + 1) % 3) } },
              },
              LOG_LEVEL_TEXT[@log_level]),
          ]

          children << h(:div, {
                          style: {
                            margin: '1vmin 0',
                            display: 'flex',
                            flexDirection: 'row',
                            alignItems: 'center',
                          },
                        }, chat_line)
        end

        props = {
          style: {
            display: 'inline-block',
            width: '100%',
          },
        }

        h(:div, props, children)
      end
    end
  end
end
