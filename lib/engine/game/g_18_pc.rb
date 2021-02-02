# frozen_string_literal: true

require_relative '../config/game/g_18_pc'
require_relative 'base'

module Engine
  module Game
    class G18PC < Base
      register_colors(black: '#37383a',
                      orange: '#f48221',
                      brightGreen: '#76a042',
                      red: '#d81e3e',
                      turquoise: '#00a993',
                      blue: '#0189d1',
                      brown: '#7b352a')

      load_from_json(Config::Game::G18PC::JSON)

      DEV_STAGE = :alpha

      GAME_LOCATION = 'Catalunya'
      GAME_RULES_URL = ''
      GAME_DESIGNER = 'João Cardoso'
      GAME_PUBLISHER = :self_published
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18PC'
    end
  end
end
