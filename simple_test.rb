# 测试代码
# Create by xiongwei

# 小步语义
# 虚拟机运算
Machine.new(
Add.new(
Multiply.new( Number.new(1), Number.new(2)),
Multiply.new( Number.new(3), Number.new(4))
)
).run

# 小于运算
Machine.new(
LessThen.new( Number.new(5), Add.new( Number.new(2), Number.new(2)))
).run

# 加入变量
Machine.new(
Add.new( Variable.new(:x), Variable.new(:y)),
{ x: Number.new(3), y: Number.new(4) }
).run

# 赋值表达式
statement = Assign.new(:x, Add.new( Variable.new(:x), Number.new(1)))
environment = { x: Number.new(2) }
statement.reducible?
statement, environment = statement.reduce( environment)
statement, environment = statement.reduce( environment)
statement, environment = statement.reduce( environment)
statement.reducible?
#  虚拟机版
Machine.new(
Assign.new( :x, Add.new( Variable.new(:x), Variable.new(:y))),
{ x: Number.new(3), y: Number.new(4) }
).run

# If语句
Machine.new(
If.new(
Variable.new(:x),
Assign.new(:y, Number.new(1)),
Assign.new(:y, Number.new(2))
),
{ x: Boolean.new(true) }
).run
Machine.new(
If.new(
Variable.new(:x),
Assign.new(:y, Number.new(1)),
DoNothing.new
),
{ x: Boolean.new(false) }
).run

# Sequence序列
Machine.new(
Sequence.new(
Assign.new(:x, Add.new( Number.new(1), Number.new(1))),
Assign.new(:y, Add.new( Variable.new(:x), Number.new(3)))
),
{}
).run

# While循环
Machine.new(
While.new(
LessThen.new(Variable.new(:x), Number.new(5)),
Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
),
{ x: Number.new(1) }
).run

# 大步语义
# 基本运算
Number.new( 23).evaluate( {})
Variable.new( :x).evaluate( { x: Number.new(23) })
LessThen.new(
Add.new( Variable.new( :x), Number.new( 2)),
Variable.new( :y)
).evaluate( { x: Number.new( 2), y: Number.new( 5) })

# 序列
statement = 
Sequence.new(
Assign.new( :x, Add.new( Number.new( 1), Number.new( 1))),
Assign.new( :y, Add.new( Variable.new( :x), Number.new( 3)))
)
statement.evaluate( {})

# While循环
statement =
While.new( 
LessThen.new( Variable.new( :x), Number.new( 5)),
Assign.new( :x, Multiply.new( Variable.new( :x), Number.new( 3)))
)
statement.evaluate( { x: Number.new( 1)})