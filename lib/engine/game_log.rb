# frozen_string_literal: true

module Engine
  class GameLog < Array
    def initialize(game)
      @game = game
      @last_action_id = 0
    end

    def message!(action)
      # TODO: Don't repeat this
      self << { type: :undo } if action.id && @last_action_id + 1 < action.id
      @last_action_id = action.id if action.id

      # TODO: Make each type a different "Entry" class
      self << {
        type: :message,
        id: action.id,
        created_at: action.created_at,
        username: action.entity&.name,
        message: action.message,
      }
    end

    def action!(message)
      acted!(nil, message)
    end

    def acted!(entity, message)
      return self << message unless (action = @game&.current_action)

      entity ||= action.entity
      entity_list = []

      while entity
        entity_list << entity.name
        break if entity.player?

        entity = entity.owner
      end

      if action.id && @last_action_id == action.id
        return self << "#{entity.name} #{message}" if entity

        return self << message
      end

      self << { type: :undo } if action.id && @last_action_id + 1 < action.id
      @last_action_id = action.id if action.id

      self << {
        type: :action,
        id: action.id,
        created_at: action.created_at,
        entity_list: entity_list,
        user: (@game.player_by_id(action.user)&.name || 'Owner' if action.user),
        message: message,
      }
    end

    def queue!
      old_size = size
      yield
      @queued_log = pop(size - old_size)
    end

    def flush!
      @queued_log.each { |l| self << l }
      @queued_log = []
    end
  end
end
