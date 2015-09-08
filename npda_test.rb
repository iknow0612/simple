## 非确定性下推自动机测试
## create by xiongwei

require './class/pda'

puts '识别相等数目的两种字符串 a 和 b(确定性):'
rulebook = DPDARulebook.new([
    PDARule.new( 1, 'a', 2, '$', [ 'a', '$']),
    PDARule.new( 1, 'b', 2, '$', [ 'b', '$']),
    PDARule.new( 2, 'a', 2, 'a', [ 'a', 'a']),
    PDARule.new( 2, 'b', 2, 'b', [ 'b', 'b']),
    PDARule.new( 2, 'a', 2, 'b', []),
    PDARule.new( 2, 'b', 2, 'a', []),
    PDARule.new( 2, nil, 1, '$', [ '$'])
])
dpda_design = DPDADesign.new( 1, '$', [1], rulebook)
p dpda_design.accepts?( 'ababab')
p dpda_design.accepts?( 'bbbaaaab')
p dpda_design.accepts?( 'baa')
puts

puts 'NPDA 测试:'
rulebook = NPDARulebook.new([
    PDARule.new( 1, 'a', 1, '$', [ 'a', '$']),
    PDARule.new( 1, 'a', 1, 'a', [ 'a', 'a']),
    PDARule.new( 1, 'a', 1, 'b', [ 'a', 'b']),
    PDARule.new( 1, 'b', 1, '$', [ 'b', '$']),
    PDARule.new( 1, 'b', 1, 'a', [ 'b', 'a']),
    PDARule.new( 1, 'b', 1, 'b', [ 'b', 'b']),
    PDARule.new( 1, nil, 2, '$', [ '$']),
    PDARule.new( 1, nil, 2, 'a', [ 'a']),
    PDARule.new( 1, nil, 2, 'b', [ 'b']),
    PDARule.new( 2, 'a', 2, 'a', []),
    PDARule.new( 2, 'b', 2, 'b', []),
    PDARule.new( 2, nil, 3, '$', [ '$'])
])
configuration = PDAConfiguration.new( 1, Stack.new( [ '$']))
npda = NPDA.new( Set[ configuration], [ 3], rulebook)
p npda.accepting?
p npda.current_configurations
npda.read_string( 'abb')
p npda.accepting?
p npda.current_configurations
npda.read_string( 'a')
p npda.accepting?
p npda.current_configurations
puts

puts 'NPDADesign 测试:'
npda_design = NPDADesign.new( 1, '$', [ 3], rulebook)
p npda_design.accepts?( 'abba')
p npda_design.accepts?( 'babbaabbab')
p npda_design.accepts?( 'babbaabbaba')
p npda_design.accepts?( 'abb')
