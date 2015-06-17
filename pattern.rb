# 正则表达式
# create by xiongwei

require( './class/automaton.rb')

module Pattern
    def bracket( outer_precedence)
        if precedence < outer_precedence
            '(' + to_s + ')'
        else
            to_s
        end
    end

    def inspect
        "/#{self}/"
    end

    # 模式匹配
    def matches?( string)
        to_nfa_design.accepts?( string)
    end
end

class Empty
    include Pattern

    def to_s
        ''
    end

    def precedence
        3
    end

    # 语法转换NFA
    def to_nfa_design
        start_state = Object.new
        accept_states = [ start_state]
        rulebook = NFARulebook.new( [])

        NFADesign.new( start_state, accept_states, rulebook)
    end
end

class Literal < Struct.new( :character)
    include Pattern

    def to_s
        character
    end

    def precedence
        3
    end

    # 语法转换NFA
    def to_nfa_design
        start_state = Object.new
        accept_state = Object.new
        rule = FARule.new( start_state, character, accept_state)
        rulebook = NFARulebook.new( [ rule])

        NFADesign.new( start_state, [ accept_state], rulebook)
    end
end

class Concatenate < Struct.new( :first, :second)
    include Pattern

    def to_s
        [first, second].map { |pattern| pattern.bracket( precedence) }.join
    end

    def precedence
        1
    end

    # 语法转换NFA
    def to_nfa_design
        first_nfa_design = first.to_nfa_design
        second_nfa_design = second.to_nfa_design

        # 第一个NFA的起始状态
        start_state = first_nfa_design.start_state
        # 第二个NFA的接受状态
        accept_states = second_nfa_design.accept_states
        # 两台NFA的所有规则
        rules = first_nfa_design.rulebook.rules + second_nfa_design.rulebook.rules
        # 一些额外的自由移动，可以把第一台NFA旧的接受状态与第二个NFA的其实状态连接起来
        extra_rules = first_nfa_design.accept_states.map { |state|
            FARule.new( state, nil, second_nfa_design.start_state)
        }
        rulebook = NFARulebook.new( rules + extra_rules)

        NFADesign.new( start_state, accept_states, rulebook)
    end
end

class Choose < Struct.new( :first, :second)
    include Pattern

    def to_s
        [first, second].map { |pattern| pattern.bracket( precedence) }.join( '|')
    end

    def precedence
        0
    end

    # 语法转换NFA
    def to_nfa_design
        first_nfa_design = first.to_nfa_design
        second_nfa_design = second.to_nfa_design

        # 一个新的起始状态
        start_state = Object.new
        # 两台NFA的所有接受状态
        accept_states = first_nfa_design.accept_states + second_nfa_design.accept_states
        # 两台NFA的所有规则
        rules = first_nfa_design.rulebook.rules + second_nfa_design.rulebook.rules
        # 两个额外的自由移动，可以把新的起始状态与NFA旧的起始状态连接起来
        extra_rules = [ first_nfa_design, second_nfa_design].map { |nfa_design|
            FARule.new( start_state, nil, nfa_design.start_state)
        }
        rulebook = NFARulebook.new( rules + extra_rules)

        NFADesign.new( start_state, accept_states, rulebook)
    end
end

class Repeat < Struct.new( :pattern)
    include Pattern

    def to_s
        pattern.bracket( precedence) + '*'
    end

    def precedence
        2
    end

    # 语法转换NFA
    def to_nfa_design
        pattern_nfa_design = pattern.to_nfa_design

        # 一个新的起始状态，它也是一个接受状态
        start_state = Object.new
        # 旧的NFA中所有的接受规则
        accept_states = pattern_nfa_design.accept_states + [ start_state]
        # 旧的NFA中所有的规则
        rules = pattern_nfa_design.rulebook.rules
        # 一些额外的自由移动，把旧的FNA的每一个接受状态与旧的起始状态连接起来；另一些自由移动，把新的起始状态与旧的起始状态连接起来
        extra_rules =
            pattern_nfa_design.accept_states.map { |accept_state|
                FARule.new( accept_state, nil, pattern_nfa_design.start_state)
            } +
            [ FARule.new( start_state, nil, pattern_nfa_design.start_state)]
        rulebook = NFARulebook.new( rules + extra_rules)

        NFADesign.new( start_state, accept_states, rulebook)
    end
end

# 等价性 NFA转DFA
class NFASimulation < Struct.new( :nfa_design)
    def next_state( state, character)
        nfa_design.to_nfa( state).tap { |nfa|
            nfa.read_character( character)
        }.current_states
    end

    def rules_for( state)
        nfa_design.rulebook.alphabet.map { |character|
            FARule.new( state, character, next_state( state, character))
        }
    end

    def discover_states_and_rules( states)
        rules = states.flat_map { |state| rules_for( state) }
        more_states = rules.map( &:follow).to_set

        if more_states.subset?( states)
            [ states, rules]
        else
            discover_states_and_rules( states + more_states)
        end
    end

    def to_dfa_design
        start_state = nfa_design.to_nfa.current_states
        states, rules = discover_states_and_rules( Set[ start_state])
        accept_states = states.select { |state| nfa_design.to_nfa( state).accepting? }

        DFADesign.new( start_state, accept_states, DFARulebook.new( rules))
    end
end
