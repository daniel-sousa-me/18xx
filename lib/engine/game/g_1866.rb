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
                  'All companies go back on the market diagonaly (left and then down if possible) the same amount of steps as shares unsold (either on the Corporation treasury or the Bank pool).']
      ).freeze

      CE_POSSIBLE_PHASES = %w[3 4 5]

      TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }, { lay: :not_if_upgraded, upgrade: false, cost: 0 }].freeze

      def stock_round
        Round::Stock.new(self, [
          Step::HomeToken,
          Step::DiscardTrain,
          Step::Exchange,
          Step::SpecialTrack,
          Step::G1866::BuySellParShares,
        ])
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::Exchange,
          #Step::SpecialTrack,
          Step::BuyCompany,
          Step::G1866::SpecialFMSB,
          Step::HomeToken,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::G1866::Dividend,
          Step::DiscardTrain,
          Step::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def init_company_abilities
        @companies.each do |company|
          next unless (ability = abilities(company, :exchange))

          next unless ability.from.include?(:par)

          exchange_corporations(ability).first.par_via_exchange = company
          @tbf_company = company
        end
        super
      end

      def setup
        # Due to SC adding an extra train this isn't quite a phase change, so the event needs to be tied to a train.
        ce_train = CE_POSSIBLE_PHASES[rand % CE_POSSIBLE_PHASES.size]
        @log << "La crisis económica de 1866 occurs on purchase of the first #{ce_train} train"
        train = depot.upcoming.find { |t| t.name == ce_train }
        train.events << { 'type' => 'ce' }
      end

      def home_token_locations(corporation)
        raise NotImplementedError unless corporation.name == 'TBF'

        # TBF, find all locations with neutral or no token
        hexes = @hexes.dup
        hexes.select do |hex|
          hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
        end
      end

      def place_home_token(corporation)
        super

        @tbf_company = nil if corporation.name == 'TBF'
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

      def fmsb_company
        @fmsb_company ||= company_by_id('FMSB')
      end

      def bff_corporation
        @bff_corporation ||= corporation_by_id('BFF')
      end

      def tmb_corporation
        @tmb_corporation ||= corporation_by_id('TMB')
      end

      def hexes_connected?(start_city, goal_cities)
        start_city.walk { |path| return true if goal_cities.include?(path.b) }

        false
      end

      def action_processed(action)
        return unless @tbf_company
        return if !@tbf_company.closed? && !@tbf_company&.owner&.corporation?

        @log << 'TBF can no longer be converted to a public corporation'
        @corporations.reject! { |c| c.id == 'TBF' }
        @tbf_company = nil
      end

      def corporation_available?(corp)
        return false if corp.id == 'TBF' && @tbf_company&.owner != @round.current_entity

        super
      end

      def subsidy_for(route, stops)
        puts stops.any? { |s| s.hex.name == 'I5' } ? 20 : 0
        stops.any? { |s| s.hex.name == 'I5' } ? 20 : 0
      end

      def routes_subsidy(routes)
        routes.sum(&:subsidy)
      end

      def check_other(route)
        return unless route.stops.map(&:hex).map(&:id).include?('A11')
        return if fmsb_company.closed?
        return if fmsb_company.owner == route.corporation

        raise GameError, 'Only the owner of FMSB can run to Madrid'
      end
    end
  end
end
