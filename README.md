# xpath-builder

A JavaScript DSL around a subset of XPath 1.0. Its primary purpose is to
facilitate writing complex XPath queries from JavaScript code.

[![Build Status](https://secure.travis-ci.org/featurist/xpath-builder.png?branch=master)](http://travis-ci.org/featurist/xpath-builder)

xpath-builder is a port of the [xpath](https://github.com/jnicklas/xpath) Ruby gem.


## Generating expressions

To create quick, one-off expressions, create an xpath builder:

```js
x = require('xpath-builder').dsl();

x.descendant('ul').where(x.attr('id').equals('foo'))
```

However for more complex expressions, it is probably more convenient to include
the builder object in your prototype chain:

```js
function MyXPaths() {}

MyXPaths.prototype = require('xpath-builder').dsl();

MyXPaths.prototype.fooList = function() {
  return this.descendant('ul').where(this.attr('id').equals('foo'));
};

MyXPaths.prototype.passwordField = function(id) {
  return this.descendant('input')
             .where(this.attr('type').equals('password'))
             .where(this.attr('id').equals(id));
};
```

Both ways return an
[`Expression`](./src/expression.pogo)
instance, which can be further modified.  To convert the expression to a
string, just call `.toString()` on it. All available expressions are defined in
[`DSL`](./src/dsl.pogo).

## Strings and Literals

When you send a string as an argument to any xpath-builder function, it may be interepreted as a string literal, or an xpath literal, depending on the function:

```js
x.descendant('p').where(x.attr('id').equals('foo'))
```

Which generates:

```
.//p[./@id = 'foo']
```

Occasionally you might want XPath literals instead of string literals, in which case wrap your string in a call to .literal():

```js
x.descendant('p').where(x.attr('id').equals(x.literal('foo')))
```

Which generates:

```
.//p[./@id = foo]
```

This expression would match any p tag whose id attribute matches a 'foo' tag it contains. Most of the time, this is not what you want.


## License

(The MIT License)

Copyright © 2013 Josh Chisholm

Copyright © 2010 Jonas Nicklas

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the ‘Software’), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.