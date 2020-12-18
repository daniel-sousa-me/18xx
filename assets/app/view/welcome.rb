# frozen_string_literal: true

require 'lib/publisher'

module View
  class Welcome < Snabberb::Component
    needs :app_route, default: nil, store: true
    needs :show_intro, default: true

    def render
      children = [render_notification]
      children << render_buttons

      h('div#welcome.half', children)
    end

    def render_notification
      message = <<~MESSAGE
        <p>This is an copy of the site <a href="https://18xx.games">18xx.games</a> by Toby Mao and contributors.</p>

        <p>This is intended to help test an alpha version of 1870. All other games are disabled.</p>

        <p>The accounts here are independent from the ones on the real site, because I don't have access to your passwords. You'll have to create a new account here. As usual you are advised to use a different password.</p>

        <p>Email notifications are disabled, so you can put a bogus email address</p>
      MESSAGE

      props = {
        style: {
          background: 'rgb(240, 229, 140)',
          color: 'black',
          marginBottom: '1rem',
        },
        props: {
          innerHTML: message,
        },
      }

      h('div#notification.padded', props)
    end

    def render_buttons
      props = {
        style: {
          margin: '1rem 0',
        },
      }

      create_props = {
        on: {
          click: -> { store(:app_route, '/new_game') },
        },
      }

      tutorial_props = {
        on: {
          click: -> { store(:app_route, '/tutorial?action=1') },
        },
      }

      h('div#buttons', props, [
        h(:button, create_props, 'CREATE A NEW GAME'),
        h(:button, tutorial_props, 'TUTORIAL'),
      ])
    end
  end
end
