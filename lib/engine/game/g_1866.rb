# frozen_string_literal: true

require_relative '../config/game/g_1866'
require_relative 'base'

module Engine
  module Game
    class G1866 < Base
      register_colors(black: '#37383a',
                      orange: '#f48221',
                      brightGreen: '#76a042',
                      red: '#d81e3e',
                      turquoise: '#00a993',
                      blue: '#0189d1',
                      brown: '#7b352a')

      load_from_json(Config::Game::G1866::JSON)

      DEV_STAGE = :alpha

      GAME_LOCATION = 'Catalunya'
      GAME_RULES_URL = ''
      GAME_DESIGNER = 'João Cardoso'
      GAME_PUBLISHER = :self_published
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1866'

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'ce' => ['La crisis económica de 1866',
                  'All companies go back on the market diagonaly (down and left) the same amount of steps as shares unsold (either on the Corporation treasury or the Bank pool).']
      ).freeze

      CE_POSSIBLE_PHASES = %w[3 4 5]

      def setup
        # Due to SC adding an extra train this isn't quite a phase change, so the event needs to be tied to a train.
        ce_train = CE_POSSIBLE_PHASES[rand % CE_POSSIBLE_PHASES.size]
        @log << "La crisis económica de 1866 occurs on purchase of the first #{ce_train} train"
        train = depot.upcoming.find { |t| t.name == ce_train }
        train.events << { 'type' => 'ce' }
      end
      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::Exchange,
          Step::SpecialTrack,
          Step::BuyCompany,
          Step::G1866::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::DiscardTrain,
          Step::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end



      def event_ce!
        @log << '-- Event: La crisis económica de 1866! --'
        @corporations.each do |corp|
          next unless corp.floated?

          (corp.num_market_shares + corp.num_ipo_shares).times do
            @stock_market.move_left(corp)
            @stock_market.move_down(corp)
          end
        end
      end
    end
  end
end
