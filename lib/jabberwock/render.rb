require 'ncursesw'

# Renderer powered by ncurses
class Render
    def initialize
        @s = Ncurses.initscr  # Start screen
        Ncurses.cbreak        # Get keys as soon as they're pressed
        Ncurses.noecho        # Don't display keys that are prssed
        Ncurses.curs_set(0)   # Cursor display mode. 0 - Invisible, 1 - Slightly visible, 2 - Visible

        Ncurses.start_color   # Enable color

        # Initializer all colors
        Ncurses.init_pair(1, 2, 0) # Green
        Ncurses.init_pair(2, 3, 0) # Orange
        Ncurses.init_pair(3, 4, 0) # Blue
        Ncurses.init_pair(4, 5, 0) # Purple
        Ncurses.init_pair(5, 6, 0) # Cyan
        Ncurses.init_pair(6, 7, 0) # White
        Ncurses.init_pair(7, 1, 0) # Red
        Ncurses.init_pair(8, 8, 0) # Black

        # Create a new hash to store colors and the associated color
        @colormap = Hash.new(Ncurses.COLOR_PAIR(6))
        @colormap['GREEN']  = Ncurses.COLOR_PAIR(1)
        @colormap['ORANGE'] = Ncurses.COLOR_PAIR(2)
        @colormap['BLUE']   = Ncurses.COLOR_PAIR(3)
        @colormap['PURPLE'] = Ncurses.COLOR_PAIR(4)
        @colormap['CYAN']   = Ncurses.COLOR_PAIR(5)
        @colormap['WHITE']  = Ncurses.COLOR_PAIR(6)
        @colormap['RED']    = Ncurses.COLOR_PAIR(7)
        @colormap['BLACK']  = Ncurses.COLOR_PAIR(8)
    end

    # Backspace character
    def bs
        Ncurses::KEY_BACKSPACE
    end

    # Clear the screen
    def clear
        Ncurses.clear
    end

    # Stop ncurses
    def close
        Ncurses.endwin
    end

    # Get keypresses
    def getc
        return Ncurses.stdscr.getch.chr
    end

    # Place string with color based on hash
    def place x, y, s, c='WHITE'
        @s.attrset @colormap[c]
        @s.mvaddstr y, x, s.to_s
    end

    # Redraw screen
    def redraw
        Ncurses.refresh
    end
end
