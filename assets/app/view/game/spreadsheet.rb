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

        @players = @game.players.reject(&:bankrupt)
        @hide_ipo = @game.all_corporations.reject(&:minor?).all?(&:always_market_price)
        @hide_reserved = @game.all_corporations.reject(&:minor?).flat_map(&:shares).all?(&:buyable)
        @show_corporation_size = @game.all_corporations.any? { |c| @game.show_corporation_size?(c) }
        @hide_companies = @game.all_corporations.reject(&:minor?).flat_map(&:companies).none?
        @hide_connection_runs = @game.connection_runs.none?

        children = []
        children << render_table

        h('div#spreadsheet', { style: {
          overflow: 'auto',
        } }, children.compact)
      end

      def render_table
        h(:table, { style: {
          margin: '1rem 0 1.5rem 0',
          borderCollapse: 'collapse',
          textAlign: 'center',
          whiteSpace: 'nowrap',
        } }, [
          h(:thead, render_title),
          h(:tbody, render_corporations),
          h(:thead, [
            h(:tr, { style: { height: '1rem' } }, ''),
          ]),
          h(:tbody, [
            render_player_cash,
            render_player_value,
            render_player_liquidity,
            render_player_shares,
            render_player_companies,
            render_player_certs,
          ]),
          h(:thead, [
            h(:tr, { style: { height: '1rem' } }, ''),
          ]),
          *render_player_history,
        ])
        # TODO: consider adding OR information (could do both corporation OR revenue and player change in value)
        # TODO: consider adding train availability
      end

      def or_history(corporations)
        corporations.flat_map { |c| c.operating_history.keys }.uniq.sort
      end

      def render_history_titles(corporations)
        or_history(corporations).map { |turn, round| h(:th, @game.or_description_short(turn, round)) }
      end

      def render_player_history
        # OR history should exist in all
        zebra_row = true
        last_values = nil
        @game.players.first.history.map do |h|
          values = @game.players.map do |p|
            p.history.find { |h2| h2.round == h.round }.value
          end
          next if values == last_values

          last_values = values
          zebra_row = !zebra_row
          h(:tr, zebra_props(zebra_row), [
            h('th.left', h.round),
            *values.map { |v| h('td.padded_number', @game.format_currency(v)) },
          ])
        end.compact.reverse
      end

      def render_history(corporation)
        hist = corporation.operating_history
        if hist.empty?
          # This is a company that hasn't floated yet
          []
        else
          or_history(@game.all_corporations).map do |x|
            round = @game.or_description_short(*x)

            h(:td, hist[x] ? [render_dividend(round, hist[x], corporation)] : '')
          end
        end
      end

      def render_title
        th_props = lambda do |cols, alt_bg = false, border_right = true|
          props = zebra_props(alt_bg)
          props[:attrs] = { colspan: cols }
          props[:style][:padding] = '0.3rem'
          props[:style][:borderRight] = "1px solid #{color_for(:font2)}" if border_right
          props[:style][:fontSize] = '1.1rem'
          props[:style][:letterSpacing] = '1px'
          props
        end

        or_history_titles = render_history_titles(@game.all_corporations)

        highlight_props = {
          style: {
            background: 'salmon',
            color: 'black',
          },
        }

        extra = []
        extra << h(:th, render_sort_link('Loans', :loans)) if @game.total_loans&.nonzero?
        extra << h(:th, render_sort_link('Shorts', :shorts)) if @game.respond_to?(:available_shorts)
        extra << h(:th, render_sort_link('Size', :size)) if @show_corporation_size
        extra << h(:th, 'Companies') unless @hide_companies

        top =
          h(:tr, [
            h(:th, ''),
            h(:th, th_props[@game.players.size], 'Players'),
            h(:th, th_props[@hide_reserved ? 2 : 3, true], 'Shares'),
            h(:th, th_props[@hide_ipo ? 1 : 2], 'Prices'),
            h(:th, th_props[4 + extra.size, true, false], 'Corporation'),
            h(:th, ''),
            h(:th, th_props[or_history_titles.size + (@hide_connection_runs ? 0 : 2), false, false], 'OR History'),
          ])

        bottom = [h(:th, { style: { paddingBottom: '0.3rem' } }, render_sort_link('SYM', :id))]

        @players.each do |p|
          highlight = if @game.round.is_a?(Engine::Round::Stock)
                        @game.round.current_entity == p
                      else
                        p == @game.priority_deal_player
                      end

          bottom << h('th.name.nowrap.right',
                      highlight ? highlight_props : {}, render_sort_link(p.name, p.id))
        end

        bottom << h(:th, @game.ipo_name)
        bottom << h(:th, @game.ipo_reserved_name) unless @hide_reserved
        bottom << h(:th, 'Market')

        if @hide_ipo
          bottom << h(:th, render_sort_link('Price', :share_price))
        else
          bottom << h(:th, render_sort_link(@game.ipo_name, :par_price)) unless @hide_ipo
          bottom << h(:th, render_sort_link('Market', :share_price))
        end

        bottom << h(:th, render_sort_link('Cash', :cash))
        bottom << h(:th, render_sort_link('Order', :order))
        bottom << h(:th, 'Trains')
        bottom << h(:th, 'Tokens')

        bottom = bottom.concat(extra)

        bottom << h(:th, '')
        bottom << h(:th, { attrs: { colSpan: 2 } }, 'Conn') unless @hide_connection_runs
        bottom = bottom.concat(or_history_titles)

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

      def render_corporations
        sorted_corporations.map.with_index do |corp_array, index|
          render_corporation(*corp_array, index)
        end
      end

      def sorted_corporations
        floated_corporations = @game.round.entities

        result = @game.all_corporations.reject(&:closed?).select { |c| c.minor? || c.ipoed }
        result = result.sort.each.with_index.map do |c, order|
          operating_order = (floated_corporations.find_index(c) || -1) + 1
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
                 else
                   @game.player_by_id(@spreadsheet_sort_by)&.num_shares_of(corporation)
                 end
          [main, corporation]
        end

        result.reverse! if @spreadsheet_sort_order == 'DESC'
        result
      end

      def render_corporation(corporation, order, index)
        border_style = "1px solid #{color_for(:font2)}"

        name_props =
          {
            style: {
              background: corporation.color,
              color: corporation.text_color,
            },
        }

        tr_props = zebra_props(index.odd?)
        market_props = { style: { borderRight: border_style } }
        if !corporation.floated?
          tr_props[:style][:opacity] = '0.6'
        elsif corporation.share_price&.highlight? &&
          (color = StockMarket::COLOR_MAP[@game.class::STOCKMARKET_COLORS[corporation.share_price.type]])
          market_props[:style][:backgroundColor] = color
          market_props[:style][:color] = contrast_on(color)
        end

        order_props = { style: { paddingLeft: '1.2em' } }
        if order.positive?
          order_text = order.to_s
          order_text += '*' if @game.round.acted?(corporation)
        end

        children = [h(:th, name_props, corporation.name)]
        @players.each do |p|
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
                      corporation.num_ipo_non_reserved_shares.to_s)
        children << h('td.padded_number',
                      corporation.num_ipo_reserved_shares.to_s) unless @hide_reserved
        children << h('td.padded_number', { style: { borderRight: border_style } },
                      "#{corporation.receivership? ? '*' : ''}#{num_shares_of(@game.share_pool, corporation)}")

        children << h('td.padded_number',
                      corporation.par_price ? @game.format_currency(corporation.par_price.price) : '') unless @hide_ipo

        children << h('td.padded_number', market_props,
                      corporation.share_price ? @game.format_currency(corporation.share_price.price) : '')
        children << h('td.padded_number', @game.format_currency(corporation.cash))
        children << h('td.left', order_props, order_text)
        children << h(:td, corporation.trains.map(&:name).join(', '))
        children << h(:td, "#{corporation.tokens.map { |t| t.used ? 0 : 1 }.sum} / #{corporation.tokens.size}")

        if @game.total_loans&.nonzero?
          children << h(:td, "#{corporation.loans.size} / #{@game.maximum_loans(corporation)}")
        end
        children << h(:td, @game.available_shorts(corporation).to_s) if @game.respond_to?(:available_shorts)
        if @show_corporation_size
          children << h(:td, @game.show_corporation_size?(corporation) ? corporation.total_shares.to_s : '')
        end

        children << render_companies(corporation) unless @hide_companies
        children << h(:th, name_props, corporation.name)
        unless @hide_connection_runs
          if @game.connection_runs[corporation]
            round = @game.or_description_short(*@game.connection_runs[corporation][:turn])
            children << h(:td, round)
            children << h(:td, [render_dividend(round, @game.connection_runs[corporation][:info], corporation)])
          else
            children << h(:td, '')
            children << h(:td, '')
          end
        end
        children = children.concat(render_history(corporation))

        h(:tr, tr_props, children)
      end

      def render_companies(entity)
        h(:td, entity.companies.map(&:sym).join(', '))
      end

      def render_player_companies
        h(:tr, zebra_props, [
          h(:th, 'Companies'),
          *@game.players.map { |p| render_companies(p) },
        ])
      end

      def render_player_cash
        h(:tr, zebra_props, [
          h('th.left', 'Cash'),
          *@game.players.map { |p| h('td.padded_number', @game.format_currency(p.cash)) },
          h(:td, { style: { backgroundColor: color_for(:bg) } }, ''),
          h(:td, { style: { backgroundColor: color_for(:bg), color: color_for(:font), position: 'relative' } },
            [h(:div, { style: { position: 'absolute' } }, [h(Bank, game: @game)])]),
        ])
      end

      def render_player_value
        h(:tr, zebra_props(true), [
          h('th.left', 'Value'),
          *@game.players.map { |p| h('td.padded_number', @game.format_currency(@game.player_value(p))) },
        ])
      end

      def render_player_liquidity
        h(:tr, zebra_props, [
          h('th.left', 'Liquidity'),
          *@game.players.map { |p| h('td.padded_number', @game.format_currency(@game.liquidity(p))) },
        ])
      end

      def render_player_shares
        h(:tr, zebra_props(true), [
          h('th.left', 'Shares'),
          *@game.players.map do |p|
            h('td.padded_number', @game.all_corporations.sum { |c| c.minor? ? 0 : num_shares_of(p, c) })
          end,
        ])
      end

      def render_player_certs
        cert_limit = @game.cert_limit
        props = { style: { color: 'red' } }
        h(:tr, zebra_props(true), [
          h('th.left', "Certs/#{cert_limit}"),
          *@game.players.map { |player| render_player_cert_count(player, cert_limit, props) },
        ])
      end

      def render_player_cert_count(player, cert_limit, props)
        num_certs = @game.num_certs(player)
        h('td.padded_number', num_certs > cert_limit ? props : '', num_certs)
      end

      def render_dividend(round, info, corporation)
        kind = info.dividend.kind
        revenue = info.revenue.abs.to_s

        props = {
          style: {
            opacity: case kind
                     when 'withhold'
                       '0.5'
                     when 'half'
                       '0.75'
                     else
                       '1.0'
                     end,
            textDecorationLine: kind == 'half' ? 'underline' : '',
            textDecorationStyle: kind == 'half' ? 'dotted' : '',
          },
        }

        if info.dividend&.id&.positive?
          link_h = history_link(revenue,
                                "Go to run #{round} of #{corporation.name}",
                                info.dividend.id - 1)
          h(:span, props, [link_h])
        else
          h(:span, props, revenue)
        end
      end

      def zebra_props(alt_bg = false)
        factor = Native(`window.matchMedia('(prefers-color-scheme: dark)').matches`) ? 0.9 : 0.5
        {
          style: {
            backgroundColor: alt_bg ? convert_hex_to_rgba(color_for(:bg2), factor) : color_for(:bg2),
            color: color_for(:font2),
          },
        }
      end

      private

      def num_shares_of(entity, corporation)
        return corporation.president?(entity) ? 1 : 0 if corporation.minor?

        entity.num_shares_of(corporation, ceil: false)
      end
    end
  end
end
