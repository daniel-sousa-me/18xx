# frozen_string_literal: true

require 'game_manager'
require 'user_manager'
require 'lib/settings'
require 'view/game_row'
require 'view/logo'
require 'view/form'

module View
  class User < Form
    include Lib::Settings
    include GameManager
    include UserManager

    needs :type
    needs :vapid_public_key, default: nil, store: true
    needs :notification_permission, default: nil, store: true
    needs :serviceworker, default: nil, store: true
    needs :webpush_subscription, default: nil, store: true

    TILE_COLORS = Lib::Hex::COLOR.freeze
    ROUTE_COLORS = Lib::Settings::ROUTE_COLORS.freeze

    def render_content
      children =
        case @type
        when :profile
          render_profile
        when :signup
          render_signup
        when :login
          render_login
        end

      h(:div, children)
    end

    def input_elm(setting)
      Native(@inputs[setting]).elm
    end

    def render_profile
      return [h('h3', 'You are not logged in')] unless @user

      title = 'Profile Settings'
      inputs = [
        render_username,
        h('div#settings__options', [
          render_checkbox('Turn and Message Emails', :notifications),
          render_checkbox('Red 18xx.games Logo', :red_logo),
        ]),
        h('div#settings__colors', { style: { maxWidth: '38rem' } }, [
          render_color('Main Background', :bg, color_for(:bg)),
          render_color('Main Font Color', :font, color_for(:font)),
          render_color('Alternative Background', :bg2, color_for(:bg2)),
          render_color('Alternative Font Color', :font2, color_for(:font2)),
          render_color('Your Turn', :your_turn, color_for(:your_turn)),
          render_color('Hotseat Game', :hotseat_game, color_for(:hotseat_game)),
        ]),
        render_tile_colors,
        render_route_colors,
        h('div#settings__buttons', { style: { marginTop: '1rem' } }, [
          render_button('Save Changes') { submit },
          render_button('Reset to Defaults') { reset_settings },
          render_button('Logout', { style: { display: 'block', margin: '1rem 0' } }) { logout },
          render_button('Delete Account and All Data', { style: { margin: '0 0.5rem 0 0' } }) { delete },
          render_input('Type DELETE to confirm', id: :confirm, type: :confirm, input_style: { width: '5rem' }),
        ]),
      ]

      finished_games = @games
        .select { |game| user_in_game?(@user, game) && %w[finished archived].include?(game['status']) }
        .sort_by { |game| -game['updated_at'] }

      [render_form(title, inputs),
       render_webpush,
       h(GameRow,
         header: 'Your Finished Games',
         game_row_games: finished_games,
         type: :personal,
         user: @user)]
    end

    def render_signup
      return [h('h3', 'You are already logged in')] if @user

      title = 'Signup'
      inputs = [
        render_input('User Name', id: :name),
        render_input('Email', id: :email, type: :email, attrs: { autocomplete: 'email' }),
        render_input('Password', id: :password, type: :password, attrs: { autocomplete: 'new-password' }),
        render_checkbox('Turn and Message Emails', :notifications),
        h(:div, [render_button('Create Account') { submit }]),
      ]

      [render_form(title, inputs)]
    end

    def render_login
      return [h('h3', 'You are already logged in')] if @user

      title = 'Login'
      inputs = [
        render_input('', id: :email, type: :hidden, attrs: { value: 'daniel.sousa.me', autocomplete: 'email' }),
        render_input('Password', id: :password, type: :password, attrs: { autocomplete: 'current-password' }),
        h(:div, { style: { marginBottom: '1rem' } }, [render_button('Login') { submit }]),
        h(:a, { attrs: { href: '/forgot' } }, 'Forgot Password'),
      ]

      [render_form(title, inputs)]
    end

    def reset_settings
      input_elm(:red_logo).checked = default_for(:red_logo)
      %i[bg font bg2 font2 your_turn hotseat_game].each { |e| input_elm(e).value = default_for(e) }
      TILE_COLORS.each { |color, hex_color| input_elm(color).value = hex_color }
      ROUTE_COLORS.each_with_index do |hex_color, index|
        input_elm(route_prop_string(index, :color)).value = hex_color
        input_elm(route_prop_string(index, :dash)).value = '0'
        input_elm(route_prop_string(index, :width)).value = 8
      end

      submit
    end

    def render_username
      h('div#settings__username', [
        render_input(
          'User Name',
          id: :name,
          attrs: { value: @user&.dig('name') || '' },
          input_style: { width: '10.5rem' },
        ),
      ])
    end

    def render_checkbox(label, id)
      render_input(label, id: id, type: :checkbox, attrs: { checked: setting_for(id) })
    end

    def render_color(label, id, hex_color, attrs: {})
      render_input(label, id: id, type: :color, attrs: { value: hex_color, **attrs }, on: { change: -> { submit } },
                          input_style: { backgroundColor: hex_color })
    end

    def render_tile_colors
      h('div#settings__tiles', [
        h(:h3, 'Map & Tile Colors'),
        h(:div, TILE_COLORS.map do |color, _|
          render_color('', color, setting_for(color), attrs: { title: color == 'white' ? 'plain' : color })
        end),
      ])
    end

    def render_route_colors
      grid_props = {
        style: {
          display: 'grid',
          grid: '1fr / 5rem 4rem 5rem 5rem',
          alignItems: 'center',
        },
      }

      children = ROUTE_COLORS.map.with_index do |_, index|
        label_props =
          if index.zero?
            {
              attrs: {
                title: 'Your player color',
              },
              style: {
                textDecoration: 'underline',
                textUnderlineOffset: '0.2rem',
                cursor: 'pointer',
              },
            }
          else
            {}
          end

        h(:div, grid_props, [
          h(:label, label_props, "Route #{index + 1}"),
          render_color(
            '',
            route_prop_string(index, :color),
            route_prop(index, :color),
            attrs: { title: "color of route, train and player #{index + 1}#{index.zero? ? ' (you)' : ''}" },
          ),
          render_input(
            '',
            id: route_prop_string(index, :width),
            type: :number,
            attrs: {
              title: 'width of route on map',
              min: 6,
              max: 24,
              value: route_prop(index, :width),
            },
            input_style: { width: '3.5rem' },
          ),
          render_input(
            '',
            id: route_prop_string(index, :dash),
            type: :text,
            attrs: {
              title: 'dash/gap lengths of route on map, for help hover/click header',
              value: route_prop(index, :dash),
            },
            input_style: { width: '7rem' },
          ),
        ])
      end

      header_props = { style: { marginLeft: '0.5rem' } }

      help_message = <<~MESSAGE
        5 = dash 5, gap 5, [repeat]
        15 5 7.5 5 = dash 15, gap 5, dash 7.5, gap 5, [repeat]
        hex width (side to side) = 174
      MESSAGE
      link_props = {
        props: {
          href: 'https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-dasharray',
          title: help_message,
        },
        style: {
          marginLeft: '0.5rem',
        },
      }

      h('div#settings__routes', [
        h(:h3, 'Routes, Trains & Players'),
        h(:div, grid_props, [
          h(:div, ''),
          h(:div, header_props, 'Color'),
          h(:div, header_props, 'Width'),
          h(:a, link_props, 'Dash'),
        ]),
        *children,
      ])
    end

    def delete
      return store(:flash_opts, 'Confirmation not correct') if input_elm(:confirm).value != 'DELETE'

      delete_user
    end

    def submit
      case @type
      when :signup
        create_user(params)
      when :login
        login(params)
      when :profile
        edit_user(params)
      end
    end

    def render_webpush
      %x{
        if("navigator" in window) {
          if (navigator.serviceWorker && #{@serviceworker.nil?}) {
            navigator.serviceWorker.register('/serviceworker.js')
            .then(function(reg) {
              self['$store']('serviceworker', true)
            });
          }

          navigator.serviceWorker.ready.then((serviceWorkerRegistration) => {
            serviceWorkerRegistration.pushManager
            .getSubscription()
            .then((subscription) => {
              if(subscription && subscription.endpoint != #{@webpush_subscription}) {
                self['$store']('webpush_subscription', subscription.endpoint);
              }
            });
          });
        }

        if ("Notification" in window && Notification.permission != #{@notification_permission}) {
          self['$store']('notification_permission', Notification.permission);
        }
      }

      webpush_subscriptions = @user&.dig(:settings, :webpush_subscriptions) || []

      subscribed = false
      rows = webpush_subscriptions.map do |l|
        current_device = l[:subscription][:endpoint] == @webpush_subscription
        subscribed = true if current_device

        h(:li, [
          l[:device] + (current_device ? ' (This device) ' : ' '),
          render_button('Remove') { webpush_unsubscribe(l[:device], current_device) },
        ])
      end

      h(:div, [
        h(:H2, 'Background notifications'),
        h(:ul, rows),
        render_webpush_subscribe(subscribed),
      ])
    end

    def render_webpush_subscribe(subscribed)
      return h(:div, 'This device doesn\'t support background notifications') unless @serviceworker

      return h(:div, 'You have denied permission to show notifications') if @notification_permission == 'denied'

      unless @notification_permission == 'granted'
        return render_button('Allow browser notifications') { ask_notifications_permission }
      end

      return h(:div, 'Push notifications are enabled for this device') if subscribed

      device_input = h(:input, { attrs: { type: :text } })

      h(:div, [
        'Device name:',
        device_input,
        render_button('Add device') { webpush_subscribe(Native(device_input).elm.value) },
      ])
    end

    def ask_notifications_permission
      %x{
        if ("Notification" in window) {
          if (Notification.permission === "default") {
            Notification.requestPermission().then(function(permission) {
              self['$store']('notification_permission', permission);
            })
          }
        }
      }
    end

    # rubocop:disable Lint/UnusedMethodArgument
    def webpush_subscribe(device)
      %x{
        if("navigator" in window) {
          navigator.serviceWorker.ready.then((serviceWorkerRegistration) => {
            console.log(vapid_public_key);
            serviceWorkerRegistration.pushManager
            .subscribe({
              userVisibleOnly: true,
              applicationServerKey: #{@vapid_public_key}
            })
            .then((subscription) => {
              self['$webpush_subscribe_save'](device, subscription.toJSON())
            });
          });
        }
      }
    end
    # rubocop:enable Lint/UnusedMethodArgument

    def webpush_subscribe_save(device, subscription)
      webpush_subscriptions = @user[:settings][:webpush_subscriptions] || []
      webpush_subscriptions << { device: device, subscription: subscription }

      edit_user({ webpush_subscriptions: webpush_subscriptions })
    end

    def webpush_unsubscribe(device, current_device)
      subscriptions = @user[:settings][:webpush_subscriptions]
      edit_user({ webpush_subscriptions: subscriptions.reject { |s| s[:device] == device } })
      return unless current_device

      %x{
        if("navigator" in window) {
          navigator.serviceWorker.ready.then((serviceWorkerRegistration) => {
            serviceWorkerRegistration.pushManager
            .getSubscription()
            .then((subscription) => {
              if(subscription) {
                subscription.unsubscribe();
              }
            });
          });
        }
      }
    end
  end
end
