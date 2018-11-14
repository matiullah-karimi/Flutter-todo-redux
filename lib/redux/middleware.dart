import 'dart:convert';

import 'package:flutter_crud_redux/model/model.dart';
import 'package:flutter_crud_redux/redux/actions.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Middleware<AppState>> appStateMiddleware([AppState state]) {
  final loadItems = _loadFromPrefs(state);
  final saveItems = _saveToPrefs(state);

  return [
    TypedMiddleware<AppState, AddItemAction> (saveItems),
    TypedMiddleware<AppState, RemoveItemAction> (saveItems),
    TypedMiddleware<AppState, RemoveItemsAction> (saveItems),
    TypedMiddleware<AppState, GetItemsAction> (loadItems),
    TypedMiddleware<AppState, EditItemAction> (saveItems),
  ];
}

Middleware<AppState> _saveToPrefs(AppState state) {
  return (Store<AppState> store, action, NextDispatcher next) {
    next(action);
    saveToPrefs(store.state);
  };
}

Middleware<AppState> _loadFromPrefs(AppState state) {
  return (Store<AppState> store, action, NextDispatcher next) {
    next(action);
    loadFromPrefs().then((state) => store.dispatch(LoadedItemsAction(state.items)));
  };
}

void saveToPrefs(AppState state) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var decodedState = json.encode(state.toJson());
  await preferences.setString('itemsState', decodedState);
}

Future<AppState> loadFromPrefs() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var string = preferences.getString('itemsState');
  if (string != null) {
    Map map = json.decode(string);
    return AppState.fromJson(map);
  }

  return AppState.initialState();
}

// void appStateMiddleware(Store<AppState> store, action, NextDispatcher next) async {
//   next(action);

//   if (action is AddItemAction || action is RemoveItemAction || action is RemoveItemsAction) {
//     saveToPrefs(store.state);
//   }

//   if (action is GetItemsAction) {
//     await loadFromPrefs().then((state) => store.dispatch(LoadedItemsAction(state.items)));
//   }
// }