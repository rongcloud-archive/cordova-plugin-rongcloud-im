package io.rong.cordova;

import android.app.ActivityManager;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.net.Uri;
import android.text.TextUtils;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.rong.common.ErrorCode;
import io.rong.common.RongErrorResult;
import io.rong.common.RongException;
import io.rong.common.RongResult;
import io.rong.common.translation.ITranslatedMessage;
import io.rong.common.translation.TranslatedConversation;
import io.rong.common.translation.TranslatedConversationNtfyStatus;
import io.rong.common.translation.TranslatedDiscussion;
import io.rong.common.translation.TranslatedMessage;
import io.rong.common.translation.TranslatedQuietHour;
import io.rong.imlib.RongIMClient;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.Discussion;
import io.rong.imlib.model.Group;
import io.rong.imlib.model.Message;
import io.rong.message.CommandMessage;
import io.rong.message.CommandNotificationMessage;
import io.rong.message.ImageMessage;
import io.rong.message.LocationMessage;
import io.rong.message.RichContentMessage;
import io.rong.message.TextMessage;
import io.rong.message.VoiceMessage;
import io.rong.push.RongPushInterface;

public class RongCloudLibPlugin extends CordovaPlugin {
    private final String TAG = "RongCloudLibPlugin";

    private boolean mInitialized;
    private Context mContext;
    private RongIMClient mRongClient;
    private Gson mGson;
    private MessageListener mMessageListener;
    private ExecutorService mThreadPool = Executors.newFixedThreadPool(1);

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        mContext = cordova.getActivity().getApplicationContext();
        mGson = new Gson();
    }

    @Override
    public boolean execute(final String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        mThreadPool.execute(new Runnable() {
            @Override
            public void run() {
                Method method = null;
                try {
                    method = RongCloudLibPlugin.class.getDeclaredMethod(action,
                            JSONArray.class, CallbackContext.class);
                    method.invoke(RongCloudLibPlugin.this, args, callbackContext);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });

        return true;
    }

    private TranslatedMessage translateMessage(Message message) {
        return new TranslatedMessage(message);
    }

    private boolean isInBackground() {
        ActivityManager activityManager = (ActivityManager) mContext.getSystemService(Context.ACTIVITY_SERVICE);
        String appPackageName = mContext.getPackageName();
        List<ActivityManager.RunningTaskInfo> runningTaskInfo = activityManager.getRunningTasks(1);
        String topAppPackageName = runningTaskInfo.get(0).topActivity.getPackageName();
        return !appPackageName.equals(topAppPackageName);
    }

    private boolean notificationDisabled = false;
    public void disableLocalNotification(CallbackContext context) {
        notificationDisabled = true;
        callModuleSuccess(context);
    }

    private void notifyIfNeed(CallbackContext context,Message message,int left){

        if (isInQuietTime(mContext)) {
            return;
        }

        RongIMClient.getInstance().getConversationNotificationStatus(message.getConversationType(), message.getTargetId(), new RongIMClient.ResultCallback<Conversation.ConversationNotificationStatus>() {
            @Override
            public void onSuccess(Conversation.ConversationNotificationStatus conversationNotificationStatus) {
                if (Conversation.ConversationNotificationStatus.NOTIFY == conversationNotificationStatus) {
                    sendNotification();
                }
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {

            }
        });
    }

    private void sendNotification() {
        Notification notification = null;
        Intent intent = mContext.getPackageManager().getLaunchIntentForPackage(mContext.getPackageName());
        intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
        PackageManager pm = mContext.getPackageManager();
        ApplicationInfo ai = mContext.getApplicationInfo();
        String title = (String) pm.getApplicationLabel(ai);
        String tickerText = mContext.getResources().getString(mContext.getResources().getIdentifier("rc_notification_ticker_text", "string", mContext.getPackageName()));
        PendingIntent pendingIntent = PendingIntent.getActivity(mContext, 0, intent, 0);
        if (android.os.Build.VERSION.SDK_INT < 11) {
            // notification = new Notification(ai.icon, tickerText, System.currentTimeMillis());
            // notification.setLatestEventInfo(mContext, title, tickerText, pendingIntent);
            // notification.flags = Notification.FLAG_AUTO_CANCEL;
            // notification.defaults = Notification.DEFAULT_SOUND;
            try {
                Method method;
                notification = new Notification(mContext.getApplicationInfo().icon, tickerText, System.currentTimeMillis());

                Class<?> classType = Notification.class;
                method = classType.getMethod("setLatestEventInfo", new Class[]{Context.class, String.class, String.class, PendingIntent.class});
                method.invoke(notification, new Object[]{mContext, title, tickerText, pendingIntent});

                notification.flags = Notification.FLAG_AUTO_CANCEL;
                notification.defaults = Notification.DEFAULT_ALL;
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            BitmapDrawable bitmapDrawable = (BitmapDrawable) ai.loadIcon(pm);
            Bitmap appIcon = bitmapDrawable.getBitmap();
            Notification.Builder builder = new Notification.Builder(mContext);
            builder.setLargeIcon(appIcon);
            builder.setSmallIcon(mContext.getApplicationInfo().icon);
            builder.setTicker(tickerText);
            builder.setContentTitle(title);
            builder.setContentText(tickerText);
            builder.setContentIntent(pendingIntent);
            builder.setAutoCancel(true);
            builder.setDefaults(Notification.DEFAULT_ALL);
            notification = builder.getNotification();
        }
        NotificationManager nm = (NotificationManager) mContext.getSystemService(mContext.NOTIFICATION_SERVICE);
        nm.notify(0, notification);
    }

    class MessageListener implements RongIMClient.OnReceiveMessageListener {
        CallbackContext context;

        MessageListener(CallbackContext context) {
            this.context = context;
        }

        @Override
        public boolean onReceived(Message message, int left) {
            if(isInBackground() && !notificationDisabled) {
                notifyIfNeed(context,message,left);
            }
            TranslatedMessage msg = translateMessage(message);
            callModuleSuccessWithoutStatus(context, new ReceiveMessageModel(left, msg), true);
            return false;
        }
    }

    public void init(JSONArray args, CallbackContext callbackContext) {
        try {
            String appkey = args.getString(0);
            RongIMClient.init(mContext, appkey);
            RongPushInterface.init(mContext, appkey);
            mRongClient = RongIMClient.getInstance();
            mInitialized = true;
            callModuleSuccess(callbackContext);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    void connect(final JSONArray args, final CallbackContext callbackContext) {
        if(!mInitialized) {
            callModuleError(callbackContext, new RongException(ErrorCode.NOT_INIT));
            return;
        }

        try {
            String token = args.getString(0);
            RongIMClient.connect(token, new RongIMClient.ConnectCallback() {
                @Override
                public void onTokenIncorrect() {
                    callModuleError(callbackContext, new RongException(31004));
                }

                @Override
                public void onSuccess(String s) {
                    callModuleSuccess(callbackContext, new ConnectResultModel(s));
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    callModuleError(callbackContext, new RongException(errorCode.getValue()));
                }
            });
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public void logout(JSONArray args, final CallbackContext context) {
        if(!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.logout();
        callModuleSuccess(context, null);
    }

    public void getConversationList(final JSONArray args, final CallbackContext context) {
        if(!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.getConversationList(new RongIMClient.ResultCallback<List<Conversation>>() {
            @Override
            public void onSuccess(List<Conversation> conversations) {
                ArrayList<TranslatedConversation> list = new ArrayList<TranslatedConversation>();
                if (conversations == null || conversations.size() == 0) {
                    callModuleSuccess(context, list);
                    return;
                }

                for (Conversation conversation : conversations) {
                    TranslatedConversation tc = new TranslatedConversation(conversation);
                    list.add(tc);
                }
                callModuleSuccess(context, list);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }


    public void setOnReceiveMessageListener(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }

        mMessageListener = new MessageListener(context);
        if (mRongClient != null) {
            RongIMClient.setOnReceiveMessageListener(mMessageListener);
        }
    }

    public void disconnect(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.disconnect(args.optBoolean(0));
        callModuleSuccess(context, null);
    }

    void sendTextMessage(final JSONArray args, final CallbackContext callbackContext) {
        if(!mInitialized) {
            callModuleError(callbackContext, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(callbackContext, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String type = args.optString(0);
        String targetId = args.optString(1);
        String content = args.optString(2);
        String extra = args.optString(3);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId) || TextUtils.isEmpty(content)) {
            callModuleError(callbackContext, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        TextMessage textMessage = TextMessage.obtain(content);
        if (!TextUtils.isEmpty(extra))
            textMessage.setExtra(extra);

        mRongClient.sendMessage(conversationType, targetId, textMessage, null, null, new RongIMClient.SendMessageCallback() {
            @Override
            public void onError(Integer id, RongIMClient.ErrorCode errorCode) {
                callModuleError(callbackContext, id, new RongException(errorCode.getValue()));
            }

            @Override
            public void onSuccess(Integer id) {
                callModuleSuccess(callbackContext, new ProgressModel(id));
            }
        }, new RongIMClient.ResultCallback<Message>() {
            @Override
            public void onSuccess(Message message) {
                TranslatedMessage translatedMessage = new TranslatedMessage(message);
                callModulePrepare(callbackContext, new ProgressModel(translatedMessage));
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(callbackContext, new RongException(errorCode.getValue()));
            }
        });
    }

    public void sendImageMessage(final JSONArray args, final CallbackContext callbackContext) {
        if(!mInitialized) {
            callModuleError(callbackContext, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(callbackContext, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String type = args.optString(0);
        String targetId = args.optString(1);
        String image = args.optString(2);
        String extra = args.optString(3);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId) || TextUtils.isEmpty(image) || !image.startsWith("file")) {
            callModuleError(callbackContext, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callModuleError(callbackContext, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        final Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);

        Uri imageUri = Uri.parse(image);
        final ImageMessage imageMessage = ImageMessage.obtain(imageUri, imageUri);

        if (!TextUtils.isEmpty(extra))
            imageMessage.setExtra(extra);

        mRongClient.sendImageMessage(conversationType, targetId, imageMessage, null, null, new RongIMClient.SendImageMessageCallback() {
            @Override
            public void onAttached(Message message) {
                TranslatedMessage translatedMessage = new TranslatedMessage(message);
                callModulePrepare(callbackContext, new ProgressModel(translatedMessage));
            }

            @Override
            public void onError(Message message, RongIMClient.ErrorCode errorCode) {
                callModuleError(callbackContext, new ProgressModel(message.getMessageId()), new RongException(errorCode.getValue()));
            }

            @Override
            public void onSuccess(Message message) {
                callModuleSuccess(callbackContext, new ProgressModel(message.getMessageId()));
            }

            @Override
            public void onProgress(Message message, int i) {
                callModuleProgress(callbackContext, new ProgressModel(message.getMessageId(), i));
            }
        });
    }

    public void sendVoiceMessage(final JSONArray args, final CallbackContext context) {
        if(!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String type = args.optString(0);
        final String targetId = args.optString(1);
        String voicePath = args.optString(2);
        final int duration = args.optInt(3);
        final String extra = args.optString(4);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId) || duration == 0 || TextUtils.isEmpty(voicePath)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        File file = new File(voicePath);
        if (!file.exists()) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        final Uri voiceUri = Uri.fromFile(file);
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        final Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        VoiceMessage voiceMessage = VoiceMessage.obtain(voiceUri, duration);
        if (!TextUtils.isEmpty(extra))
            voiceMessage.setExtra(extra);

        mRongClient.sendMessage(conversationType, targetId, voiceMessage, null, null, new RongIMClient.SendMessageCallback() {
            @Override
            public void onError(Integer id, RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new ProgressModel(id), new RongException(errorCode.getValue()));
            }

            @Override
            public void onSuccess(Integer id) {
                callModuleSuccess(context, new ProgressModel(id));
            }
        }, new RongIMClient.ResultCallback<Message>() {
            @Override
            public void onSuccess(Message message) {
                TranslatedMessage translatedMessage = new TranslatedMessage(message);
                callModulePrepare(context, new ProgressModel(translatedMessage));
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void sendRichContentMessage(final JSONArray args, final CallbackContext context) {
        if(!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String type = args.optString(0);
        String targetId = args.optString(1);
        String title = args.optString(2);
        String content = args.optString(3);
        String imageUrl = args.optString(4);
        final String extra = args.optString(5);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId) || TextUtils.isEmpty(title) || TextUtils.isEmpty(content)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        RichContentMessage richContentMessage = RichContentMessage.obtain(title, content, imageUrl);
        if (!TextUtils.isEmpty(extra))
            richContentMessage.setExtra(extra);

        mRongClient.sendMessage(conversationType, targetId, richContentMessage, null, null, new RongIMClient.SendMessageCallback() {
            @Override
            public void onError(Integer id, RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new ProgressModel(id), new RongException(errorCode.getValue()));
            }

            @Override
            public void onSuccess(Integer id) {
                callModuleSuccess(context, new ProgressModel(id));
            }
        }, new RongIMClient.ResultCallback<Message>() {
            @Override
            public void onSuccess(Message message) {
                TranslatedMessage translatedMessage = new TranslatedMessage(message);
                callModulePrepare(context, new ProgressModel(translatedMessage));
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }


    public void sendLocationMessage(final JSONArray args, final CallbackContext context) {
        if(!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String type = args.optString(0);
        final String targetId = args.optString(1);
        final double lat = args.optDouble(2);
        final double lng = args.optDouble(3);
        final String poi = args.optString(4);
        final String imagePath = args.optString(5);
        final String extra = args.optString(6);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId) || TextUtils.isEmpty(imagePath)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        final Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        File file = new File(imagePath);
        final Uri imageUri = Uri.fromFile(file);
        if (!file.exists()) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        LocationMessage locationMessage = LocationMessage.obtain(lat, lng, poi, imageUri);
        if (!TextUtils.isEmpty(extra))
            locationMessage.setExtra(extra);
        mRongClient.sendMessage(conversationType, targetId, locationMessage, null, null, new RongIMClient.SendMessageCallback() {
            @Override
            public void onError(Integer id, RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new ProgressModel(id), new RongException(errorCode.getValue()));
            }

            @Override
            public void onSuccess(Integer id) {
                callModuleSuccess(context, new ProgressModel(id));
            }
        }, new RongIMClient.ResultCallback<Message>() {
            @Override
            public void onSuccess(Message message) {
                TranslatedMessage translatedMessage = new TranslatedMessage(message);
                callModulePrepare(context, new ProgressModel(translatedMessage));
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void getGroupConversationList(JSONArray array, final CallbackContext context) {
        if(!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.getConversationList(new RongIMClient.ResultCallback<List<Conversation>>() {
            @Override
            public void onSuccess(List<Conversation> conversations) {
                if (conversations == null || conversations.size() == 0) {
                    callModuleSuccess(context, "");
                    return;
                }

                ArrayList<TranslatedConversation> list = new ArrayList<TranslatedConversation>();
                for (Conversation conversation : conversations) {
                    TranslatedConversation tc = new TranslatedConversation(conversation);
                    list.add(tc);
                }
                callModuleSuccess(context, list);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }

    public void sendCommandNotificationMessage(final JSONArray args, final CallbackContext context) {
        if(!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String type = args.optString(0);
        String targetId = args.optString(1);
        String name = args.optString(2);
        String data = args.optString(3);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId) || TextUtils.isEmpty(name) || TextUtils.isEmpty(data)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mRongClient.sendMessage(conversationType, targetId, CommandNotificationMessage.obtain(name, data), null, null, new RongIMClient.SendMessageCallback() {
            @Override
            public void onError(Integer id, RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new ProgressModel(id), new RongException(errorCode.getValue()));
            }

            @Override
            public void onSuccess(Integer id) {
                callModuleSuccess(context, new ProgressModel(id));
            }
        }, new RongIMClient.ResultCallback<Message>() {
            @Override
            public void onSuccess(Message message) {
                TranslatedMessage translatedMessage = new TranslatedMessage(message);
                callModulePrepare(context, new ProgressModel(translatedMessage));
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void sendCommandMessage(final JSONArray args, final CallbackContext context) {
        if(!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String type = args.optString(0);
        String targetId = args.optString(1);
        String name = args.optString(2);
        String data = args.optString(3);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId) || TextUtils.isEmpty(name) || TextUtils.isEmpty(data)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mRongClient.sendMessage(conversationType, targetId, CommandMessage.obtain(name, data), null, null, new RongIMClient.SendMessageCallback() {
            @Override
            public void onError(Integer id, RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new ProgressModel(id), new RongException(errorCode.getValue()));
            }

            @Override
            public void onSuccess(Integer id) {
                callModuleSuccess(context, new ProgressModel(id));
            }
        }, new RongIMClient.ResultCallback<Message>() {
            @Override
            public void onSuccess(Message message) {
                TranslatedMessage translatedMessage = new TranslatedMessage(message);
                callModulePrepare(context, new ProgressModel(translatedMessage));
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void getConversationNotificationStatus(final JSONArray args, final CallbackContext context) {
        if(!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String type = args.optString(0);
        String targetId = args.optString(1);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mRongClient.getConversationNotificationStatus(conversationType, targetId, new RongIMClient.ResultCallback<Conversation.ConversationNotificationStatus>() {
            @Override
            public void onSuccess(Conversation.ConversationNotificationStatus conversationNotificationStatus) {
                TranslatedConversationNtfyStatus state = new TranslatedConversationNtfyStatus(conversationNotificationStatus);
                callModuleSuccess(context, state);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }


    public void setConversationNotificationStatus(final JSONArray args, final CallbackContext context) {
        if(!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String type = args.optString(0);
        String targetId = args.optString(1);
        String status = args.optString(2);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId) || TextUtils.isEmpty(status)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        Conversation.ConversationNotificationStatus conversationNotificationStatus = Conversation.ConversationNotificationStatus.valueOf(status);
        mRongClient.setConversationNotificationStatus(conversationType,
                targetId,
                conversationNotificationStatus,
                new RongIMClient.ResultCallback<Conversation.ConversationNotificationStatus>() {
                    @Override
                    public void onSuccess(Conversation.ConversationNotificationStatus conversationNotificationStatus) {
                        TranslatedConversationNtfyStatus state = new TranslatedConversationNtfyStatus(conversationNotificationStatus);
                        callModuleSuccess(context, state);
                    }

                    @Override
                    public void onError(RongIMClient.ErrorCode errorCode) {
                        callModuleSuccess(context, errorCode.getValue());
                    }
                });
    }


    public void setDiscussionInviteStatus(final JSONArray args, final CallbackContext context) {
        String targetId = args.optString(0);
        String status = args.optString(1);

        if (TextUtils.isEmpty(targetId) || TextUtils.isEmpty(targetId) || TextUtils.isEmpty(status)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        RongIMClient.DiscussionInviteStatus discussionInviteStatus = RongIMClient.DiscussionInviteStatus.valueOf(status);
        mRongClient.setDiscussionInviteStatus(targetId, discussionInviteStatus, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callModuleSuccess(context, null);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));

            }
        });
    }


    public void syncGroup(final JSONArray args, final CallbackContext context) {
        JSONArray object = args.optJSONArray(0);
        if (object == null) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        TypeToken<ArrayList<Group>> typeToken = new TypeToken<ArrayList<Group>>() {};
        List<Group> groups = mGson.fromJson(object.toString(), typeToken.getType());
        if (groups == null || groups.size() == 0) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        mRongClient.syncGroup(groups, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callModuleSuccess(context, null);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }


    public void joinGroup(final JSONArray args, final CallbackContext context) {
        String groupId = args.optString(0);
        String groupName = args.optString(1);

        if (TextUtils.isEmpty(groupId) || TextUtils.isEmpty(groupName)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        mRongClient.joinGroup(groupId, groupName, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callModuleSuccess(context, null);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }



    public void quitGroup(final JSONArray args, final CallbackContext context) {
        String groupId = args.optString(0);

        if (TextUtils.isEmpty(groupId)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.quitGroup(groupId, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callModuleSuccess(context, null);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }


    public void setConnectionStatusListener(JSONArray array, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        RongIMClient.setConnectionStatusListener(new RongIMClient.ConnectionStatusListener() {
            @Override
            public void onChanged(ConnectionStatus connectionStatus) {
                callModuleSuccessWithoutStatus(context, new ConnectionStatusResult(connectionStatus.getValue()), true);
            }
        });
    }


    public void joinChatRoom(final JSONArray args, final CallbackContext context) {
        String chatRoomId = args.optString(0);
        int defMessageCount = args.optInt(1);

        if (TextUtils.isEmpty(chatRoomId)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.joinChatRoom(chatRoomId, defMessageCount, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callModuleSuccess(context, null);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }


    public void quitChatRoom(final JSONArray args, final CallbackContext context) {
        String chatRoomId = args.optString(0);

        if (TextUtils.isEmpty(chatRoomId)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.quitChatRoom(chatRoomId, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callModuleSuccess(context, null);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }
    public void getConversation(final JSONArray args, final CallbackContext context) {
        final String type = args.optString(0);
        final String targetId = args.optString(1);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);

        mRongClient.getConversation(conversationType, targetId, new RongIMClient.ResultCallback<Conversation>() {
            @Override
            public void onSuccess(Conversation conversation) {
                TranslatedConversation tc = null;
                if (conversation == null) {
                    callModuleSuccess(context, "");
                } else {
                    tc = new TranslatedConversation(conversation);
                    callModuleSuccess(context, tc);
                }
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }


    public void removeConversation(final JSONArray args, final CallbackContext context) {
        String type = args.optString(0);
        String targetId = args.optString(1);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);

        mRongClient.removeConversation(conversationType, targetId, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callModuleSuccess(context);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }


    public void setConversationToTop(final JSONArray args, final CallbackContext context) {
        String type = args.optString(0);
        String targetId = args.optString(1);
        boolean isTop = args.optBoolean(2);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);

        mRongClient.setConversationToTop(conversationType, targetId, isTop, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callModuleSuccess(context);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }


    public void getTotalUnreadCount(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.getTotalUnreadCount(new RongIMClient.ResultCallback<Integer>() {
            @Override
            public void onSuccess(Integer integer) {
                callModuleSuccess(context, integer);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });

    }

    public void getUnreadCount(final JSONArray args, final CallbackContext context) {
        String type = args.optString(0);
        String targetId = args.optString(1);
        JSONArray jsonArray = args.optJSONArray(2);

        if ((TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) && (jsonArray == null || jsonArray.length() == 0)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        if (!TextUtils.isEmpty(type) && !TextUtils.isEmpty(targetId)) {
            Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
            mRongClient.getUnreadCount(conversationType, targetId, new RongIMClient.ResultCallback<Integer>() {
                @Override
                public void onSuccess(Integer integer) {
                    callModuleSuccess(context, integer);
                }

                @Override
                public void onError(RongIMClient.ErrorCode e) {
                    callModuleError(context, new RongException(e.getValue()));
                }
            });
        } else {
            int i = 0;

            Conversation.ConversationType[] conversationTypes = new Conversation.ConversationType[jsonArray.length()];
            while (i < jsonArray.length()) {
                String item = jsonArray.optString(i);
                Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(item);
                conversationTypes[i] = conversationType;
                i++;
            }

            mRongClient.getUnreadCount(conversationTypes, new RongIMClient.ResultCallback<Integer>() {
                @Override
                public void onSuccess(Integer integer) {
                    callModuleSuccess(context, integer);
                }

                @Override
                public void onError(RongIMClient.ErrorCode e) {
                    callModuleError(context, new RongException(e.getValue()));
                }
            });
        }
    }

    public void getUnreadCountByConversationTypes(final JSONArray args, final CallbackContext context){
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        JSONArray jsonArray = args.optJSONArray(0);

        if (jsonArray == null || jsonArray.length() == 0) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        int i = 0;
        Conversation.ConversationType[] conversationTypes = new Conversation.ConversationType[jsonArray.length()];
        while (i < jsonArray.length()) {
            String item = jsonArray.optString(i);
            Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(item);
            conversationTypes[i] = conversationType;
            i++;
        }

        mRongClient.getUnreadCount(conversationTypes, new RongIMClient.ResultCallback<Integer>() {
            @Override
            public void onSuccess(Integer integer) {
                callModuleSuccess(context,integer);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context,new RongException(errorCode.getValue()));
            }
        });
    }

    public void getLatestMessages(final JSONArray args, final CallbackContext context) {
        final String type = args.optString(0);
        final String targetId = args.optString(1);
        final int count = args.optInt(2);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);

        mRongClient.getLatestMessages(conversationType, targetId, count, new RongIMClient.ResultCallback<List<Message>>() {
            @Override
            public void onSuccess(List<Message> messages) {
                if (messages == null || messages.size() == 0) {
                    callModuleSuccess(context, "");
                    return;
                }
                ArrayList<TranslatedMessage> list = new ArrayList<TranslatedMessage>();
                for (Message message : messages) {
                    TranslatedMessage tm = new TranslatedMessage(message);
                    list.add(tm);
                }
                Collections.reverse(list);
                callModuleSuccess(context, list);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }


    public void getHistoryMessages(final JSONArray args, final CallbackContext context) {
        final String type = args.optString(0);
        final String targetId = args.optString(1);
        final int count = args.optInt(2);
        final int oldestMessageId = args.optInt(3);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mRongClient.getHistoryMessages(conversationType, targetId, oldestMessageId, count, new RongIMClient.ResultCallback<List<Message>>() {
            @Override
            public void onSuccess(List<Message> messages) {
                if (messages == null || messages.size() == 0) {
                    callModuleSuccess(context, "");
                    return;
                }

                ArrayList<TranslatedMessage> list = new ArrayList<TranslatedMessage>();
                for (Message message : messages) {
                    TranslatedMessage tm = new TranslatedMessage(message);
                    list.add(tm);
                }
                callModuleSuccess(context, list);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }


    public void getHistoryMessagesByObjectName(final JSONArray args, final CallbackContext context) {
        final String type = args.optString(0);
        final String targetId = args.optString(1);
        final int oldestMessageId = args.optInt(2);
        final String objectName = args.optString(3);
        final int count = args.optInt(4);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);

        mRongClient.getHistoryMessages(conversationType, targetId, objectName, oldestMessageId, count, new RongIMClient.ResultCallback<List<Message>>() {
            @Override
            public void onSuccess(List<Message> messages) {
                if (messages == null || messages.size() == 0) {
                    callModuleSuccess(context, "");
                    return;
                }

                ArrayList<TranslatedMessage> list = new ArrayList<TranslatedMessage>();
                for (Message message : messages) {
                    TranslatedMessage tm = new TranslatedMessage(message);
                    list.add(tm);
                }
                callModuleSuccess(context, list);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }


    public void deleteMessages(final JSONArray args, final CallbackContext context) {
        JSONArray jsonArray = args.optJSONArray(0);

        if (jsonArray == null || jsonArray.length() == 0) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        int[] ids = new int[jsonArray.length()];
        int i = 0;
        while (i < jsonArray.length()) {
            ids[i] = jsonArray.optInt(i);
            i++;
        }

        mRongClient.deleteMessages(ids, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callModuleSuccess(context);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }


    public void clearMessages(final JSONArray args, final CallbackContext context) {
        String type = args.optString(0);
        String targetId = args.optString(1);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mRongClient.clearMessages(conversationType, targetId, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callModuleSuccess(context);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }


    public void clearMessagesUnreadStatus(final JSONArray args, final CallbackContext context) {
        String type = args.optString(0);
        String targetId = args.optString(1);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mRongClient.clearMessagesUnreadStatus(conversationType, targetId, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callModuleSuccess(context);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }


    public void setMessageExtra(final JSONArray args, final CallbackContext context) {
        int messageId = args.optInt(0);
        String value = args.optString(1);

        if (messageId < 0 || TextUtils.isEmpty(value)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.setMessageExtra(messageId, value, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callModuleSuccess(context);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }


    public void setMessageReceivedStatus(final JSONArray args, final CallbackContext context) {
        int messageId = args.optInt(0);
        String status = args.optString(1);

        if (messageId < 1 || status == null) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        int value;
        if(status.equals("UNREAD"))
            value = 0;
        else if(status.equals("READ"))
            value = 1;
        else if(status.equals("LISTENED"))
            value = 2;
        else if(status.equals("DOWNLOADED"))
            value = 4;
        else {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Message.ReceivedStatus receivedStatus = new Message.ReceivedStatus(value);
        mRongClient.setMessageReceivedStatus(messageId, receivedStatus, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callModuleSuccess(context);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }



    public void getTextMessageDraft(final JSONArray args, final CallbackContext context) {
        String type = args.optString(0);
        String targetId = args.optString(1);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mRongClient.getTextMessageDraft(conversationType, targetId, new RongIMClient.ResultCallback<String>() {
            @Override
            public void onSuccess(String content) {
                if (content == null)
                    callModuleSuccess(context, "");
                else
                    callModuleSuccess(context, content);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }


    public void saveTextMessageDraft(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String type = args.optString(0);
        String targetId = args.optString(1);
        String content = args.optString(2);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId) || TextUtils.isEmpty(content)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mRongClient.saveTextMessageDraft(conversationType, targetId, content, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callModuleSuccess(context);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }



    public void clearTextMessageDraft(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String type = args.optString(0);
        String targetId = args.optString(1);

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mRongClient.clearTextMessageDraft(conversationType, targetId, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callModuleSuccess(context);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }


    public void createDiscussion(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String name = args.optString(0);
        JSONArray jsonArray = args.optJSONArray(1);
        if (TextUtils.isEmpty(name) || jsonArray == null || jsonArray.length() == 0) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        List<String> ids = new ArrayList<String>(jsonArray.length());
        int i = 0;
        while (i < jsonArray.length()) {
            ids.add(jsonArray.optString(i));
            i++;
        }

        mRongClient.createDiscussion(name, ids, new RongIMClient.CreateDiscussionCallback() {
            @Override
            public void onSuccess(String s) {
                callModuleSuccess(context, new DiscussionModel(s));
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void clearConversations(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        JSONArray jsonArray = args.optJSONArray(0);

        if (jsonArray == null || jsonArray.length() == 0) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        int i = 0;
        Conversation.ConversationType[] conversationTypes = new Conversation.ConversationType[jsonArray.length()];
        while (i < jsonArray.length()) {
            String item = jsonArray.optString(i);
            Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(item);
            conversationTypes[i] = conversationType;
            i++;
        }

        mRongClient.clearConversations(new RongIMClient.ResultCallback() {
            @Override
            public void onSuccess(Object o) {
                callModuleSuccess(context);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        }, conversationTypes);
    }


    public void getConnectionStatus(final JSONArray args, final CallbackContext context) {
        RongIMClient.ConnectionStatusListener.ConnectionStatus status;
        if(!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if(mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        status = mRongClient.getCurrentConnectionStatus();
        int code = -1;
        if(status != null)
            code = status.getValue();
        callModuleSuccess(context, new ConnectionStatusResult(code));
    }


    public void getRemoteHistoryMessages(final JSONArray args, final CallbackContext context) {
        final String type = args.optString(0);
        final String targetId = args.optString(1);
        final long dateTime = args.optLong(2);
        final int count = args.optInt(3);

        if(mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mRongClient.getRemoteHistoryMessages(conversationType, targetId, dateTime, count, new RongIMClient.ResultCallback<List<Message>>() {
            @Override
            public void onSuccess(List<Message> messages) {
                if (messages == null || messages.size() == 0) {
                    callModuleSuccess(context, "");
                    return;
                }

                ArrayList<TranslatedMessage> list = new ArrayList<TranslatedMessage>();
                for (Message message : messages) {
                    TranslatedMessage tm = new TranslatedMessage(message);
                    list.add(tm);
                }
                callModuleSuccess(context, list);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }


    public void setMessageSentStatus(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        final int id = args.optInt(0);
        final String state = args.optString(1);
        if(state == null){
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        Message.SentStatus status = Message.SentStatus.valueOf(state);
        if(id <= 0 || status == null){
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        mRongClient.setMessageSentStatus(id, status, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callModuleSuccess(context);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }


    public void getCurrentUserId(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String id = mRongClient.getCurrentUserId();
        callModuleSuccess(context, id);
    }


    public void getDeltaTime(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        long time = mRongClient.getDeltaTime();
        callModuleSuccess(context, time);
    }


    public void clearNotifications(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        RongPushInterface.clearAllNotifications(mContext);
        callModuleSuccess(context, null);
    }


    public void addToBlacklist(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String id = args.optString(0);
        if(TextUtils.isEmpty(id)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        mRongClient.addToBlacklist(id, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callModuleSuccess(context, null);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }


    public void removeFromBlacklist(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String id = args.optString(0);
        if(TextUtils.isEmpty(id)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        mRongClient.removeFromBlacklist(id, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callModuleSuccess(context, null);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }


    public void getBlacklistStatus(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String id = args.optString(0);
        if(TextUtils.isEmpty(id)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        mRongClient.getBlacklistStatus(id, new RongIMClient.ResultCallback<RongIMClient.BlacklistStatus>() {
            @Override
            public void onSuccess(RongIMClient.BlacklistStatus blacklistStatus) {
                if (blacklistStatus == null)
                    callModuleSuccess(context, 1);
                else
                    callModuleSuccess(context, blacklistStatus.getValue());
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }


    public void getBlacklist(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.getBlacklist(new RongIMClient.GetBlacklistCallback() {
            @Override
            public void onSuccess(String[] strings) {
                if (strings == null || strings.length == 0) {
                    callModuleSuccess(context, new String[0]);
                    return;
                }
                callModuleSuccess(context, strings);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callModuleError(context, new RongException(e.getValue()));
            }
        });
    }


    public void setNotificationQuietHours(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        final String startTime = args.optString(0);
        final int spanMinutes = args.optInt(1);
        if(TextUtils.isEmpty(startTime)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        mRongClient.setNotificationQuietHours(startTime, spanMinutes, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callModuleSuccess(context, null);
                saveNotificationQuietHours(mContext,startTime,spanMinutes);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }


    public void removeNotificationQuietHours(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        mRongClient.removeNotificationQuietHours(new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callModuleSuccess(context, null);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }


    public void getNotificationQuietHours(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        mRongClient.getNotificationQuietHours(new RongIMClient.GetNotificationQuietHoursCallback() {
            @Override
            public void onSuccess(String startTime, int spanMinutes) {
                TranslatedQuietHour quiet = new TranslatedQuietHour(startTime, spanMinutes);
                callModuleSuccess(context, quiet);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void getDiscussion(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String discussionId = args.optString(0);

        if (TextUtils.isEmpty(discussionId)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        mRongClient.getDiscussion(discussionId, new RongIMClient.ResultCallback<Discussion>() {
            @Override
            public void onSuccess(Discussion discussion) {
                TranslatedDiscussion td = null;
                if (discussion == null) {
                    callModuleSuccess(context, "");
                } else {
                    td = new TranslatedDiscussion(discussion);
                    callModuleSuccess(context, td);
                }
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }


    public void setDiscussionName(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String discussionId = args.optString(0);
        String name = args.optString(1);

        if (TextUtils.isEmpty(discussionId) || TextUtils.isEmpty(name)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        mRongClient.setDiscussionName(discussionId, name, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callModuleSuccess(context, null);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }


    public void addMemberToDiscussion(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String discussionId = args.optString(0);
        JSONArray jsonArray = args.optJSONArray(1);

        if (TextUtils.isEmpty(discussionId) || jsonArray == null || jsonArray.length() == 0) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        List<String> ids = new ArrayList<String>(jsonArray.length());
        int i = 0;
        while (i < jsonArray.length()) {
            ids.add(jsonArray.optString(i));
            i++;
        }

        mRongClient.addMemberToDiscussion(discussionId, ids, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callModuleSuccess(context, null);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }


    public void removeMemberFromDiscussion(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String discussionId = args.optString(0);
        String userId = args.optString(1);

        if (TextUtils.isEmpty(discussionId) || TextUtils.isEmpty(userId)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        mRongClient.removeMemberFromDiscussion(discussionId, userId, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callModuleSuccess(context, null);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }


    public void quitDiscussion(final JSONArray args, final CallbackContext context) {
        if (!mInitialized) {
            callModuleError(context, new RongException(ErrorCode.NOT_INIT));
            return;
        }
        if (mRongClient == null) {
            callModuleError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        String discussionId = args.optString(0);
        if (TextUtils.isEmpty(discussionId)) {
            callModuleError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        mRongClient.quitDiscussion(discussionId, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callModuleSuccess(context, null);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callModuleError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public static class ConnectResultModel {
        String userId;

        public ConnectResultModel(String userId) {
            this.userId = userId;
        }

        public String getUserId() {
            return userId;
        }

        public void setUserId(String userId) {
            this.userId = userId;
        }
    }

    private class DiscussionModel {
        String discussionId;
        DiscussionModel(String discussionId) {
            this.discussionId = discussionId;
        }
    }

    public static class ProgressModel {
        TranslatedMessage message;
        Integer progress;

        public ProgressModel(int msgId, int progress) {
            message = new TranslatedMessage();
            message.setMessageId(msgId);
            this.progress = progress;
        }

        public ProgressModel(int msgId) {
            message = new TranslatedMessage();
            message.setMessageId(msgId);
        }

        public ProgressModel(TranslatedMessage message) {
            this.message = message;
        }

        public ProgressModel(TranslatedMessage message, int progress) {
            this.message = message;
            this.progress = progress;
        }

        public TranslatedMessage getMessage() {
            return message;
        }

        public void setMessage(TranslatedMessage message) {
            this.message = message;
        }

        public int getProgress() {
            return progress;
        }

        public void setProgress(int progress) {
            this.progress = progress;
        }
    }


    public static class ReceiveMessageModel {
        int left;
        ITranslatedMessage message;

        public ReceiveMessageModel(int left, ITranslatedMessage message) {
            this.left = left;
            this.message = message;
        }

        public ReceiveMessageModel(ITranslatedMessage message) {
            this.message = message;
        }

        public ITranslatedMessage getMessage() {
            return message;
        }

        public void setMessage(ITranslatedMessage message) {
            this.message = message;
        }
    }

    private final <T> JSONObject getJsonObjectResult(T result) {
        String json = mGson.toJson(result);
        JSONObject object = null;
        try {
            object = new JSONObject(json);
        } catch (JSONException ex) {
            ex.printStackTrace();
        }
        return object;
    }

    private <T> void callModuleSuccess(CallbackContext context, T model) {
        RongResult<T> result = new RongResult<T>();
        result.setStatus(RongResult.Status.success);
        result.setResult(model);
        JSONObject jsonData = getJsonObjectResult(result);
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, jsonData);
        context.sendPluginResult(pluginResult);
    }

    private <T> void callModuleSuccessWithoutStatus(CallbackContext context, T model, boolean keep) {
        RongResult<T> result = new RongResult<T>();
        result.setResult(model);
        JSONObject jsonData = getJsonObjectResult(result);
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, jsonData);
        pluginResult.setKeepCallback(keep);
        context.sendPluginResult(pluginResult);
    }

    private <T> void callModuleSuccess(CallbackContext context) {
        RongResult<T> result = new RongResult<T>();
        result.setStatus(RongResult.Status.success);
        JSONObject jsonData = getJsonObjectResult(result);
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, jsonData);
        pluginResult.setKeepCallback(false);
        context.sendPluginResult(pluginResult);
    }

    private final <T> void callModuleProgress(CallbackContext context, T model) {
        final RongResult<T> result = new RongResult<T>();
        result.setStatus(RongResult.Status.progress);
        result.setResult(model);
        JSONObject jsonData = getJsonObjectResult(result);
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, jsonData);
        pluginResult.setKeepCallback(true);
        context.sendPluginResult(pluginResult);
    }

    private final <T> void callModulePrepare(CallbackContext context, T model) {
        final RongResult<T> result = new RongResult<T>();
        result.setStatus(RongResult.Status.prepare);
        result.setResult(model);
        JSONObject jsonData = getJsonObjectResult(result);
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, jsonData);
        pluginResult.setKeepCallback(true);
        context.sendPluginResult(pluginResult);
    }

    private void callModuleError(CallbackContext context, RongException e) {
        final RongResult result = new RongResult();
        result.setStatus(RongResult.Status.error);
        result.setResult(e);
        JSONObject jsonData = getJsonObjectResult(result);
        PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, jsonData);
        context.sendPluginResult(pluginResult);
    }

    private <T> void callModuleError(CallbackContext context, T modle, RongException e) {
        final RongErrorResult result = new RongErrorResult();
        result.setResult(modle);
        result.setStatus(e.getCode());
        JSONObject jsonData = getJsonObjectResult(result);
        PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, jsonData);
        context.sendPluginResult(pluginResult);
    }

    public class ConnectionStatusResult {
        AdaptConnectionStatus connectionStatus;

        public ConnectionStatusResult(int code) {
            connectionStatus = AdaptConnectionStatus.setValue(code);
        }
    }

    private enum AdaptConnectionStatus {
        NETWORK_UNAVAILABLE(-1, "NETWORK_UNAVAILABLE"),
        CONNECTED(0, "CONNECTED"),
        CONNECTING(1, "CONNECTING"),
        DISCONNECTED(2, "DISCONNECTED"),
        KICKED(3, "KICKED"),
        TOKEN_INCORRECT(4, "TOKEN_INCORRECT"),
        SERVER_INVALID(5, "SERVER_INVALID");

        Integer code;
        String msg;
        AdaptConnectionStatus(int code, String msg) {
            this.code = code;
            this.msg = msg;
        }

        static AdaptConnectionStatus setValue(int code) {
            for (AdaptConnectionStatus c : AdaptConnectionStatus.values()) {
                if (code == c.code) {
                    return c;
                }
            }
            return NETWORK_UNAVAILABLE;
        }
    }

    /**
     * 本地化通知免打扰时间。
     *
     * @param startTime   默认  “-1”
     * @param spanMinutes 默认 -1
     */
    public static void saveNotificationQuietHours(Context mContext, String startTime, int spanMinutes) {

        SharedPreferences mPreferences = null;

        if (mContext != null)
            mPreferences = mContext.getSharedPreferences("RONG_SDK", Context.MODE_PRIVATE);

        if (mPreferences != null) {
            SharedPreferences.Editor editor = mPreferences.edit();
            editor.putString("QUIET_HOURS_START_TIME", startTime);
            editor.putInt("QUIET_HOURS_SPAN_MINUTES", spanMinutes);
            editor.commit();
        }
    }

    /**
     * 获取通知免打扰开始时间
     *
     * @return
     */
    public static String getNotificationQuietHoursForStartTime(Context mContext) {
        SharedPreferences mPreferences = null;

        if (mPreferences == null && mContext != null)
            mPreferences = mContext.getSharedPreferences("RONG_SDK", Context.MODE_PRIVATE);

        if (mPreferences != null) {
            return mPreferences.getString("QUIET_HOURS_START_TIME", "");
        }

        return "";
    }

    /**
     * 获取通知免打扰时间间隔
     *
     * @return
     */
    public static int getNotificationQuietHoursForSpanMinutes(Context mContext) {
        SharedPreferences mPreferences = null;

        if (mPreferences == null && mContext != null)
            mPreferences = mContext.getSharedPreferences("RONG_SDK", Context.MODE_PRIVATE);

        if (mPreferences != null) {
            return mPreferences.getInt("QUIET_HOURS_SPAN_MINUTES", 0);
        }

        return 0;
    }

    private boolean isInQuietTime(Context context) {

        String startTimeStr = getNotificationQuietHoursForStartTime(context);

        int hour = -1;
        int minute = -1;
        int second = -1;

        if (!TextUtils.isEmpty(startTimeStr) && startTimeStr.indexOf(":") != -1) {
            String[] time = startTimeStr.split(":");

            try {
                if (time.length >= 3) {
                    hour = Integer.parseInt(time[0]);
                    minute = Integer.parseInt(time[1]);
                    second = Integer.parseInt(time[2]);
                }
            } catch (NumberFormatException e) {
            }
        }

        if (hour == -1 || minute == -1 || second == -1) {
            return false;
        }

        Calendar startCalendar = Calendar.getInstance();
        startCalendar.set(Calendar.HOUR_OF_DAY, hour);
        startCalendar.set(Calendar.MINUTE, minute);
        startCalendar.set(Calendar.SECOND, second);


        long spanTime = getNotificationQuietHoursForSpanMinutes(context) * 60;
        long startTime = startCalendar.getTimeInMillis() / 1000;

        Calendar endCalendar = Calendar.getInstance();
        endCalendar.setTimeInMillis(startTime * 1000 + spanTime * 1000);

        Calendar currentCalendar = Calendar.getInstance();

        if (currentCalendar.after(startCalendar) && currentCalendar.before(endCalendar)) {
            return true;
        } else {
            return false;
        }
    }
}
