# Turn $VERBOSE to true for some better debugging
# $VERBOSE = true

# $: << File.join(File.dirname(__FILE__),"./lib/")

require './lib/jabberwock'

j = Jabberwock.new
j.interrupt_screen ['How To Play', '',
                        'Press ">" to go down stairs',
                        'Press "q" to quit at anytime',
                        'Walk over money to pick it up!',
                        'Avoid enemies; you only have 3 lives!',
                        'Try to get the highest score possible!', '',
                        'Movement:',
                        '                        k or 8',
                        '                          ^',
                        '                  y or 7  |  u or 9',
                        '                       \  |  /',
                        '                        \   /',
                        '              h or 4 <--  +  --> l or 6',
                        '                        /   \\',
                        '                       /  |  \\',
                        '                  b or 1  |  n or 3',
                        '                          v',
                        '                        j or 2', '', '',
                        'Press any key to continue...']
j.new_game
j.play
j.quit
