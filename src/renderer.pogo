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

    substring function (current, args, ...) =
        "substring(#(current), #(args.join(', ')))"

    concat function (args) =
        "concat(#(args.join(', ')))"

    string length function (current) =
        "string-length(#(current))"

}

Renderer.render (node, type) =
    if (typeof (type) == 'undefined') @{ type := '*' }
    @new Renderer (type).render (node)

exports.Renderer = Renderer