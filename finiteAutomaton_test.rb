# 有限自动机测试
# create by xiongwei

# 确定性有限自动机
rulebook = DFARulebook.new( [
FARule.new( 1, 'a', 2), FARule.new( 1, 'b', 1),
FARule.new( 2, 'a', 2), FARule.new( 2, 'b', 3),
FARule.new( 3, 'a', 3), FARule.new( 3, 'b', 3)
])
rulebook.next_state( 1, 'a')
rulebook.next_state( 1, 'b')
rulebook.next_state( 2, 'b')

DFA.new( 1, [ 1, 3], rulebook).accepting?
DFA.new( 1, [ 3], rulebook).accepting?

dfa = DFA.new( 1, [ 3], rulebook); dfa.accepting?
dfa.read_character( 'b'); dfa.accepting?
3.times do dfa.read_character( 'a') end; dfa.accepting?
dfa.read_character( 'b'); dfa.accepting?

dfa = DFA.new( 1, [ 3], rulebook); dfa.accepting?
dfa.read_string( 'baaab'); dfa.accepting?

dfa_design = DFADesign.new( 1, [ 3], rulebook)
dfa_design.accepts?( 'a')
dfa_design.accepts?( 'baa')
dfa_design.accepts?( 'baba')

# 非确定性有限自动机
rulebook = NFARulebook.new( [
FARule.new( 1, 'a', 1), FARule.new( 1, 'b', 1), FARule.new( 1, 'b', 2),
FARule.new( 2, 'a', 3), FARule.new( 2, 'b', 3),
FARule.new( 3, 'a', 4), FARule.new( 3, 'b', 4)
])
rulebook.next_states( Set[ 1], 'b')
rulebook.next_states( Set[ 1, 2], 'a')
rulebook.next_states( Set[ 1, 3], 'b')

NFA.new( Set[ 1], [4], rulebook).accepting?
NFA.new( Set[ 1, 2, 4], [ 4], rulebook).accepting?

nfa = NFA.new( Set[ 1], [ 4], rulebook); nfa.accepting?
nfa.read_character( 'b'); nfa.accepting?
nfa.read_character( 'a'); nfa.accepting?
nfa.read_character( 'b'); nfa.accepting?
nfa = NFA.new( Set[ 1], [ 4], rulebook); nfa.accepting?
nfa.read_string( 'bbbbb'); nfa.accepting?

nfa_design = NFADesign.new( 1, [4], rulebook)
nfa_design.accepts?( 'bab')
nfa_design.accepts?( 'bbbbb')
nfa_design.accepts?( 'bbabb')

# 自由移动
rulebook = NFARulebook.new( [
FARule.new( 1, nil, 2), FARule.new( 1, nil, 4),
FARule.new( 2, 'a', 3),
FARule.new( 3, 'a', 2),
FARule.new( 4, 'a', 5),
FARule.new( 5, 'a', 6),
FARule.new( 6, 'a', 4)
])
rulebook.next_states( Set[ 1], nil)

rulebook.follow_free_moves( Set[ 1])

nfa_design = NFADesign.new( 1, [2, 4], rulebook)
nfa_design.accepts?( 'aa')
nfa_design.accepts?( 'aaa')
nfa_design.accepts?( 'aaaaa')
nfa_design.accepts?( 'aaaaaa')