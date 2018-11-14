import 'package:flutter/material.dart';
import 'package:flutter_crud_redux/redux/middleware.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:flutter_crud_redux/model/model.dart';
import 'package:flutter_crud_redux/redux/actions.dart';
import 'package:flutter_crud_redux/redux/reducers.dart';
import 'package:flutter_redux_dev_tools/flutter_redux_dev_tools.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Store<AppState> store = DevToolsStore<AppState>(appStateReducer,
        initialState: AppState.initialState(),
        middleware: appStateMiddleware());
    return StoreProvider(
      store: store,
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: StoreBuilder<AppState>(
            onInit: (store) => store.dispatch(GetItemsAction()),
            builder: (BuildContext context, Store<AppState> store) =>
                MyHomePage(store),
          )),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final DevToolsStore<AppState> store;

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
      drawer: Container(
        child: ReduxDevTools(store),
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

  void _showOverlay(BuildContext context, Item item) {
    Navigator.of(context).push(TutorialOverlay(item));
  }

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
                trailing: Checkbox(
                  value: item.completed,
                  onChanged: (b) {
                    _viewModel.onCompletedItem(item);
                  },
                ),
                onTap: () {
                  _showOverlay(context, item);
                },
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
  final Function(Item) onCompletedItem;
  final Function(Item) onEditItem;

  _ViewModel(
      {this.items,
      this.onAddItem,
      this.onRemoveItem,
      this.onRemoveItems,
      this.onCompletedItem,
      this.onEditItem});

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

    _onCompletedItem(Item item) {
      store.dispatch(ItemCompletedAction(item));
    }

    _onEditItem(Item item) {
      store.dispatch(EditItemAction(item));
    }

    return _ViewModel(
        items: store.state.items,
        onAddItem: _onAddItem,
        onRemoveItem: _onRemoveItem,
        onRemoveItems: _onRemoveItems,
        onCompletedItem: _onCompletedItem,
        onEditItem: _onEditItem);
  }
}

class TutorialOverlay extends ModalRoute<void> {
  final Item item;
  TextEditingController textController = TextEditingController();

  TutorialOverlay(this.item) {
    this.textController.text = item.body;
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
        converter: (Store<AppState> store) => _ViewModel.create(store),
        builder: (BuildContext context, _ViewModel viewModle) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(10.0),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: textController,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Dismiss'),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        RaisedButton(
                          onPressed: () {
                            viewModle.onEditItem(item.copyWith(body: textController.text));
                             Navigator.pop(context);
                          },
                          child: Text('Update'),
                        ),
                      ])
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
