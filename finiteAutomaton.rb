# 模拟有限自动机
# create by xiongwei

class FARule < Struct.new( :state, :character, :next_state)
	def applies_to?( state, character)
		self.state == state && self.character == character
	end
	
	def follow
		next_state
	end
	
	def inspect
		"#<FARule #{state.inspect} --#{character}--> #{next_state.inspect}>"
	end
end

# 确定性有限自动机
class DFARulebook < Struct.new( :rules)
	def next_state( state, character)
		rule_for( state, character).follow
	end
	
	def rule_for( state, character)
		rules.detect { |rule| rule.applies_to?( state, character) }
	end
end
#  DFA
class DFA < Struct.new( :current_state, :accept_states, :rulebook)
	def accepting?
		accept_states.include?( current_state)
	end
	
	def read_character( character)
		self.current_state = rulebook.next_state( current_state, character)
	end
	
	def read_string( string)
		string.chars.each do |character|
			read_character( character)
		end
	end
end
#  DFADesign 自动构建一次性DFA实例
class DFADesign < Struct.new( :start_state, :accept_states, :rulebook)
	def to_dfa
		DFA.new( start_state, accept_states, rulebook)
	end
	
	def accepts?( string)
		to_dfa.tap { |dfa| dfa.read_string( string) }.accepting?
	end
end

# 非确定性有限自动机
require 'set'
class NFARulebook < Struct.new( :rules)
	def next_states( states, character)
		states.flat_map { |state| follow_rules_for( state, character) }.to_set
	end
	
	def follow_rules_for( state, character)
		rules_for( state, character).map( &:follow)
	end
	
	def rules_for( state, character)
		rules.select { |rule| rule.applies_to?( state, character) }
	end
	
	# 自由移动
	def follow_free_moves( states)
		more_states = next_states( states, nil)
		
		if more_states.subset?( states)
			states
		else
			follow_free_moves( states + more_states)
		end
	end
end
#  NFA
class NFA < Struct.new( :current_states, :accept_states, :rulebook)
	def accepting?
		( current_states & accept_states).any?
	end
	
	def read_character( character)
		self.current_states = rulebook.next_states( current_states, character)
	end
	
	def read_string( string)
		string.chars.each do |character|
			read_character( character)
		end
	end
	
	# 自由移动
	def current_states
		rulebook.follow_free_moves( super)
	end
end
#  NFADesign 自动构建NFA实例
class NFADesign < Struct.new( :start_state, :accept_states, :rulebook)
	def accepts?( string)
		to_nfa.tap { |nfa| nfa.read_string( string) }.accepting?
	end
	
	def to_nfa
		NFA.new( Set[ start_state], accept_states, rulebook)
	end
end

# 正则表达式
module Pattern
    def bracket( outer_precedence)
        if precedence < outer_precedence
            '(' + to_s + ')'
        else
            to_s
        end
    end

    def inspect
        "/#{self}/"
    end

    # 模式匹配
    def matches?( string)
        to_nfa_design.accepts?( string)
    end
end

class Empty
    include Pattern

    def to_s
        ''
    end

    def precedence
        3
    end

    # 语法转换NFA
    def to_nfa_design
        start_state = Object.new
        accept_states = [ start_state]
        rulebook = NFARulebook.new( [])

        NFADesign.new( start_state, accept_states, rulebook)
    end
end

class Literal < Struct.new( :character)
    include Pattern

    def to_s
        character
    end

    def precedence
        3
    end

    # 语法转换NFA
    def to_nfa_design
        start_state = Object.new
        accept_state = Object.new
        rule = FARule.new( start_state, character, accept_state)
        rulebook = NFARulebook.new( [ rule])

        NFADesign.new( start_state, [ accept_state], rulebook)
    end
end

class Concatenate < Struct.new( :first, :second)
    include Pattern

    def to_s
        [first, second].map { |pattern| pattern.bracket( precedence) }.join
    end

    def precedence
        1
    end

    # 语法转换NFA
    def to_nfa_design
        first_nfa_design = first.to_nfa_design
        second_nfa_design = second.to_nfa_design

        # 第一个NFA的起始状态
        start_state = first_nfa_design.start_state
        # 第二个NFA的接受状态
        accept_states = second_nfa_design.accept_states
        # 两台NFA的所有规则
        rules = first_nfa_design.rulebook.rules + second_nfa_design.rulebook.rules
        # 一些额外的自由移动，可以把第一台NFA旧的接受状态与第二个NFA的其实状态连接起来
        extra_rules = first_nfa_design.accept_states.map { |state|
            FARule.new( state, nil, second_nfa_design.start_state)
        }
        rulebook = NFARulebook.new( rules + extra_rules)

        NFADesign.new( start_state, accept_states, rulebook)
    end
end

class Choose < Struct.new( :first, :second)
    include Pattern

    def to_s
        [first, second].map { |pattern| pattern.bracket( precedence) }.join( '|')
    end

    def precedence
        0
    end

    # 语法转换NFA
    def to_nfa_design
        first_nfa_design = first.to_nfa_design
        second_nfa_design = second.to_nfa_design

        # 一个新的起始状态
        start_state = Object.new
        # 两台NFA的所有接受状态
        accept_states = first_nfa_design.accept_states + second_nfa_design.accept_states
        # 两台NFA的所有规则
        rules = first_nfa_design.rulebook.rules + second_nfa_design.rulebook.rules
        # 两个额外的自由移动，可以把新的起始状态与NFA旧的起始状态连接起来
        extra_rules = [ first_nfa_design, second_nfa_design].map { |nfa_design|
            FARule.new( start_state, nil, nfa_design.start_state)
        }
        rulebook = NFARulebook.new( rules + extra_rules)

        NFADesign.new( start_state, accept_states, rulebook)
    end
end

class Repeat < Struct.new( :pattern)
    include Pattern

    def to_s
        pattern.bracket( precedence) + '*'
    end

    def precedence
        2
    end

    # 语法转换NFA
    def to_nfa_design
        pattern_nfa_design = pattern.to_nfa_design

        # 一个新的起始状态，它也是一个接受状态
        start_state = Object.new
        # 旧的NFA中所有的接受规则
        accept_states = pattern_nfa_design.accept_states + [ start_state]
        # 旧的NFA中所有的规则
        rules = pattern_nfa_design.rulebook.rules
        # 一些额外的自由移动，把旧的FNA的每一个接受状态与旧的起始状态连接起来；另一些自由移动，把新的起始状态与旧的起始状态连接起来
        extra_rules =
            pattern_nfa_design.accept_states.map { |accept_state|
                FARule.new( accept_state, nil, pattern_nfa_design.start_state)
            } +
            [ FARule.new( start_state, nil, pattern_nfa_design.start_state)]
        rulebook = NFARulebook.new( rules + extra_rules)

        NFADesign.new( start_state, accept_states, rulebook)
    end
end
