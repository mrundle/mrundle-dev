#include <errno.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

#define PROMPT_CHAR "~"
#define MRSH_RL_BUFSZ 1024
#define MRSH_TOK_BUFSZ 2

// TODO use mrlibc

#define elementsof(arr) (sizeof(arr) / sizeof(arr[0]))

#define error(args...) do { \
    fprintf(stderr, "mrsh: ");  \
    fprintf(stderr, args);  \
    fprintf(stderr, "\n");  \
    exit(EXIT_FAILURE);     \
} while (0)

#define fatal(args...) do { \
    error(args);            \
    exit(EXIT_FAILURE);     \
} while (0)

struct _builtin {
    void (*function)(char **args);
    const char *const name;
    const char *const description;
};

#define DECLARE_BUILTIN(name) static void name(char **args);
DECLARE_BUILTIN(mrsh_help);
DECLARE_BUILTIN(mrsh_exit);
DECLARE_BUILTIN(mrsh_cd);

struct _builtin _builtins[] = {
    { mrsh_help, "help", "Display this message" },
    { mrsh_exit, "exit", "Exit the shell" },
    { mrsh_cd,   "cd"  , "Change your working directory, e.g. `cd /tmp`"},
};

static void
mrsh_help(char **args)
{
    printf("Matt Rundle's Shell. The following are built-ins: \n");
    for (unsigned i = 0; i < elementsof(_builtins); i++) {
        printf("    %s - %s\n", _builtins[i].name, _builtins[i].description);
    }
}

static void
mrsh_exit(char **args)
{
    exit(EXIT_SUCCESS);
}

static void
mrsh_cd(char **args)
{
    if (args[1] == NULL) {
        error("mrsh: expected arg to 'cd'\n");
        return;
    }
    if (chdir(args[1]) != 0) {
        error("mrsh: chdir(): %s", strerror(errno));
    }
}

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
    pid_t pid, wpid;
    int status;

    pid = fork();
    if (pid == 0) {
        // child
        if (execvp(*args, args) == -1) {
            error("couldn't execute %s: %s",
                  *args, strerror(errno));
        }
    } else if (pid > 0) {
        int status;
        do {
            wpid = waitpid(pid, &status, WUNTRACED); 
        } while (!WIFEXITED(status) && !WIFSIGNALED(status));
    } else {
        fatal("fork(): %s", strerror(errno));
    }
}

int
main(int argc, char **argv)
{
    while (1) {
        printf(PROMPT_CHAR " ");
        char *line = mrsh_read_line();
        char **args = mrsh_tok_line(line);
        for (unsigned i = 0; i < elementsof(_builtins); i++) {
            if (strcmp(*args, _builtins[i].name) == 0) {
                _builtins[i].function(args);
                continue;
            }
        }
        mrsh_exec(args);
    }

    return 0;
}
