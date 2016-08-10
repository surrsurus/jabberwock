# Console for storing messages
class Console
    def initialize
        # Create class object so that all instances of Console
        # have access to the same variable
        @@messages = ['Welcome...']
    end

    # Return elements in reverse order
    def get n
        return @@messages.size - 1 - n < 0 ? " " : @@messages[n - 1]
    end

    # Add to messages
    def add msg
        @@messages << msg
    end

    # Clear all items from messages
    def clear
        @@messages = []
    end
end
