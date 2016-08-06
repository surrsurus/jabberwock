require 'json'

# Interpret JSON data and give hashes based on parsed data
class JSONReader
    def initialize
        # Load monster data from file
        @monster_data = File.read('./lib/jaberwock/json/monster.json')
    end

    # Return a hash of parsed data for monster.json
    def get_monster_hash
        return JSON.parse @monster_data
    end
end
