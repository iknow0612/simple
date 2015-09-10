##  判断算术优先级
# craete by xiongwei

class Number < Struct.new( :value)
    def precedence
        3
    end

    def bracket( outer_precedence)
        if precedence < outer_precedence
            '(' + to_s + ')'
        else
            to_s
        end
    end

    def to_s
        value.to_s
    end

    def inspect
        "#{self}"
    end
end

class Add < Struct.new( :left, :right)
    def precedence
        2
    end

    def bracket( outer_precedence)
        if precedence < outer_precedence
            '(' + to_s + ')'
        else
            to_s
        end
    end

    def to_s
        left.bracket( precedence) + '+' + right.bracket( precedence)
    end

    def inspect
        "#{self}"
    end
end

class Multiply < Struct.new( :left, :right)
    def precedence
        1
    end

    def bracket( outer_precedence)
        if precedence < outer_precedence
            '(' + to_s + ')'
        else
            to_s
        end
    end

    def to_s
        left.bracket( precedence) + '*' + right.bracket( precedence)
    end

    def inspect
        "#{self}"
    end
end
