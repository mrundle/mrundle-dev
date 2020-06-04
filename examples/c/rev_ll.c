/*
 * Reverse a linked list
 */

#include <stdio.h>

struct node {
    int val;
    struct node *next;
};

void print_list(struct node *node) {
    while (node != NULL) {
        printf("%d ", node->val);
        node = node->next;
    }
    printf("\n");
}

struct node *reverse_list(struct node *node) {
    if (node == NULL) return NULL;
    struct node *prv = NULL;
    struct node *cur = node;

    while (cur != NULL) {
        struct node *nxt = cur->next;
        cur->next = prv;
        prv = cur;
        cur = nxt;
    }
    return prv;
}

int main(void) {
    struct node d = { 4, NULL };
    struct node c = { 3, &d   };
    struct node b = { 2, &c   };
    struct node a = { 1, &b   };

    print_list(&a);
    print_list(reverse_list(&a));

    return 0;
}
