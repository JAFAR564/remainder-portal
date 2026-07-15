import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';

class MonitoringService {
  static final MonitoringService _instance = MonitoringService._internal();
  factory MonitoringService() => _instance;
  MonitoringService._internal();

  bool _isFirebaseInitialized = false;

  /// Initializes monitoring, setting up crashlytics error handlers.
  Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isFirebaseInitialized = true;
        
        // Pass all uncaught "Fatal" errors from the framework to Crashlytics
        FlutterError.onError = (errorDetails) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        };
        
        // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };

        // Enable automatic data collection for performance monitoring
        await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
        debugPrint("📊 Firebase Crashlytics & Performance Monitoring initialized successfully.");
      } else {
        _setupLocalLogging();
      }
    } catch (e, stack) {
      debugPrint("⚠️ Failed to initialize Firebase monitoring: $e");
      debugPrint(stack.toString());
      _setupLocalLogging();
    }
  }

  void _setupLocalLogging() {
    _isFirebaseInitialized = false;
    // Local fallback: log to console
    FlutterError.onError = (errorDetails) {
      debugPrint("[Local Error (Flutter)] ${errorDetails.exception}");
      debugPrint("${errorDetails.stack}");
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint("[Local Error (Platform)] $error");
      debugPrint("$stack");
      return true;
    };
    debugPrint("📊 Using local logging fallback (Offline/Dev mode).");
  }

  /// Logs a non-fatal error to Crashlytics or local console.
  Future<void> logError(dynamic error, StackTrace? stackTrace, {String? reason}) async {
    if (_isFirebaseInitialized) {
      await FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: reason);
    } else {
      debugPrint("[Error] ${reason ?? 'An error occurred'}: $error");
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }

  /// Logs a custom message to Crashlytics log stream or local console.
  void log(String message) {
    if (_isFirebaseInitialized) {
      FirebaseCrashlytics.instance.log(message);
    } else {
      debugPrint("[Log] $message");
    }
  }

  /// Starts a performance trace.
  Future<PerformanceTrace> startTrace(String traceName) async {
    if (_isFirebaseInitialized) {
      final trace = FirebasePerformance.instance.newTrace(traceName);
      await trace.start();
      return _FirebasePerformanceTrace(trace);
    } else {
      return _LocalPerformanceTrace(traceName);
    }
  }
}

/// Abstract interface for measuring performance metrics.
abstract class PerformanceTrace {
  Future<void> stop();
  void putAttribute(String name, String value);
  void incrementMetric(String name, int value);
}

class _FirebasePerformanceTrace implements PerformanceTrace {
  final Trace _trace;
  _FirebasePerformanceTrace(this._trace);

  @override
  Future<void> stop() async {
    await _trace.stop();
  }

  @override
  void putAttribute(String name, String value) {
    _trace.putAttribute(name, value);
  }

  @override
  void incrementMetric(String name, int value) {
    _trace.incrementMetric(name, value);
  }
}

class _LocalPerformanceTrace implements PerformanceTrace {
  final String _name;
  final Stopwatch _stopwatch;

  _LocalPerformanceTrace(this._name) : _stopwatch = Stopwatch()..start();

  @override
  Future<void> stop() async {
    _stopwatch.stop();
    debugPrint("⏱️ [Trace] '$_name' completed in ${_stopwatch.elapsedMilliseconds}ms");
  }

  @override
  void putAttribute(String name, String value) {
    debugPrint("⏱️ [Trace] '$_name' attribute: $name = $value");
  }

  @override
  void incrementMetric(String name, int value) {
    debugPrint("⏱️ [Trace] '$_name' metric: $name += $value");
  }
}
