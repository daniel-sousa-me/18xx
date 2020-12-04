# frozen_string_literal: true

require 'game_manager'
require 'lib/params'
require 'lib/storage'

module View
  module Game
    module Actionable
      def self.included(base)
        base.needs :game_data, default: {}, store: true
        base.needs :game, store: true
        base.needs :flash_opts, default: {}, store: true
        base.needs :confirm_opts, default: {}, store: true
        base.needs :connection, store: true, default: nil
        base.needs :user, store: true, default: nil
        base.needs :tile_selector, default: nil, store: true
        base.needs :selected_company, default: nil, store: true
        base.needs :selected_corporation, default: nil, store: true
        base.needs :app_route, default: nil, store: true
        base.needs :round_history, default: nil, store: true
        base.needs :selected_action_id, default: nil, store: true
      end

      def save_user_settings(settings)
        @connection.safe_post(GameManager.url(@game_data, '/user_settings'), settings)

        @game_data['user_settings'] ||= {}
        @game_data['user_settings'].merge!(settings)
      end

      def participant?
        return @participant if defined?(@participant)

        @participant = (@game.players.map(&:id) + [@game_data['user']['id']]).include?(@user&.dig('id'))
      end

      def check_consent(player, click)
        opts = {
          color: :yellow,
          click: click,
          message: "This action requires consent from #{player.name}!",
        }
        store(:confirm_opts, opts, skip: false)
      end

      def valid_actor?(action)
        @valid_actors = @game.valid_actors(action)
        @valid_actors.any? { |actor| actor.id == @user['id'] }
      end

      def process_action(action)
        hotseat = @game_data[:mode] == :hotseat

        if @game.exception
          msg = 'This game is broken and cannot accept any new actions. If '\
                'this issue has not already been reported, please follow the '\
                'instructions at the top of the page to report it.'
          return store(:flash_opts, msg)
        end

        static_undo = false
        if Lib::Params['action']
          if action.is_a?(Engine::Action::Undo) && action.action_id.to_s == Lib::Params['action'].to_s
            @game_data[:actions] = @game_data[:actions] + @game.unprocessed_actions.map(&:to_h)
            static_undo = true
          else
            return store(:flash_opts, 'You cannot make changes while browsing history.
              Press >| to navigate to the current game action.')
          end
        end

        if !hotseat &&
           !action.free? &&
           participant? &&
           !valid_actor?(action)
          if Lib::Storage[@game.id]&.dig('master_mode')
            action.user = @user['id']
          else
            msg =
              if @game.active_players_id.include?(@user['id'])
                unless @valid_actors.empty?
                  "Only #{@valid_actors.map(&:name).join(' and ')} "\
                  'may perform that action. Turn on master mode under the Tools '\
                  'menu to act for others.'
                end
              else
                'Not your turn. Turn on master mode under the Tools menu to act '\
                'for others.'
              end
            return store(:flash_opts, msg)
          end
        end

        game = if static_undo
                 @game.process_static_undo(action)
               else
                 @game.process_action(action, add_auto_actions: true).maybe_raise!
               end

        @game_data[:actions] << action.to_h
        store(:game_data, @game_data, skip: true)

        if game.finished
          @game_data[:result] = game.result
          @game_data[:status] = 'finished'
        else
          @game_data[:result] = {}
          @game_data[:status] = 'active'
        end

        if hotseat
          @game_data[:turn] = game.turn
          @game_data[:round] = game.round.name
          @game_data[:acting] = game.active_players_id
          @game_data[:updated_at] = Time.now.to_i
          Lib::Storage[@game_data[:id]] = @game_data
        elsif participant?
          json = action.to_h
          if @game_data&.dig('settings', 'pin')
            meta = {
              game_result: @game_data[:result],
              game_status: @game_data[:status],
              active_players: game.active_players_id,
              turn: game.turn,
              round: game.round.name,
            }
            json['meta'] = meta
          end
          @connection.post(GameManager.url(@game_data, '/action'), json) do |data|
            if (error = data['error'])
              store(:flash_opts, "The server did not accept this action due to: #{error}... refreshing.")
              `setTimeout(function() { location.reload() }, 5000)`
            end
          end
        else
          store(
            :flash_opts,
            'You are not in this game. Moves are temporary. You can clone this game in the tools tab.',
            skip: true,
          )
        end

        clear_ui_state
        store(:game, game)
      rescue StandardError => e
        clear_ui_state
        store(:flash_opts, e.message)
        `setTimeout(function() { self['$store']('game', Opal.nil) }, 10)`
      end

      def clear_ui_state
        store(:selected_company, nil, skip: true)
        store(:selected_corporation, nil, skip: true)
        store(:tile_selector, nil, skip: true)
        store(:selected_action_id, nil, skip: true)
      end

      def history_link(text, title, action_id = nil, hotkey = nil)
        route = Lib::Params.add(@app_route, 'action', action_id)

        click = lambda do
          store(:round_history, @game.round_history, skip: true) unless @round_history
          store(:round_history, nil, skip: true) unless action_id
          store(:app_route, route)
          clear_ui_state
        end

        h(Link, {
            href: route,
            click: click,
            title: "#{title}#{' – hotkey: ' + hotkey if hotkey}",
            children: text,
            style: {
              color: 'currentColor',
              textDecoration: 'none',
            },
            class: "#hist_#{hotkey}",
          })
      end
    end
  end
end
