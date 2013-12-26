HTML () = this

HTML.prototype = require './dsl'.dsl()

HTML.prototype.link (locator) =
    locator := locator.to string()
    self.descendant('a').where(self.attr('href')).where (
        self.attr('id').equals(locator).or (
            self.string().n().is(locator)
        ).or (
            self.attr('title').is(locator)
        ).or (
            self.descendant('img').where(self.attr('alt').is(locator))
        )
    )

HTML.prototype.button (locator) =
    locator := locator.to string()
    self.descendant('input').where(
        self.attr('type').one of('submit', 'reset', 'image', 'button')
    ).where(
        self.attr('id').equals(locator).or(
            self.attr('value').is(locator)
        ).or(
            self.attr('title').is(locator)
        )
    ).union(
        self.descendant('button').where(
            self.attr('id').equals(locator).or(
                self.attr('value').is(locator)
            ).or(
                self.string().n().is(locator)
            ).or(
                self.attr('title').is(locator)
            )
        )
    ).union(
        self.descendant('input').where(
            self.attr('type').equals('image')
        ).where(
            self.attr('alt').is(locator)
        )
    )

HTML.prototype.link or button (locator) =
    self.link(locator).union(self.button(locator))

HTML.prototype.fieldset (locator) =
    locator := locator.to string()
    self.descendant('fieldset').where(
        self.attr('id').equals(locator).or(
            self.child('legend').where(self.string().n().is(locator))
        )
    )

HTML.prototype.field (locator) =
    xpath = self.descendant ('input', 'textarea', 'select').where(self.attr('type').one of('submit', 'image', 'hidden').inverse())
    self.locate field (xpath, locator)

HTML.prototype.fillableField (locator) =
    xpath = self.descendant('input', 'textarea').where(
        self.attr('type').one of('submit', 'image', 'radio', 'checkbox', 'hidden', 'file').inverse()
    )
    self.locate field(xpath, locator.to string())

HTML.prototype.select (locator) =
    self.locate field(self.descendant('select'), locator)

HTML.prototype.checkbox (locator) =
    self.locate field(self.descendant('input').where(self.attr('type').equals('checkbox')), locator)

HTML.prototype.radio button (locator) =
    self.locate field(self.descendant('input').where(self.attr('type').equals('radio')), locator)

HTML.prototype.file field (locator) =
    self.locate field(self.descendant('input').where(self.attr('type').equals('file')), locator)

HTML.prototype.optgroup (locator) =
    self.descendant('optgroup').where(self.attr('label').is(locator.to string()))

HTML.prototype.option (locator) =
    self.descendant('option').where(self.string().n().is(locator.to string()))

HTML.prototype.table(locator) =
    locator := locator.to string()
    self.descendant('table').where(self.attr('id').equals(locator).or(self.descendant('caption').is(locator)))

HTML.prototype.definition description (locator) =
    locator := locator.to string()
    self.descendant('dd').where(
        self.attr('id').equals(locator).or(
            self.previous sibling('dt').where(self.string().n().equals(locator))
        )
    )

HTML.prototype.locate field (xpath, locator) =
    locator := locator.to string()
    xpath.where(
        self.attr('id').equals(locator).or(
            self.attr('name').equals(locator)
        ).or(
            self.attr('placeholder').equals(locator)
        ).or(
            self.attr('id').equals(self.anywhere('label').where(self.string().n().is(locator)).attr('for'))
        )
    ).union(
        self.descendant('label').where(
            self.string().n().is(locator)
        ).descendant (xpath)
    )

module.exports = @new HTML()
