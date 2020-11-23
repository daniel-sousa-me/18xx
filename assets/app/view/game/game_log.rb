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
      needs :show_log, default: true, store: true

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
          children << h(:div, {
                          style: {
                            margin: '0 0 1vmin 0',
                            display: 'flex',
                            flexDirection: 'row',
                          },
                        }, [
            h(:span, {
                style: {
                  fontWeight: 'bold',
                  margin: 'auto 0',
                },
              }, [@user['name'] + ':']),
            h('input#chatbar',
              attrs: {
                autocomplete: 'off',
                title: 'hotkey: c – esc to leave',
                type: 'text',
                value: @chat_input,
              },
              style: {
                marginLeft: '0.5rem',
                flex: '1',
              },
              on: { keyup: key_event }),
            ])
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
