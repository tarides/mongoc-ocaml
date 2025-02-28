#include <bson/bson.h>
#include <mongoc/mongoc.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    mongoc_client_t *client;
    mongoc_collection_t *collection;
    mongoc_cursor_t *cursor;
    const char *json;
    bson_t *query;
    const bson_t *doc;
    bson_error_t error;

    mongoc_init();

    client = mongoc_client_new("mongodb://127.0.0.1:27017");

    if (!client) {
        fprintf(stderr, "Failed to connect to MongoDB\n");
        return EXIT_FAILURE;
    }

    collection = mongoc_client_get_collection(client, "bitcoin", "price_2017_2023");

    json =  "{ \"timestamp\" : { \"$gt\" : \"2022-07-28 10:00:00\", \"$lte\" : \"2022-07-28 10:10:00\" } }";

    printf("BSON query: %s\n", json);

    query = bson_new_from_json((const uint8_t *) json, -1, &error);

    if (!query) {
        fprintf(stderr, "Error parsing JSON: %s\n", error.message);
        return 1;
    }

    cursor = mongoc_collection_find_with_opts(collection, query, NULL, NULL);

    printf("Bitcoin prices on July 28, 2022, at 10 a.m. during 10 minutes:\n");

    while (mongoc_cursor_next(cursor, &doc)) {
        char *str = bson_as_json(doc, NULL);
        printf("%s\n", str);
        bson_free(str);
    }

    if (mongoc_cursor_error(cursor, &error)) {
        fprintf(stderr, "Cursor Error: %s\n", error.message);
        return EXIT_FAILURE;
    }

    bson_destroy(query);
    mongoc_cursor_destroy(cursor);
    mongoc_collection_destroy(collection);
    mongoc_client_destroy(client);
    mongoc_cleanup();

    return EXIT_SUCCESS;
}
