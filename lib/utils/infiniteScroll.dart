import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:nsfw_flutter/utils/arrayWindow.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const int _windowSize = windowSize;

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
    return list;
  }

  Map<String,int> get visibleItemsMinMax {
    List<int> list = visibleItems;
    
    if(list.isEmpty){
      return {};
    }
    int visibleMin = pow(2, 32).floor();
    int visibleMax = -1;

    for (var element in list) {
      
      if(element>visibleMax){
        visibleMax = element;
      }
      if(element<visibleMin){
        visibleMin=element;
      }

    }
    return {'min': visibleMin, 'max': visibleMax};
  }

  void initialFetch({required int length, int windowSize = _windowSize}){
    Future<List<U>> future = _fetchFunction(limit: windowSize, skip: 0);    

    setState((){
      arrW = ArrayWindow(
        length: length,
        windowSize: windowSize,
        future: future
      );
    });

    future.whenComplete(() => Future.delayed(const Duration(milliseconds: 100)).whenComplete(() => itemScrollController.jumpTo(index: 0, alignment: 0)) );
  }

  void _visibleItemsListener () {
    Map<String, int> visible = visibleItemsMinMax;

    if(visible.isEmpty){
      return;
    }

    int visibleFirst = visible['min'] as int;
    int visibleLast = visible['max'] as int;

    int lastGlobal = arrW.getGlobalIndex(visibleLast);
    int firstGlobal = arrW.getGlobalIndex(visibleFirst);

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
        callback: (){

          switch(direction){
            case WindowMovementDirection.back:
              itemScrollController.jumpTo(index: (visibleFirst+1) - (hint['jump'] as int));
              break;
            case WindowMovementDirection.front:
              itemScrollController.jumpTo(index: visibleLast - (hint['jump'] as int), alignment: 1);
              break;
            default:
              // TODO: Handle this case.
              break;
          }
        }
        
      );
    });
  }
}