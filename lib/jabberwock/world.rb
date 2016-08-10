require './lib/jabberwock/ai'
require './lib/jabberwock/console'
require './lib/jabberwock/entity'
require './lib/jabberwock/json/handler'
require './lib/jabberwock/pos'
require './lib/jabberwock/tile'

# AI hash for monster creation from JSON
AI = {}
AI['dumbgrid'] = DumbGridAI
AI['dumbdiag'] = DumbDiagAI
AI['dumbomni'] = DumbOmniAI

# Yolk of the game
class World
    attr_reader :width, :height, :entities, :monsters, :player, :state
    attr_accessor :map, :floor, :objects

    def initialize width, height
        @width, @height = width, height

        # Holds all tiles
        @map = Array.new(@width+1) { Array.new(@height+1) }

        @entities = []  # Holds all entities
        @monsters = []  # Holds all monsters
        @objects = []   # Holds all objects

        # Holds the current floor number
        @floor = 0

        # Creates player and stairs for the floor
        @player = Player.new(Pos.new(0, 0), 'Player', '@')
        @stairs = Entity.new(Pos.new(0, 0), 'stairs', '>')

        # Player state
        @state = 'alive'

        # JSON handler
        @json = JSONReader.new

        # Console
        @con = Console.new
    end

    # Clean up map by filtering tiles and altering them based on their neighbors
    def clean_map
        iterate_map do |pos|
            if @map[pos.x][pos.y].neighbors_that_block > 4
                @map[pos.x][pos.y] = Tile.new('#', true, 'GREEN')
            elsif @map[pos.x][pos.y].neighbors_that_block < 2
                @map[pos.x][pos.y] = Tile.new('.', false, 'BLUE')
            end
        end
        iterate_map { |pos| update_neighbors pos }
    end

    # Generator that returns a pos for each map coord
    def iterate_map
        @width.times do |x|
            @height.times do |y|
                yield Pos.new(x, y)
            end
        end
    end

    # Line area surrounding map bounds with a pretty border
    def make_border
        iterate_map { |pos| @map[pos.x][pos.y] = get_border_style pos }
    end

    # Create a blob of random open space
    # NOTE: for better looking results, call clean_map afterwards
    def make_cave
        # Don't waste resources by continuously checking a new instance of tile
        wall = Tile.new('#', true, 'GREEN') # Is used for comparison, not visuals
        2000.times do
            pos = get_random_pos
            if @map[pos.x][pos.y] = wall
                # New instance of a floor tile is needed every time
                @map[pos.x][pos.y] = Tile.new(':', false, 'BLUE')
            end
        end
        # After tiles are created we update neighbors
        iterate_map { |pos| update_neighbors pos }
    end

    # Makes a generic floor, utilizing methods inside of world
    def make_floor
        reset_map
        make_cave
        clean_map
        clean_map
        make_border
        populate
    end

    # Move an entity by a certain ammount (Unless moved into a blocking tile)
    def move_entity entity, dx, dy
        unless @map[entity.pos.x + dx][entity.pos.y - dy].blocks
            entity.place Pos.new(entity.pos.x + dx, entity.pos.y - dy)
        end
    end

    # Each monster should take their turn
    def monster_turn
        @monsters.each do |mon|
            # Get direction and try to move
            dir = mon.ai_turn
            move_entity mon, dir.x, dir.y
            # Check player overlap
            if mon.pos == @player.pos
                @con.add 'You run into a %s!' % mon.name
                @player.life -= 1
                if @player.life == 0
                    @state = 'dead'
                else
                    @monsters.delete mon
                end
            end
        end
    end

    # Player on stairs?
    def on_stairs?
        return @player.pos == @stairs.pos ? true : false
    end

    # Player on a monster?
    def on_monster?
        @monsters.each do |mon|
            if @player.pos == mon.pos
                return true
            end
        end
        return false
    end

    # Player on a monster?
    def on_object?
        @objects.each do |obj|
            if @player.pos == obj.pos
                return true
            end
        end
        return false
    end

    # Get a clear position on the map
    def get_clear_pos
        pos = get_random_pos

        until nearby_is_clear(pos) && !@map[pos.x][pos.y].blocks && pos != @player.pos
            pos = get_random_pos
        end

        return pos
    end

    # Place objects and entities around map
    def populate
        @player.place get_clear_pos
        make_monsters
        make_gold
        # @monsters.push(generate_monster 'jubjub', get_clear_pos)
        spawn_stairs
    end

    # Clear map with map.
    def reset_map
        # For each element in @map, then for each element of that element,
        # set it to a tile.
        # NOTE: This IS more compact than if iterate_map was used
        @map.map! { |x| x.map { |y| Tile.new('♣', true, 'GREEN') } }
        @stairs = Entity.new(Pos.new(0,0), 'stairs', '>', 'WHITE')
        @entities = []
        @objects = []
        @monsters = []
    end

    # Mystical magical behind the scenes functions. A.K.A the ugly ones nothing
    # needs to see or use
    private

    # Returns a value that depends on level. the table specifies what
    # value occurs after each level, default is 0.
    def chance_at_level table
        # In case if you couldn't figure out what that means here's an example:
        # input ->        [[25, 6]]
        #       chance ----/    \----- beyond this dungeon level
        # All of the chances are totalled and then the result is
        # the chance at n level / total chance

        table.reverse.each do |pair|
            if @floor >= pair[1] # Level
                return pair[0] # Chance
            end
        end
        return 0
    end

    # Generate a monster based on it's ID in JSON
    def generate_monster id, pos
        return Monster.new(pos,
            @json.get_monster_hash[id]['name'],
            @json.get_monster_hash[id]['char'],
            @json.get_monster_hash[id]['color'],
            AI[@json.get_monster_hash[id]['ai']].new)
    end

    # Take coordinate pair, return a border tile
    def get_border_style pos
        # This code makes my eyes burn. Thank god it's private and no one
        # needs to see it to use this class.
        return case [pos.x, pos.y]
        when [0, 0]                    then Tile.new('┌', true, 'BLUE') # Top left
        when [0, @height - 1]          then Tile.new('└', true, 'BLUE') # Bottom left
        when [@width - 1, @height - 1] then Tile.new('┘', true, 'BLUE') # Bottom right
        when [@width - 1, 0]           then Tile.new('┐', true, 'BLUE') # Top right
        else
            if pos.x == 0 || pos.x == @width-1     then Tile.new('│', true, 'BLUE')  # Left/Right
            elsif pos.y == 0 || pos.y == @height-1 then Tile.new('─', true, 'BLUE')  # Top/Bottom
            else @map[pos.x][pos.y] end                                      # Everything else
        end
    end

    # Recursive function to return a random position on the map
    def get_random_pos
        pos = Pos.new(rand(@width/2)+rand(@width/2), rand(@height/2)+rand(@height/2))

        # Fringe cases that should be filtered out
        while pos.x <= 0 || pos.y <= 0 && @map[pos.x][pos.y].blocks
            pos = get_random_pos
        end

        return pos
    end

    def make_gold
        rand(@floor).times { @objects.push(Gold.new(get_clear_pos, rand(@floor) + @floor)) }
    end

    # Create monsters from JSON based on their chance hash for the current floor
    def make_monsters
        # Chance of each monster
        monster_chances = {}

        # Create hash with the ID as the key and chance table as value
        @json.get_monster_hash.keys.each do |id|
            monster_chances[@json.get_monster_hash[id]['id']] =
            chance_at_level(@json.get_monster_hash[id]['chance'])
        end

        # Define the number of monsters for the current floor
        num_monsters = (@floor * 2) + 8

        num_monsters.times do |i|
            # Choose a monster
            choice = random_chance_choice(monster_chances)

            # Make it and add monster to object list
            @monsters << generate_monster(choice, get_clear_pos)
        end
    end

    # Check if nearby tiles are clear
    def nearby_is_clear pos
        return @map[pos.x][pos.y].neighbors_that_block > 4 ? false : true
    end

    # Choose one option from a hash of chances, returning its key
    def random_chance_choice chances_hash
        chances = chances_hash.values
        strings = chances_hash.keys

        return strings[random_choice_index chances]
    end

    # Choose one option from list of chances, returning its index
    def random_choice_index chances

        # The dice will land on some number between 1 and the sum of the chances
        dice = rand(chances.reduce(:+)) + 1

        # Go through all chances, keeping the sum so far
        running_sum = 0
        choice = 0

        chances.each do |i|
            running_sum += i

            # See if the dice landed in the part that corresponds to this choice
            if dice <= running_sum
                return choice
            end
            choice += 1
        end
    end

    # Put stairs on the map
    def spawn_stairs
        @stairs.place get_clear_pos
        @entities << @stairs
    end

    # Update the neighbors of a certain position
    def update_neighbors pos
        # This tile var points to the one inside of map.
        tile = @map[pos.x][pos.y]
        tile.clear_neighbors
        # Yuck! Ugly code ahead.
        # Basically, check all directions and if a tile is there,
        # add it to the referenced tile's @neihbors hash
        if @map[pos.x][pos.y-1]   then tile.add_neighbor('N',  @map[pos.x][pos.y-1])   end
        if @map[pos.x+1][pos.y-1] then tile.add_neighbor('NE', @map[pos.x+1][pos.y-1]) end
        if @map[pos.x+1][pos.y]   then tile.add_neighbor('E',  @map[pos.x+1][pos.y])   end
        if @map[pos.x+1][pos.y+1] then tile.add_neighbor('SE', @map[pos.x+1][pos.y+1]) end
        if @map[pos.x][pos.y+1]   then tile.add_neighbor('S',  @map[pos.x][pos.y+1])   end
        if @map[pos.x-1][pos.y+1] then tile.add_neighbor('SW', @map[pos.x-1][pos.y+1]) end
        if @map[pos.x-1][pos.y]   then tile.add_neighbor('W',  @map[pos.x-1][pos.y])   end
        if @map[pos.x-1][pos.y-1] then tile.add_neighbor('NW', @map[pos.x-1][pos.y-1]) end
    end
end
