// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults



// FIXME Function (constructor) documentation for what this does and
// how is missing

// class TermInfoPanel
function TermInfoPanel(divNode) {
    this.div = $(divNode);
    this.infoTable = MochiKit.DOM.TABLE(null);
    MochiKit.DOM.appendChildNodes(this.div, this.infoTable);
    this.nameNode = MochiKit.DOM.TD({"class":"TermInfoPanel-name", "colspan":"2"});
    MochiKit.DOM.appendChildNodes(this.infoTable, MochiKit.DOM.TR(null, this.nameNode));
    this.idNode = MochiKit.DOM.TD(null);
    MochiKit.DOM.appendChildNodes(this.infoTable, MochiKit.DOM.TR(null, MochiKit.DOM.TD({"class":"TermInfoPanel-field-label"}, "ID:"), this.idNode));
    this.synonymsData = MochiKit.DOM.TD(null);
    MochiKit.DOM.appendChildNodes(this.infoTable, MochiKit.DOM.TR(null, TD({"class":"TermInfoPanel-field-label"}, "Synonyms:"), this.synonymsData));
    this.defNode = MochiKit.DOM.TD(null);
    MochiKit.DOM.appendChildNodes(this.infoTable, MochiKit.DOM.TR(null, MochiKit.DOM.TD({"class":"TermInfoPanel-field-label"}, "Definition:"), this.defNode));
    this.parentsRow = MochiKit.DOM.TR(null, MochiKit.DOM.TD({"colspan":"2", "class":"TermInfoPanel-header-label"}, "Parents"));
    MochiKit.DOM.appendChildNodes(this.infoTable, this.parentsRow);
    this.childrenRow = MochiKit.DOM.TR(null, MochiKit.DOM.TD({"colspan":"2", "class":"TermInfoPanel-header-label"}, "Children"));
    MochiKit.DOM.appendChildNodes(this.infoTable, this.childrenRow);
}

// FIXME method documentation for what this does and how is missing
TermInfoPanel.prototype.setTerm = function(data) {
    MochiKit.DOM.replaceChildNodes(this.nameNode, data.name);
    MochiKit.DOM.replaceChildNodes(this.idNode, data.id);
    MochiKit.DOM.replaceChildNodes(this.synonymsData, this.formatSynonyms(data.synonyms));
    MochiKit.DOM.replaceChildNodes(this.defNode, data.definition);
    var rows = this.infoTable.childNodes;
    for (var i = rows.length; i > 0; i--) {
        var child = rows.item(i - 1);
        if (child == this.parentsRow) {
            break;
        }
        this.infoTable.removeChild(child);
    }
    this.displayRelationships(this.infoTable, data.parents);
    MochiKit.DOM.appendChildNodes(this.infoTable, this.childrenRow);
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
        MochiKit.DOM.appendChildNodes(table, MochiKit.DOM.TR(null, MochiKit.DOM.TD({"class":"TermInfoPanel-field-label relation_name", "title":link.relation.id}, (link.relation.name ? link.relation.name : link.relation.id) + ":"), MochiKit.DOM.TD({"title":link.target.id}, (link.target.name ? link.target.name : link.target.id))));
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
    this.deferred = MochiKit.Async.loadJSONDoc(termURL);
    this.deferred.addCallback(MochiKit.Base.bind(this.update, this));
    this.deferred.addErrback(function(error) { 
        if (!(error instanceof MochiKit.Async.CancelledError)) {
            MochiKit.Logging.logError("Couldn't load term info:", error);
        }
    });
}

// FIXME method documentation for what this does and how is missing
TermInfoPanelDataSource.prototype.update = function(data) {
    this.panel.setTerm(data);
}

