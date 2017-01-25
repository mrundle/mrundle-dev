// TODO use mrlibc

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#define PROMPT_CHAR "~"
#define MRSH_RL_BUFSZ 1024
#define MRSH_TOK_BUFSZ 2

#define fatal(args...) do { \
    fprintf(stderr, "mrsh: ");  \
    fprintf(stderr, args);  \
    fprintf(stderr, "\n");  \
    exit(EXIT_FAILURE);     \
} while (0)

// todo implement malloc :) http://danluu.com/malloc-tutorial/
static void *
mrsh_malloc(size_t size)
{
    void *ret = malloc(size); 
    if (ret == NULL) fatal("allocation error");
    return ret;
}

static void *
mrsh_realloc(void *ptr, size_t size)
{
    void *ret = realloc(ptr, size); 
    if (ret == NULL) fatal("allocation error");
    return ret;
}

#include <stdbool.h>

bool
mrsh_is_ws(const char *c)
{
    switch (*c) {
            case ' ':
            case '\t':
            case '\n':
            case '\a':
            case '\r':
                return true;
    }
    return false;
}

// split on ws
char **
mrsh_tok_line(char *line)
{
    int buflen = MRSH_TOK_BUFSZ;
    char **tokens = mrsh_malloc(buflen * sizeof(*tokens));
    int pos = 0;

    int len;
    int done = 0;
    for (int i = 0, j = 0; ; j++) {
        if (line[j] == '\0') {
            done = 1;
        } else if (!mrsh_is_ws(&line[j])) {
            continue;
        }
        if (i == j) break;

        // add to token buf
        len = j - i;
        char *tok = mrsh_malloc(len + 1);
        memcpy(tok, &line[i], len);
        tok[len] = '\0';
        tokens[pos++] = tok;

        if (pos >= buflen) {
            buflen *= 2;
            tokens = mrsh_realloc(tokens, buflen * sizeof(*tokens));
        }

        if (done) break;

        while (line[j] != '\0' &&
               mrsh_is_ws(&line[j])) {
            j++;
        }
        i = j;
    }

    tokens[pos] = NULL;
    return tokens;
}

char *
mrsh_read_line(void)
{
    int buflen = MRSH_RL_BUFSZ;
    char *buf = mrsh_malloc(buflen);

    for (int c, pos = 0; ; pos++) {
        if ((c = getchar()) == EOF || c == '\n') {
            buf[pos] = '\0';
            return buf;
        } else {
            buf[pos] = c;
        }

        if (pos + 1 >= buflen) {
            buflen += MRSH_RL_BUFSZ;
            buf = mrsh_realloc(buf, buflen);
        }
    }
}

static void
mrsh_exec(char **args)
{
    while (*args != NULL) {
        printf("arg: %s\n", *args);
        args++;
    }
}

int
main(int argc, char **argv)
{
    int status;

    while (1) {
        printf(PROMPT_CHAR " ");
        char *line = mrsh_read_line();
        char **args = mrsh_tok_line(line);
        if (strcmp(line, "exit") == 0) {
            exit(EXIT_SUCCESS);
        } else if (strcmp(line, "quit") == 0) {
            exit(EXIT_SUCCESS);
        }
        mrsh_exec(args);
        printf("got %s\n", line);
    }

    return 0;
}
