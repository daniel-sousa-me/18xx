# frozen_string_literal: true

module Engine
  # Information about an players status
  class PlayerInfo
    attr_reader :round_name, :turn, :round_no, :value, :action_id

    def initialize(round_name, turn, round_no, player_value, action_id)
      @round_name = round_name
      @turn = turn
      @round_no = round_no
      @value = player_value
      @action_id = action_id
    end

    def round
      if %w[AR MR OR].include?(round_name)
        "#{round_name} #{turn}.#{round_no}"
      else
        "#{round_name} #{turn}"
      end
    end

    def to_h
      {
        round_name: @round_name,
        turn: @turn,
        round_no: @round_no,
        value: @value,
        action: @action_id,
      }
  end
end
