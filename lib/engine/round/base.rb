# frozen_string_literal: true

if RUBY_ENGINE == 'opal'
  require_tree '../step'
else
  require 'require_all'
  require_rel '../step'
end

module Engine
  module Round
    class Base
      attr_reader :entities, :entity_index, :round_num, :steps
      attr_accessor :last_to_act, :pass_order, :at_start

      DEFAULT_STEPS = [
        Step::EndGame,
        Step::Message,
        Step::Program,
      ].freeze

      def initialize(game, steps, **opts)
        @game = game
        @log = game.log
        @entity_index = 0
        @round_num = opts[:round_num] || 1
        @entities = select_entities
        @last_to_act = nil
        @pass_order = []

        @steps = (DEFAULT_STEPS + steps).map do |step, step_opts|
          step_opts ||= {}
          step = step.new(@game, self, **step_opts)
          step.round_state.each do |key, value|
            singleton_class.class_eval { attr_accessor key }
            send("#{key}=", value)
          end
          step.setup
          step
        end
      end

      def setup; end

      def name
        raise NotImplementedError
      end

      def select_entities
        raise NotImplementedError
      end

      def current_entity
        active_entities[0]
      end

      def description
        active_step.description
      end

      def active_entities
        active_step&.active_entities || []
      end

      # TODO: This is deprecated
      def can_act?(entity)
        active_step&.current_entity == entity
      end

      def teleported?(_entity)
        false
      end

      def pass_description
        active_step.pass_description
      end

      def process_action(action)
        type = action.type
        clear_cache!

        before_process(action)

        step = @steps.find do |s|
          next unless s.active?

          process = s.actions(action.entity).include?(type)
          blocking = s.blocking?
          if blocking && !process
            raise GameError, "Blocking step #{s.description} cannot process action #{action['id']}"
          end

          blocking || process
        end
        raise GameError, "No step found for action #{type} at #{action.id}: #{action.to_h}" unless step

        step.acted = true
        step.send("process_#{action.type}", action)

        @at_start = false

        after_process_before_skip(action)
        skip_steps
        clear_cache!
        after_process(action)
      end

      def actions_for(entity)
        actions = []
        return actions unless entity

        @steps.each do |step|
          next unless step.active?

          available_actions = step.actions(entity)
          actions.concat(available_actions)
          break if step.blocking?
        end
        actions.uniq
      end

      def step_for(entity, action)
        return unless entity

        @steps.find { |step| step.active? && step.actions(entity).include?(action) }
      end

      def active_step(entity = nil)
        return @steps.find { |step| step.active? && step.actions(entity).any? } if entity

        @active_step ||= @steps.find { |step| step.active? && step.blocking? }
      end

      def auto_actions
        active_step&.auto_actions(current_entity)
      end

      def finished?
        !active_step
      end

      def goto_entity!(entity)
        @entity_index = @entities.find_index(entity)
      end

      def next_entity_index!
        # If overriding, make sure to call @game.next_turn!
        @game.next_turn!
        @entity_index = (@entity_index + 1) % @entities.size
      end

      def acted?(entity)
        @entities.take(@entity_index + 1).any?(entity)
      end

      def reset_entity_index!
        @entity_index = 0
      end

      def clear_cache!
        @active_step = nil
      end

      def operating?
        false
      end

      def stock?
        false
      end

      private

      def skip_steps
        @steps.each do |step|
          next if !step.active? || !step.blocks? || @entities[@entity_index]&.closed?
          break if step.blocking?

          step.skip!
        end
      end

      def before_process(_action); end

      def after_process_before_skip(_action); end

      def after_process(_action); end
    end
  end
end