// FIXME function documentation for what this does and how is missing
function initAutocomplete(input, div, ontologyPrefixes) {
	var dataSource = new YAHOO.util.XHRDataSource(URL.autocomplete());
	dataSource.responseSchema = { resultsList:"matches", fields:[{key:"match_text"}, {key:"id"}, {key:"match_type"}] };
	dataSource.responseType = YAHOO.util.XHRDataSource.TYPE_JSON;
	var autocomplete = new YAHOO.widget.AutoComplete(input, div, dataSource);
    autocomplete.generateRequest = function(query) {
        return "?text=" + query + "&ontology=" + ontologyPrefixes.join(",") + "&syn=true" + "&limit=101";
    };
    autocomplete.maxResultsDisplayed = 100;
    autocomplete.queryDelay = 0.2;
    autocomplete.minQueryLength = 4;
    autocomplete.forceSelection = false;
    autocomplete.formatResult = function(resultData , query , resultMatch) {
        var matchType = resultData[2];
        return resultMatch + ((matchType != "name") ? " <span class=\"match_type\">" + matchType + "</span>" : "");
    }
    autocomplete.dataReturnEvent.subscribe(function(theEvent, data) {
        var autocompleteObject = data[0];
        var queryText = data[1];
        var results = data[2];
        if (results.length > autocomplete.maxResultsDisplayed) {
            autocomplete.setFooter("results truncated at " + autocomplete.maxResultsDisplayed + " matches");
        } else {
            autocomplete.setFooter(null);
        }
    });
    return autocomplete;
}

function getParameters() {
    // get the current URL
     var url = window.location.toString();
     //get the parameters
     url.match(/\?(.+)$/);
     var params = RegExp.$1;
     // split up the query string and store in a dictionary
     var params = params.split("&");
     var queryStringList = {};
     for (var i=0; i<params.length; i++) {
         var tmp = params[i].split("=");
         queryStringList[tmp[0]] = unescape(tmp[1]);
     }
     return queryStringList;
}

//takes a taxon structure or term info structure and determines if possesses an italic rank
function italicTaxon(taxon) {
    var rank_id = null
    if (MochiKit.Base.isUndefinedOrNull(taxon["rank"])) {
        if (!MochiKit.Base.isUndefinedOrNull(taxon["parents"])) {
            for (var i = 0; i < taxon["parents"].length; i++) {
                var link = taxon["parents"][i];
                if (link["relation"]["id"] == HAS_RANK) {
                    rank_id = link["target"]["id"]
                }
            }
        }
    } else {
        rank_id = taxon["rank"]["id"];
    }
    return MochiKit.Base.findValue([GENUS_ID, SPECIES_ID], rank_id) != -1;
}

//takes a taxon structure or term info structure and determines if the taxon should be marked as extinct
function extinctTaxon(taxon) {
	if (MochiKit.Base.isUndefinedOrNull(taxon["extinct"])) {
		return false;
	} else {
		return taxon["extinct"];
	}
}

var HAS_RANK = "has_rank";
var SPECIES_ID = "TTO:species";
var GENUS_ID = "TTO:genus";

var HOST = "http://" + window.location.hostname;

var OBDWS = HOST + "/OBD-WS";

var BIOPORTAL = "http://bioportal.bioontology.org/virtual"

var URL = {

    term : function(termID) {
		return OBDWS + "/term/" + termID;
	},

    homology : function(termID) {
        return OBDWS + "/term/" + termID + "/homology";
    },
    
    autocomplete : function() {
        return OBDWS + "/term/search";
    },
    
    generalTerm : function(termName) {
        return HOST + "/search/general/" + escape(termName);
    },
    
    entity : function(termID) {
        return HOST + "/search/entity/" + termID;
    },
    
    taxon : function(termID) {
        return HOST + "/search/taxon/" + termID;
    },
    
    gene : function(termID) {
        return HOST + "/search/gene/" + termID;
    },
    
    quality : function(termID) {
        return BIOPORTAL + "/1107/" + termID;
    },
    
    source : function(sourcesList) {
        return OBDWS + "/phenotypes/source/" + sourcesList.join(",");
    },
    
    childPhenotypes : function(entity, quality, taxon) {
        return OBDWS + "/phenotypes?type=evo&entity=" + entity + "&quality=" + quality + "&subject=" + taxon + "&group=" + taxon;
    },
    
    bioportalTAO : function(termID) {
        return BIOPORTAL + "/1110/" + termID;
    },
    
    bioportalTTO : function(termID) {
        return BIOPORTAL + "/1081/" + termID;
    },
    
    zfinGene : function(geneID) {
        return "http://zfin.org/cgi-bin/webdriver?MIval=aa-markerview.apg&OID=" + geneID;
    }
    
};

var ONTOLOGY = {
    TAO : "TAO",
    TTO : "TTO",
    ZFIN : "ZFIN"
};