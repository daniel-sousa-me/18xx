# frozen_string_literal: true

module View
  module Game
    class Clock < Snabberb::Component

      needs :time_spent
      needs :counting

      def render
        secs = @time_spent.to_i
        secs += (Time.now - @counting).to_i if @counting
        mins = (secs / 60).to_i
        hours = (mins / 60).to_i
        days = (hours / 24).to_i

        h(:span, "#{days}D #{(hours % 24).to_s.rjust(2, '0')}:#{(mins % 60).to_s.rjust(2, '0')}:#{(secs % 60).to_s.rjust(2, '0')}")
      end
    end
  end
end
