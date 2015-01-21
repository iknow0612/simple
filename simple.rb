# simple的实现
# create by xiongwei

# 表达式
#  类型
#   数值
class Number < Struct.new(:value)
	def to_s
		value.to_s
	end
	
	def inspect
		"<<#{self}>>"
	end
	
	def reducible?
		false
	end
end
#   布尔
class Boolean < Struct.new(:value)
	def to_s
		value.to_s
	end
	
	def inspect
		"<<#{self}>>"
	end
	
	def reducible?
		false
	end
end

#  变量
class Variable < Struct.new(:name)
	def to_s
		name.to_s
	end
	
	def inspect
		"#{self}"
	end
	
	def reducible?
		true
	end
	
	def reduce( environment)
		environment[ name]
	end
end

#  基本算术符
#   加法
class Add < Struct.new(:left, :right)
	def to_s
		"#{left} + #{right}"
	end
	
	def inspect
		"<<#{self}>>"
	end
	
	def reducible?
		true
	end
	
	def reduce( environment)
		if left.reducible?
			Add.new( left.reduce( environment), right)
		elsif right.reducible?
			Add.new( left, right.reduce( environment))
		else
			Number.new( left.value + right.value)
		end
	end
end
#   乘法
class Multiply < Struct.new(:left, :right)
	def to_s
		"#{left} * #{right}"
	end
	
	def inspect
		"<<#{self}>>"
	end
	
	def reducible?
		true
	end
	
	def reduce( environment)
		if left.reducible?
			Multiply.new( left.reduce( environment), right)
		elsif right.reducible?
			Multiply.new( left, right.reduce( environment))
		else
			Number.new( left.value * right.value)
		end
	end
end
#   小于运算
class LessThen < Struct.new(:left, :right)
	def to_s
		"#{left} < #{right}"
	end
	
	def inspect
		"<<#{self}>>"
	end
	
	def reducible?
		true
	end
	
	def reduce( environment)
		if left.reducible?
			LessThen.new( left.reduce( environment), right)
		elsif right.reducible?
			LessThen.new( left, right.reduce( environment))
		else
			Boolean.new( left.value < right.value)
		end
	end
end

# 虚拟机
class Machine < Struct.new(:expression, :environment)
	def step
		self.expression = expression.reduce( environment)
	end
	
	def run
		while expression.reducible?
			puts expression
			step
		end
		puts expression
	end
end