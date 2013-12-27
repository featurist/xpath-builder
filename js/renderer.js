(function() {
    var self = this;
    var Renderer;
    Renderer = function(type) {
        this.type = type;
        return this;
    };
    Renderer.prototype = {
        render: function(node) {
            var self = this;
            var a;
            a = node.args.map(function(arg) {
                return self.convertArgument(arg);
            });
            return self[node.expression].apply(self, a);
        },
        convertArgument: function(argument) {
            var self = this;
            if (argument.isExpression || argument.isUnion) {
                return self.render(argument);
            } else if (argument instanceof Array) {
                return argument.map(function(e) {
                    return self.convertArgument(e);
                });
            } else if (typeof argument === "string") {
                return self.stringLiteral(argument);
            } else if (argument.isLiteral) {
                return argument.value;
            } else {
                return argument.toString();
            }
        },
        stringLiteral: function(string) {
            var self = this;
            if (string.indexOf("'") > -1) {
                string = string.split("'", -1).map(function(substr) {
                    return "'" + substr + "'";
                }).join(',"\'",');
                return "concat(" + string + ")";
            } else {
                return "'" + string + "'";
            }
        },
        thisNode: function() {
            var self = this;
            return ".";
        },
        descendant: function(parent, elementNames) {
            var self = this;
            var names;
            if (elementNames.length === 1) {
                return parent + "//" + elementNames[0];
            } else if (elementNames.length > 1) {
                names = elementNames.map(function(e) {
                    return "self::" + e;
                });
                return parent + "//*[" + names.join(" | ") + "]";
            } else {
                return parent + "//*";
            }
        },
        child: function(parent, elementNames) {
            var self = this;
            var names;
            if (elementNames.length === 1) {
                return parent + "/" + elementNames[0];
            } else if (elementNames.length > 1) {
                names = elementNames.map(function(e) {
                    return "self::" + e;
                });
                return parent + "/*[" + names.join(" | ") + "]";
            } else {
                return parent + "/*";
            }
        },
        axis: function(parent, name, tagName) {
            var self = this;
            return parent + "/" + name + "::" + tagName;
        },
        nodeName: function(current) {
            var self = this;
            return "name(" + current + ")";
        },
        where: function(on, condition) {
            var self = this;
            return on + "[" + condition + "]";
        },
        attribute: function(current, name) {
            var self = this;
            return current + "/@" + name;
        },
        equality: function(one, two) {
            var self = this;
            return one + " = " + two;
        },
        addition: function(one, two) {
            var self = this;
            return one + " + " + two;
        },
        subtraction: function(one, two) {
            var self = this;
            return one + " - " + two;
        },
        is: function(one, two) {
            var self = this;
            if (self.type === "exact") {
                return self.equality(one, two);
            } else {
                return self.contains(one, two);
            }
        },
        variable: function(name) {
            var self = this;
            return "%{" + name + "}";
        },
        text: function(current) {
            var self = this;
            return current + "/text()";
        },
        normalizedSpace: function(current) {
            var self = this;
            return "normalize-space(" + current + ")";
        },
        literal: function(node) {
            var self = this;
            return node;
        },
        union: function() {
            var self = this;
            var expressions = Array.prototype.slice.call(arguments, 0, arguments.length);
            return expressions.join(" | ");
        },
        anywhere: function(elementNames) {
            var self = this;
            var names;
            if (elementNames.length === 1) {
                return "//" + elementNames[0];
            } else if (elementNames.length > 1) {
                names = elementNames.map(function(e) {
                    return "self::" + e;
                }).join(" | ");
                return "//*[" + names + "]";
            } else {
                return "//*";
            }
        },
        contains: function(current, value) {
            var self = this;
            return "contains(" + current + ", " + value + ")";
        },
        startsWith: function(current, value) {
            var self = this;
            return "starts-with(" + current + ", " + value + ")";
        },
        endsWith: function(current, value) {
            var self = this;
            return "substring(" + current + ", string-length(" + current + ") - string-length(" + value + ") + 1, string-length(" + current + ")) = " + value;
        },
        and: function(one, two) {
            var self = this;
            return "(" + one + " and " + two + ")";
        },
        or: function(one, two) {
            var self = this;
            return "(" + one + " or " + two + ")";
        },
        oneOf: function(current, values) {
            var self = this;
            return values.map(function(value) {
                return current + " = " + value;
            }).join(" or ");
        },
        nextSibling: function(current, elementNames) {
            var self = this;
            var names;
            if (elementNames.length === 1) {
                return current + "/following-sibling::*[1]/self::" + elementNames[0];
            } else if (elementNames.length > 1) {
                names = elementNames.map(function(e) {
                    return "self::" + e;
                });
                return current + "/following-sibling::*[1]/self::*[" + names.join(" | ") + "]";
            } else {
                return current + "/following-sibling::*[1]/self::*";
            }
        },
        previousSibling: function(current, elementNames) {
            var self = this;
            var names;
            if (elementNames.length === 1) {
                return current + "/preceding-sibling::*[1]/self::" + elementNames[0];
            } else if (elementNames.length > 1) {
                names = elementNames.map(function(e) {
                    return "self::" + e;
                });
                return current + "/preceding-sibling::*[1]/self::*[" + names.join(" | ") + "]";
            } else {
                return current + "/preceding-sibling::*[1]/self::*";
            }
        },
        inverse: function(current) {
            var self = this;
            return "not(" + current + ")";
        },
        stringFunction: function(current) {
            var self = this;
            return "string(" + current + ")";
        },
        substringFunction: function(current, args) {
            var self = this;
            return "substring(" + current + ", " + args.join(", ") + ")";
        },
        concatFunction: function(args) {
            var self = this;
            return "concat(" + args.join(", ") + ")";
        },
        stringLengthFunction: function(current) {
            var self = this;
            return "string-length(" + current + ")";
        }
    };
    Renderer.render = function(node, type) {
        var self = this;
        if (typeof type === "undefined") {
            type = "*";
        }
        return new Renderer(type).render(node);
    };
    exports.Renderer = Renderer;
}).call(this);