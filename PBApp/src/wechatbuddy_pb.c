#include <pebble.h>
#include "iosdownload.h"

#define PERSIST_KEY_ARRAY_BEGIN 10
#define PERSIST_KEY_SIZE 80

static Window *window;
static TextLayer *text_layer;
static GBitmap *bitmap;
static BitmapLayer *bitmap_layer;
static GRect bounds;
static size_t persistDataSize;

static void presentQRCodeWithData(uint8_t *data) {
  GSize gsize = GSize(116, 116);
  bitmap = gbitmap_create_blank(gsize, GBitmapFormat1Bit);
  free(gbitmap_get_data(bitmap));
  gbitmap_set_data(bitmap, data, GBitmapFormat1Bit, (persistDataSize / 116), true);
  bitmap_layer_set_bitmap(bitmap_layer, bitmap);
}

static void savePersistData() {
  persist_write_int(PERSIST_KEY_SIZE, persistDataSize);
  // make packages
  uint8_t byte_array[256];
  unsigned int offset = 0;
  for (unsigned int byte = 0; byte < persistDataSize; byte += 256) {
    size_t length = 256 < persistDataSize - byte ? 256 : persistDataSize - byte;
    memcpy(byte_array, gbitmap_get_data(bitmap) + byte, length);
    persist_write_data(PERSIST_KEY_ARRAY_BEGIN + offset, byte_array, length);
    offset++;
  }
  printf("persist data saved in %d arrays", offset);
}

static uint8_t* loadPersistData() {
  // merge packages
  uint8_t byte_array[256];
  unsigned int offset = 0;
  uint8_t *tmp = malloc(persistDataSize);

  for (unsigned int byte = 0; byte < persistDataSize; byte += 256) {
    size_t length = 256 < persistDataSize - byte ? 256 : persistDataSize - byte;
    persist_read_data(PERSIST_KEY_ARRAY_BEGIN + offset, byte_array, length);
    memcpy(tmp + byte, byte_array, length);
    offset++;
  }
  return tmp;
}

static void window_load(Window *window) {
  Layer *window_layer = window_get_root_layer(window);
  bounds = layer_get_bounds(window_layer);

  // Bitmap layer
  bitmap_layer = bitmap_layer_create(bounds);
  layer_add_child(window_layer, bitmap_layer_get_layer(bitmap_layer));

  if (persist_exists(PERSIST_KEY_SIZE)) {
    persistDataSize = persist_read_int(PERSIST_KEY_SIZE);
    uint8_t *data = loadPersistData();
    presentQRCodeWithData(data);
  }
  else {
    // Text layer
    text_layer = text_layer_create((GRect) { .origin = { 0, 72 }, .size = { bounds.size.w, 40 } });
    text_layer_set_text(text_layer, "Please use the iOS app to transfer your QR code");
    text_layer_set_text_alignment(text_layer, GTextAlignmentCenter);
    layer_add_child(window_layer, text_layer_get_layer(text_layer));

    persistDataSize = 0;
    bitmap = NULL;
  }
}

static void window_unload(Window *window) {
  text_layer_destroy(text_layer);
  gbitmap_destroy(bitmap);
  bitmap_layer_destroy(bitmap_layer);
}

void download_complete_handler(iOSDownload *download) {
  printf("Loaded QR code with %lu bytes", download->length);
  printf("Heap free is %u bytes", heap_bytes_free());

  if (bitmap != NULL) {
    printf("destroy bitmap");
    gbitmap_destroy(bitmap);
  }
  persistDataSize = download->length;
  presentQRCodeWithData(download->data);
  savePersistData();
  
  download->data = NULL;
  iOSdownload_destroy(download);
}

static void init(void) {
  // Need to initialize this first to make sure it is there when
  // the window_load function is called by window_stack_push.
  iOSdownload_initialize(download_complete_handler);

  window = window_create();
  window_set_window_handlers(window, (WindowHandlers) {
    .load = window_load,
    .unload = window_unload,
  });
  const bool animated = true;
  window_stack_push(window, animated);
}

static void deinit(void) {
  iOSdownload_deinitialize();
  window_destroy(window);
}

int main(void) {
  init();

  APP_LOG(APP_LOG_LEVEL_DEBUG, "Done initializing, pushed window: %p", window);

  app_event_loop();
  deinit();
}
