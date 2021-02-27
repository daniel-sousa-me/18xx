# frozen_string_literal: true

require './lib/engine'

game = Engine::Game.load(ARGF.read, strict: false)

output = {
  players: game.players.map do |p|
  [p.id, {
     name: p.name,
     round_history: p.history.map(&:to_h),
     bankrupt: p.bankrupt,
   }]
end.to_h,
  phases: game.phases
}

puts JSON.pretty_generate(output)
