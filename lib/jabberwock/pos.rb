# x, y coordinate holder
class Pos
    attr_reader :x, :y

    def initialize x, y
        @x, @y = x, y
    end

    ### Methods that emulate built-in

    # Compare to other positions
    def == pos
       return @x == pos.x && @y == pos.y ? true : false
    end

    # Is equal to other position?
    def eql? pos
        return self == pos
    end

    # To array
    def to_a
        return [@x, @y]
    end

    # To string
    def to_s
        return '(' + @x.to_s + ", " + @y.to_s + ')'
    end
end
