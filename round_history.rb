# frozen_string_literal: true

require './lib/engine'

game = Engine::Game.load(ARGF.read, strict: false)

puts game.players.map do |p|
  [p, p.history.map(&:to_h)]
end.to_h

