# Base class for all 'complex' game objects
class Entity
    attr_accessor :pos, :name, :char, :color

    def initialize pos, name, char, color='WHITE'
        @pos, @name, @char, @color = pos, name, char, color
    end

    # Place at certain position
    def place pos
        @pos = pos
    end

    ### Methods that emulate built-in ones

    # To string
    def to_s
        return @name + ' : ' + @char
    end
end

# Gold item
class Gold < Entity
    attr_reader :val

    def initialize pos, val, name='gold', char='$', color='GREEN'
        @pos, @val, @name, @char, @color = pos, val, name, char, color
    end
end

# Player entity
class Player < Entity
    attr_reader :max_life
    attr_accessor :life

    def initialize pos, name, char, color='CYAN'
        @pos, @name, @char, @color = pos, name, char, color
        @life, @max_life = 3, 3
    end

    def get_life_str
        return '♥' * @life
    end
end

# Same thing as an entity, but takes an AI as an argument
class Monster < Entity
    def initialize pos, name, char, color='WHITE', ai
        @pos, @name, @char, @color, @ai = pos, name, char, color, ai
    end

    # Return a direction the monster wants to move in
    def ai_turn
        return @ai.take_turn
    end
end
