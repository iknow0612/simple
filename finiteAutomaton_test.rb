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