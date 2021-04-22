unit esp_idf_version;

interface

const
  ESP_IDF_VERSION_MAJOR = 3;
  ESP_IDF_VERSION_MINOR = 3;
  ESP_IDF_VERSION_PATCH = 0;

function esp_get_idf_version: PChar; external;

implementation

end.
