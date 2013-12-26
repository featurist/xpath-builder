(function() {
    var self = this;
    var HTML;
    HTML = function() {
        return this;
    };
    HTML.prototype = require("./dsl").dsl();
    HTML.prototype.link = function(locator) {
        var self = this;
        locator = locator.toString();
        return self.descendant("a").where(self.attr("href")).where(self.attr("id").equals(locator).or(self.string().n().is(locator)).or(self.attr("title").is(locator)).or(self.descendant("img").where(self.attr("alt").is(locator))));
    };
    HTML.prototype.button = function(locator) {
        var self = this;
        locator = locator.toString();
        return self.descendant("input").where(self.attr("type").oneOf("submit", "reset", "image", "button")).where(self.attr("id").equals(locator).or(self.attr("value").is(locator)).or(self.attr("title").is(locator))).union(self.descendant("button").where(self.attr("id").equals(locator).or(self.attr("value").is(locator)).or(self.string().n().is(locator)).or(self.attr("title").is(locator)))).union(self.descendant("input").where(self.attr("type").equals("image")).where(self.attr("alt").is(locator)));
    };
    HTML.prototype.linkOrButton = function(locator) {
        var self = this;
        return self.link(locator).union(self.button(locator));
    };
    HTML.prototype.fieldset = function(locator) {
        var self = this;
        locator = locator.toString();
        return self.descendant("fieldset").where(self.attr("id").equals(locator).or(self.child("legend").where(self.string().n().is(locator))));
    };
    HTML.prototype.field = function(locator) {
        var self = this;
        var xpath;
        xpath = self.descendant("input", "textarea", "select").where(self.attr("type").oneOf("submit", "image", "hidden").inverse());
        return self.locateField(xpath, locator);
    };
    HTML.prototype.fillableField = function(locator) {
        var self = this;
        var xpath;
        xpath = self.descendant("input", "textarea").where(self.attr("type").oneOf("submit", "image", "radio", "checkbox", "hidden", "file").inverse());
        return self.locateField(xpath, locator.toString());
    };
    HTML.prototype.select = function(locator) {
        var self = this;
        return self.locateField(self.descendant("select"), locator);
    };
    HTML.prototype.checkbox = function(locator) {
        var self = this;
        return self.locateField(self.descendant("input").where(self.attr("type").equals("checkbox")), locator);
    };
    HTML.prototype.radioButton = function(locator) {
        var self = this;
        return self.locateField(self.descendant("input").where(self.attr("type").equals("radio")), locator);
    };
    HTML.prototype.fileField = function(locator) {
        var self = this;
        return self.locateField(self.descendant("input").where(self.attr("type").equals("file")), locator);
    };
    HTML.prototype.optgroup = function(locator) {
        var self = this;
        return self.descendant("optgroup").where(self.attr("label").is(locator.toString()));
    };
    HTML.prototype.option = function(locator) {
        var self = this;
        return self.descendant("option").where(self.string().n().is(locator.toString()));
    };
    HTML.prototype.table = function(locator) {
        var self = this;
        locator = locator.toString();
        return self.descendant("table").where(self.attr("id").equals(locator).or(self.descendant("caption").is(locator)));
    };
    HTML.prototype.definitionDescription = function(locator) {
        var self = this;
        locator = locator.toString();
        return self.descendant("dd").where(self.attr("id").equals(locator).or(self.previousSibling("dt").where(self.string().n().equals(locator))));
    };
    HTML.prototype.locateField = function(xpath, locator) {
        var self = this;
        locator = locator.toString();
        return xpath.where(self.attr("id").equals(locator).or(self.attr("name").equals(locator)).or(self.attr("placeholder").equals(locator)).or(self.attr("id").equals(self.anywhere("label").where(self.string().n().is(locator)).attr("for")))).union(self.descendant("label").where(self.string().n().is(locator)).descendant(xpath));
    };
    module.exports = new HTML();
}).call(this);