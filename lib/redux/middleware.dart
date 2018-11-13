import 'dart:convert';

import 'package:flutter_crud_redux/model/model.dart';
import 'package:flutter_crud_redux/redux/actions.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

void appStateMiddleware(Store<AppState> store, action, NextDispatcher next) async {
  next(action);

  if (action is AddItemAction || action is RemoveItemAction || action is RemoveItemsAction) {
    saveToPrefs(store.state);
  }

  if (action is GetItemsAction) {
    await loadFromPrefs().then((state) => store.dispatch(LoadedItemsAction(state.items)));
  }
}