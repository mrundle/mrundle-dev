#include <lua5.1/lauxlib.h>
#include <lua5.1/lua.h>
#include <lua5.1/lualib.h>

static int
square(lua_State *L) {
    float ret = lua_tonumber(L, -1);
    printf("Top of square(), number=%f\n", ret);
    lua_pushnumber(L, ret*ret);
    return 1;
}

/*
 * luaopen_* NEEDS to match the name of the
 * .so and the thing that you "require" in
 * the calling lua script
 */
int luaopen_power(lua_State *L) {
    lua_register(L, "square", square);
    return 0;
}
