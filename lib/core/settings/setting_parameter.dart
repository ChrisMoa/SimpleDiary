abstract class ValueObserver {
  void onValueChange();
}

class SettingsParameter<T> {
  T _value;
  final List<ValueObserver> _observers = [];

  SettingsParameter(this._value);

  T get value {
    return _value;
  }

  set value(T newValue) {
    _value = newValue;
    notifyObservers();
  }

  void addObserver(ValueObserver observer) {
    _observers.add(observer);
  }

  void removeObserver(ValueObserver observer) {
    _observers.remove(observer);
  }

  void notifyObservers() {
    for (var observer in _observers) {
      observer.onValueChange();
    }
  }
}

/*
class MyWidget extends StatefulWidget implements ValueObserver {
  SettingsParameter<String> parameter;

  MyWidget(this.parameter);

  @override
  void initState() {
    super.initState();
    parameter.addObserver(this);
  }

  @override
  void dispose() {
    parameter.removeObserver(this);
    super.dispose();
  }

  @override
  void onValueChange() {
    Handle value change here
    setState(() {
      Update widget based on new value
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget build implementation
  }
}

*/
