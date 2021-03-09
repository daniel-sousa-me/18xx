# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1866
      module Meta
        include Game::Meta

        DEV_STAGE = :prototype

        GAME_DESIGNER = 'João Cardoso'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1866'
        GAME_LOCATION = 'Catalunya'
        GAME_PUBLISHER = :self_published
        GAME_RULES_URL = ''

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
