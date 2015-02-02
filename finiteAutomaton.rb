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
