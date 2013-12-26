xpath = require 'xpath'
dom = require('xmldom').DOMParser
html = require '../js/html'
cheerio = require 'cheerio'

load (template) as doc =
    html = require('fs').read file sync "#(__dirname)/fixtures/#(template)"
    @new dom().parse from string(html.to string())

describe 'html'

    doc = load 'form.html' as doc
    type = nil
    subject = nil
    not a string (str) = { to string() = str.to string() }

    describe (behaviour, description) =
        global.describe (behaviour)
            if (behaviour.index of '.' == 0)
                before @{ subject := behaviour.replace(r/[\.\(\)]/g, '') }

            if (behaviour == 'with exact match')
                before @{ type := 'exact' }
            else
                before @{ type := nil }

            description ()

    get(text) =
        expression = html.(subject).call(html, text)
        xp = expression.to XPath(type)
        elements = xpath.select(xp, doc)
        if (elements.length > 0)
            cheerio(elements.0.to string()).attr('data')
        else
            []

    describe '.link()'

        it("finds links by id")                                @{ get('some-id').should.equal 'link-id' }
        it("finds links by content")                           @{ get('An awesome link').should.equal 'link-text' }
        it("finds links by content regardless of whitespace")  @{ get('My whitespaced link').should.equal 'link-whitespace' }
        it("finds links with child tags by content")           @{ get('An emphatic link').should.equal 'link-children' }
        it("finds links by the content of their child tags")   @{ get('emphatic').should.equal 'link-children' }
        it("finds links by approximate content")               @{ get('awesome').should.equal 'link-text' }
        it("finds links by title")                             @{ get('My title').should.equal 'link-title' }
        it("finds links by approximate title")                 @{ get('title').should.equal 'link-title' }
        it("finds links by image's alt attribute")             @{ get('Alt link').should.equal 'link-img' }
        it("finds links by image's approximate alt attribute") @{ get('Alt').should.equal 'link-img' }
        it("does not find links without href attributes")      @{ get('Wrong Link').length.should.equal 0 }
        it("casts to string")                                  @{ get(not a string('some-id')).should.equal 'link-id' }

        describe "with exact match"

            it("finds links by content")                                   @{ get('An awesome link').should.equal 'link-text' }
            it("does not find links by approximate content")               @{ get('awesome').length.should.equal 0 }
            it("finds links by title")                                     @{ get('My title').should.equal 'link-title' }
            it("does not find links by approximate title")                 @{ get('title').length.should.equal 0 }
            it("finds links by image's alt attribute")                     @{ get('Alt link').should.equal 'link-img' }
            it("does not find links by image's approximate alt attribute") @{ get('Alt').length.should.equal 0 }

    describe '.button()'

        describe "with submit type"

            it("finds buttons by id")                @{ get('submit-with-id').should.equal 'id-submit' }
            it("finds buttons by value")             @{ get('submit-with-value').should.equal 'value-submit' }
            it("finds buttons by approximate value") @{ get('mit-with-val').should.equal 'value-submit' }
            it("finds buttons by title")             @{ get('My submit title').should.equal 'title-submit' }
            it("finds buttons by approximate title") @{ get('submit title').should.equal 'title-submit' }

            describe "with exact match"

                it("finds buttons by value")                     @{ get('submit-with-value').should.equal 'value-submit' }
                it("does not find buttons by approximate value") @{ get('mit-with-val').length.should.equal 0 }
                it("finds buttons by title")                     @{ get('My submit title').should.equal 'title-submit' }
                it("does not find buttons by approximate title") @{ get('submit title').length.should.equal 0 }

        describe "with reset type"

            it("finds buttons by id")                @{ get('reset-with-id').should.equal 'id-reset' }
            it("finds buttons by value")             @{ get('reset-with-value').should.equal 'value-reset' }
            it("finds buttons by approximate value") @{ get('set-with-val').should.equal 'value-reset' }
            it("finds buttons by title")             @{ get('My reset title').should.equal 'title-reset' }
            it("finds buttons by approximate title") @{ get('reset title').should.equal 'title-reset' }

            describe "with exact match"

                it("finds buttons by value")                     @{ get('reset-with-value').should.equal 'value-reset' }
                it("does not find buttons by approximate value") @{ get('set-with-val').length.should.equal 0 }
                it("finds buttons by title")                     @{ get('My reset title').should.equal 'title-reset' }
                it("does not find buttons by approximate title") @{ get('reset title').length.should.equal 0 }

        describe "with button type"

            it("finds buttons by id")                @{ get('button-with-id').should.equal 'id-button' }
            it("finds buttons by value")             @{ get('button-with-value').should.equal 'value-button' }
            it("finds buttons by approximate value") @{ get('ton-with-val').should.equal 'value-button' }
            it("finds buttons by title")             @{ get('My button title').should.equal 'title-button' }
            it("finds buttons by approximate title") @{ get('button title').should.equal 'title-button' }

            describe "with exact match"

                it("finds buttons by value")                     @{ get('button-with-value').should.equal 'value-button' }
                it("does not find buttons by approximate value") @{ get('ton-with-val').length.should.equal 0 }
                it("finds buttons by title")                     @{ get('My button title').should.equal 'title-button' }
                it("does not find buttons by approximate title") @{ get('button title').length.should.equal 0 }

        describe "with image type"

            it("finds buttons by id")                        @{ get('imgbut-with-id').should.equal 'id-imgbut' }
            it("finds buttons by value")                     @{ get('imgbut-with-value').should.equal 'value-imgbut' }
            it("finds buttons by approximate value")         @{ get('gbut-with-val').should.equal 'value-imgbut' }
            it("finds buttons by alt attribute")             @{ get('imgbut-with-alt').should.equal 'alt-imgbut' }
            it("finds buttons by approximate alt attribute") @{ get('mgbut-with-al').should.equal 'alt-imgbut' }
            it("finds buttons by title")                     @{ get('My imgbut title').should.equal 'title-imgbut' }
            it("finds buttons by approximate title")         @{ get('imgbut title').should.equal 'title-imgbut' }

            describe "with exact match"

                it("finds buttons by value")                             @{ get('imgbut-with-value').should.equal 'value-imgbut' }
                it("does not find buttons by approximate value")         @{ get('gbut-with-val').length.should.equal 0 }
                it("finds buttons by alt attribute")                     @{ get('imgbut-with-alt').should.equal 'alt-imgbut' }
                it("does not find buttons by approximate alt attribute") @{ get('mgbut-with-al').length.should.equal 0 }
                it("finds buttons by title")                             @{ get('My imgbut title').should.equal 'title-imgbut' }
                it("does not find buttons by approximate title")         @{ get('imgbut title').length.should.equal 0 }

        describe "with button tag"

            it("finds buttons by id")                       @{ get('btag-with-id').should.equal 'id-btag' }
            it("finds buttons by value")                    @{ get('btag-with-value').should.equal 'value-btag' }
            it("finds buttons by approximate value")        @{ get('tag-with-val').should.equal 'value-btag' }
            it("finds buttons by text")                     @{ get('btag-with-text').should.equal 'text-btag' }
            it("finds buttons by text ignoring whitespace") @{ get('My whitespaced button').should.equal 'btag-with-whitespace' }
            it("finds buttons by approximate text ")        @{ get('tag-with-tex').should.equal 'text-btag' }
            it("finds buttons with child tags by text")     @{ get('An emphatic button').should.equal 'btag-with-children' }
            it("finds buttons by text of their children")   @{ get('emphatic').should.equal 'btag-with-children' }
            it("finds buttons by title")                    @{ get('My btag title').should.equal 'title-btag' }
            it("finds buttons by approximate title")        @{ get('btag title').should.equal 'title-btag' }

            describe "with exact match"

                it("finds buttons by value")                     @{ get('btag-with-value').should.equal 'value-btag' }
                it("does not find buttons by approximate value") @{ get('tag-with-val').length.should.equal 0 }
                it("finds buttons by text")                      @{ get('btag-with-text').should.equal 'text-btag' }
                it("does not find buttons by approximate text ") @{ get('tag-with-tex').length.should.equal 0 }
                it("finds buttons by title")                     @{ get('My btag title').should.equal 'title-btag' }
                it("does not find buttons by approximate title") @{ get('btag title').length.should.equal 0 }

        describe "with unknown type"

            it("does not find the button") @{ get('schmoo button').length.should.equal 0 }

        it("casts to string") @{ get(not a string('tag-with-tex')).should.equal 'text-btag' }

    describe '.linkOrButton()'

        it("finds links")   @{ get('some-id').should.equal 'link-id' }
        it("finds buttons") @{ get('My whitespaced button').should.equal 'btag-with-whitespace' }

        describe "with exact match"

            it("finds links by content")                     @{ get('An awesome link').should.equal 'link-text' }
            it("does not find links by approximate content") @{ get('awesome').length.should.equal 0 }

    describe '.fieldset()'

        it("finds fieldsets by id")                  @{ get('some-fieldset-id').should.equal 'fieldset-id' }
        it("finds fieldsets by legend")              @{ get('Some Legend').should.equal 'fieldset-legend' }
        it("finds fieldsets by legend child tags")   @{ get('Span Legend').should.equal 'fieldset-legend-span' }
        it("accepts approximate legends")            @{ get('Legend').should.equal 'fieldset-legend' }
        it("finds nested fieldsets by legend")       @{ get('Inner legend').should.equal 'fieldset-inner' }
        it("casts to string")                        @{ get(not a string('Inner legend')).should.equal 'fieldset-inner' }

        describe "with exact match"

            it("finds fieldsets by legend")            @{ get('Some Legend').should.equal 'fieldset-legend' }
            it("does not find by approximate legends") @{ get('Legend').length.should.equal 0 }

    describe '.field()'

        describe "by id"

            it("finds inputs with no type")       @{ get('input-with-id').should.equal 'input-with-id-data' }
            it("finds inputs with text type")     @{ get('input-text-with-id').should.equal 'input-text-with-id-data' }
            it("finds inputs with password type") @{ get('input-password-with-id').should.equal 'input-password-with-id-data' }
            it("finds inputs with custom type")   @{ get('input-custom-with-id').should.equal 'input-custom-with-id-data' }
            it("finds textareas")                 @{ get('textarea-with-id').should.equal 'textarea-with-id-data' }
            it("finds select boxes")              @{ get('select-with-id').should.equal 'select-with-id-data' }
            it("does not find submit buttons")    @{ get('input-submit-with-id').length.should.equal 0 }
            it("does not find image buttons")     @{ get('input-image-with-id').length.should.equal 0 }
            it("does not find hidden fields")     @{ get('input-hidden-with-id').length.should.equal 0 }

        describe "by name"

            it("finds inputs with no type")       @{ get('input-with-name').should.equal 'input-with-name-data' }
            it("finds inputs with text type")     @{ get('input-text-with-name').should.equal 'input-text-with-name-data' }
            it("finds inputs with password type") @{ get('input-password-with-name').should.equal 'input-password-with-name-data' }
            it("finds inputs with custom type")   @{ get('input-custom-with-name').should.equal 'input-custom-with-name-data' }
            it("finds textareas")                 @{ get('textarea-with-name').should.equal 'textarea-with-name-data' }
            it("finds select boxes")              @{ get('select-with-name').should.equal 'select-with-name-data' }
            it("does not find submit buttons")    @{ get('input-submit-with-name').length.should.equal 0 }
            it("does not find image buttons")     @{ get('input-image-with-name').length.should.equal 0 }
            it("does not find hidden fields")     @{ get('input-hidden-with-name').length.should.equal 0 }

        describe "by placeholder"

            it("finds inputs with no type")       @{ get('input-with-placeholder').should.equal 'input-with-placeholder-data' }
            it("finds inputs with text type")     @{ get('input-text-with-placeholder').should.equal 'input-text-with-placeholder-data' }
            it("finds inputs with password type") @{ get('input-password-with-placeholder').should.equal 'input-password-with-placeholder-data' }
            it("finds inputs with custom type")   @{ get('input-custom-with-placeholder').should.equal 'input-custom-with-placeholder-data' }
            it("finds textareas")                 @{ get('textarea-with-placeholder').should.equal 'textarea-with-placeholder-data' }
            it("does not find hidden fields")     @{ get('input-hidden-with-placeholder').length.should.equal 0 }

        describe "by referenced label"

            it("finds inputs with no type")       @{ get('Input with label').should.equal 'input-with-label-data' }
            it("finds inputs with text type")     @{ get('Input text with label').should.equal 'input-text-with-label-data' }
            it("finds inputs with password type") @{ get('Input password with label').should.equal 'input-password-with-label-data' }
            it("finds inputs with custom type")   @{ get('Input custom with label').should.equal 'input-custom-with-label-data' }
            it("finds textareas")                 @{ get('Textarea with label').should.equal 'textarea-with-label-data' }
            it("finds select boxes")              @{ get('Select with label').should.equal 'select-with-label-data' }
            it("does not find submit buttons")    @{ get('Input submit with label').length.should.equal 0 }
            it("does not find image buttons")     @{ get('Input image with label').length.should.equal 0 }
            it("does not find hidden fields")     @{ get('Input hidden with label').length.should.equal 0 }

        describe "by parent label"

            it("finds inputs with no type")       @{ get('Input with parent label').should.equal 'input-with-parent-label-data' }
            it("finds inputs with text type")     @{ get('Input text with parent label').should.equal 'input-text-with-parent-label-data' }
            it("finds inputs with password type") @{ get('Input password with parent label').should.equal 'input-password-with-parent-label-data' }
            it("finds inputs with custom type")   @{ get('Input custom with parent label').should.equal 'input-custom-with-parent-label-data' }
            it("finds textareas")                 @{ get('Textarea with parent label').should.equal 'textarea-with-parent-label-data' }
            it("finds select boxes")              @{ get('Select with parent label').should.equal 'select-with-parent-label-data' }
            it("does not find submit buttons")    @{ get('Input submit with parent label').length.should.equal 0 }
            it("does not find image buttons")     @{ get('Input image with parent label').length.should.equal 0 }
            it("does not find hidden fields")     @{ get('Input hidden with parent label').length.should.equal 0 }

        it("casts to string") @{ get(not a string 'select-with-id').should.equal 'select-with-id-data' }

    describe '.fillableField()'

        describe "by parent label"

            it("finds inputs with text type")                    @{ get('Label text').should.equal 'id-text' }
            it("finds inputs where label has problem chars")     @{ get("Label text's got an apostrophe").should.equal 'id-problem-text' }

    describe '.select()'

        it("finds selects by id")             @{ get('select-with-id').should.equal 'select-with-id-data' }
        it("finds selects by name")           @{ get('select-with-name').should.equal 'select-with-name-data' }
        it("finds selects by label")          @{ get('Select with label').should.equal 'select-with-label-data' }
        it("finds selects by parent label")   @{ get('Select with parent label').should.equal 'select-with-parent-label-data' }
        it("casts to string")                 @{ get(not a string 'Select with parent label').should.equal 'select-with-parent-label-data' }

    describe '.checkbox()'

        it("finds checkboxes by id")           @{ get('input-checkbox-with-id').should.equal 'input-checkbox-with-id-data' }
        it("finds checkboxes by name")         @{ get('input-checkbox-with-name').should.equal 'input-checkbox-with-name-data' }
        it("finds checkboxes by label")        @{ get('Input checkbox with label').should.equal 'input-checkbox-with-label-data' }
        it("finds checkboxes by parent label") @{ get('Input checkbox with parent label').should.equal 'input-checkbox-with-parent-label-data' }
        it("casts to string")                  @{ get(not a string 'Input checkbox with parent label').should.equal 'input-checkbox-with-parent-label-data' }

    describe '.radioButton()'

        it("finds radio buttons by id")           @{ get('input-radio-with-id').should.equal 'input-radio-with-id-data' }
        it("finds radio buttons by name")         @{ get('input-radio-with-name').should.equal 'input-radio-with-name-data' }
        it("finds radio buttons by label")        @{ get('Input radio with label').should.equal 'input-radio-with-label-data' }
        it("finds radio buttons by parent label") @{ get('Input radio with parent label').should.equal 'input-radio-with-parent-label-data' }
        it("casts to string")                     @{ get(not a string 'Input radio with parent label').should.equal 'input-radio-with-parent-label-data' }

    describe '.fileField()'

        it("finds file fields by id")           @{ get('input-file-with-id').should.equal 'input-file-with-id-data' }
        it("finds file fields by name")         @{ get('input-file-with-name').should.equal 'input-file-with-name-data' }
        it("finds file fields by label")        @{ get('Input file with label').should.equal 'input-file-with-label-data' }
        it("finds file fields by parent label") @{ get('Input file with parent label').should.equal 'input-file-with-parent-label-data' }
        it("casts to string")                   @{ get(not a string  'Input file with parent label').should.equal 'input-file-with-parent-label-data' }

    describe '.optgroup()'

        it("finds optgroups by label")             @{ get('Group A').should.equal 'optgroup-a' }
        it("finds optgroups by approximate label") @{ get('oup A').should.equal 'optgroup-a' }
        it("casts to string")                      @{ get(not a string 'Group A').should.equal 'optgroup-a' }

        describe 'with exact match'

            it("finds by label")                     @{ get('Group A').should.equal 'optgroup-a' }
            it("does not find by approximate label") @{ get('oup A').length.should.equal 0 }

    describe '.option()'

        it("finds by text")             @{ get('Option with text').should.equal 'option-with-text-data' }
        it("finds by approximate text") @{ get('Option with').should.equal 'option-with-text-data' }
        it("casts to string")           @{ get(not a string 'Option with text').should.equal 'option-with-text-data' }

        describe "with exact match"

            it("finds by text")                     @{ get('Option with text').should.equal 'option-with-text-data' }
            it("does not find by approximate text") @{ get('Option with').length.should.equal 0 }

    describe ".table()"

        it("finds by id")                  @{ get('table-with-id').should.equal 'table-with-id-data' }
        it("finds by caption")             @{ get('Table with caption').should.equal 'table-with-caption-data' }
        it("finds by approximate caption") @{ get('Table with').should.equal 'table-with-caption-data' }
        it("casts to string")              @{ get(not a string 'Table with caption').should.equal 'table-with-caption-data' }

        describe "with exact match"

            it("finds by caption")                     @{ get('Table with caption').should.equal 'table-with-caption-data' }
            it("does not find by approximate caption") @{ get('Table with').length.should.equal 0 }

    describe ".definitionDescription()"

        before
            doc := load 'stuff.html' as doc

        it("finds definition description by id")   @{ get('latte').should.equal "with-id" }
        it("finds definition description by term") @{ get("Milk").should.equal "with-dt" }
        it("casts to string")                      @{ get(not a string "Milk").should.equal "with-dt" }
