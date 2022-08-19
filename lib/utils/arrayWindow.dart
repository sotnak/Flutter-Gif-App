enum ArrayWindowStatus{
  ok,
  loading,
  front,
  back
}

enum WindowMovementDirection{
  front,
  back,
  none
}

class ArrayWindow<T>{
  int _chunk = 0;
  int _windowSize = 32;
  List<T> _array = [];
  Future<List<T>> _futureArray = Future.value([]);
  bool _isLoading = false;
  final int length;

  ArrayWindow({int? windowSize, int? chunk, Future<List<T>>? futureList, required this.length}){
    if (windowSize != null){
      _windowSize = windowSize;
    }

    if(chunk != null){
      _chunk = chunk;
    }

    if(futureList != null){
      _isLoading = true;
      _futureArray = futureList;
      _futureArray.then((value) => {
        _array = value,
        _isLoading = false
      });
    }
  }

  List<T> get array => _array;
  int get chunk => _chunk;
  Future<List<T>> get futureArray => _futureArray;

  Map<String, int> getHint(WindowMovementDirection direction){
    switch(direction){
      case WindowMovementDirection.back:
        return {
          'skip': ( (_chunk-1) * _windowSize * (3/8) ).floor(),
          'limit': _windowSize,
        };

      case WindowMovementDirection.front:
        return {
          'skip': ( (_chunk+1) * _windowSize * (3/8) ).floor(),
          'limit': _windowSize,
        };

      case WindowMovementDirection.none:
        return {
          'skip': ( (_chunk) * _windowSize * (3/8) ).floor(),
          'limit': _windowSize,
        };
    }
  }
  
  ArrayWindowStatus getStatus(int index){

    if(_isLoading){
      return ArrayWindowStatus.loading;
    }

    int innerIndex = getInnerIndex(index);

    if(innerIndex <= _windowSize * 1/8 && _chunk > 0){
      return ArrayWindowStatus.back;
    }

    if(innerIndex >= _windowSize * 7/8){
      return ArrayWindowStatus.front;
    }

    return ArrayWindowStatus.ok;
  }

  void setFutureArray({required Future<List<T>> future, required WindowMovementDirection direction, Function()? callback }) {
    _isLoading = true;
    _futureArray = future;
    _futureArray.then((value) => {
      _array = value,
      if(direction == WindowMovementDirection.front){
        _chunk++
      }
      else if(direction == WindowMovementDirection.back){
        _chunk--
      },
      _isLoading = false
    }).whenComplete(() => {if( callback != null) callback()});
  }

  bool _innerIndexCheck(int index){
    if( 0 <= index && index < _array.length ){
      return true;
    }
    
    return false;
  }

  int getInnerIndex(int globalIndex){

    if(globalIndex<0 || globalIndex >= length){
      throw Exception('Global index is out of range');
    }

    int innerIndex = globalIndex - (_chunk * _windowSize * (3/8) ).floor();

    if(!_innerIndexCheck(innerIndex)){
      throw Exception('Inner index is out of range');
    }

    return innerIndex;
  }

  T operator [] (int globalIndex){
    return _array[getInnerIndex(globalIndex)];
  }
}