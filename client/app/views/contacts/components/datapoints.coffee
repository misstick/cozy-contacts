ContactDatapointView = require 'views/contacts/components/datapoint'

CONFIG = require('config').contact


module.exports = class ContactDatapointsView extends Mn.CollectionView

    tagName: ->
        if @options.cardViewModel.get 'edit' then 'fieldset' else 'ul'


    behaviors:
        Form: {}

    ui: ->
        ui =
            formInputs: ':input:not(button)'
            formDelete: 'button.delete'
        ui.formAutoAdd = '.value' unless @options.name is 'xtras'
        return ui


    childView: ContactDatapointView

    childViewOptions: (model, index)->
        _.extend _.pick(@options, 'name', 'cardViewModel'), index: index


    initialize: ->
        @_initializeEditMode() if @options.cardViewModel.get 'edit'


    _initializeEditMode: ->
        @addEmptyField() unless @options.name is 'xtras'


    onFormFieldAdd: (name) ->
        @addEmptyField name


    onFormFieldUpdate: (el) ->
        $item = @$(el).parents '[data-cid]'
        model = @collection.get $item.data 'cid'
        attrs = _.reduce $item.find(':input').serializeArray(), (memo, input) ->
            memo[_.last(input.name.split '.')] = input.value
            return memo
        , {}
        model.set attrs


    onFormFieldDelete: (id) ->
        @collection.remove id


    getDatapoints: ->
        @collection.filter (model) -> not _.isEmpty model.get('value')


    addEmptyField: (name) ->
        model = @collection.add
            type:  undefined
            value: ''
            name:  name or @options.name

        return if name in CONFIG.datapoints.main

        @$("[data-cid=#{model.cid}] input.value").focus()