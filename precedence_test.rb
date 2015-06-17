# precedence test
# create by xiongwei

require( './precedence.rb')

Add.new( Multiply.new( Number.new( 1), Number.new( 2)), Number.new( 3))

Add.new( Number.new( 1), Multiply.new( Number.new( 2), Number.new(3)))
