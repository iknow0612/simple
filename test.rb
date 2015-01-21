# 测试代码
# Create by xiongwei

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