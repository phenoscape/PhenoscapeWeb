// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


var HOST = "http://" + window.location.hostname;

// FIXME Function (constructor) documentation for what this does and
// how is missing

// class TermInfoPanel
function TermInfoPanel(divNode) {
    this.div = $(divNode);
    this.infoTable = TABLE(null);
    appendChildNodes(this.div, this.infoTable);
    this.nameNode = TD({"class":"TermInfoPanel-name", "colspan":"2"});
    appendChildNodes(this.infoTable, TR(null, this.nameNode));
    this.idNode = TD(null);
    appendChildNodes(this.infoTable, TR(null, TD({"class":"TermInfoPanel-field-label"}, "ID:"), this.idNode));
    this.synonymsData = TD(null);
    appendChildNodes(this.infoTable, TR(null, TD({"class":"TermInfoPanel-field-label"}, "Synonyms:"), this.synonymsData));
    this.defNode = TD(null);
    appendChildNodes(this.infoTable, TR(null, TD({"class":"TermInfoPanel-field-label"}, "Definition:"), this.defNode));
    this.parentsRow = TR(null, TD({"colspan":"2", "class":"TermInfoPanel-header-label"}, "Parents"));
    appendChildNodes(this.infoTable, this.parentsRow);
    this.childrenRow = TR(null, TD({"colspan":"2", "class":"TermInfoPanel-header-label"}, "Children"));
    appendChildNodes(this.infoTable, this.childrenRow);
}

// FIXME method documentation for what this does and how is missing
TermInfoPanel.prototype.setTerm = function(data) {
    replaceChildNodes(this.nameNode, data.name);
    replaceChildNodes(this.idNode, data.id);
    replaceChildNodes(this.synonymsData, this.formatSynonyms(data.synonyms));
    replaceChildNodes(this.defNode, data.definition);
    var rows = this.infoTable.childNodes;
    for (var i = rows.length; i > 0; i--) {
        var child = rows.item(i - 1);
        if (child == this.parentsRow) {
            break;
        }
        this.infoTable.removeChild(child);
    }
    this.displayRelationships(this.infoTable, data.parents);
    appendChildNodes(this.infoTable, this.childrenRow);
    this.displayRelationships(this.infoTable, data.children);
}

// FIXME method documentation for what this does and how is missing
TermInfoPanel.prototype.formatSynonyms = function(synonyms) {
    var synonymsText = "";
    for (var i = 0; i < synonyms.length; i++) {
        synonymsText  = synonymsText + synonyms[i].name;
        if (i < (synonyms.length - 1)) {
            synonymsText = synonymsText + ", ";
        }
    }
    return synonymsText;
}

// FIXME method documentation for what this does and how is missing
TermInfoPanel.prototype.displayRelationships = function(table, links) {
    for (var i = 0; i < links.length; i++) {
        var link = links[i];
        appendChildNodes(table, TR(null, TD({"class":"TermInfoPanel-field-label relation_name", "title":link.relation.id}, (link.relation.name ? link.relation.name : link.relation.id) + ":"), TD({"title":link.target.id}, (link.target.name ? link.target.name : link.target.id))));
    }
}


// FIXME Function (constructor) documentation for what this does and
// how is missing
// class TermInfoPanelDataSource
function TermInfoPanelDataSource(panelObj) {
    this.deferred = null;
    this.panel = panelObj;
}

// FIXME method documentation for what this does and how is missing
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

// FIXME method documentation for what this does and how is missing
TermInfoPanelDataSource.prototype.update = function(data) {
    this.panel.setTerm(data);
}

// FIXME function documentation for what this does and how is missing

// FIXME shouldn't some of the URL prefix strings be constants and
// declared separately?
function initAutocomplete(input, div, ontologyPrefix) {
	var dataSource = new YAHOO.util.XHRDataSource(HOST + "/OBD-WS/term/search");
	dataSource.responseSchema = { resultsList:"matches", fields:[{key:"match_text"}, {key:"id"}, {key:"match_type"}] };
	dataSource.responseType = YAHOO.util.XHRDataSource.TYPE_JSON;
	var autocomplete = new YAHOO.widget.AutoComplete(input, div, dataSource);
    autocomplete.generateRequest = function(query) {
        return "?text=" + query + "&ontology=" + ontologyPrefix + "&syn=true";
    };
    autocomplete.maxResultsDisplayed = 100;
    autocomplete.queryDelay = 0.3;
    autocomplete.minQueryLength = 3;
    autocomplete.forceSelection = false;
    autocomplete.formatResult = function(resultData , query , resultMatch) {
        var matchType = resultData[2];
        return resultMatch + ((matchType != "name") ? " <span class=\"match_type\">" + matchType + "</span>" : "");
    }
    return autocomplete;
}

var OBDWS = HOST + "/OBD-WS/";

var URL = {
    
    homology : function(termID) {
        return OBDWS + "term/" + termID + "/homology";
    }
}