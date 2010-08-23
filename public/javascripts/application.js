// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


// initializes an autocomplete text field using jquery
function initAutocomplete(input_id, ontologyPrefixes, query_type, min_chars, width){
  if(!query_type){query_type='';}
  if(!min_chars){min_chars=4;}
  if(!width){width=400;}
  
  var ac = jQuery("#"+input_id).autocomplete(OBDWS + "/term/search", {
    width: width,
    selectFirst: false,
    minChars: min_chars,
    dataType: 'json',
    max: 100,
    //delay: 20,
    extraParams: {
      q: '',
      ontology: ontologyPrefixes,
      text: function(){ return jQuery("#"+input_id).val(); },
      syn: 'true',
      limit: '101',
      type: query_type
    },
    formatItem: function(item) {
      return item.match_text + ((item.match_type != "name") ? " <span class=\"match_type\">synonym for " + item.name + "</span>" : "");
    },
    parse: function(data){
      var parsed = [];
      data = data.matches;
      for (var i = 0; i < data.length; i++) {
        parsed[parsed.length] = {
          data: data[i],
          value: data[i].name,
          result: data[i].name
        };
      }
      return parsed;
    }
  });
  return ac;
}


function setNextIndex(index_id, input_starts_with){
  var inputs = jQuery("input[name*=" + input_starts_with + "]");
  var max_index = -1;
  inputs.each(function(i, el) {
    //example: filter_phenotype_1_entity
    element_id = parseInt(el.id.split("_")[2]);
    if (element_id > max_index){ max_index = element_id; }
  });
  jQuery("#" + index_id).val(max_index + 1);
}


function clearInputs(inputs){
  var inputs = jQuery.isArray(inputs) ? inputs : [inputs]
  for(var x=0; x < inputs.length; x++){ 
    jQuery(inputs[x]).attr('value','');
  }
}


function buildBroadenRefineMenu(link, terms, element_index){
  var options = {minWidth: 120, onClick: function(e, menuItem){  
    //setup data with existing phenotype
    var data = {replace_phenotype_index: element_index}
    jQuery.each(['entity', 'quality', 'related_entity'], function(index, phenotype_component){
      if(terms[phenotype_component]){
        data[phenotype_component+"_id"] = terms[phenotype_component];
      }
    });
    //overwrite phenotype with new term
    data[menuItem.data.term_type+"_id"] = menuItem.data.id;
    jQuery.ajax({url: '/search/phenotype_filter', data: data});
  }};
  
  var items = [];
  index = 0;
  jQuery.each(terms, function(term_type, term_id){
    if(term_id != ''){
      if(index > 0){ items.push({src: ''}); } //add seperator line
      var section = {src: term_type, subMenu: [{src: 'broaden'}, {src: ''}, {src: 'refine'}]};
      jQuery.ajax({url: OBDWS + "/term/" + term_id, dataType: 'json', async: false,
        success: function(data){
          if(data.parents.length > 0){ section['subMenu'][0]['subMenu'] = []; }
          jQuery.each(data.parents, function(i,item){
            if(i > 0){ section['subMenu'][0]['subMenu'].push({src: ''}); } //add seperator line
            //item.target.id
            section['subMenu'][0]['subMenu'].push({src: item.target.name, data: {id: item.target.id, term_type: term_type}});
          });
          if(data.children.length > 0){ section['subMenu'][2]['subMenu'] = []; }
          jQuery.each(data.children, function(i,item){
            if(i > 0){ section['subMenu'][2]['subMenu'].push({src: ''}); } //add seperator line
            //item.target.id
            section['subMenu'][2]['subMenu'].push({src: item.target.name, data: {id: item.target.id, term_type: term_type}});
          });
        } 
      });
      items.push(section);
    }
    index++;
  });
  
  jQuery('#broaden_refine_menu').menu(options, items);
  link_element = jQuery('#'+link.id);
  var pos = link_element.offset();  
  var width = link_element.width();
  jQuery('#broaden_refine_menu').css( { "left": (pos.left + width) + "px", "top":pos.top + "px" } );
  jQuery('#broaden_refine_menu').click();
}


function changeSectionFilterOperators(filter_section) {
  radio_btn = jQuery('#filter_' + filter_section + '_match_type_any');
  if(radio_btn.length > 0){
    content = (radio_btn.is(':checked')) ? 'or' : 'and';
    jQuery('.' + filter_section + '.filter_operator').html(content);
  }
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