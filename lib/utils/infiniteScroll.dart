import 'package:flutter/widgets.dart';
import 'package:nsfw_flutter/utils/arrayWindow.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const int windowSize = 128;

typedef FetchFunction<V> = Future<List<V>> Function({required int limit, required int skip});

mixin InfiniteScroll<T extends StatefulWidget, U> on State<T>{

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  bool _listenerAttached = false;

  FetchFunction<U> _fetchFunction = ({required int limit, required int skip}) => throw Exception('fetchFunction not set');

  late ArrayWindow<U> arrW;

  set fetchFunction(FetchFunction<U> function) => _fetchFunction = function;

  bool get listenerAttached => _listenerAttached;

  void attachListener(){
    if(_listenerAttached){
      throw Exception('Listener already attached');
    }

    _listenerAttached = true;
    itemPositionsListener.itemPositions.addListener(_visibleItemsListener);
  }

  void detachListener(){
    if(!_listenerAttached){
      throw Exception('Listener not attached');
    }

    itemPositionsListener.itemPositions.removeListener(_visibleItemsListener);
    _listenerAttached = false;
  }

  List<int> get visibleItems {
    List<int> list = itemPositionsListener.itemPositions.value.map((elem) => elem.index).toList(growable: false);
    list.sort((a,b)=>a.compareTo(b));
    return list;
  }

  void initialFetch({required int length, int windowSize = windowSize}){
    setState((){
      arrW = ArrayWindow(
        length: length,
        windowSize: windowSize,
        future: _fetchFunction(limit: windowSize, skip: 0)
      );
    });
  }

  void _visibleItemsListener () {
    List<int> visible = visibleItems;

    if(visible.isEmpty){
      return;
    }

    int lastGlobal = arrW.getGlobalIndex(visible.last);
    int firstGlobal = arrW.getGlobalIndex(visible.first);

    ArrayWindowStatus lastStatus = arrW.getStatus(lastGlobal);
    ArrayWindowStatus firstStatus =  arrW.getStatus(firstGlobal);
    WindowMovementDirection direction = WindowMovementDirection.none;

    if(firstStatus == ArrayWindowStatus.back){
      direction = WindowMovementDirection.back;
    }

    if(lastStatus == ArrayWindowStatus.front){
      direction = WindowMovementDirection.front;
    }

    if(direction == WindowMovementDirection.none){
      return;
    }

    final hint = arrW.getHint(direction);
    setState((){
      arrW.setFutureArray(
        future: _fetchFunction(limit: hint['limit'] as int, skip: hint['skip'] as int),
        direction: direction,
        callback: ()=>{
          itemScrollController.jumpTo(index: visibleItems.first - (hint['jump'] as int) )
        }
      );
    });
  }
}