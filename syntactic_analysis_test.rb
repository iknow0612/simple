# 4.3.2语法分析
# create by xiongwei

require './class/pda.rb'
require './class/lexcial_analyzer.rb'

puts '语法分析:'

puts '起始, S 表示语句:'
start_rule = PDARule.new( 1, nil, 2, '$', ['S', '$'])
p start_rule

puts '符号规则:'
symbol_rules = [
    # <statement> ::= <while> | <assign>
    PDARule.new( 2, nil, 2, 'S', ['W']),
    PDARule.new( 2, nil, 2, 'S', ['A']),

    # <while> ::= 'w' '(' <expression> ')' '{' <statement> '}'
    PDARule.new( 2, nil, 2, 'W', ['w', '(', 'E', ')', '{', 'S', '}']),

    # <assign> ::= 'v' = <expression>
    PDARule.new( 2, nil, 2, 'A', ['v', '=', 'E']),

    # <expression> ::= <less-than>
    PDARule.new( 2, nil, 2, 'E', ['L']),

    # <less-than> ::= <multiply> '<' <less-than> | <multiply>
    PDARule.new( 2, nil, 2, 'L', ['M', '<', 'L']),
    PDARule.new( 2, nil, 2, 'L', ['M']),

    # <multiply> ::= <term> '*' <multiply> | <term>
    PDARule.new( 2, nil, 2, 'M', ['T', '*', 'M']),
    PDARule.new( 2, nil, 2, 'M', ['T']),

    # <term> ::= 'n' | 'v'
    PDARule.new( 2, nil, 2, 'T', ['n']),
    PDARule.new( 2, nil, 2, 'T', ['v'])
]
p symbol_rules

puts '单词规则:'
token_rules = LexicalAnalyzer::GRAMMAR.map do | rule|
    PDARule.new( 2, rule[:token], 2, rule[:token], [])
end
p token_rules

puts '栈为空时,转为接受状态'
stop_rule = PDARule.new( 2, nil, 3, '$', ['$'])
p stop_rule

puts '构造 NPDA...'
rulebook = NPDARulebook.new( [start_rule, stop_rule] + symbol_rules + token_rules)
npda_design = NPDADesign.new( 1, '$', [3], rulebook)

puts '分析:'
token_string = LexicalAnalyzer.new( 'while ( x < 5) { x = x * 3 }').analyze.join
p token_string
p npda_design.accepts?( token_string)
token_string2 = LexicalAnalyzer.new( 'while ( x < 5 x = x * }').analyze.join
p token_string2
p npda_design.accepts?( token_string2 )
