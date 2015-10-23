Contact = require 'models/contact'


module.exports = class ContactsListener extends CozySocketListener

    models:
        'contact': Contact

    events: [
        'contact.create'
        'contact.update'
        'contact.delete'
    ]

    onRemoteCreate: (model) ->
        @collection.add model, merge:true

    onRemoteUpdate: (model) ->
        @collection.add model, merge: true

    onRemoteDelete: (model) ->
        @collection.remove model
