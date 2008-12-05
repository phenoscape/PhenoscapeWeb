// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


// class TermInfoPanel
function TermInfoPanel(divNode) {
    this.div = $(divNode);
    this.nameNode = DIV({"class":"TermInfoPanel.name"});
    replaceChildNodes(this.div, this.nameNode);
    var infoTable = TABLE(null);
    appendChildNodes(this.div, infoTable);
    this.idNode = TD(null);
    appendChildNodes(infoTable, TR(null, TD(null, "ID:"), this.idNode));
    this.defNode = TD(null);
    appendChildNodes(infoTable, TR(null, TD(null, "Definition:"), this.defNode));
    appendChildNodes(this.div, DIV(null, "Parents"));
    this.parentsTable = TABLE(null);
    appendChildNodes(this.div, this.parentsTable);
    appendChildNodes(this.div, DIV(null, "Children"));
    this.childrenTable = TABLE(null);
    appendChildNodes(this.div, this.childrenTable);
}

TermInfoPanel.prototype.setTerm = function(data) {
    replaceChildNodes(this.nameNode, data.name);
    replaceChildNodes(this.idNode, data.id);
    replaceChildNodes(this.defNode, data.definition);
    this.displayRelationships(this.parentsTable, data.parents);
    this.displayRelationships(this.childrenTable, data.children);
}

TermInfoPanel.prototype.displayRelationships = function(table, links) {
    replaceChildNodes(table);
    for (var i = 0; i < links.length; i++) {
        var link = links[i];
        appendChildNodes(table, TR(null, TD({"title":link.id}, link.relation), TD(link.name)));
    }
}


// class TermInfoPanelDataSource
function TermInfoPanelDataSource(panelObj) {
    this.deferred = null;
    this.panel = panelObj;
}

TermInfoPanelDataSource.prototype.loadTerm = function(termURL) {
    if (this.deferred) { this.deferred.cancel(); }
    this.deferred = loadJSONDoc(termURL);
    this.deferred.addCallback(bind(this.update, this));
    this.deferred.addErrback(function(error) { 
        if (!(error instanceof CancelledError)) {
            logError("Couldn't load term info:", error);
        }
    });
}

TermInfoPanelDataSource.prototype.update = function(data) {
    this.panel.setTerm(data);
}
