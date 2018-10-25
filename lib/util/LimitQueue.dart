import 'dart:collection';

/// 定长的队列
class LimitQueue<T> {
  ListQueue<T> _queue = ListQueue<T>();
  final int limit;
  LimitQueue(this.limit);

  void addLast(T item) {
    if (_queue.length >= limit) {
      _queue.removeFirst();
    }
    _queue.addLast(item);
  }
  void addFirst(T item) {
    if (_queue.length >= limit) {
      _queue.removeLast();
    }
    _queue.addFirst(item);
  }

  T elementAt(int index) {
    return _queue.elementAt(index);
  }

  void clear(){
    _queue.clear();
  }

  int getLength() {
    return _queue.length;
  }
}
