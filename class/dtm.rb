## 图灵机的模拟
## create by xiongwei

## 模拟纸带
class Tape < Struct.new( :left, :middle, :right, :blank)
    def inspect
        "#<Tape #{left.join}(#{middle})#{right.join}>"
    end

    def write( character)
        Tape.new( left, character, right, blank)
    end

    def move_head_left
        Tape.new( left[ 0..-2], left.last || blank, [ middle] + right, blank)
    end

    def move_head_right
        Tape.new( left + [ middle], right.first || blank, right.drop( 1), blank)
    end
end

## 图灵机的配置: 一个状态和一条纸带的组合
class TMConfiguration < Struct.new( :state, :tape)
end
# 规则
class TMRule < Struct.new( :state, :character, :next_state, :write_character, :direction)
    def applies_to?( configuration)
        state == configuration.state && character == configuration.tape.middle
    end

    def follow( configuration)
        TMConfiguration.new( next_state, next_tape( configuration))
    end

    def next_tape( configuration)
        written_tape = configuration.tape.write( write_character)

        case direction
        when :left
            written_tape.move_head_left
        when :right
            written_tape.move_head_right
        end
    end
end

## 确定性图灵机
# Rulebook
class DTMRulebook < Struct.new( :rules)
    def next_configuration( configuration)
        rule_for( configuration).follow( configuration)
    end

    def rule_for( configuration)
        rules.detect { | rule| rule.applies_to?( configuration) }
    end

    def accepts_to?( configuration)
        rule_for( configuration)
    end
end
# 封装为 DTM
class DTM < Struct.new( :current_configuration, :accept_state, :rulebook)
    def accepting?
        accept_state.include?( current_configuration.state)
    end

    def step
        self.current_configuration = rulebook.next_configuration( current_configuration)
    end

    def run
        step until accepting? || stuck?
    end

    def stuck?
        !accepting? && !rulebook.accepts_to?( current_configuration)
    end
end
