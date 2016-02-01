## 模拟 lambda 演算
## ‘只做了一小部分’
## create by xiongwei

puts '模拟数字'
ZERO    = -> p { -> x {       x   }}
ONE     = -> p { -> x {     p[x]  }}
TWO     = -> p { -> x {   p[p[x]] }}
THREE   = -> p { -> x { p[p[p[x]]]}}
# 模拟的数字转换为 ruby 数字
def to_integer( proc)
    proc[ -> n { n + 1}][0]
end
puts '测试:'
p to_integer( ZERO)
p to_integer( ONE)
p to_integer( TWO)
p to_integer( THREE)
puts

puts '模拟布尔'
TRUE  = -> x { -> y { x }}
FALSE = -> x { -> y { y }}
# 模拟的布尔转换为 ruby 布尔值
def to_boolean( proc)
    proc[true][false]
end
puts '测试:'
p to_boolean( TRUE)
p to_boolean( FALSE)
puts

puts '模拟 if'
IF = -> b { b}
puts '测试:'
p IF[TRUE]['happy']['sad']
p IF[FALSE]['happy']['sad']
puts

puts '模拟谓词'
IS_ZERO = -> n { n[-> x { FALSE }][TRUE]}
puts '测试:'
p to_boolean IS_ZERO[ZERO]
p to_boolean IS_ZERO[TWO]
puts

puts '模拟有序对'
PAIR  = -> x { -> y { -> f { f[x][y] } } }
LEFT  = -> p { p[-> x { -> y { x } } ] }
RIGHT = -> p { p[-> x { -> y { y } } ] }
puts '测试:'
my_pair = PAIR[THREE][ONE]
p to_integer( LEFT[my_pair])
p to_integer( RIGHT[my_pair])
puts

puts '模拟数值运算'
# 递增
INCREMENT = -> n { -> p { -> x { p[n[p][x]] } } }
# 递减
SLIDE     = -> p { PAIR[RIGHT[p]][INCREMENT[RIGHT[p]]] }
DECREMENT = -> n { LEFT[n[SLIDE][PAIR[ZERO][ZERO]]] }
# 加 减 乘 取幂
ADD      = -> m { -> n { n[INCREMENT][m] } }
SUBTRACT = -> m { -> n { n[DECREMENT][m] } }
MULTIPLY = -> m { -> n { n[ADD[m]][ZERO] } }
POWER    = -> m { -> n { n[MULTIPLY[m]][ONE] } }
puts '测试:'
p to_integer( ADD[ONE][TWO])
p to_integer( DECREMENT[THREE])
p to_integer( MULTIPLY[TWO][THREE])
p to_integer( POWER[TWO][THREE])
