## 图灵机测试
## create by xiongwei

require './class/dtm.rb'

puts '模拟纸带测试:'
tape = Tape.new( [ '1', '0', '1'], '1', [], '_')
p tape
p tape.middle

p tape.move_head_left
p tape.write( '0')
p tape.move_head_right
p tape.move_head_right.write( '0')
puts


puts '图灵机配置和规则测试:'
rule = TMRule.new( 1, '0', 2, '1', :right)
p rule
p rule.applies_to?( TMConfiguration.new( 1, Tape.new( [], '0', [], '_')))
p rule.applies_to?( TMConfiguration.new( 1, Tape.new( [], '1', [], '_')))
p rule.applies_to?( TMConfiguration.new( 2, Tape.new( [], '0', [], '_')))

p rule.follow( TMConfiguration.new( 1, Tape.new( [], '0', [], '_')))
puts


puts 'DTMRulebook 测试:'
rulebook = DTMRulebook.new([
    TMRule.new( 1, '0', 2, '1', :right),
    TMRule.new( 1, '1', 1, '0', :left),
    TMRule.new( 1, '_', 2, '1', :right),
    TMRule.new( 2, '0', 2, '0', :right),
    TMRule.new( 2, '1', 2, '1', :right),
    TMRule.new( 2, '_', 3, '_', :left)
])
configuration = TMConfiguration.new( 1, tape)
p configuration
configuration = rulebook.next_configuration( configuration)
p configuration
configuration = rulebook.next_configuration( configuration)
p configuration
p rulebook.next_configuration( configuration)
puts


puts 'DTM 测试:'
dtm = DTM.new( TMConfiguration.new( 1, tape), [3], rulebook)
p dtm.current_configuration
p dtm.accepting?
dtm.run
p dtm.current_configuration
p dtm.accepting?
puts


puts '卡死状态测试:'
tape = Tape.new( ['1', '2', '1'], '1', [], '_')
dtm = DTM.new( TMConfiguration.new( 1, tape), [3], rulebook)
dtm.run
p dtm.current_configuration
puts


puts '使用图灵机识别类似\'aaabbbccc\'字符串:'
rulebook = DTMRulebook.new([
    # 状态1: 向右扫描, 查找 a
    TMRule.new( 1, 'X', 1, 'X', :right), # 跳过 X
    TMRule.new( 1, 'a', 2, 'X', :right), # 删除 a, 进入状态 2
    TMRule.new( 1, '_', 6, '_', :left),  # 查找空格, 进入状态6(接受)

    # 状态2: 向右扫描, 查找 b
    TMRule.new( 2, 'a', 2, 'a', :right),
    TMRule.new( 2, 'X', 2, 'X', :right),
    TMRule.new( 2, 'b', 3, 'X', :right),

    # 状态3: 向右扫描, 查找 c
    TMRule.new( 3, 'b', 3, 'b', :right),
    TMRule.new( 3, 'X', 3, 'X', :right),
    TMRule.new( 3, 'c', 4, 'X', :right),

    # 状态4: 向右扫描, 查找字符串结束标记
    TMRule.new( 4, 'c', 4, 'c', :right),
    TMRule.new( 4, '_', 5, '_', :left),

    # 状态5: 向左扫描, 查找字符串开始标记
    TMRule.new( 5, 'a', 5, 'a', :left),
    TMRule.new( 5, 'b', 5, 'b', :left),
    TMRule.new( 5, 'c', 5, 'c', :left),
    TMRule.new( 5, 'X', 5, 'X', :left),
    TMRule.new( 5, '_', 1, '_', :right)
])
tape = Tape.new( [], 'a', ['a', 'a', 'b', 'b', 'b', 'c', 'c', 'c'], '_')
dtm = DTM.new( TMConfiguration.new( 1, tape), [6], rulebook)
10.times { dtm.step}
p dtm.current_configuration
25.times { dtm.step}
p dtm.current_configuration
dtm.run
p dtm.current_configuration
