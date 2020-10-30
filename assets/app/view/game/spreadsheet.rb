# frozen_string_literal: true

require 'lib/color'
require 'lib/settings'
require 'lib/storage'
require 'view/link'
require 'view/game/bank'
require 'view/game/stock_market'
require 'view/game/actionable'

module View
  module Game
    class Spreadsheet < Snabberb::Component
      include Lib::Color
      include Lib::Settings
      include Actionable

      needs :game

      def render
        @spreadsheet_sort_by = Lib::Storage['spreadsheet_sort_by']
        @spreadsheet_sort_order = Lib::Storage['spreadsheet_sort_order']
        @delta_value = Lib::Storage['spreadsheet_delta_value']
        @hide_not_floated = Lib::Storage['spreadsheet_hide_not_floated']

        @hide_ipo = @game.all_corporations.reject(&:minor?).all?(&:always_market_price)
        @hide_reserved = @game.all_corporations.reject(&:minor?).flat_map(&:shares).all?(&:buyable)

        h('div#spreadsheet',
          [h('table.comfortable', table_props, render_corporation_table + render_player_table)])
      end

      def render_corporation_table
        [
          h(:thead, render_titles),
          h(:tbody, render_corporations),
          h(:tfoot, [
            h(:tr, { style: { height: '1rem' } }, [
              h(:td, { attrs: { colspan: @game.players.size + 8 } }, ''),
              h(:td, { attrs: { colspan: 2 } }, @game.respond_to?(:token_note) ? @game.token_note : ''),
              h(:td, { attrs: { colspan: 1 } }, ''),
            ]),
          ]),
        ]
      end

      def render_player_table
        [
          h('tbody#player_details', [
            h(:tr, { style: { height: '1rem' } }, ''),
            render_player_cash,
            render_player_value,
            render_player_liquidity,
            render_player_shares,
            render_player_companies,
            render_player_certs,
            h(:tr, { style: { height: '1rem' } }, ''),
            *render_player_or_history,
]),
          h(:tr, [h(:td, { attrs: { colspan: 5 } }, [render_spreadsheet_controls])]),
        ]
      end

      def render_extra_cards
        attrs = {
          style: {
            backgroundColor: color_for(:bg),
            color: color_for(:font),
            paddingLeft: '30px',
            textAlign: 'left',
            verticalAlign: 'top',
          },
          attrs: { colspan: 1000, rowspan: 1000 },
        }
        h(:td, attrs, [
          h(Bank, game: @game),
          h(GameInfo, game: @game, layout: 'upcoming_trains'),
        ].compact)
      end

      def or_history(corporations)
        corporations.flat_map { |c| c.operating_history.keys }.uniq.sort
      end

      def render_history_titles(corporations)
        or_history(corporations).map do |turn, round|
          h(:th, bottom_th_props, render_sort_link(@game.or_description_short(turn, round), [turn, round]))
        end
      end

      def render_player_or_history
        # OR history should exist in all
        last_values = nil
        @game.players.first.history.map do |h|
          values = @game.players.map do |p|
            p.history.find { |h2| h2.round == h.round }.value
          end
          next if values == last_values

          delta_v = (last_values || Array.new(values.size, 0)).map(&:-@).zip(values).map(&:sum) if @delta_value
          last_values = values
          row_content = values.map.with_index do |v, i|
            disp_value = @delta_value ? delta_v[i] : v
            h('td.padded_number',
              disp_value.negative? ? { style: { color: 'red' } } : {},
              @game.format_currency(disp_value))
          end

          h(:tr, tr_default_props, [
            h('th.left', { attrs: { colspan: 2 } }, h.round),
            *row_content,
          ])
        end.compact.reverse
      end

      def render_history(corporation)
        or_history(@game.all_corporations).map do |x|
          render_or_history_row(corporation.operating_history, corporation, x)
        end
      end

      def render_or_history_row(hist, corporation, x)
        if hist[x]
          revenue_text, alpha =
            case (hist[x].dividend.is_a?(Engine::Action::Dividend) ? hist[x].dividend.kind : 'withhold')
            when 'withhold'
              ["[#{hist[x].revenue}]", '0.5']
            when 'half'
              ["।#{hist[x].revenue}।", '0.75']
            else
              [hist[x].revenue.to_s, '1.0']
            end

          props = {
            style: {
              color: convert_hex_to_rgba(color_for(:font2), alpha),
              padding: '0 0.15rem',
            },
          }

          if hist[x]&.dividend&.id&.positive?
            link_h = history_link(revenue_text,
                                  "Go to run #{x} of #{corporation.name}",
                                  hist[x].dividend.id - 1)
            h(:td, props, [link_h])
          else
            h(:td, props, revenue_text)
          end
        else
          h(:td, '')
        end
      end

      def render_titles
        th_props = lambda do |cols, border_right = true|
          props = tr_default_props
          props[:attrs] = { colspan: cols }
          props[:style][:padding] = '0.3rem'
          props[:style][:borderRight] = "1px solid #{color_for(:font2)}" if border_right
          props[:style][:fontSize] = '1.1rem'
          props[:style][:letterSpacing] = '1px'
          props
        end

        or_history_titles = render_history_titles(@game.all_corporations)

        extra = []
        extra << h(:th, bottom_th_props, render_sort_link('Loans', :loans)) if @game.total_loans&.nonzero?
        if @game.total_loans.positive?
          extra << h(:th, bottom_th_props, render_sort_link('Buying Power', :buying_power))
          extra << h(:th, bottom_th_props, render_sort_link('Interest Due', :interest))
        end

        top =
          h(:tr, [
            h(:th, { attrs: { colspan: 2 }, style: { minWidth: '5rem' } }, ''),
            h(:th, th_props[@game.players.size], 'Players'),
            h(:th, th_props[(@hide_reserved ? 2 : 3) + (@game.respond_to?(:available_shorts) ? 1 : 0), true], 'Shares'),
            h(:th, th_props[@hide_ipo ? 1 : 2], 'Prices'),
            h(:th, th_props[4 + extra.size, true, false], 'Corporation'),
            h(:th, th_props[or_history_titles.size, false], 'OR History'),
          ])

        bottom = [h(:th, { attrs: { colspan: 2 }, style: { paddingBottom: '0.3rem' } },
                    render_sort_link('SYM', :order))]

        h_player = (@game.round.is_a?(Engine::Round::Stock) ? @game.round.current_entity : @game.priority_deal_player)

        @game.players.each do |p|
          bottom << h('th.name.nowrap.right', bottom_th_props(p == h_player), render_sort_link(p.name, p.id))
        end

        bottom << h(:th, bottom_th_props, render_sort_link(@game.ipo_name, :ipo_shares))
        bottom << h(:th, bottom_th_props,
                    render_sort_link(@game.ipo_reserved_name, :ipo_reserved_shares)) unless @hide_reserved
        bottom << h(:th, bottom_th_props, render_sort_link('Shorts', :shorts)) if @game.respond_to?(:available_shorts)
        bottom << h(:th, bottom_th_props, render_sort_link('Market', :market_shares))

        if @hide_ipo
          bottom << h(:th, bottom_th_props, render_sort_link('Price', :share_price))
        else
          bottom << h(:th, bottom_th_props, render_sort_link(@game.ipo_name, :par_price)) unless @hide_ipo
          bottom << h(:th, bottom_th_props, render_sort_link('Market', :share_price))
        end

        bottom << h(:th, bottom_th_props, render_sort_link('Cash', :cash))
        bottom << h(:th, bottom_th_props, render_sort_link('Trains', :trains))
        bottom << h(:th, bottom_th_props, render_sort_link('Tokens', :tokens))

        bottom.concat(extra)

        bottom << h(:th, bottom_th_props, render_sort_link('Companies', :companies))
        bottom.concat(or_history_titles)

        [top, h(:tr, bottom)]
      end

      def render_sort_link(text, sort_by)
        [
          h(
            Link,
            href: '',
            title: 'Sort',
            click: lambda {
              mark_sort_column(sort_by)
              toggle_sort_order
            },
            children: text,
          ),
          h(:span, @spreadsheet_sort_by == sort_by ? sort_order_icon : ''),
        ]
      end

      def sort_order_icon
        return '↓' if @spreadsheet_sort_order == 'ASC'

        '↑'
      end

      def mark_sort_column(sort_by)
        Lib::Storage['spreadsheet_sort_by'] = sort_by
        update
      end

      def toggle_sort_order
        Lib::Storage['spreadsheet_sort_order'] = @spreadsheet_sort_order == 'ASC' ? 'DESC' : 'ASC'
        update
      end

      def toggle_delta_value
        Lib::Storage['spreadsheet_delta_value'] = !@delta_value
        update
      end

      def render_toggle_not_floated_link
        toggle = lambda do
          Lib::Storage['spreadsheet_hide_not_floated'] = !@hide_not_floated
          update
        end

        h('span.small_font', [
          '(',
          h(:a,
            {
              attrs: {
                onclick: 'return false',
                title: @hide_not_floated ? 'Show all corporations' : 'Hide not floated corporations',
              },
              on: { click: toggle },
              style: {
                cursor: 'pointer',
                textDecoration: 'underline',
              },
            },
            @hide_not_floated ? 'floated' : 'all'),
          ')',
         ])
      end

      def render_spreadsheet_controls
        h(:button, {
            style: { minWidth: '9.5rem' },
            on: { click: -> { toggle_delta_value } },
          },
          "Show #{@delta_value ? 'Total' : 'Delta'} Values")
      end

      def render_corporations
        sorted_corporations.map.with_index do |corp_array, index|
          render_corporation(*corp_array, index)
        end
      end

      def sorted_corporations
        operating_corporations =
          if @game.round.operating?
            @game.round.entities
          else
            @game.operating_order
          end
        result = @game.all_corporations.select { |c| c.minor? || c.ipoed }
        result = result.sort.each.with_index.map do |c, order|
          operating_order = (operating_corporations.find_index(c) || -1) + 1
          [c, order + 1, operating_order]
        end

        result = if result.map(&:last).all?(0)
                   result.map { |c, order, _| [c, order] }
                 else
                   result.map { |c, _, order| [c, order] }
                 end

        result.sort_by! do |corporation, order|
          main = case @spreadsheet_sort_by
                 when :cash
                   corporation.cash
                 when :id
                   corporation.id
                 when :ipo_shares
                   corporation.num_ipo_non_reserved_shares
                 when :ipo_reserved_shares
                   corporation.num_ipo_reserved_shares
                 when :market_shares
                   num_shares_of(@game.share_pool, corporation)
                 when :order
                   (order.positive? ? order : Float::INFINITY)
                 when :par_price
                   corporation.par_price&.price || 0
                 when :share_price
                   corporation.share_price&.price || 0
                 when :loans
                   corporation.loans.size
                 when :short
                   @game.available_shorts(corporation)
                 when :size
                   corporation.total_shares
                 when :buying_power
                   @game.buying_power(corporation, full: true)
                 when :interest
                   @game.interest_owed(corporation)
                 when :trains
                   if corporation.floated?
                     [corporation.trains.size, corporation.trains.map { |c| c.distance || 0 }.sum]
                   else
                     -1
                   end
                 when :tokens
                   [@game.count_available_tokens(corporation), corporation.tokens.size]
                 when :companies
                   [corporation.companies.size, corporation.companies.map { |c| c.value || 0 }.sum]
                 else
                   @game.player_by_id(@spreadsheet_sort_by)&.num_shares_of(corporation)
                 end
          [main, corporation]
        end

        result.reverse! if @spreadsheet_sort_order == 'DESC'
        result
      end

      def render_corporation(corporation, order, _index)
        return '' if @hide_not_floated && !corporation.floated?

        border_style = "1px solid #{color_for(:font2)}"

        name_props =
          {
            style: {
              position: 'sticky',
              left: 0,
              zIndex: 1,
              opacity: 1,
              backgroundColor: corporation.color,
              color: corporation.text_color,
              width: '100%',
              display: 'inline-flex',
              alignItems: 'center',
              padding: '0',
            },
          }

        tr_props = tr_default_props
        market_props = { style: { borderRight: border_style } }
        if !corporation.floated?
          tr_props[:style][:opacity] = '0.5'
        elsif corporation.share_price&.highlight? &&
          (color = StockMarket::COLOR_MAP[@game.class::STOCKMARKET_COLORS[corporation.share_price.type]])
          market_props[:style][:backgroundColor] = color
          market_props[:style][:color] = contrast_on(color)
        end

        order_props = {
          style: {
            backgroundColor: corporation.color,
            color: corporation.text_color,
          },
        }
        if order.positive?
          operating_order_text = order.to_s
          order_props[:style][:opacity] = '0.6' if @game.round.acted?(corporation)
        end

        logo_props = {
          attrs: { src: logo_for_user(corporation) },
          style: {
            height: '1.1rem',
            width: '1.1rem',
            padding: '3px',
          },
        }

        children = [
          h('td.padded_number', order_props, operating_order_text),
          h(:th, name_props, [h(:img, logo_props), h(:span, { style: { padding: '0 5px' } }, corporation.name)]),
        ]
        @game.players.each do |p|
          sold_props = { style: {} }
          if @game.round.active_step&.did_sell?(corporation, p)
            sold_props[:style][:backgroundColor] = '#9e0000'
            sold_props[:style][:color] = 'white'
          elsif num_shares_of(p, corporation).zero?
            sold_props[:style][:opacity] = '0.5'
          end

          sold_props[:style][:fontWeight] = 'bold' if corporation.president?(p)
          share_holding = num_shares_of(p, corporation).to_s unless corporation.minor?
          share_holding = '*' if corporation.minor? && corporation.president?(p)

          children << h('td.padded_number', sold_props, share_holding || '')
        end

        children << h('td.padded_number', { style: { borderLeft: border_style } },
                      corporation.minor? ? '' : corporation.num_ipo_non_reserved_shares.to_s)
        children << h('td.padded_number',
                      corporation.minor? ? '' : corporation.num_ipo_reserved_shares.to_s) unless @hide_reserved
        children << h('td.padded_number',
                      @game.available_shorts(corporation).to_s) if @game.respond_to?(:available_shorts)
        children << h('td.padded_number', { style: { borderRight: border_style } },
                      "#{corporation.receivership? ? '*' : ''}#{num_shares_of(@game.share_pool, corporation)}")

        children << h('td.padded_number',
                      corporation.par_price ? @game.format_currency(corporation.par_price.price) : '') unless @hide_ipo

        children << h('td.padded_number', market_props,
                      corporation.share_price ? @game.format_currency(corporation.share_price.price) : '')

        children << h('td.padded_number', @game.format_currency(corporation.cash))
        children << h(:td, corporation.trains.map(&:name).join(', '))
        children << h(:td, [
          @game.count_available_tokens(corporation).to_s,
          h(:span, { style: { opacity: '0.6' } }, ' / '),
          corporation.tokens.size.to_s,
        ])

        if @game.total_loans&.nonzero?
          children << h(:td, [
            corporation.loans.size.to_s,
            h(:span, { style: { opacity: '0.6' } }, ' / '),
            @game.maximum_loans(corporation),
          ])
        end

        if @game.total_loans.positive?
          children << h(:td, @game.format_currency(@game.buying_power(corporation, full: true)))
          interest_props = { style: {} }
          unless @game.can_pay_interest?(corporation)
            color = StockMarket::COLOR_MAP[:yellow]
            interest_props[:style][:backgroundColor] = color
            interest_props[:style][:color] = contrast_on(color)
          end
          children << h(:td, interest_props, @game.format_currency(@game.interest_owed(corporation)).to_s)
        end

        children << render_companies(corporation)
        children.concat(render_history(corporation))

        h(:tr, tr_props, children)
      end

      def render_companies(entity)
        h('td.padded_number', entity.companies.map(&:sym).join(', '))
      end

      def render_player_companies
        h(:tr, tr_default_props, [
          h('th.left', { attrs: { colspan: 2 } }, 'Companies'),
          *@game.players.map { |p| render_companies(p) },
        ])
      end

      def render_player_cash
        h(:tr, tr_default_props, [
          h('th.left', { attrs: { colspan: 2 } }, 'Cash'),
          *@game.players.map { |p| h('td.padded_number', @game.format_currency(p.cash)) },
          render_extra_cards,
        ])
      end

      def render_player_value
        h(:tr, tr_default_props, [
          h('th.left', { attrs: { colspan: 2 } }, 'Value'),
          *@game.players.map { |p| h('td.padded_number', @game.format_currency(@game.player_value(p))) },
        ])
      end

      def render_player_liquidity
        h(:tr, tr_default_props, [
          h('th.left', { attrs: { colspan: 2 } }, 'Liquidity'),
          *@game.players.map { |p| h('td.padded_number', @game.format_currency(@game.liquidity(p))) },
        ])
      end

      def render_player_shares
        h(:tr, tr_default_props, [
          h('th.left', { attrs: { colspan: 2 } }, 'Shares'),
          *@game.players.map do |p|
            h('td.padded_number', @game.all_corporations.sum { |c| c.minor? ? 0 : num_shares_of(p, c) })
          end,
        ])
      end

      def render_player_certs
        cert_limit = @game.cert_limit
        props = { style: { color: 'red' } }
        h(:tr, tr_default_props, [
          h('th.left', { attrs: { colspan: 2 } }, 'Certs' + (@game.show_game_cert_limit? ? "/#{cert_limit}" : '')),
          *@game.players.map { |player| render_player_cert_count(player, cert_limit, props) },
        ])
      end

      def render_player_cert_count(player, cert_limit, props)
        num_certs = @game.num_certs(player)
        h('td.padded_number', num_certs > cert_limit ? props : '', num_certs)
      end

      def tr_default_props
        {
          style: {
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
          },
        }
      end

      def table_props
        {
          style: {
            borderCollapse: 'collapse',
            textAlign: 'center',
            whiteSpace: 'nowrap',
          },
        }
      end

      def bottom_th_props(pd = false)
        {
          style: {
            position: 'sticky',
            top: '60px',
            zIndex: 1,
            backgroundColor: (pd ? 'salmon' : color_for(:bg)),
            color: (pd ? 'black' : color_for(:font)),
          },
        }
      end

      private

      def num_shares_of(entity, corporation)
        return corporation.president?(entity) ? 1 : 0 if corporation.minor?

        entity.num_shares_of(corporation, ceil: false)
      end

      def logo_for_user(entity)
        @user&.dig('settings', 'simple_logos') ? entity.simple_logo : entity.logo
      end
    end
  end
end
