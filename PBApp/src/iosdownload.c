// Based on Netdownload (https://github.com/pebble-examples/pebble-faces/blob/master/src/netdownload.c)
//
//  iosdownload.c
//  WeChatBuddy
//
//  Created by Tyler Weimin Ouyang on 8/1/15.
//  Copyright (c) 2015 Tyler. All rights reserved.
//

#include "iosdownload.h"

iOSDownloadContext* iOSdownload_create_context(iOSDownloadCallback callback) {
  iOSDownloadContext *ctx = malloc(sizeof(iOSDownloadContext));

  ctx->length = 0;
  ctx->index = 0;
  ctx->data = NULL;
  ctx->callback = callback;

  return ctx;
}

void iOSdownload_destroy_context(iOSDownloadContext *ctx) {
  if (ctx->data) {
    free(ctx->data);
  }
  free(ctx);
}

void iOSdownload_initialize(iOSDownloadCallback callback) {
  iOSDownloadContext *ctx = iOSdownload_create_context(callback);
  APP_LOG(APP_LOG_LEVEL_DEBUG, "iOSDownloadContext = %p", ctx);
  app_message_set_context(ctx);

  app_message_register_inbox_received(iOSdownload_receive);
  app_message_register_inbox_dropped(iOSdownload_dropped);
  app_message_register_outbox_sent(iOSdownload_out_success);
  app_message_register_outbox_failed(iOSdownload_out_failed);
  APP_LOG(APP_LOG_LEVEL_DEBUG, "Max buffer sizes are %li / %li", app_message_inbox_size_maximum(), app_message_outbox_size_maximum());
  app_message_open(app_message_inbox_size_maximum(), app_message_outbox_size_maximum());
}

void iOSdownload_deinitialize() {
  iOSdownload_destroy_context(app_message_get_context());
  app_message_set_context(NULL);
}

void iOSdownload_request(char *url) {
  DictionaryIterator *outbox;
  app_message_outbox_begin(&outbox);
  // Tell the javascript how big we want each chunk of data: max possible size - dictionary overhead with one Tuple in it.
  uint32_t chunk_size = app_message_inbox_size_maximum() - dict_calc_buffer_size(1);
  dict_write_int(outbox, IOSDL_CHUNK_SIZE, &chunk_size, sizeof(uint32_t), false);
  // Send the URL
  dict_write_cstring(outbox, IOSDL_URL, url);

  app_message_outbox_send();
}

void iOSdownload_destroy(iOSDownload *image) {
  // We malloc'd that memory before creating the GBitmap
  // We are responsible for freeing it.
  if (image) {
    free(image->data);
    free(image);
  }
}

void iOSdownload_receive(DictionaryIterator *iter, void *context) {
  iOSDownloadContext *ctx = (iOSDownloadContext*) context;

  Tuple *tuple = dict_read_first(iter);
  if (!tuple) {
    APP_LOG(APP_LOG_LEVEL_ERROR, "Got a message with no first key! Size of message: %li", (uint32_t)iter->end - (uint32_t)iter->dictionary);
    return;
  }
  switch (tuple->key) {
    case IOSDL_DATA:
      if (ctx->index + tuple->length <= ctx->length) {
        memcpy(ctx->data + ctx->index, tuple->value->data, tuple->length);
        ctx->index += tuple->length;
        APP_LOG(APP_LOG_LEVEL_DEBUG, "Received Bufsize=%li BufIndex=%li DataLen=%i",
          ctx->length, ctx->index, tuple->length);
      }
      else {
        APP_LOG(APP_LOG_LEVEL_WARNING, "Not overriding rx buffer. Bufsize=%li BufIndex=%li DataLen=%i",
          ctx->length, ctx->index, tuple->length);
      }
      break;
    case IOSDL_BEGIN:
      APP_LOG(APP_LOG_LEVEL_DEBUG, "Start transmission. Size=%lu", tuple->value->uint32);
      if (ctx->data != NULL) {
        free(ctx->data);
      }
      ctx->data = malloc(tuple->value->uint32);
      if (ctx->data != NULL) {
        ctx->length = tuple->value->uint32;
        ctx->index = 0;
      }
      else {
        APP_LOG(APP_LOG_LEVEL_WARNING, "Unable to allocate memory to receive image.");
        ctx->length = 0;
        ctx->index = 0;
      }
      break;
    case IOSDL_END:
      if (ctx->data && ctx->length > 0 && ctx->index > 0) {
        iOSDownload *image = malloc(sizeof(iOSDownload));
        image->data = ctx->data;
        image->length = ctx->length;

        printf("Received file of size=%lu and address=%p", ctx->length, ctx->data);
        ctx->callback(image);

        // We have transfered ownership of this memory to the app. Make sure we dont free it.
        // (see iOSdownload_destroy for cleanup)
        ctx->data = NULL;
        ctx->index = ctx->length = 0;
      }
      else {
        APP_LOG(APP_LOG_LEVEL_DEBUG, "Got End message but we have no image...");
      }
      break;
    default:
      APP_LOG(APP_LOG_LEVEL_WARNING, "Unknown key in dict: %lu", tuple->key);
      break;
  }
}

char *translate_error(AppMessageResult result) {
  switch (result) {
    case APP_MSG_OK: return "APP_MSG_OK";
    case APP_MSG_SEND_TIMEOUT: return "APP_MSG_SEND_TIMEOUT";
    case APP_MSG_SEND_REJECTED: return "APP_MSG_SEND_REJECTED";
    case APP_MSG_NOT_CONNECTED: return "APP_MSG_NOT_CONNECTED";
    case APP_MSG_APP_NOT_RUNNING: return "APP_MSG_APP_NOT_RUNNING";
    case APP_MSG_INVALID_ARGS: return "APP_MSG_INVALID_ARGS";
    case APP_MSG_BUSY: return "APP_MSG_BUSY";
    case APP_MSG_BUFFER_OVERFLOW: return "APP_MSG_BUFFER_OVERFLOW";
    case APP_MSG_ALREADY_RELEASED: return "APP_MSG_ALREADY_RELEASED";
    case APP_MSG_CALLBACK_ALREADY_REGISTERED: return "APP_MSG_CALLBACK_ALREADY_REGISTERED";
    case APP_MSG_CALLBACK_NOT_REGISTERED: return "APP_MSG_CALLBACK_NOT_REGISTERED";
    case APP_MSG_OUT_OF_MEMORY: return "APP_MSG_OUT_OF_MEMORY";
    case APP_MSG_CLOSED: return "APP_MSG_CLOSED";
    case APP_MSG_INTERNAL_ERROR: return "APP_MSG_INTERNAL_ERROR";
    default: return "UNKNOWN ERROR";
  }
}

void iOSdownload_dropped(AppMessageResult reason, void *context) {
  APP_LOG(APP_LOG_LEVEL_ERROR, "Dropped message! Reason given: %s", translate_error(reason));
}

void iOSdownload_out_success(DictionaryIterator *iter, void *context) {
  APP_LOG(APP_LOG_LEVEL_DEBUG, "Message sent.");
}

void iOSdownload_out_failed(DictionaryIterator *iter, AppMessageResult reason, void *context) {
  APP_LOG(APP_LOG_LEVEL_DEBUG, "Failed to send message. Reason = %s", translate_error(reason));
}
