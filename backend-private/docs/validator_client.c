#include <stdio.h>
#include <string.h>
#include <curl/curl.h>

static size_t write_cb(void *contents, size_t size, size_t nmemb, void *userp) {
    size_t total = size * nmemb;
    strncat((char *)userp, (char *)contents, total);
    return total;
}

int post_qr(const char *base_url, const char *api_key, const char *qr) {
    CURL *curl = curl_easy_init();
    if (!curl) {
        return -1;
    }

    char url[256];
    snprintf(url, sizeof(url), "%s/api/validators/validate-qr", base_url);

    char body[1024];
    snprintf(body, sizeof(body), "{\"qr\":\"%s\"}", qr);

    char response[4096] = {0};

    struct curl_slist *headers = NULL;
    headers = curl_slist_append(headers, "Content-Type: application/json");
    char api_header[256];
    snprintf(api_header, sizeof(api_header), "x-api-key: %s", api_key);
    headers = curl_slist_append(headers, api_header);

    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, body);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_cb);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, response);

    CURLcode res = curl_easy_perform(curl);
    long status = 0;
    curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &status);

    curl_slist_free_all(headers);
    curl_easy_cleanup(curl);

    if (res != CURLE_OK) {
        printf("curl error: %s\n", curl_easy_strerror(res));
        return -1;
    }

    printf("status: %ld\n", status);
    printf("response: %s\n", response);
    return 0;
}

int main(int argc, char **argv) {
    if (argc < 4) {
        printf("Usage: validator_client <base_url> <api_key> <qr_string>\n");
        return 1;
    }
    return post_qr(argv[1], argv[2], argv[3]);
}
