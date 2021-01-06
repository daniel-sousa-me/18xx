# frozen_string_literal: true

module View
  class LogLine < Snabberb::Component
    include View::Game::Actionable
    include Lib::Settings

    needs :line
    needs :app_route, default: nil, store: true
    needs :show_messages, default: true, store: true
    needs :log_level, default: 2, store: true
    needs :round_history, default: nil, store: true

    def render
      time_props = { style: {
        margin: '0.2rem 0.3rem',
        fontSize: 'smaller',
      },
}

      username_props = { style: {
        margin: '0 0.2rem',
        fontWeight: 'bold',
      },
}

      message_props = { style: { margin: '0 0.1rem' } }

      time_str = '⇤'
      if @line[:created_at]
        time = @line[:created_at]
        time_str = time.strftime('%R ')
      end

      case @line[:type]
      when :action
        if @log_level.positive?
          master_mode_props = { style: {
            margin: '0.1rem',
            fontSize: 'smaller',
          },
}

          children = [h('span.time', time_props, [history_link(time_str, "Go to action##{@line[:id]}", @line[:id])])]

          unless @line[:entity_list].empty?
            # These spaces are appended to tell Chrome to separate words when selecting the text
            children << h('span.username', username_props, @line[:entity_list].last + ' ')
          end

          children << h('span.master_mode', master_mode_props, "(controlled by #{@line[:user]})") if @line[:user]

          @line[:entity_list][0..-2].each { |e| children << h('span.entity', "· #{e} ") }

          children << h('span.message', message_props, @line[:message])

          h(:span, children)
        end
      when :message
        h(:span, [
          h('span.time', time_props, [history_link(time_str, "Go to action##{@line[:id]}", @line[:id])]),
          h('span.username', username_props, @line[:username]),
          h('span.separator', time_props, ' ➤ '),
          h('span.message', message_props, @line[:message]),
        ]) if @show_messages
      when :undo
        if @log_level.positive?
          undo_props = { style: {
            margin: '-0.2rem',
            fontSize: '0.7rem',
          },
}

          h('div.undo', undo_props, '↺')
        end
      end
    end
  end
end
