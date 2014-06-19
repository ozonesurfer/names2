import 'dart:html';
import 'dart:indexed_db' as idb;
import 'dart:async';
//import 'dart:core';

void main() {
  new NameList().open();
  /*
  querySelector("#sample_text_id")
      ..text = "Click me!"
      ..onClick.listen(reverseText);
      */ 
}
/*
void reverseText(MouseEvent event) {
  var text = querySelector("#sample_text_id").text;
  var buffer = new StringBuffer();
  for (int i = text.length - 1; i >= 0; i--) {
    buffer.write(text[i]);
  }
  querySelector("#sample_text_id").text = buffer.toString();
}
*/ 

class Name {
  var key;
  String firstName, lastName;
  Name(this.key, this.firstName, this.lastName);
  
  @override
  toString() => "{$firstName $lastName}";
}

class NameList {
  static final String _NAME_DB = "name2";
  static final String _NAME_STORE = "names2";
  
  idb.Database _db;
  idb.Index _index;
  int _version = 12;
  InputElement _first, _last;
  Element _nameItems;
  
  
  NameList() {
    _nameItems = querySelector("#name_list");
    _first = querySelector("#first");
    _last = querySelector("#last");
    querySelector("#btn").onClick.listen((e) => _onAddName());
  }
  
  Future open() {
    return window.indexedDB.open(_NAME_DB, version: _version,
        onUpgradeNeeded: _onUpgradeNeeded)
        .then(_onDbOpened)
        .catchError(_onError);
  }
  
  void _onError(e) {
    window.alert('Something went wrong!');
    window.console.log('An error occured: {$e}');
  }
  
  void _onDbOpened(idb.Database db) {
    _db = db;
    _getAllNames();
  }
  
  void _onUpgradeNeeded(idb.VersionChangeEvent e) {
    idb.Database db = (e.target as idb.OpenDBRequest).result;
    if (db.objectStoreNames.contains(_NAME_STORE)) {
      db.deleteObjectStore(_NAME_STORE);
      var store = db.createObjectStore(_NAME_STORE, keyPath: 'key_path', autoIncrement: true);
    store.createIndex('name_index', ['firstName', 'lastName'], unique: false);
    } else {
      var store = db.createObjectStore(_NAME_STORE, keyPath: 'key_path', autoIncrement: true);
    store.createIndex('name_index', ['firstName', 'lastName'], unique: false);
    }
  }
  
  void _onAddName() {
    var value1 = _first.value.trim();
    var value2 = _last.value.trim();
    if (value1.length > 0 && value2.length > 0) {
//      _q = _getDup(value1, value2);
//      window.console.log("_q = $_q");
      _addName(value1, value2);
    }
    _first.value = '';
    _last.value = '';
  }
 
  
  void _qbeast(int onValue, String first, String last) {
 //   window.console.log("onValue = $onValue");
    var trans = _db.transaction(_NAME_STORE, 'readwrite');
    var store = trans.objectStore(_NAME_STORE);
    var name = {'firstName': first, 'lastName': last};
    if (onValue == 0){
      window.alert("Adding name");
      store.put(name).then((_) => _renderName(name)).catchError(_onError);
    } else {
      window.alert("$first $last is already on file $onValue times"); 
    }
 //   window.console.log("q is set to $_q");
  }
  
 
  
  void _addName(String first, String last) {
    
    var trans = _db.transaction(_NAME_STORE, 'readwrite');
    var store = trans.objectStore(_NAME_STORE);
 //   var name = {'firstName': first, 'lastName': last};
    var name = [first, last];
    var index = store.index('name_index');
    var bound = idb.KeyRange.only_(name);
    index.openCursor(range: bound, autoAdvance: true)
    .length.then((onValue) => _qbeast(onValue, first, last)).catchError(_onError);
    
      
      
  
  }
  
  void _getAllNames() {
    _nameItems.nodes.clear();
    
    var trans = _db.transaction(_NAME_STORE, 'readwrite');
    var store = trans.objectStore(_NAME_STORE);
    
    var request = store.openCursor(autoAdvance: true).listen((cursor) {
      _renderName(cursor.value);
    }).onError(_onError);
  }
  
  void _renderName(Map nameItem) {
    var first = nameItem['firstName'];
    var last = nameItem['lastName'];
    var name = '$first $last';
    window.console.log('name = $name');
//    var textDisplay = new Element.span();
//    textDisplay.text = name;
    var nameElement = new Element.tag('li');
 //   nameElement.nodes.add(textDisplay);
    nameElement.appendText(name);
    
    _nameItems.nodes.add(nameElement);
  }
}
