## 确定性下推自动机测试
## create by xiongwei

require './class/pda'

puts '栈测试:'
stack = Stack.new( ['a', 'b', 'c', 'd', 'e'])
p stack.top
p stack.pop.pop.top
p stack.push('x').push('y').top
p stack.push('x').push('y').pop.top
puts

puts '存储PDA配置测试:'
rule = PDARule.new( 1, '(', 2, '$', ['b', '$'])
p rule
configuration = PDAConfiguration.new( 1, Stack.new( ['$']))
p configuration
p rule.applies_to?( configuration, '(')
puts

puts '获得下一个状态:'
p rule.follow( configuration)
puts

puts '确定性自动机规则手册测试:'
puts '...生成手册'
rulebook = DPDARulebook.new([
    PDARule.new( 1, '(', 2, '$', ['b', '$']),
    PDARule.new( 2, '(', 2, 'b', ['b', 'b']),
    PDARule.new( 2, ')', 2, 'b', []),
    PDARule.new( 2, nil, 1, '$', ['$'])
])
configuration = rulebook.next_configuration( configuration, '(')
p configuration
configuration = rulebook.next_configuration( configuration, '(')
p configuration
configuration = rulebook.next_configuration( configuration, ')')
p configuration
puts

puts 'DPDA测试:'
dpda = DPDA.new( PDAConfiguration.new( 1, Stack.new( ['$'])), [1], rulebook)
p dpda.accepting?
dpda.read_string( '(()')
p dpda.accepting?
p dpda.current_configuration
puts

puts '自由移动测试:'
configuration = PDAConfiguration.new( 2, Stack.new( ['$']))
p rulebook.follow_free_moves( configuration)
puts

puts 'DPDA测试(包含自由移动):'
dpda = DPDA.new( PDAConfiguration.new( 1, Stack.new( ['$'])), [1], rulebook)
dpda.read_string( '(()(')
p dpda.accepting?
p dpda.current_configuration
dpda.read_string( '))()')
p dpda.accepting?
p dpda.current_configuration
puts

puts 'PDPADesign测试:'
dpda_design = DPDADesign.new( 1, '$', [1], rulebook)
p dpda_design.accepts?( '((()))()()(())')
p dpda_design.accepts?( '((()))()()(())(')
p dpda_design.accepts?( '((()))()()(()))')
