# Store map tiles and their neighbors
class Tile
    attr_reader :char, :blocks, :color

    def initialize char, blocks, color='WHITE'
        @char, @blocks, @color = char, blocks, color
        @neighbors = {}
    end

    # Add a key value pair to neighbors
    def add_neighbor k, v
        @neighbors[k] = v
    end

    # Remove all key value pair from neigbors
    def clear_neighbors
        @neighbors = {}
    end

    # Return the number of blocking neighbors
    # NOTE: Make sure neighbors are updated before calling!
    def neighbors_that_block
        # For each value, create a new array of 1s and 0s if the tile blocks
        # or doesn't block respectively. Then, add all of the values, and
        # that is the number of blocking neighbors
        return @neighbors.values.map {|v| v.blocks ? 1 : 0 }.reduce(:+)
    end

    ### Methods that emulate built-in ones

    # To string
    def to_s
        return @char
    end
end
