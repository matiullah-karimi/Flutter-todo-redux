import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:flutter_crud_redux/model/model.dart';
import 'package:flutter_crud_redux/redux/actions.dart';
import 'package:flutter_crud_redux/redux/reducers.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Store<AppState> store =
        Store<AppState>(appStateReducer, initialState: AppState.initialState());
    return StoreProvider(
      store: store,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: StoreBuilder<AppState>(
          onInit: (store) => store.dispatch(GetItemsAction()),
          builder: (BuildContext context, Store<AppState> store) => MyHomePage(store),
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final Store<AppState> store;
  
  MyHomePage(this.store);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Redux example'),
      ),
      body: StoreConnector<AppState, _ViewModel>(
        converter: (Store<AppState> store) => _ViewModel.create(store),
        builder: (BuildContext context, _ViewModel viewModel) => Column(
              children: <Widget>[
                AddItemWidget(viewModel),
                Expanded(
                  child: ItemListWidget(viewModel),
                ),
                RemoveItemsButton(viewModel)
              ],
            ),
      ),
    );
  }
}

class AddItemWidget extends StatefulWidget {
  final _ViewModel _viewModel;

  AddItemWidget(this._viewModel);

  @override
  _AddItemWidgetState createState() => _AddItemWidgetState();
}

class _AddItemWidgetState extends State<AddItemWidget> {
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      TextField(
        controller: controller,
        decoration: InputDecoration(hintText: 'Add item'),
        onSubmitted: (String s) {
          widget._viewModel.onAddItem(s);
          controller.text = '';
        },
      ),
      RaisedButton(
        child: Text('Add'),
        onPressed: () {
           widget._viewModel.onAddItem(controller.text);
           controller.text = '';
        },
      )
    ]);
  }
}

class ItemListWidget extends StatelessWidget {
  final _ViewModel _viewModel;
  
  ItemListWidget(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _viewModel.items
          .map((Item item) => ListTile(
                title: Text(item.body),
                leading: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _viewModel.onRemoveItem(item),
                ),
              ))
          .toList(),
    );
  }
}

class RemoveItemsButton extends StatelessWidget {
  final _ViewModel _viewModel;

  RemoveItemsButton(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text('Delete all'),
      onPressed: () => _viewModel.onRemoveItems(),
    );
  }
}

class _ViewModel {
  final List<Item> items;
  final Function(String) onAddItem;
  final Function(Item) onRemoveItem;
  final Function() onRemoveItems;

  _ViewModel({
    this.items,
    this.onAddItem,
    this.onRemoveItem,
    this.onRemoveItems
  });

  factory _ViewModel.create(Store<AppState> store) {
    _onAddItem(String body) {
      store.dispatch(AddItemAction(body));
    }

    _onRemoveItem(Item item) {
      store.dispatch(RemoveItemAction(item));
    }

    _onRemoveItems() {
      store.dispatch(RemoveItemsAction());
    }

    return _ViewModel(
        items: store.state.items,
        onAddItem: _onAddItem,
        onRemoveItem: _onRemoveItem,
        onRemoveItems: _onRemoveItems);
  }
}
