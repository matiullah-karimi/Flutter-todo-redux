
import 'package:flutter_crud_redux/model/model.dart';
import 'package:flutter_crud_redux/redux/actions.dart';
import 'package:redux/redux.dart';

AppState appStateReducer(AppState state, action) {
  return AppState(items: itemReducer(state.items, action));
}

Reducer<List<Item>> itemReducer = combineReducers<List<Item>> ([
  TypedReducer<List<Item>, AddItemAction>(addItemReducer),
  TypedReducer<List<Item>, RemoveItemAction>(removeItemReducer),
  TypedReducer<List<Item>, RemoveItemsAction>(removeItemsReducer),
  TypedReducer<List<Item>, LoadedItemsAction>(loadItemsReducer),
  TypedReducer<List<Item>, ItemCompletedAction>(itemCompletedReducer),
  TypedReducer<List<Item>, EditItemAction>(editItemReducer),
]);

List<Item> addItemReducer(List<Item> items, AddItemAction action) {
  return []
    ..addAll(items)
    ..add(Item(id: action.id, body: action.item));
}

List<Item> removeItemReducer(List<Item> items, RemoveItemAction action) {
  return List.unmodifiable(List.from(items)..remove(action.item));
}

List<Item> removeItemsReducer(List<Item> items, RemoveItemsAction action) {
  return [];
}

List<Item> loadItemsReducer(List<Item> items, LoadedItemsAction action) {
  return action.items;
}

List<Item> itemCompletedReducer(List<Item> items, ItemCompletedAction action) {
  return items.map((item) => item.id == action.item.id ? 
    item.copyWith(completed: !item.completed) :
    item
  ).toList();
}

List<Item> editItemReducer(List<Item> items, EditItemAction action) {
  print(action.item.body);
  return items.map((item) => item.id == action.item.id ? action.item : item).toList();
}

// List<Item> itemReducer (List<Item> state, action) {
//   if (action is AddItemAction) {
//     return []
//       ..addAll(state)
//       ..add(Item(id: action.id, body: action.item));
//   }

//   if (action is RemoveItemAction) {
//     return List.unmodifiable(List.from(state)..remove(action.item));
//   }

//   if (action is RemoveItemsAction) {
//     return List.unmodifiable([]);
//   }

//   if (action is LoadedItemsAction) {
//     return action.items;
//   }

//   return state;
// }