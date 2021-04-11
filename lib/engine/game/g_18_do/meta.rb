# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18DO
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Wolfram Janich, Michael Scharf'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18DO'
        GAME_LOCATION = 'Dortmund, Germany'
        GAME_PUBLISHER = :fox_in_the_box
        GAME_RULES_URL = 'https://foxinthebox.cz/image/catalog/ke-stazeni/18DO_TRG_Draft_rules.pdf'

        PLAYER_RANGE = [2, 5].freeze
      end
    end
  end
end
