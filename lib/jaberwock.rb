require './lib/jaberwock/console'
require './lib/jaberwock/render'
require './lib/jaberwock/world'

## Size constants
# Standard terminal size
MAX_WIDTH  = 80
MAX_HEIGHT = 24

# Size of map
MAP_WIDTH  = 80
MAP_HEIGHT = 23

# Console area is the difference between max and map
# Can be set to 0 to disable console
CONSOLE_HEIGHT = MAX_HEIGHT - MAP_HEIGHT

## Keymap
# Define movement keys
DIR_MAP = {}
DIR_MAP['N']  = ['8', 'k']
DIR_MAP['NE'] = ['9', 'u']
DIR_MAP['E']  = ['6', 'l']
DIR_MAP['SE'] = ['3', 'n']
DIR_MAP['S']  = ['2', 'j']
DIR_MAP['SW'] = ['1', 'b']
DIR_MAP['W']  = ['4', 'h']
DIR_MAP['NW'] = ['7', 'y']

## Actions
ACT_MAP = {}
ACT_MAP['GO DOWN STAIRS'] = ['>']
ACT_MAP['QUIT'] = ['q']
ACT_MAP['DEBUG REMAKE MAP'] = ['r']

# Game engine
class Jaberwock
    def initialize
        # Rendering engine
        @ren = Render.new

        # New world object to manipulate
        @wld = World.new(MAP_WIDTH, MAP_HEIGHT)

        # Console
        @con = Console.new

        # Score
        @score = 0
    end

    # Render all game entities. Should not be delegated to any other object
    def draw
        # Map
        @wld.iterate_map { |pos| @ren.place pos.x, pos.y, @wld.map[pos.x][pos.y].char, @wld.map[pos.x][pos.y].color }

        # Things
        @wld.entities.each { |e| @ren.place e.pos.x, e.pos.y, e.char, e.color }
        @wld.objects.each  { |o| @ren.place o.pos.x, o.pos.y, o.char, o.color }
        @wld.monsters.each { |m| @ren.place m.pos.x, m.pos.y, m.char, m.color }

        # Player
        @ren.place @wld.player.pos.x, @wld.player.pos.y, @wld.player.char, @wld.player.color

        # Console
        CONSOLE_HEIGHT.times { |y| @wld.width.times { |i| @ren.place i, MAX_HEIGHT - y - 1, ' '} }
        CONSOLE_HEIGHT.times { |y| @ren.place 0, MAX_HEIGHT - y - 1, @con.get(y)}

        @ren.place MAX_WIDTH - 15, MAP_HEIGHT - 1, '[ Floor: %d ]' % @wld.floor, 'BLUE'
        @ren.place 3, MAP_HEIGHT - 1, '[ ' + (' ' * @wld.player.max_life) + ' ]', 'BLUE'
        @ren.place 5, MAP_HEIGHT - 1, @wld.player.get_life_str, 'RED'

        # Always put after finished placing
        @ren.redraw
    end

    # Handle keypresses
    def handle
        c = @ren.getc

        @turns += 1

        # Handle movement keys
        # If direction map for a direction key contains the key pressed,
        # go that way
        if DIR_MAP['W'].include? c
            @wld.move_entity @wld.player, -1, 0
        elsif DIR_MAP['S'].include? c
            @wld.move_entity @wld.player, 0, -1
        elsif DIR_MAP['N'].include? c
            @wld.move_entity @wld.player, 0, 1
        elsif DIR_MAP['E'].include? c
            @wld.move_entity @wld.player, 1, 0
        elsif DIR_MAP['NW'].include? c
            @wld.move_entity @wld.player, -1, 1
        elsif DIR_MAP['NE'].include? c
            @wld.move_entity @wld.player, 1, 1
        elsif DIR_MAP['SW'].include? c
            @wld.move_entity @wld.player, -1, -1
        elsif DIR_MAP['SE'].include? c
            @wld.move_entity @wld.player, 1, -1

        # Quit
        elsif ACT_MAP['QUIT'].include? c
            @exit = true

        # Map reset
        elsif ACT_MAP['DEBUG REMAKE MAP'].include? c
            @wld.make_floor

        # Floor change
        elsif ACT_MAP['GO DOWN STAIRS'].include? c
            if @wld.on_stairs?
                @wld.floor += 1
                @wld.make_floor
                @con.clear
                @con.add 'You venture further into the forest...'
            end
        end

        # Let monsters take turns
        @wld.monster_turn

        # Pick up objects if possible
        # NOTE: Probably not the best idea to be checking every time a key is pressed
        @wld.objects.each do |obj|
            if obj.pos == @wld.player.pos
                @score += obj.val
                @con.add 'You picked up %d gold!' % obj.val
                @wld.objects.delete obj
            end
        end
    end

    # Create a basic screen with messages
    def interrupt_screen messages
        @ren.clear

        # Draw messages
        messages.each_with_index do |msg, y|
            @ren.place 2, y + 1, msg, 'WHITE'
        end

        # Continue when any key is pressed
        c = @ren.getc
        if c == nil
            sleep 0.2
        end
    end

    # Initialize a new game
    def new_game
        @turns = 0
        @wld.floor = 1
        @exit = false
        @wld.make_floor
    end

    # Starts the game loop. Finishes when @exit is true
    def play
        begin
            until @exit
                draw
                handle
                if @wld.state == 'dead'
                    interrupt_screen [
                        'You died!', '',
                        'You lasted %d turns' % @turns,
                        'You you died on floor %d' % @wld.floor,
                        'You you had %d gold' % @score, '', '',
                        'Press any key to continue...'
                    ]
                    quit
                end
            end
        rescue => err
            @ren.close
            p ex.class, ex.message, ex.backtrace
        end
    end

    # Clean up and quit
    def quit
        @ren.close
        puts 'Goodbye!'
        exit 0
    end
end
