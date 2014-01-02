Renderer (type) =
    this.type = type
    this

Renderer.prototype = {

    render (node) =
        a = node.args.map @(arg) @{ self.convert argument (arg) }
        self.(node.expression).apply (self, a)

    convert argument (argument) =
        if ((argument.is expression) || (argument.is union))
            self.render (argument)
        else if (argument :: Array)
            argument.map @(e) @{ self.convert argument(e) }
        else if (argument :: String)
            self.string literal (argument)
        else if (argument :: Number)
            argument
        else if (argument.is literal)
            argument.value
        else
            argument.to string()

    string literal (string) =
        if (string.index of ("'") > -1)
            string := string.split("'", -1).map(
                @(substr) @{ "'#(substr)'" }
            ).join(',"''",')
            "concat(#(string))"
        else
            "'#(string)'"

    this node () =
      '.'

    descendant (parent, element names) =
        if (element names.length == 1)
            "#(parent)//#(element names.0)"
        else if (element names.length > 1)
            names = element names.map @(e) @{ "self::#(e)" }
            "#(parent)//*[#(names.join(' | '))]"
        else
            "#(parent)//*"

    child (parent, element names) =
        if (element names.length == 1)
            "#(parent)/#(element names.0)"
        else if (element names.length > 1)
            names = element names.map @(e) @{ "self::#(e)" }
            "#(parent)/*[#(names.join(' | '))]"
        else
            "#(parent)/*"

    axis (parent, name, tag name) =
        "#(parent)/#(name)::#(tag name)"

    node name (current) =
        "name(#(current))"

    where (on, condition) =
        "#(on)[#(condition)]"

    attribute (current, name) =
        "#(current)/@#(name)"

    equality (one, two) =
        "#(one) = #(two)"

    addition (one, two) =
        "#(one) + #(two)"

    subtraction (one, two) =
        "#(one) - #(two)"

    is (one, two) =
        if (self.type == 'exact')
            self.equality (one, two)
        else
            self.contains (one, two)

    variable (name) =
        "%{#(name)}"

    text (current) =
        "#(current)/text()"

    normalized space (current) =
        "normalize-space(#(current))"

    literal (node) =
        node

    union (expressions, ...) =
        expressions.join(' | ')

    anywhere (element names) =
        if (element names.length == 1)
            "//#(element names.0)"
        else if (element names.length > 1)
            names = element names.map(@(e) @{ "self::#(e)" }).join " | "
            "//*[#(names)]"
        else
            "//*"

    contains (current, value) =
        "contains(#(current), #(value))"

    starts with (current, value) =
        "starts-with(#(current), #(value))"

    ends with (current, value) =
        "substring(#(current), string-length(#(current)) - string-length(#(value)) + 1, string-length(#(current))) = #(value)"

    and (one, two) =
        "(#(one) and #(two))"

    or (one, two) =
        "(#(one) or #(two))"

    one of (current, values) =
        values.map(@(value) @{ "#(current) = #(value)" }).join(' or ')

    next sibling (current, element names) =
        if (element names.length == 1)
            "#(current)/following-sibling::*[1]/self::#(element names.0)"
        else if (element names.length > 1)
            names = element names.map @(e) @{ "self::#(e)" }
            "#(current)/following-sibling::*[1]/self::*[#(names.join(' | '))]"
        else
            "#(current)/following-sibling::*[1]/self::*"

    previous sibling (current, element names) =
        if (element names.length == 1)
            "#(current)/preceding-sibling::*[1]/self::#(element names.0)"
        else if (element names.length > 1)
            names = element names.map @(e) @{ "self::#(e)" }
            "#(current)/preceding-sibling::*[1]/self::*[#(names.join(" | "))]"
        else
            "#(current)/preceding-sibling::*[1]/self::*"

    inverse (current) =
        "not(#(current))"

    string function (current) =
        "string(#(current))"

    substring function (current, args) =
        "substring(#(current), #(args.join(', ')))"

    concat function (args) =
        "concat(#(args.join(', ')))"

    string length function (current) =
        "string-length(#(current))"

    count function (current) =
        "count(#(current))"

    nth of type (n) =
        "position() = #(n)"

    nth of type mod (m, n) =
        if (m == -1)
            "(position() <= #(n)) and (((position() - #(n)) mod 1) = 0)"
        else if (n > 0)
            "(position() >= #(n)) and (((position() - #(n)) mod #(m)) = 0)"
        else
            "(position() mod #(m)) = 0"

    nth of type odd () =
        "(position() mod 2) = 1"

    nth of type even () =
        "(position() mod 2) = 0"

    nth last of type (n) =
        "position() = last() - #(n - 1)"

    nth last of type mod (m, n) =
        if (m == -1)
            "((last() - position() + 1) <= #(n)) and ((((last() - position() + 1) - #(n)) mod 1) = 0)"
        else if (n > 0)
            "((last() - position() + 1) >= #(n)) and ((((last() - position() + 1) - #(n)) mod #(m)) = 0)"
        else
            "((last() - position() + 1) mod #(m)) = 0"

    nth last of type odd () =
        "((last() - position() + 1) >= 1) and ((((last() - position() + 1) - 1) mod 2) = 0)"

    nth last of type even () =
        "((last() - position() + 1) mod 2) = 0"

    last of type () =
        "position() = last()"

    nth child (n) =
        "count(preceding-sibling::*) = #(n - 1)"

    nth last child (n) =
        "count(following-sibling::*) = #(n - 1)"

    first child () =
        "count(preceding-sibling::*) = 0"

    last child () =
        "count(following-sibling::*) = 0"

    only child () =
        "count(preceding-sibling::*) = 0 and count(following-sibling::*) = 0"

    only of type () =
        "last() = 1"

    empty () =
        "not(node())"

}

Renderer.render (node, type) =
    if (typeof (type) == 'undefined') @{ type := '*' }
    @new Renderer (type).render (node)

exports.Renderer = Renderer