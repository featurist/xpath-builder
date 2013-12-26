(function() {
    var self = this;
    var Literal;
    Literal = function(value) {
        this.value = value;
        this.isLiteral = true;
        return this;
    };
    Literal.prototype.isLiteral = true;
    exports.Literal = Literal;
}).call(this);