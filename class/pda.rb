## 下推自动机
## create by xiongwei

# 栈类实现
class Stack < Struct.new( :contents)
    def push( character)
        Stack.new( [character] + contents)
    end

    def pop
        Stack.new( contents.drop( 1))
    end

    def top
        contents.first
    end

    def inspect
        "#<Stack (#{top})#{contents.drop(1).join}>"
    end
end
# 配置存储（一个状态和一个栈）
class PDAConfiguration < Struct.new( :state, :stack)
    # 阻塞状态
    STUCK_STATE = Object.new

    def stuck
        PDAConfiguration.new( STUCK_STATE, stack)
    end

    def stuck?
        state == STUCK_STATE
    end
end
# 状态规则
class PDARule < Struct.new( :state, :character, :next_state,
                            :pop_character, :push_characters)
    def applies_to?( configuration, character)
        self.state == configuration.state &&
            self.pop_character == configuration.stack.top &&
            self.character == character
    end

    def follow( configuration)
        PDAConfiguration.new( next_state, next_stack( configuration))
    end

    def next_stack( configuration)
        popped_stack = configuration.stack.pop

        push_characters.reverse.
            inject( popped_stack) { |stack, character| stack.push(character) }
    end
end

## 确定性下推自动机
# 规则手册
class DPDARulebook < Struct.new( :rules)
    def next_configuration( configuration, character)
        rule_for( configuration, character).follow( configuration)
    end

    def rule_for( configuration, character)
        rules.detect { |rule| rule.applies_to?( configuration, character) }
    end

    # 添加自由移动
    def applies_to?( configuration, character)
        !rule_for( configuration, character).nil?
    end

    def follow_free_moves( configuration)
        if applies_to?( configuration, nil)
            follow_free_moves( next_configuration( configuration, nil))
        else
            configuration
        end
    end
end
# DPDA
class DPDA < Struct.new( :current_configuration, :accept_states, :rulebook)
    def accepting?
        accept_states.include?( current_configuration.state)
    end

    def read_character( character)
        self.current_configuration = (next_configuration( character))
    end

    def read_string( string)
        string.chars.each do | character|
            read_character( character) unless stuck?
        end
    end

    # 提供对自由移动的支持
    def current_configuration
        rulebook.follow_free_moves( super)
    end

    # 提供对阻塞状态的支持
    def next_configuration( character)
        if rulebook.applies_to?( current_configuration, character)
            rulebook.next_configuration( current_configuration, character)
        else
            current_configuration.stuck
        end
    end

    def stuck?
        current_configuration.stuck?
    end
end
# 封装 DPDADesign
class DPDADesign < Struct.new( :start_state, :bottom_character, :accept_states, :rulebook)
    def accepts?( string)
        to_dpda.tap { | dpda| dpda.read_string( string) }.accepting?
    end

    def to_dpda
        start_stack = Stack.new([ bottom_character])
        start_configuration = PDAConfiguration.new( start_state, start_stack)
        DPDA.new( start_configuration, accept_states, rulebook)
    end
end

## 非确定下推自动机
require 'set'
# 规则手册
class NPDARulebook < Struct.new( :rules)
    def next_configurations( configurations, character)
        configurations.flat_map { | config| follow_rules_for( config, character) }.to_set
    end

    def follow_rules_for( configuration, character)
        rules_for( configuration, character).map { | rule| rule.follow( configuration) }
    end

    def rules_for( configuration, character)
        rules.select { | rule| rule.applies_to?( configuration, character) }
    end

    # 自由移动
    def follow_free_moves( configurations)
        more_configurations = next_configurations( configurations, nil)
        if more_configurations.subset?( configurations)
            configurations
        else
            follow_free_moves( configurations + more_configurations)
        end
    end
end
# NPDA
class NPDA < Struct.new( :current_configurations, :accept_states, :rulebook)
    def accepting?
        current_configurations.any? { | config| accept_states.include?( config.state) }
    end

    def read_character( character)
        self.current_configurations = rulebook.next_configurations( current_configurations, character)
    end

    def read_string( string)
        string.chars.each do | character|
            read_character( character)
        end
    end

    def current_configurations
        rulebook.follow_free_moves( super)
    end
end
# NPDADesign
class NPDADesign < Struct.new( :start_state, :bottom_character, :accept_states, :rulebook)
    def accepts?( string)
        to_npda.tap { | npda| npda.read_string( string) }.accepting?
    end

    def to_npda
        start_stack = Stack.new( [ bottom_character])
        start_configuration = PDAConfiguration.new( start_state, start_stack)
        NPDA.new( Set[ start_configuration], accept_states, rulebook)
    end
end
