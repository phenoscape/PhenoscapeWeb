// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

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