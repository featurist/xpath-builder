expression = require './expression'
Literal = require './literal'.Literal

top level methods = {

    current () =
        @new Expression 'thisNode'

    name () =
        @new Expression ('nodeName', self.current())

    descendant (element names, ...) =
        @new Expression ('descendant', self.current(), literals(element names))

    child (element names, ...) =
        @new Expression ('child', self.current(), literals(element names))

    axis (name, tag name) =
        @new Expression ('axis', self.current(), @new Literal(name), @new Literal(tag name || '*'))

    next sibling (names, ...) =
        @new Expression ('nextSibling', self.current(), literals(names))

    previous sibling (names, ...) =
        @new Expression ('previousSibling', self.current(), literals(names))

    anywhere (names, ...) =
        @new Expression ('anywhere', literals(names))

    attr (name) =
        @new Expression ('attribute', self.current(), @new Literal(name))

    contains (expression) =
        @new Expression ('contains', self.current(), expression)

    starts with (expression) =
        @new Expression ('startsWith', self.current(), expression)

    ends with (expression) =
        @new Expression ('endsWith', self.current(), expression)

    text () =
        @new Expression ('text', self.current())

    string () =
        @new Expression ('stringFunction', self.current())

    substring (expression a, expression b) =
        expressions = [expression a]
        if (expression b) @{ expressions.push (expression b) }
        @new Expression ('substringFunction', self.current(), expressions)

    string length () =
        @new Expression ('stringLengthFunction', self.current())

    literal (string) =
        @new Literal(string)

    concat (expressions, ...) =
        @new Expression ('concatFunction', expressions)

    nth child (n) =
        @new Expression ('nthChild', n)

    nth last child (n) =
        @new Expression ('nthLastChild', n)

    first child () =
        @new Expression ('firstChild')

    last child () =
        @new Expression ('lastChild')

    only child () =
        @new Expression ('onlyChild')

    only of type () =
        @new Expression ('onlyOfType')

    first of type () =
        @new Expression ('nthOfType', 1)

    last of type () =
        @new Expression ('lastOfType')

    nth of type (n) =
        @new Expression ('nthOfType', n)

    nth last of type (n) =
        @new Expression ('nthLastOfType', n)

    nth of type mod (m, n) =
        @new Expression ('nthOfTypeMod', m, n || 0)

    nth of type odd () =
        @new Expression ('nthOfTypeOdd')

    nth of type even () =
        @new Expression ('nthOfTypeEven')

    nth last of type mod (m, n) =
        @new Expression ('nthLastOfTypeMod', m, n || 0)

    nth last of type odd () =
        @new Expression ('nthLastOfTypeOdd')

    nth last of type even () =
        @new Expression ('nthLastOfTypeEven')

    empty () =
        @new Expression ('empty')

}

expression level methods = {

    where (expression) =
        @new Expression('where', self.current(), expression)

    one of (expressions, ...) =
        @new Expression('oneOf', self.current(), expressions)

    equals (expression) =
        @new Expression('equality', self.current(), expression)

    is (expression) =
        @new Expression('is', self.current(), expression)

    or (expression) =
        @new Expression('or', self.current(), expression)

    and (expression) =
        @new Expression('and', self.current(), expression)

    union (expressions, ...) =
        @new Union([self].concat(expressions))

    inverse () =
        @new Expression('inverse', self.current())

    string literal () =
        @new Expression('stringLiteral', self)

    normalize () =
        @new Expression('normalizedSpace', self.current())

    n () =
        self.normalize()

    add (number) =
        @new Expression('addition', self.current(), number)

    subtract (number) =
        @new Expression('subtraction', self.current(), number)

    count () =
        @new Expression ('countFunction', self.current())

}

literals (items) = items.map @(item) @{ @new Literal(item) }

Top Level () = this
Top Level.prototype = top level methods

Expression Level () = this
Expression Level.prototype = @new Top Level()

for @(method) in (expression level methods)
    Expression Level.prototype.(method) = expression level methods.(method)

Expression = expression.create expression (Expression Level.prototype)

Union (expressions) =
    this.expression = 'union'
    this.args = expressions
    this

Union.prototype = Expression.prototype

exports.dsl () = @new Top Level()
