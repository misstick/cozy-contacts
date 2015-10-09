DatapointsView  = require 'views/contacts/components/datapoints'
XtrasView       = require 'views/contacts/components/xtras'
EditActionsView = require 'views/contacts/components/edit_actions'
TagsActionsView = require 'views/contacts/components/edit_tags'

t = require 'lib/i18n'

CONFIG = require('config').contact


module.exports = class ContactCardView extends Mn.LayoutView

    template: require 'views/templates/contacts/card'

    tagName: 'section'

    className: 'card'

    attributes:
        role: 'dialog'


    behaviors: ->
        opts =
            name: @options.model.get 'fn'

        Navigator: {}
        Dialog:    {}
        Form:      {}
        Dropdown:  {}
        PickAvatar: {}
        Confirm:
            triggers:
                'click @ui.delete':
                    event:      'delete'
                    title:      t 'card confirm delete title', opts
                    message:    t 'card confirm delete message', opts
                    btn_ok:     t 'card confirm delete ok'
                    btn_cancel: t 'card confirm delete cancel'

    ui:
        navigate: '[href^=contacts], [data-next]'
        edit:     '.edit'
        delete:   '.delete'
        submit:   '[type=submit]'
        cancel:   '.cancel'
        inputs:   '.group:not([data-cid]) :input:not(button)'
        add:      '.add button'
        clear:    '.clear'
        avatar:   '.avatar'

    regions:
        'tags': '.edit.tags'


    modelEvents:
        'change:edit':     'render'
        'change:initials': 'updateInitials'
        'change':          'onModelChange'
        'before:save':     'syncDatapoints'
        'save':            'onSave'
        'destroy':         -> @triggerMethod 'dialog:close'


    childEvents:
        'form:key:enter': 'onFormKeyEnter'


    initialize: ->
        Mn.bindEntityEvents @model, @, @model.viewEvents


    serializeData: ->
        _.extend {}, super,
            lists: CONFIG.datapoints.types
            fullname: @model.toString pre: '<b>', post: '</b>'


    _renderDatapoints: ->
        @$('.datapoints').each (index, el) =>
            name = el.dataset.type
            @addRegion name, "[data-type=#{name}]"
            @showChildView name, new DatapointsView
                collection:    @model[name]
                name:          name
                cardViewModel: @model

        @addRegion 'xtras-infos', '[data-type=xtras-infos]'
        @showChildView 'xtras-infos', new XtrasView model: @model


    _renderEditActions: ->
        @addRegion 'actions', '.actions'
        @showChildView 'actions', new EditActionsView model: @model


    onRender: ->
        @showChildView 'tags', new TagsActionsView model: @model
        @_renderDatapoints()
        @_renderEditActions() if @model.get 'edit'


    onDomRefresh: ->
        if @model.get('edit')
            @ui.inputs.filter('[name="name.first"]').focus()
        else
            @ui.edit.focus()


    onSave: ->
        return unless @model.get 'new'
        app  = require 'application'
        dest = "contacts/#{@model.get 'id'}"
        app.router.navigate dest, trigger: true


    onEditCancel: ->
        @triggerMethod 'dialog:close' if @model.get 'new'


    onFormKeyEnter: ->
        inputs = @$ ':input:not(button):not([type=hidden])'
        inputs.eq(inputs.index(document.activeElement) + 1).focus()


    onFormFieldAdd: (type) ->
        return if type in CONFIG.xtras
        @getRegion('xtras').currentView.addEmptyField type


    updateInitials: (model, value) ->
        @$('.initials').text value


    syncDatapoints: ->
        @regionManager.each (region) =>
            return unless region.currentView?.getDatapoints
            name       = region.currentView.options.name
            datapoints = region.currentView.getDatapoints()
            @model.syncDatapoints name, datapoints
