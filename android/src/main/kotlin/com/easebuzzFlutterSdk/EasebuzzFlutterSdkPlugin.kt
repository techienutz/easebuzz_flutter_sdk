package com.easebuzzFlutterSdk

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull
import com.easebuzz.flutter.JsonConverter
import com.easebuzz.payment.kit.PWECheckoutActivity
import com.google.gson.Gson
import datamodels.PWEStaticDataModel
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import org.json.JSONObject
import java.util.HashMap

/** EasebuzzFlutterSdkPlugin */
class EasebuzzFlutterSdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {

  private lateinit var channel: MethodChannel
  private var channelResult: Result? = null
  private var startPayment = true
  private var activity: Activity? = null
  private var activityBinding: ActivityPluginBinding? = null
  val PWE_REQUEST_CODE = 100 // Define PWE_REQUEST_CODE as 100

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "easebuzz")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    channelResult = result
    if (call.method == "payWithEasebuzz") {
      if (startPayment) {
        startPayment = false
        startPayment(call.arguments)
      }
    } else {
      result.notImplemented()
    }
  }

  private fun startPayment(arguments: Any) {
    try {
      val gson = Gson()
      val parameters = JSONObject(gson.toJson(arguments))
      val currentActivity = activity
      if (currentActivity != null) {
        val intentProceed = Intent(currentActivity, PWECheckoutActivity::class.java)
        intentProceed.flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT

        val keys: Iterator<*> = parameters.keys()
        while (keys.hasNext()) {
          val key = keys.next() as String
          val value = parameters.optString(key)
          if (key == "amount") {
            val amount = parameters.optString("amount").toDouble()
            intentProceed.putExtra(key, amount)
          } else {
            intentProceed.putExtra(key, value)
          }
        }

        currentActivity.startActivityForResult(intentProceed, PWE_REQUEST_CODE)
      } else {
        // Handle the case where activity is null
        startPayment = true
        val errorMap = HashMap<String, Any>()
        val errorDescMap = HashMap<String, Any>()
        errorDescMap["error"] = "ActivityNull"
        errorDescMap["error_msg"] = "Activity is not available to start payment."
        errorMap["result"] = PWEStaticDataModel.TXN_FAILED_CODE
        errorMap["payment_response"] = errorDescMap
        channelResult?.success(errorMap)
      }
    } catch (e: Exception) {
      startPayment = true
      val errorMap = HashMap<String, Any>()
      val errorDescMap = HashMap<String, Any>()
      val errorDesc = "Exception occurred: ${e.message}"
      errorDescMap["error"] = "Exception"
      errorDescMap["error_msg"] = errorDesc
      errorMap["result"] = PWEStaticDataModel.TXN_FAILED_CODE
      errorMap["payment_response"] = errorDescMap
      channelResult?.success(errorMap)
    }
  }

  // Implement the ActivityResultListener to handle activity results
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode == PWE_REQUEST_CODE) {
      startPayment = true
      if (data != null) {
        val response = JSONObject()
        val errorMap = HashMap<String, Any>()
        try {
          val result = data.getStringExtra("result") ?: "Unknown result"
          val paymentResponse = data.getStringExtra("payment_response") ?: "Empty payment response"
          val obj = JSONObject(paymentResponse)
          response.put("result", result)
          response.put("payment_response", obj)
          channelResult?.success(JsonConverter.convertToMap(response));
//          channelResult?.success(response.toMap())
        } catch (e: Exception) {
          val errorDescMap = HashMap<String, Any>()
          errorDescMap["error"] = "Error"
          errorDescMap["error_msg"] = e.message ?: "Unknown error"
          errorMap["result"] = "payment_failed"
          errorMap["payment_response"] = errorDescMap
          channelResult?.success(errorMap)
        }
      } else {
        val errorMap = HashMap<String, Any>()
        val errorDescMap = HashMap<String, Any>()
        errorDescMap["error"] = "Empty error"
        errorDescMap["error_msg"] = "Empty payment response"
        errorMap["result"] = "payment_failed"
        errorMap["payment_response"] = errorDescMap
        channelResult?.success(errorMap)
      }
      return true
    }
    return false
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  // Implement ActivityAware to manage Activity lifecycle
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    activityBinding = binding
    activityBinding?.addActivityResultListener(this) // Register ActivityResultListener
  }

  override fun onDetachedFromActivity() {
    activityBinding?.removeActivityResultListener(this) // Unregister ActivityResultListener
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    activityBinding = binding
    activityBinding?.addActivityResultListener(this) // Register ActivityResultListener
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activityBinding?.removeActivityResultListener(this) // Unregister ActivityResultListener
    activity = null
  }

  // Utility function to convert JSONObject to Map<String, Any>
  private fun JSONObject.toMap(): Map<String, Any> = keys().asSequence().associateWith { opt(it) }
}