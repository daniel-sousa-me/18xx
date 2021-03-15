# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G1866
      class Game < Game::Base
        include_meta(G1866::Meta)

        attr_reader :crisis_triggered

        register_colors(black: '#37383a',
                        orange: '#f48221',
                        brightGreen: '#76a042',
                        red: '#d81e3e',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '%d₧'

        BANK_CASH = 7000

        CERT_LIMIT = { 2 => 20, 3 => 14, 4 => 11, 5 => 10, 6 => 9 }.freeze

        STARTING_CASH = { 2 => 900, 3 => 600, 4 => 450, 5 => 360, 6 => 300 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = true

        TILES = {
          '2' => 1,
          '3' => 1,
          '4' => 1,
          '7' => 10,
          '8' => 10,
          '9' => 10,
          '14' => 2,
          '15' => 2,
          '16' => 2,
          '17' => 1,
          '18' => 2,
          '19' => 2,
          '20' => 2,
          '21' => 1,
          '22' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 1,
          '56' => 1,
          '57' => 5,
          '58' => 1,
          '70' => 1,
          '129' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;city=revenue:50;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:3;label=C',
          },
          '432' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2,loc:1;city=revenue:60,slots:2,loc:4;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_1;'\
                      'path=a:4,b:_1;path=a:5,b:_1;path=a:_0,b:_1;label=C',
          },
          '448' => 1,
          '449' => 2,
          '450' => 2,
          '619' => 2,
          '625' => 2,
          '626' => 1,
          '627' => 1,
          '628' => 1,
          '629' => 1,
          '630' => 1,
          '632' => 1,
          '633' => 1,
        }.freeze

        LOCATION_NAMES = {
          'C1' => 'Irun',
          'D4' => 'Pobla de Segur & Tremp',
          'F2' => 'Andorra',
          'F4' => "La Seu d'Urgell & Guardiola de Berguedà",
          'G3' => 'Puigcerdà',
          'H2' => 'Livia',
          'G5' => 'Berga',
          'K3' => 'Perpignan',
          'L4' => 'Port Bou',
          'D6' => 'Balaguer',
          'K5' => 'Girona',
          'L6' => 'St Feliu de Guixols',
          'F8' => 'Igualada',
          'H8' => 'Manresa',
          'C9' => 'Lleida',
          'D10' => 'Juneda & Les Borges Blangues',
          'I5' => 'St Joan de las Abadesas',
          'J8' => 'Mataro',
          'B10' => 'Madrid',
          'C11' => 'TBD',
          'H10' => 'Barcelona',
          'G11' => 'TBD',
          'E11' => 'Reus',
          'F10' => 'Mantblanch & Valls',
          'F12' => 'Tarragona',
          'C13' => 'Tortosa',
          'B14' => 'Valencia',
          'D14' => "L'Ampolla",
        }.freeze

        MARKET = [
          %w[82 90 100 112 126 142 160 180 200 225 250 275 300 325 350],
          %w[76 82 90 100 112 126 142 165 195 225 245 265 280 295 300],
          %w[70 76 82 90p 100 112 126 145 175 205 225 245 260 275 290],
          %w[65 70 76 82 90 100 115 130 160 190 210 230],
          %w[60 66 71 76p 82 90 100 115 140 165],
          %w[55 62 67 71 76 82 90 100],
          %w[50y 58 65 67p 71 75 80],
          %w[45y 54y 63 65 69 71],
          %w[40o 50o 60y 63 68],
          %w[30b 40o 50o 60y],
          %w[20b 30b 40o 50y],
          %w[10b 20b 30b 40o],
        ].freeze

        PHASES = [{ name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
                  {
                    name: '3',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
                  },
                  {
                    name: '4',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
                  },
                  {
                    name: '5',
                    on: '5',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '6',
                    on: '6',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: 'D',
                    on: 'D',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  }].freeze

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 5 },
                  { name: '3', distance: 3, price: 180, rusts_on: '5', num: 5 },
                  { name: '4', distance: 4, price: 340, rusts_on: '6', num: 3 },
                  {
                    name: '5',
                    distance: 5,
                    price: 450,
                    num: 2,
                    events: [{ 'type' => 'close_companies' }],
                  },
                  {
                    name: '6',
                    distance: 6,
                    price: 660,
                    num: 2,
                  },
                  { name: 'D', distance: 999, price: 1100, num: 10 }].freeze

        COMPANIES = [
          {
            name: 'Companyia dels Camins de Ferro de Barcelona a Mataró',
            value: 20,
            revenue: 5,
            desc: 'Blocks I9 while owned by a player.',
            sym: 'FBM',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['I9'] }],
            color: nil,
          },
          {
            name: 'La Maquinista Terrestre i Marítima',
            value: 50,
            revenue: 10,
            desc: "While owned by a corporations, towns don't count torwards the train run"\
                  '(they still count towards revenue).',
            sym: 'MTM',
            color: nil,
          },
          {
            name: 'Companyia dels Ferrocarrils de Tarragona a Barcelona i França',
            value: 100,
            revenue: 10,
            desc: 'Can be exchanged buy a share of TBF',
            sym: 'TBF',
            abilities: [
              {
                type: 'exchange',
                corporations: ['TBF'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: nil,
          },
          {
            name: 'Companyia dels Ferrocarrils Directes de Madrid i Saragossa a Barcelona',
            value: 140,
            revenue: 0,
            desc: 'The owning Corporation may upgrade one of Igualada (F8), Manresa (H8),'\
                  ' Mataro (J8) and/or place a token on a free space if available (no track'\
                  ' connection needed and this upgrade is in addition to its normal OR actions)',
            sym: 'FMSB',
            abilities: [{
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          special: false,
                          hexes: %w[F8 H8 J8],
                          teleport: true,
                          tiles: %w[14 15 619],
                          when: %w[special_fmsb owning_corp_or_turn],
                          count: 2,
                        }],
            color: nil,
          },
          {
            name: 'Miquel Biada',
            value: 180,
            revenue: 20,
            desc: "This private comes with the 20% president's certificate of the Companyia"\
                  'del Ferrocarril de Saragossa a Barcelona (CFSB). The buying player must'\
                  'immediately set the par price for the CFSB to any par price. This private'\
                  'cannot be purchased by a Corporation and closes at the start of phase 5,'\
                  'or when the CFSB purchases a train.',
            sym: 'MB',
            abilities: [{ type: 'shares', shares: 'CFSB_0' },
                        { type: 'close', when: 'bought_train', corporation: 'CFSB' },
                        { type: 'no_buy' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'BFF',
            name: 'BFF',
            logo: '1866/BFF',
            tokens: [0, 40, 80],
            coordinates: 'K5',
            color: '#f48221',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'LRT',
            name: 'LRT',
            logo: '1866/LRT',
            tokens: [0, 40, 80],
            coordinates: 'E11',
            color: :yellow,
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'CFSB',
            name: 'CFSB',
            logo: '1866/CFSB',
            tokens: [0, 40, 80, 120],
            coordinates: 'C9',
            color: :lightgray,
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'CGFC',
            name: 'CGFC',
            logo: '1866/CGFC',
            tokens: [0, 40, 80, 120],
            coordinates: 'G5',
            color: '#0189d1',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'FSB',
            name: 'FSB',
            logo: '1866/FSB',
            tokens: [0, 40, 80],
            coordinates: 'H10',
            color: :gray,
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'TMB',
            name: 'TMB',
            logo: '1866/TMB',
            tokens: [0, 40, 80],
            coordinates: 'F12',
            color: '#d81e3e',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'TBF',
            name: 'TBF',
            logo: '1866/TBF',
            tokens: [0, 40, 80],
            shares: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
            color: '#37383a',
            reservation_color: nil,
          },
        ].freeze

        HEXES = {
          white: {
            %w[H6 J6 G7 D8 K7 I9] => '',
            %w[D2 E3 H4 J4 I7 G9] => 'upgrade=cost:40,terrain:mountain',
            %w[K5 F8 H8 J8] => 'city=revenue:0',
            %w[G5] => 'city=revenue:40;upgrade=cost:40,terrain:mountain',
            %w[E11] => 'city=revenue:40;upgrade=cost:40,terrain:mountain;border=edge:2,type:water,cost:20',
            %w[C11 L6] => 'town=revenue:0',
            %w[G3 L4] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            ['I5'] =>
                   'town=revenue:0;upgrade=cost:40,terrain:mountain;icon=image:1866/mine,sticky:1',
            %w[D4] => 'town=revenue:0;town=revenue:0',
            %w[F10] => 'stub=edge:0;town=revenue:0;town=revenue:0',
            %w[G11] => 'stub=edge:1;town=revenue:0;town=revenue:0',
            %w[F6] => 'border=edge:2,type:water,cost:20',
            %w[E7 D12] =>
                   'border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20;border=edge:3,type:water,cost:20',
            ['C11'] => 'town=revenue:0;border=edge:3,type:water,cost:20;'\
                       'border=edge:4,type:water,cost:20;border=edge:5,type:water,cost:20',
            ['E9'] =>
                   'border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20',
            %w[D6] => 'city=revenue:0;border=edge:5,type:water,cost:20',
            ['C9'] => 'city=revenue:0;border=edge:0,type:water,cost:20',
            ['C13'] => 'city=revenue:0;border=edge:4,type:water,cost:20',
            ['D10'] => 'town=revenue:0;town=revenue:0;border=edge:0,type:water,cost:20;'\
              'border=edge:1,type:water,cost:20;border=edge:4,type:water,cost:20;border=edge:5,type:water,cost:20',
            ['E5'] => 'upgrade=cost:40,terrain:mountain;border=edge:0,type:water,cost:20;'\
                      'border=edge:4,type:water,cost:20;border=edge:5,type:water,cost:20',
            ['F4'] =>
                   'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:1,type:water,cost:20',
          },
          yellow: { ['H10'] =>
            'city=revenue:30;city=revenue:30;path=a:2,b:_0;path=a:4,b:_1;label=C',
   },
          gray: {
            ['F12'] => 'city=revenue:40,slots:1;path=a:3,b:_0;path=a:4,b:_0',
            ['H2'] => 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:1',
            ['D14'] => 'town=revenue:10;path=a:2,b:_0;path=a:_0,b:3',
          },
          red: {
            ['C1'] => 'offboard=revenue:yellow_30|brown_50;path=a:5,b:_0',
            ['K3'] => 'offboard=revenue:yellow_30|brown_80;path=a:5,b:_0',
            ['B10'] => 'offboard=revenue:yellow_30|brown_60;path=a:4,b:_0;path=a:5,b:_0',
            ['B14'] => 'offboard=revenue:yellow_20|brown_40;path=a:4,b:_0',
          },
          blue: {
            ['H12'] => 'offboard=revenue:30;path=a:3,b:_0',
            ['I11'] => 'offboard=revenue:30;path=a:2,b:_0',
          },
          brown: {
            ['F2'] => 'offboard=revenue:yellow_30|brown_50,visit_cost:0;path=a:0,b:_0;icon=image:1866/coins',
          },
        }.freeze

        LAYOUT = :flat

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'ce' => ['La crisis económica de 1866',
                   'All companies go back on the market diagonaly (left and then down if possible)'\
                   'the same amount of steps as shares unsold (either on the Corporation treasury or the Bank pool).']
        ).freeze

        CRISIS_SHARE_TRIGGER = 36
        SELL_BUY_ORDER = :sell_buy_sell
        TRACK_RESTRICTION = :permissive

        TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }, { lay: :true, upgrade: true, cost: 0 }].freeze

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::HomeToken,
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G1866::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            # Engine::Step::SpecialTrack,
            Engine::Step::BuyCompany,
            G1866::Step::SpecialFmsb,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1866::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, blocks: true],
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
          @crisis_triggered = false
          @crisis_just_triggered = false
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

        def num_player_shares
          @corporations.map(&:num_player_shares).inject(:+)
        end

        def check_crisis!
          return if @crisis_triggered || num_player_shares < CRISIS_SHARE_TRIGGER

          @log << '-- Event: La crisis económica de 1866 is here! --'
          @crisis_triggered = true
          @crisis_just_triggered = true

          @corporations.each do |corp|
            next unless corp.ipoed

            old_price = corp.share_price.price
            (corp.num_market_shares + corp.num_ipo_shares).times do
              @stock_market.move_left(corp)
              @stock_market.move_down(corp)
            end

            if old_price != corp.share_price.price
              new_price = corp.share_price.price
              @log << "#{corp.name} falls from #{format_currency(old_price)} to #{format_currency(new_price)}"
            end
          end

          @round.entities.each(&:pass!)
        end

        def new_stock_round
          if @crisis_just_triggered
            @crisis_just_triggered = false

            player = @players.reject(&:bankrupt).min_by(&:cash)
            @players.rotate!(@players.index(player))

            @log << "#{player.name} is the player with less cash and gets priority"
          end

          super
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

        def action_processed(_action)
          return unless @tbf_company
          return if !@tbf_company.closed? && !@tbf_company&.owner&.corporation?

          @log << 'TBF can no longer be converted to a public corporation'
          @corporations.reject! { |c| c.id == 'TBF' }
          @tbf_company = nil
        end

        def corporation_available?(corp)
          return false if corp.id == 'TBF' && @tbf_company&.owner != @round.current_entity && !corp.ipoed

          super
        end

        def president_bonus_for(route, stops)
          # Andorra
          stops.sum { |stop| stop.hex.name == 'F2' ? stop.route_revenue(route.phase, route.train) : 0 }
        end

        def routes_president_bonus(routes)
          routes.sum(&:president_bonus)
        end

        def revenue_for(route, stops)
          super - president_bonus_for(route, stops)
        end

        def subsidy_for(_route, stops)
          # Mine
          stops.any? { |s| s.hex.name == 'I5' } ? 20 : 0
        end

        def routes_subsidy(routes)
          routes.sum(&:subsidy)
        end

        def check_other(route)
          return unless route.stops.map(&:hex).map(&:id).include?('A11')
          return if fmsb_company.closed?
          return unless fmsb_company.owner.player?

          raise GameError, "Can't run to Madrid while FMSB is owned by a player"
        end

        def company_sold(company, corporation)
          super

          return unless company.id == 'MTM'
          return if corporation.trains.empty?

          train = corporation.trains.min_by(&:distance)
          train.rusts_on = nil
          train.buyable = false
        end
      end
    end
  end
end
