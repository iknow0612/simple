## 词法分析测试
## create by xiongwei

require( './class/lexcial_analyzer.rb')

puts '词法分析测试:'
p LexicalAnalyzer.new( 'y = x * 7').analyze
p LexicalAnalyzer.new( 'while( x< 5) { x = x * 3}').analyze
p LexicalAnalyzer.new( 'if( x < 10) { y = ture; x = 0 } else { do-nothing}').analyze
p LexicalAnalyzer.new( 'x = false').analyze
