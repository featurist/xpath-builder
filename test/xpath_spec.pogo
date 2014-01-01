libxmljs = require "libxmljs"
dsl = require '../js/dsl'.dsl ()
cheerio = require 'cheerio'

Thingy() = this
Thingy.prototype = dsl
Thingy.prototype.fooDiv () =
    this.descendant('div').where(this.attr('id').equals 'foo')

describe 'dsl'

    template = require('fs').read file sync "#(__dirname)/fixtures/simple.html"
    doc = libxmljs.parseXml(template.to string())

    select (expression, type) =
        x = expression.to XPath(type)
        selected = doc.find(expression.to XPath(type))
        if (selected :: Array)
            (selected.map @(el)
                $ = cheerio(el.to string())
                $.name = el.name()
                $
            ) || []
        else
            selected

    it "works as a mixin"
        xpath = (@new Thingy).fooDiv()
        select(xpath).0.attr('title').should.equal 'fooDiv'

    describe '.descendant()'

        it "finds nodes that are nested below the current node"
            results = select(dsl.descendant 'p')
            results.0.text().should.equal 'Blah'
            results.1.text().should.equal 'Bax'

        it "does not find nodes outside the context"
            foo div = dsl.descendant('div').where(dsl.attr('id').equals('foo'))
            results = select (dsl.descendant('p').where(dsl.attr('id').equals(foo div.attr('title'))))
            results.length.should.equal 0

        it "finds multiple kinds of nodes"
            results = select (dsl.descendant('p', 'ul'))
            results.0.text().should.equal 'Blah'
            results.3.text().should.equal 'A list'

        it "finds all nodes when no arguments given"
            results = select (dsl.descendant().where(dsl.attr('id').equals 'foo').descendant())
            results.0.text().should.equal 'Blah'
            results.4.text().should.equal 'A list'

    describe '.child()'

        it "finds nodes that are nested directly below the current node"
            results = select(dsl.descendant('div').child('p'))
            results.0.text().should.equal 'Blah'
            results.1.text().should.equal 'Bax'

        it "does not find nodes that are nested further down below the current node"
            results = select(dsl.child('p'))
            results.length.should.equal 0

        it "finds multiple kinds of nodes"
            results = select(dsl.descendant('div').child('p', 'ul'))
            results.0.text().should.equal 'Blah'
            results.3.text().should.equal 'A list'

        it "finds all nodes when no arguments given"
            results = select(dsl.descendant().where(dsl.attr('id').equals('foo')).child())
            results.0.text().should.equal 'Blah'
            results.3.text().should.equal 'A list'

    describe '.axis()'

        it "finds nodes given the xpath axis"
            results = select(dsl.axis('descendant', 'p'))
            results.0.text().should == "Blah"

        it "finds nodes given the xpath axis without a specific tag"
            results = select(dsl.descendant('div').where(dsl.attr('id').equals 'foo').axis('descendant'))
            results.0.attr('id').should.equal "fooDiv"

    describe '.nextSibling()'

        it "finds nodes which are immediate siblings of the current node"
            select(dsl.descendant('p').where(dsl.attr('id').equals 'fooDiv').next sibling('p')).0.text().should.equal 'Bax'
            select(dsl.descendant('p').where(dsl.attr('id').equals 'fooDiv').next sibling('ul', 'p')).0.text().should.equal 'Bax'
            select(dsl.descendant('p').where(dsl.attr('title').equals 'monkey').next sibling('ul', 'p')).0.text().should.equal 'A list'
            select(dsl.descendant('p').where(dsl.attr('id').equals 'fooDiv').next sibling('ul', 'li')).length.should.equal 0
            select(dsl.descendant('p').where(dsl.attr('id').equals 'fooDiv').next sibling()).0.text().should.equal 'Bax'

    describe '.previousSibling()'

        it "finds nodes which are exactly preceding the current node"
            select(dsl.descendant('p').where(dsl.attr('id').equals 'wooDiv').previous sibling('p')).0.text().should.equal 'Bax'
            select(dsl.descendant('p').where(dsl.attr('id').equals 'wooDiv').previous sibling('ul', 'p')).0.text().should.equal 'Bax'
            select(dsl.descendant('p').where(dsl.attr('title').equals 'gorilla').previous sibling('ul', 'p')).0.text().should.equal 'A list'
            select(dsl.descendant('p').where(dsl.attr('id').equals 'wooDiv').previous sibling('ul', 'li')).length.should.equal 0
            select(dsl.descendant('p').where(dsl.attr('id').equals 'wooDiv').previous sibling()).0.text().should.equal 'Bax'

    describe '.anywhere()'

        it "finds nodes regardless of the context"
            foo div = dsl.anywhere('div').where(dsl.attr('id').equals 'foo')
            results = select(dsl.descendant('p').where(dsl.attr('id').equals (foo div.attr 'title')))
            results.0.text().should.equal "Blah"

        it "finds multiple kinds of nodes regardless of the context"
            context = dsl.descendant('div').where(dsl.attr('id').equals 'woo')
            results = select(context.anywhere('p', 'ul'))
            results.0.text().should.equal 'Blah'
            results.3.text().should.equal 'A list'
            results.4.text().should.equal 'A list'
            results.6.text().should.equal 'Bax'

        it "finds all nodes when no arguments given regardless of the context"
            results = select(dsl.descendant('div').where(dsl.attr('id').equals 'woo').anywhere())
            results.0.name.should.equal 'html'
            results.1.name.should.equal 'head'
            results.2.name.should.equal 'body'
            results.6.text().should.equal 'Blah'
            results.10.text().should.equal 'A list'
            results.13.text().should.equal 'A list'
            results.15.text().should.equal 'Bax'

    describe '.contains()'

        it "finds nodes that contain the given string"
            results = select(dsl.descendant('div').where(dsl.attr('title').contains('ooD')))
            results.0.attr('id').should.equal "foo"

        it "finds nodes that contain the given expression"
            expression = dsl.anywhere('div').where(dsl.attr('title').equals 'fooDiv').attr('id')
            results = select(dsl.descendant('div').where(dsl.attr('title').contains(expression)))
            results.0.attr('id').should.equal "foo"

    describe '.concat()'

        it "concatenates expressions"
            foo = dsl.anywhere('div').where(dsl.attr('title').equals 'fooDiv').attr('id')
            results = select(dsl.descendant('div').where(dsl.attr('title').equals(dsl.concat(foo, 'Div'))))
            results.0.attr('id').should.equal "foo"

    describe '.count()'

        it "counts elements"
            results = select(dsl.descendant('div').where(dsl.child().count().equals(2)))
            results.0.attr('id').should.equal "preference"

    describe '.nthChild()'

        it "finds the nth child element"
            results = select(dsl.descendant('div').where(dsl.nth child(3)))
            results.0.attr('id').should.equal "foo"

    describe '.nthLastChild()'

        it "finds the nth last child element"
            results = select(dsl.descendant('div').where(dsl.nth last child(3)))
            results.0.attr('id').should.equal "moar"

    describe '.firstChild()'

        it "finds the first child element"
            results = select(dsl.descendant('div').where(dsl.first child()))
            results.0.attr('id').should.equal "bar"

    describe '.onlyChild()'

        it "finds the only child element"
            results = select(dsl.descendant().where(dsl.only child()))
            results.0.name.should.equal 'li'

    describe '.startsWith()'

        it "finds nodes that begin with the given string"
            results = select(dsl.descendant('*').where(dsl.attr('id').starts with('foo')))
            results.length.should.equal 2
            results.0.attr('id').should.equal "foo"
            results.1.attr('id').should.equal "fooDiv"

        it "finds nodes that start with the given expression"
            expression = dsl.anywhere('div').where(dsl.attr('title').equals 'fooDiv').attr('id')
            results = select(dsl.descendant('div').where(dsl.attr('title').starts with(expression)))
            results.0.attr('id').should.equal "foo"

    describe '.endsWith()'

        it "finds nodes that end with the given string"
            results = select(dsl.descendant('*').where(dsl.attr('title').ends with('ooDiv')))
            results.length.should.equal 2
            results.0.attr('id').should.equal "foo"
            results.1.attr('id').should.equal "woo"

        it "finds nodes that end with the given expression"
            expression = dsl.concat('ooD', 'iv')
            results = select(dsl.descendant('*').where(dsl.attr('title').ends with(expression)))
            results.length.should.equal 2
            results.0.attr('id').should.equal "foo"
            results.1.attr('id').should.equal "woo"

    describe '.text()'

        it "selects a node's text"
            results = select(dsl.descendant('p').where(dsl.text().equals 'Bax'))
            results.0.text().should.equal 'Bax'
            results.1.attr('title').should.equal 'monkey'
            results := select(dsl.descendant('div').where(dsl.descendant('p').text().equals 'Bax'))
            results.0.attr('title').should.equal 'fooDiv'

    describe '.substring()'

        describe "when called with one argument"

            it "selects the part of a string after the specified character"
                results = select(dsl.descendant('span').where(dsl.attr('id').equals "substring").text().substring(7))
                results.should.equal "there"

        describe "when called with two arguments"

            it "selects the part of a string after the specified character, up to the given length"
                results = select(dsl.descendant('span').where(dsl.attr('id').equals "substring").text().substring(2, 4))
                results.should.equal "ello"

    describe '.stringLength()'

        it "returns the length of a string"
            results = select(dsl.descendant('span').where(dsl.attr('id').equals "string-length").text().string length())
            results.should.equal 11

    describe '.where()'

        it "limits the expression to find only certain nodes"
            select(dsl.descendant('div').where(dsl.attr('id').equals 'foo')).0.attr('title').should.equal "fooDiv"

    describe '.inverse()'

        it "inverts the expression"
            select(dsl.descendant('p').where(dsl.attr('id').equals('fooDiv').inverse())).0.text().should.equal 'Bax'

    describe '.equals()'

        it "limits the expression to find only certain nodes"
            select(dsl.descendant('div').where(dsl.attr('id').equals('foo'))).0.attr('title').should.equal "fooDiv"

    describe '.add()'

        it "adds numbers together"
            select(dsl.descendant().where(dsl.string length(dsl.attr('title')).add(1).equals(7))).0.attr('title').should.equal "barDiv"

    describe '.subtract()'

        it "subtracts a number"
            select(dsl.descendant().where(dsl.string length(dsl.attr('title')).subtract(1).equals(5))).0.attr('title').should.equal "barDiv"

    describe '.is()'

        it "uses equality when 'exact' is given"
            expression = dsl.descendant('div').where(dsl.attr('id').is('foo'))
            select(expression, 'exact').0.attr('title').should.equal "fooDiv"
            expression := dsl.descendant('div').where(dsl.attr('id').is('oo'))
            select(expression, 'exact').length.should.equal 0

        it "uses substring matching when 'exact' is not given"
            expression = dsl.descendant('div').where(dsl.attr('id').is('foo'))
            select(expression).0.attr('title').should.equal "fooDiv"
            expression := dsl.descendant('div').where(dsl.attr('id').is('oo'))
            select(expression).0.attr('title').should.equal "fooDiv"

    describe '.oneOf()'

        it "returns all nodes where the condition matches"
            p = dsl.anywhere('div').where(dsl.attr('id').equals 'foo').attr('title')
            results = select(dsl.descendant('*').where(dsl.attr('id').one of('foo', p, 'baz')))
            results.0.attr('title').should.equal "fooDiv"
            results.1.text().should.equal "Blah"
            results.2.attr('title').should.equal "bazDiv"

    describe '.and()'

        it "finds all nodes in both expressions"
            results = select(dsl.descendant('*').where(dsl.contains('Bax').and(dsl.attr('title').equals('monkey'))))
            results.0.attr('title').should.equal "monkey"

    describe '.or()'

        it "finds all nodes in either expression"
            results = select(dsl.descendant('*').where(dsl.attr('id').equals('foo').or(dsl.attr('id').equals('fooDiv'))))
            results.0.attr('title').should.equal "fooDiv"
            results.1.text().should.equal "Blah"

    describe '.attr()'

        it "returns an attribute value"
            results = select(dsl.descendant('div').where(dsl.attr('id')))
            results.0.attr('title').should.equal "barDiv"
            results.1.attr('title').should.equal "fooDiv"

    describe '.name()'

        it "matches the node's name"
            results = select(dsl.descendant('*').where(dsl.name().equals 'ul'))
            results.0.text().should.equal "A list"

    describe '.union()'

        it "creates a union expression"
            expr1 = dsl.descendant('p')
            expr2 = dsl.descendant('div')
            collection = expr1.union(expr2)
            other1 = collection.where(dsl.attr('id').equals 'foo')
            other2 = collection.where(dsl.attr('id').equals 'fooDiv')
            select(other1).0.attr('title').should.equal 'fooDiv'
            select(other2).0.attr('id').should.equal 'fooDiv'

    describe '.literal()'

        it "embeds the string argument in the XPath without escaping anything"
            dsl.descendant().where(dsl.attr('x').equals(dsl.literal('foo'))).to XPath().should.equal('.//*[./@x = foo]')

    describe '.firstOfType()'

        it "selects the first element of the given type"
            first p = select(dsl.descendant('p').where(dsl.firstOfType()))
            first p.0.attr('id').should.equal 'fooDiv'

    describe '.lastOfType()'

        it "selects the last element of the given type"
            first p = select(dsl.descendant('p').where(dsl.lastOfType()))
            first p.0.attr('id').should.equal 'amingoflay'

    describe '.nthOfType()'

        it "selects the nth element of the given type"
            nth = select(dsl.descendant('div').where(dsl.nthOfType(4)))
            nth.length.should.equal 1
            nth.0.attr('id').should.equal 'woo'

    describe '.nthLastOfType()'

        it "selects the nth last element of the given type"
            second last p = select(dsl.descendant('p').where(dsl.nthLastOfType(2)))
            second last p.0.attr('id').should.equal 'impchay'
