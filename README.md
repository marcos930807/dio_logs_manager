# dio_logs_manager
[![pub package](https://img.shields.io/pub/v/dio_logs_manager.svg)](https://pub.dev/packages/dio_logs_manager)
#### HTTP Inspector tool for Dart which can debugging http requests for Dio 

##### Based on:  (https://pub.dev/packages/dio_log) with some improvements

### Add dependency

```
dependencies: 
  dio_logs_manager : ^0.0.1
```
### Usage

```
dio.interceptors.add(DioLogInterceptor());
```
### Add a global hover button on your home page to jump through the log list
```
///display overlay button 
showDebugBtn(context);
///cancel overlay button
dismissDebugBtn();
///overlay button state of display
debugBtnIsShow()
```
### Or open a log list where you want it to be

``` 
Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => LogsPage(),
    ),
  );  
```