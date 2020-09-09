package io.flutter.plugins.firebaselivestreammlvision;

import android.media.Image;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.mlkit.vision.barcode.Barcode;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.text.Text;
import com.google.mlkit.vision.text.TextRecognition;
import com.google.mlkit.vision.text.TextRecognizer;

import io.flutter.plugin.common.EventChannel;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

public class TextRecognizerHandler implements Handler {
  private final TextRecognizer recognizer;

  TextRecognizerHandler() {
    recognizer = TextRecognition.getClient();
  }

  @Override
  public void handleDetection(final InputImage image, final Image mediaImage, final EventChannel.EventSink result, final AtomicBoolean throttle) {
    recognizer
        .process(image)
            .addOnSuccessListener(new OnSuccessListener<Text>() {
              @Override
              public void onSuccess(Text visionText) {
                Map<String, Object> visionTextData = new HashMap<>();
                visionTextData.put("text", visionText.getText());

                List<Map<String, Object>> allBlockData = new ArrayList<>();
                for (Text.TextBlock block : visionText.getTextBlocks()) {
                  Map<String, Object> blockData = new HashMap<>();
                  addData(
                          blockData,
                          block.getRecognizedLanguage(),
                          block.getText());

                  List<Map<String, Object>> allLineData = new ArrayList<>();
                  for (Text.Line line : block.getLines()) {
                    Map<String, Object> lineData = new HashMap<>();
                    addData(
                            lineData,
                            line.getRecognizedLanguage(),
                            line.getText());

                    List<Map<String, Object>> allElementData = new ArrayList<>();
                    for (Text.Element element : line.getElements()) {
                      Map<String, Object> elementData = new HashMap<>();
                      addData(
                              elementData,
                              element.getRecognizedLanguage(),
                              element.getText());

                      allElementData.add(elementData);
                    }
                    lineData.put("elements", allElementData);
                    allLineData.add(lineData);
                  }
                  blockData.put("lines", allLineData);
                  allBlockData.add(blockData);
                }

                visionTextData.put("blocks", allBlockData);
                Map<String, Object> res = new HashMap<>();
                res.put("eventType", "textRecognition");
                res.put("data", visionTextData);
                throttle.set(false);
                result.success(res);
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception exception) {
                throttle.set(false);
                result.error("textRecognizerError", exception.getLocalizedMessage(), null);
              }
            })
        .addOnCompleteListener(
            new OnCompleteListener<Text>() {
              @Override
              public void onComplete(@NonNull Task<Text> task) {
                mediaImage.close();
              }
            });
  }

  private void addData(
      Map<String, Object> addTo,
      String language,
      String text) {

    List<String> allLanguageData = new ArrayList<>();
    allLanguageData.add(language);

    addTo.put("languages", allLanguageData);

    addTo.put("text", text);
  }

  @Override
  public void close() throws IOException {
    recognizer.close();
  }
}
