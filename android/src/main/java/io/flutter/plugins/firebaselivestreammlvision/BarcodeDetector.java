package io.flutter.plugins.firebaselivestreammlvision;

import android.media.Image;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.mlkit.vision.barcode.Barcode;
import com.google.mlkit.vision.barcode.BarcodeScanner;
import com.google.mlkit.vision.barcode.BarcodeScanning;
import com.google.mlkit.vision.common.InputImage;

import io.flutter.plugin.common.EventChannel;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

class BarcodeDetectorHandler implements Handler {
  private final BarcodeScanner detector;

  BarcodeDetectorHandler() {
    detector = BarcodeScanning.getClient();
  }

  @Override
  public void handleDetection(final InputImage image, final Image mediaImage, final EventChannel.EventSink result, final AtomicBoolean throttle) {
    detector
        .process(image)
            .addOnSuccessListener(new OnSuccessListener<List<Barcode>>() {
              @Override
              public void onSuccess(List<Barcode> barcodes) {
                List<Map<String, Object>> barcodeList = new ArrayList<>();

                for (Barcode barcode : barcodes) {
                  Map<String, Object> barcodeMap = new HashMap<>();

                  barcodeMap.put("value", barcode.getRawValue());
                  barcodeMap.put("displayValue", barcode.getDisplayValue());

                  barcodeList.add(barcodeMap);
                }

                Map<String, Object> res = new HashMap<>();
                res.put("eventType", "barcodeDetection");
                res.put("data", barcodes);
                throttle.set(false);
                result.success(res);
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception exception) {
                throttle.set(false);
                result.error("barcodeDetectorError", exception.getLocalizedMessage(), null);
              }
            })
        .addOnCompleteListener(
            new OnCompleteListener<List<Barcode>>() {
              @Override
              public void onComplete(@NonNull Task<List<Barcode>> task) {
                mediaImage.close();
              }
            });
  }

  @Override
  public void close() throws IOException {
    detector.close();
  }
}
