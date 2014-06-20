GocovMarkerView = require './gocov-marker-view'
{EditorView, View, Range} = require 'atom'
_ = require 'underscore-plus'

module.exports =
class GocovAreaView extends View
  @content: ->
    @div class: 'golang-gocov'

  initialize: (editorView, gocov) ->
    @views = []
    @editorView = editorView
    @gocov = gocov

  attach: =>
    return unless @gocov.isValidEditorView(@editorView)
    console.log @editorView
    console.log @editorView.underlayer
    @editorView.underlayer.append(this)
    atom.workspaceView.on 'pane:item-removed', @destroy

    if @gocov.isValidEditorView(@editorView) and @gocov.coverageFile?
      @processCoverageFile()

  destroy: =>
    return if @editorViewFound()
    atom.workspaceView.off 'pane:item-removed', @destroy if atom?.workspaceView?
    @unsubscribe()
    @remove()
    @detach()

  editorViewFound: ->
    found = false
    return unless atom?.workspaceView?
    for editor in atom.workspaceView.getEditorViews()
      found = true if editor.id is @editorView.id
    return found

  getEditorView: ->
    activeView = atom?.workspaceView?.getActiveView()
    if activeView instanceof EditorView then activeView else null

  getActiveEditor: ->
    atom?.workspace?.getActiveEditor()

  processCoverageFile: =>
    return unless @gocov.isValidEditorView(@editorView)
    @removeMarkers()

    return unless editor = @getActiveEditor()

    buffer = @editorView?.getEditor()?.getBuffer()
    return unless buffer?
    path = buffer.getPath()

    ranges = @gocov.rangesForFile(path)
    for range in ranges
      view = new GocovMarkerView(range.range, range.count, this, @getEditorView())
      @append view.element
      @views.push view

  removeMarkers: =>
    return unless @views?
    return if @views.length is 0
    for view in @views
      view.element.remove()
      view = null
    @views = []
