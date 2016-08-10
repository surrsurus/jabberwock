require './lib/jabberwock/pos'

# Basic AI that all AIs originate from
class GenericAI
    def take_turn
        return Pos.new(0, 0)
    end
end

# Dumb AI that randomly picks a direction to move in based on a possible
# list of movement directions in @vectors
# NOTE: This is a template class
class DumbAI < GenericAI
    # Ready all possible directions of movement
    def initialize
        @vectors = [Pos.new(0, 0)]
    end

    # Return a random direction to move in
    def simulate_movement
        r = rand(@vectors.size + 1)
        if r == @vectors.size
            return Pos.new(0, 0)
        else
            return @vectors[r]
        end
    end

    # Note that AIs don't return a position they want to move to,
    # but a dx, dy that they want to add to their current position
    def take_turn
        return simulate_movement
    end
end

# Dumb AI that follows a strict up-down movement scheme
class DumbGridAI < DumbAI
    # Replace possible direction vectors with strict grid movement
    def initialize
        @vectors = [Pos.new(1, 0), Pos.new(0, 1), Pos.new(-1, 0), Pos.new(0, -1)]
    end
end

# Dumb AI variant that moves diagonally
class DumbDiagAI < DumbAI
    # Replace possible direction vectors with diagonal ones
    def initialize
        @vectors = [Pos.new(1, 1), Pos.new(-1, 1), Pos.new(-1, -1), Pos.new(1, -1)]
    end
end

# Dumb AI variant that moves in all directions
class DumbOmniAI < DumbAI
    # Replace possible direction vectors with diagonal ones
    def initialize
        @vectors = [Pos.new(1, 1), Pos.new(-1, 1), Pos.new(-1, -1), Pos.new(1, -1),
                    Pos.new(1, 0), Pos.new(0, 1), Pos.new(-1, 0), Pos.new(0, -1)]
    end
end
