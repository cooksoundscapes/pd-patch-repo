#include <unistd.h>
#include <time.h>
#include "lua.h"
#include "lauxlib.h"

int pdlib_gettime(lua_State* l) {
  struct timespec t;
  clock_gettime(CLOCK_MONOTONIC, &t);
  int secs_in_millis = t.tv_sec * 1000;
  int nanos_in_millis = t.tv_nsec / 1000000;
  lua_pushnumber(l, secs_in_millis + nanos_in_millis);
  return 1;
}

int pdlib_sleep (lua_State *L) {
  int msec = (int) luaL_checknumber(L, -1);
  lua_pop (L, 1);
  usleep (msec * 1000);
  return 0;
}

int luaopen_pdlib(lua_State* l) {
  lua_newtable(l);
  lua_pushcfunction(l, pdlib_gettime);
  lua_setfield(l, -2, "gettime");
  lua_pushcfunction(l, pdlib_sleep);
  lua_setfield(l, -2, "sleep");
  return 1;
}