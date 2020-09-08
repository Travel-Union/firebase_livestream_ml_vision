package io.flutter.plugins.firebaselivestreammlvision;

import android.media.Image;

import com.google.mlkit.vision.common.InputImage;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import java.io.IOException;
import java.util.concurrent.atomic.AtomicBoolean;

interface Handler {
  void handleDetection(final InputImage image, final Image mediaImage, final EventChannel.EventSink eventSink, AtomicBoolean throttle);

  void close() throws IOException;
}

interface Setup {
  void setup(String modelName, final MethodChannel.Result result);
}
