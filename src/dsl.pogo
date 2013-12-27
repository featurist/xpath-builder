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
