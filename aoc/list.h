/*
 * general purpose doubly linked list
 */
#ifndef LIST_H
#define LIST_H

#include <stdlib.h>
#include <string.h>

// list is a chain of nodes
typedef struct List List;
typedef struct Node Node;

struct List {
    const size_t data_size; // size of data pointed to by node
    size_t len; // length of list
    Node *first; // first node of list
    Node *last; // last node of list
};

struct Node {
    void *data; // pointer to node data
    Node *next; // pointer to next node
    Node *prev; // pointer to previous node
};

// allocate list
List *list_alloc(size_t data_size);

// allocate copy of other,
// use data_copy to copy data from other item, if 0 do not copy data,
List *list_copy(const List *other, void *(*data_copy)(void *, const void *, size_t));

// free list,
// use data_free to free data in node, use 0 to not free data,
void list_free(List **list, void (*data_free)(void *));

// insert data into list at specified location,
// return 0 for success,
// return 1 for failure
int list_insert(List *list, size_t i, void *data);
int list_insert_first(List *list, void *data);
int list_insert_last(List *list, void *data);

// remove node from list at specified location,
// return data pointer,
// return 0 if i out of range
void *list_remove(List *list, size_t i);
void *list_remove_first(List *list);
void *list_remove_last(List *list);

// return node at specified location,
// return 0 if i out of range
Node *list_get(const List *list, size_t i);

// search for first occurrence of data in list,
// return matching node if found,
// return 0 if not found,
Node *list_find(const List *list, const void *data, int (*data_cmp)(const void *, const void *));

// delete specified node,
// return data pointer
void *list_delete(List *list, Node *node);

// search for first occurrence of data in list,
// return index of matching node if found,
// return list->len (out of range) if not found,
size_t list_index(const List *list, void *data, int (*data_cmp)(const void *, const void *));

// sort list in place,
void list_sort(List *list, int (*data_cmp)(const void *, const void *));

// traverse nodes of list and apply func to data,
// return 1 as soon as func returns 1,
// return 0 if func always returned 0,
int list_traverse(const List *list, int (*func)(void *));

#endif
