#include <pebble.h>

/* The key used to transmit download data. Contains byte array. */
#define IOSDL_DATA 100
/* The key used to start a new image transmission. Contains uint32 size */
#define IOSDL_BEGIN IOSDL_DATA + 1
/* The key used to finalize an image transmission. Data not defined. */
#define IOSDL_END IOSDL_DATA + 2

/* The key used to tell the JS how big chunks should be */
#define IOSDL_CHUNK_SIZE IOSDL_DATA + 3
/* The key used to request a PBI */
#define IOSDL_URL IOSDL_DATA + 4

typedef struct {
  /* We keep a pointer to the data so we can free it later. */
  uint8_t*  data;
  /* Length of data */
  uint32_t length;
} iOSDownload;

typedef void (*iOSDownloadCallback)(iOSDownload *image);

typedef struct {
  /* size of the data buffer allocated */
  uint32_t length;
  /* buffer of data that will contain the actual data */
  uint8_t *data;
  /* Next byte to write */
  uint32_t index;
  /* Callback to call when we are done loading the data */
  iOSDownloadCallback callback;
} iOSDownloadContext;

iOSDownloadContext* iOSdownload_create_context(iOSDownloadCallback callback);

void iOSdownload_initialize(iOSDownloadCallback callback);
void iOSdownload_deinitialize();

void iOSdownload_request(char *url);

// Call this when you are done using an image to properly free memory.
void iOSdownload_destroy(iOSDownload *image);

void iOSdownload_receive(DictionaryIterator *iter, void *context);
void iOSdownload_dropped(AppMessageResult reason, void *context);
void iOSdownload_out_success(DictionaryIterator *iter, void *context);
void iOSdownload_out_failed(DictionaryIterator *iter, AppMessageResult reason, void *context);
