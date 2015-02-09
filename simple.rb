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
	
	# 大步语义
	def evaluate( environment)
		self
	end
	
	# 指称语义
	def to_ruby
		"-> e { #{value.inspect} }"
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
	
	# 大步语义
	def evaluate( environment)
		self
	end
	
	# 指称语义
	def to_ruby
		"-> e { #{value.inspect} }"
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
	
	# 大步语义
	def evaluate( environment)
		environment[ name]
	end
	
	# 指称语义
	def to_ruby
		"-> e { e[#{name.inspect}] }"
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
	
	# 大步语义
	def evaluate( environment)
		Number.new( left.evaluate( environment).value + right.evaluate( environment).value)
	end
	
	# 指称语义
	def to_ruby
		"-> e { (#{left.to_ruby}).call( e) + (#{right.to_ruby}).call( e) }"
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
	
	# 大步语义
	def evaluate( environment)
		Number.new( left.evaluate( environment).value * right.evaluate( environment).value)
	end
	
	# 指称语义
	def to_ruby
		"-> e { (#{left.to_ruby}).call( e) * (#{right.to_ruby}).call(e ) }"
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
	
	# 大步语义
	def evaluate( environment)
		Number.new( left.evaluate( environment).value < right.evaluate( environment).value)
	end
	
	# 指称语义
	def to_ruby
		"-> e { (#{left.to_ruby}).call( e) < (#{right.to_ruby}).call(e ) }"
	end
end

# 语句
#  空语句
class DoNothing
	def to_s
		'do_nothing'
	end
	
	def inspect
		"<<#{self}>>"
	end
	
	def ==(other_statmement)
		other_statmement.instance_of?( DoNothing)
	end
	
	def reducible?
		false
	end
	
	# 大步语义
	def evaluate( environment)
		environment
	end
	
	# 指称语义
	def to_ruby
		'-> e { e }'
	end
end

#  赋值
class Assign < Struct.new(:name, :expression)
	def to_s
		"#{name} = #{expression}"
	end
	
	def inspect
		"<<#{self}>>"
	end
	
	def reducible?
		true
	end
	
	def reduce( environment)
		if expression.reducible?
			[Assign.new( name, expression.reduce( environment)), environment]
		else
			[DoNothing.new, environment.merge( {name => expression})]
		end
	end
	
	# 大步语义
	def evaluate( environment)
		environment.merge( { name => expression.evaluate( environment) })
	end
	
	# 指称语义
	def to_ruby
		"-> e { e.merge({ #{name.inspect} => (#{expression.to_ruby}).call( e) }) }"
	end
end

#  If语句
class If < Struct.new( :condition, :consequence, :alternative)
	def to_s
		"if (#{condition}) { #{consequence} } else { #{alternative} }"
	end
	
	def inspect
		"<<#{self}>>"
	end
	
	def reducible?
		true
	end
	
	def reduce( environment)
		if condition.reducible?
			[If.new( condition.reduce( environment), consequence, alternative), environment]
		else
			case condition
			when Boolean.new( true)
				[consequence, environment]
			when Boolean.new( false)
				[alternative, environment]
			end
		end
	end
	
	# 大步语义
	def evaluate( environment)
		case condition.evaluate( environment)
		when Boolean.new( true)
			consequence.evaluate( environment)
		when Boolean.new( false)
			alternative.evaluate( environment)
		end
	end
	
	# 指称语义
	def to_ruby
		"-> e { if (#{condition.to_ruby}).call( e)" +
			" then (#{consequence.to_ruby}).call( e)" +
			" else (#{alternative.to_ruby}).call( e)" +
			" end }"
	end
end

#  Sequence序列
class Sequence < Struct.new(:first, :second)
	def to_s
		"#{first}; #{second}"
	end
	
	def inspect
		"<<#{self}>>"
	end
	
	def reducible?
		true
	end
	
	def reduce( environment)
		case first
		when DoNothing.new
			[second, environment]
		else
			reduced_first, reduced_environment = first.reduce( environment)
			[Sequence.new( reduced_first, second), reduced_environment]
		end
	end
	
	# 大步语义
	def evaluate( environment)
		second.evaluate( first.evaluate( environment))
	end
	
	#指称语义
	def to_ruby
		"-> e { (#{second.to_ruby}).call( (#{first.to_ruby}).call( e)) }"
	end
end

#  While循环
class While < Struct.new(:condition, :body)
	def to_s
		"while (#{condition}) { #{body} }"
	end
	
	def inspect
		"<<#{self}>>"
	end
	
	def reducible?
		true
	end
	
	def reduce( environment)
		[If.new( condition, Sequence.new( body, self), DoNothing.new), environment]
	end
	
	# 大步语义
	def evaluate( environment)
		case condition.evaluate( environment)
		when Boolean.new( true)
			evaluate( body.evaluate( environment))
		when Boolean.new( false)
			environment
		end
	end
	
	#指称语义
	def to_ruby
		"-> e {" +
			"while (#{condition.to_ruby}).call( e); e = (#{body.to_ruby}).call( e); end;" +
			" e" +
			" }"
	end
end

# 虚拟机
class Machine < Struct.new(:statement, :environment)
	def step
		self.statement, self.environment = statement.reduce( environment)
	end
	
	def run
		while statement.reducible?
			puts "#{statement}, #{environment}"
			step
		end
		puts "#{statement}, #{environment}"
	end
end
