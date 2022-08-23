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

const int windowSize = 128;

class ArrayWindow<T>{
  int _chunk = 0;
  int _windowSize = 32;
  List<T> _array = const [];
  Future<List<T>> _futureArray = Future.value([]);
  bool _isLoading = false;
  final int length;

  ArrayWindow({int? windowSize, int? chunk, Future<List<T>>? future, required this.length}){
    if (windowSize != null){
      _windowSize = windowSize;
    }

    if(chunk != null){
      _chunk = chunk;
    }

    if(future != null){
      _isLoading = true;
      _futureArray = future;
      _futureArray.then((value) => {
        _array = value,
        _isLoading = false
      });
    }
  }

  ArrayWindow.empty(): length=0;

  ArrayWindow.from(ArrayWindow<T> other) :
    length=other.length,
    _chunk = other._chunk,
    _windowSize = other._windowSize,
    _array = List<T>.from(other._array),
    _futureArray = Future.value(other._array);

  List<T> get array => _array;
  int get chunk => _chunk;
  Future<List<T>> get futureArray => _futureArray;

  Map<String, int> getHint(WindowMovementDirection direction){
    switch(direction){
      case WindowMovementDirection.back:
        return {
          'skip': ( (_chunk-1) * _windowSize * (3/8) ).floor(),
          'limit': _windowSize,
          'jump': (-_windowSize * (3/8)).floor(),
        };

      case WindowMovementDirection.front:
        return {
          'skip': ( (_chunk+1) * _windowSize * (3/8) ).floor(),
          'limit': _windowSize,
          'jump': (_windowSize * (3/8)).floor(),
        };

      case WindowMovementDirection.none:
        return {
          'skip': ( (_chunk) * _windowSize * (3/8) ).floor(),
          'limit': _windowSize,
          'jump': 0
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

  int getGlobalIndex(int innerIndex){
    return innerIndex + (_chunk * _windowSize * (3/8) ).floor();
  }

  T operator [] (int globalIndex){
    return _array[getInnerIndex(globalIndex)];
  }
}